Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D11F6B0089
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 11:37:30 -0500 (EST)
Received: by pxi5 with SMTP id 5so738443pxi.12
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 08:37:28 -0800 (PST)
Subject: Re: [PATCH -mm] change anon_vma linking to fix multi-process
 server scalability issue
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100128002000.2bf5e365@annuminas.surriel.com>
References: <20100128002000.2bf5e365@annuminas.surriel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 29 Jan 2010 01:37:21 +0900
Message-ID: <1264696641.17063.32.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, lwoodman@redhat.com, akpm@linux-foundation.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi, Rik.

Thanks for good effort. 

On Thu, 2010-01-28 at 00:20 -0500, Rik van Riel wrote:
> The old anon_vma code can lead to scalability issues with heavily
> forking workloads.  Specifically, each anon_vma will be shared
> between the parent process and all its child processes.
> 
> In a workload with 1000 child processes and a VMA with 1000 anonymous
> pages per process that get COWed, this leads to a system with a million
> anonymous pages in the same anon_vma, each of which is mapped in just
> one of the 1000 processes.  However, the current rmap code needs to
> walk them all, leading to O(N) scanning complexity for each page.
> 
> This can result in systems where one CPU is walking the page tables
> of 1000 processes in page_referenced_one, while all other CPUs are
> stuck on the anon_vma lock.  This leads to catastrophic failure for
> a benchmark like AIM7, where the total number of processes can reach
> in the tens of thousands.  Real workloads are still a factor 10 less
> process intensive than AIM7, but they are catching up.
> 
> This patch changes the way anon_vmas and VMAs are linked, which
> allows us to associate multiple anon_vmas with a VMA.  At fork
> time, each child process gets its own anon_vmas, in which its
> COWed pages will be instantiated.  The parents' anon_vma is also
> linked to the VMA, because non-COWed pages could be present in
> any of the children.

any of the children? 

IMHO, "parent" is right. :)
Do I miss something? Could you elaborate it?

> 
> This reduces rmap scanning complexity to O(1) for the pages of
> the 1000 child processes, with O(N) complexity for at most 1/N
> pages in the system.  This reduces the average scanning cost in
> heavily forking workloads from O(N) to 2.
> 
> The only real complexity in this patch stems from the fact that
> linking a VMA to anon_vmas now involves memory allocations. This
> means vma_adjust can fail, if it needs to attach a VMA to anon_vma
> structures. This in turn means error handling needs to be added
> to the calling functions.
> 
> A second source of complexity is that, because there can be
> multiple anon_vmas, the anon_vma linking in vma_adjust can
> no longer be done under "the" anon_vma lock.  To prevent the
> rmap code from walking up an incomplete VMA, this patch
> introduces the VM_LOCK_RMAP VMA flag.  This bit flag uses
> the same slot as the NOMMU VM_MAPPED_COPY, with an ifdef
> in mm.h to make sure it is impossible to compile a kernel
> that needs both symbolic values for the same bitflag.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> 

<snip>

> -void vma_adjust(struct vm_area_struct *vma, unsigned long start,
> +int vma_adjust(struct vm_area_struct *vma, unsigned long start,
>  	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> @@ -542,6 +541,29 @@ again:			remove_next = 1 + (end > next->vm_end);
>  		}
>  	}
>  
> +	/*
> +	 * When changing only vma->vm_end, we don't really need
> +	 * anon_vma lock.
> +	 */
> +	if (vma->anon_vma && (insert || importer || start != vma->vm_start))
> +		anon_vma = vma->anon_vma;
> +	if (anon_vma) {
> +		/*
> +		 * Easily overlooked: when mprotect shifts the boundary,
> +		 * make sure the expanding vma has anon_vma set if the
> +		 * shrinking vma had, to cover any anon pages imported.
> +		 */
> +		if (importer && !importer->anon_vma) {
> +			/* Block reverse map lookups until things are set up. */
> +			importer->vm_flags |= VM_LOCK_RMAP;
> +			if (anon_vma_clone(importer, vma)) {
> +				importer->vm_flags &= ~VM_LOCK_RMAP;
> +				return -ENOMEM;

If we fail in here during progressing on next vmas in case of mprotect case 6, 
the previous vmas would become inconsistent state. 
How about reserve anon_vma_chains 
with the worst case number of mergable vmas spanned [start,end]?

> +			}
> +			importer->anon_vma = anon_vma;
> +		}
> +	}
> +

<snip>

> @@ -2241,10 +2286,11 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  		if (new_vma) {
>  			*new_vma = *vma;
>  			pol = mpol_dup(vma_policy(vma));
> -			if (IS_ERR(pol)) {
> -				kmem_cache_free(vm_area_cachep, new_vma);
> -				return NULL;
> -			}
> +			if (IS_ERR(pol))
> +				goto out_free_vma;
> +			INIT_LIST_HEAD(&new_vma->anon_vma_chain);

You arrested the culprit. 
My eyes is bad. :)

> +			if (anon_vma_clone(new_vma, vma))
> +				goto out_free_mempol;
>  			vma_set_policy(new_vma, pol);
>  			new_vma->vm_start = addr;
>  			new_vma->vm_end = addr + len;
> @@ -2260,6 +2306,12 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
>  		}
>  	}
>  	return new_vma;
> +
> + out_free_mempol:
> +	mpol_put(pol);
> + out_free_vma:
> +	kmem_cache_free(vm_area_cachep, new_vma);
> +	return NULL;
>  }


As I said previously, I have a concern about memory footprint. 
It adds anon_vma_chain and increases anon_vma's size for KSM.

I think it will increase 3 times more than only anon_vma.

Although you think it's not big in normal machine, 
it's not good in embedded system which is no anon_vma scalability issue
and even no-swap. so I wanted you to make it configurable.

I will measure memory usage when I have a time. :)
Go to sleep. 

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
