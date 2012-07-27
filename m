Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id E2C446B0044
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 13:15:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 28 Jul 2012 03:15:13 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RH73MA11862190
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:07:04 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RHFEZ2020294
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:15:15 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] Revert "hugetlb: avoid taking i_mmap_mutex in unmap_single_vma() for hugetlb"
In-Reply-To: <1343385965-7738-2-git-send-email-mgorman@suse.de>
References: <1343385965-7738-1-git-send-email-mgorman@suse.de> <1343385965-7738-2-git-send-email-mgorman@suse.de>
Date: Fri, 27 Jul 2012 22:45:04 +0530
Message-ID: <877gtp5dnr.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Mel Gorman <mgorman@suse.de> writes:

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

I missed that. 

>
> Second, it is protecting against a potential deadlock when
> unmap_unsingle_page is called from unmap_mapping_range(). However, hugetlbfs
> should never be in this path. It has its own setattr and truncate handlers
> where are the paths that use unmap_mapping_range().

I noted this in 

http://article.gmane.org/gmane.linux.kernel.mm/80065


>
> Unless Aneesh has another reason for the patch, it should be reverted
> to preserve hugetlb page sharing locking.
>

I guess we want to take this patch as a revert patch rather than
dropping the one in -mm. That would help in documenting the i_mmap_mutex
locking details in commit message. Or may be we should add necessary
comments around the locking ?

Acked-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> Signed-off-by: Mel Gorman <mgorman@suse.de>
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
