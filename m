Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 88DC76B027F
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 23:02:42 -0400 (EDT)
Received: by iofh134 with SMTP id h134so70824855iof.0
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 20:02:42 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id m13si506224igt.101.2015.09.30.20.02.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Sep 2015 20:02:42 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so58740626pab.3
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 20:02:41 -0700 (PDT)
Date: Wed, 30 Sep 2015 20:02:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] mm: add the "struct mm_struct *mm" local into
In-Reply-To: <20150929182800.GA21747@redhat.com>
Message-ID: <alpine.LSU.2.11.1509302001560.4528@eggly.anvils>
References: <20150929182800.GA21747@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 29 Sep 2015, Oleg Nesterov wrote:

> Cosmetic, but expand_upwards() and expand_downwards() overuse
> vma->vm_mm, a local variable makes sense imho.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/mmap.c | 24 +++++++++++++-----------
>  1 file changed, 13 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 4efdc37..7edf9ed 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2148,6 +2148,7 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
>   */
>  int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  {
> +	struct mm_struct *mm = vma->vm_mm;
>  	int error;
>  
>  	if (!(vma->vm_flags & VM_GROWSUP))
> @@ -2197,10 +2198,10 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  				 * So, we reuse mm->page_table_lock to guard
>  				 * against concurrent vma expansions.
>  				 */
> -				spin_lock(&vma->vm_mm->page_table_lock);
> +				spin_lock(&mm->page_table_lock);
>  				if (vma->vm_flags & VM_LOCKED)
> -					vma->vm_mm->locked_vm += grow;
> -				vm_stat_account(vma->vm_mm, vma->vm_flags,
> +					mm->locked_vm += grow;
> +				vm_stat_account(mm, vma->vm_flags,
>  						vma->vm_file, grow);
>  				anon_vma_interval_tree_pre_update_vma(vma);
>  				vma->vm_end = address;
> @@ -2208,8 +2209,8 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  				if (vma->vm_next)
>  					vma_gap_update(vma->vm_next);
>  				else
> -					vma->vm_mm->highest_vm_end = address;
> -				spin_unlock(&vma->vm_mm->page_table_lock);
> +					mm->highest_vm_end = address;
> +				spin_unlock(&mm->page_table_lock);
>  
>  				perf_event_mmap(vma);
>  			}
> @@ -2217,7 +2218,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  	}
>  	vma_unlock_anon_vma(vma);
>  	khugepaged_enter_vma_merge(vma, vma->vm_flags);
> -	validate_mm(vma->vm_mm);
> +	validate_mm(mm);
>  	return error;
>  }
>  #endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */
> @@ -2228,6 +2229,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
>  int expand_downwards(struct vm_area_struct *vma,
>  				   unsigned long address)
>  {
> +	struct mm_struct *mm = vma->vm_mm;
>  	int error;
>  
>  	/*
> @@ -2272,17 +2274,17 @@ int expand_downwards(struct vm_area_struct *vma,
>  				 * So, we reuse mm->page_table_lock to guard
>  				 * against concurrent vma expansions.
>  				 */
> -				spin_lock(&vma->vm_mm->page_table_lock);
> +				spin_lock(&mm->page_table_lock);
>  				if (vma->vm_flags & VM_LOCKED)
> -					vma->vm_mm->locked_vm += grow;
> -				vm_stat_account(vma->vm_mm, vma->vm_flags,
> +					mm->locked_vm += grow;
> +				vm_stat_account(mm, vma->vm_flags,
>  						vma->vm_file, grow);
>  				anon_vma_interval_tree_pre_update_vma(vma);
>  				vma->vm_start = address;
>  				vma->vm_pgoff -= grow;
>  				anon_vma_interval_tree_post_update_vma(vma);
>  				vma_gap_update(vma);
> -				spin_unlock(&vma->vm_mm->page_table_lock);
> +				spin_unlock(&mm->page_table_lock);
>  
>  				perf_event_mmap(vma);
>  			}
> @@ -2290,7 +2292,7 @@ int expand_downwards(struct vm_area_struct *vma,
>  	}
>  	vma_unlock_anon_vma(vma);
>  	khugepaged_enter_vma_merge(vma, vma->vm_flags);
> -	validate_mm(vma->vm_mm);
> +	validate_mm(mm);
>  	return error;
>  }
>  
> -- 
> 2.4.3
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
