Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 949C96B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:20:55 -0400 (EDT)
Date: Thu, 14 Jun 2012 09:20:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -V9 05/15] hugetlb: avoid taking i_mmap_mutex in
 unmap_single_vma() for hugetlb
Message-ID: <20120614072053.GC27397@tiehlicka.suse.cz>
References: <1339583254-895-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1339583254-895-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1339583254-895-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Wed 13-06-12 15:57:24, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> i_mmap_mutex lock was added in unmap_single_vma by 502717f4e ("hugetlb:
> fix linked list corruption in unmap_hugepage_range()") but we don't use
> page->lru in unmap_hugepage_range any more.  Also the lock was taken
> higher up in the stack in some code path.  That would result in deadlock.

This sounds like the deadlock is real but in the other email you wrote
that the deadlock cannot happen so it would be good to mention it here.
 
> unmap_mapping_range (i_mmap_mutex)
>  -> unmap_mapping_range_tree
>     -> unmap_mapping_range_vma
>        -> zap_page_range_single
>          -> unmap_single_vma
> 	      -> unmap_hugepage_range (i_mmap_mutex)
> 
> For shared pagetable support for huge pages, since pagetable pages are ref
> counted we don't need any lock during huge_pmd_unshare.  We do take
> i_mmap_mutex in huge_pmd_share while walking the vma_prio_tree in mapping.
> (39dde65c9940c97f ("shared page table for hugetlb page")).
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  mm/memory.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 545e18a..f6bc04f 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1326,11 +1326,8 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>  			 * Since no pte has actually been setup, it is
>  			 * safe to do nothing in this case.
>  			 */
> -			if (vma->vm_file) {
> -				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +			if (vma->vm_file)
>  				__unmap_hugepage_range(tlb, vma, start, end, NULL);
> -				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> -			}
>  		} else
>  			unmap_page_range(tlb, vma, start, end, details);
>  	}
> -- 
> 1.7.10
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
