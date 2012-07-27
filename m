Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id EE7236B009B
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 07:17:58 -0400 (EDT)
Date: Fri, 27 Jul 2012 13:17:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/2] Revert "hugetlb: avoid taking i_mmap_mutex in
 unmap_single_vma() for hugetlb"
Message-ID: <20120727111754.GE26351@tiehlicka.suse.cz>
References: <1343385965-7738-1-git-send-email-mgorman@suse.de>
 <1343385965-7738-2-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343385965-7738-2-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 27-07-12 11:46:04, Mel Gorman wrote:
> This reverts the patch "hugetlb: avoid taking i_mmap_mutex in
> unmap_single_vma() for hugetlb" from mmotm.
> 
> This patch is possibly a mistake and blocks the merging of a hugetlb fix
> where page tables can get corrupted (https://lkml.org/lkml/2012/7/24/93).
> The motivation of the patch appears to be two-fold.
> 
> First, it believes that the i_mmap_mutex is to protect against list
> corruption of the page->lru lock but that is not quite accurate. The
> i_mmap_mutex for shared page tables is meant to protect against races
> when sharing and unsharing the page tables. For example, an important
> use of i_mmap_mutex is to stabilise the page_count of the PMD page
> during huge_pmd_unshare.
> 
> Second, it is protecting against a potential deadlock when
> unmap_unsingle_page is called from unmap_mapping_range(). However, hugetlbfs
> should never be in this path. It has its own setattr and truncate handlers
> where are the paths that use unmap_mapping_range().
> 
> Unless Aneesh has another reason for the patch, it should be reverted
> to preserve hugetlb page sharing locking.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memory.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 8a989f1..22bc695 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1344,8 +1344,11 @@ static void unmap_single_vma(struct mmu_gather *tlb,
>  			 * Since no pte has actually been setup, it is
>  			 * safe to do nothing in this case.
>  			 */
> -			if (vma->vm_file)
> +			if (vma->vm_file) {
> +				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
>  				__unmap_hugepage_range(tlb, vma, start, end, NULL);
> +				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> +			}
>  		} else
>  			unmap_page_range(tlb, vma, start, end, details);
>  	}
> -- 
> 1.7.9.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
