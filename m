Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 9C5E36B0037
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:19:22 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:19:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: + mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves.patch
 added to -mm tree
Message-ID: <20130730141916.GD15847@dhcp22.suse.cz>
References: <51f6e7bb.GQh2moZ80vL8mQ+a%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51f6e7bb.GQh2moZ80vL8mQ+a%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, liwanp@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, dhillf@gmail.com, davidlohr.bueso@hp.com, david@gibson.dropbear.id.au, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Subject: mm, hugetlb: add VM_NORESERVE check in vma_has_reserves()
> 
> If we map the region with MAP_NORESERVE and MAP_SHARED, we can skip to
> check reserve counting and eventually we cannot be ensured to allocate a
> huge page in fault time.  With following example code, you can easily find
> this situation.
> 
> Assume 2MB, nr_hugepages = 100
> 
>         fd = hugetlbfs_unlinked_fd();
>         if (fd < 0)
>                 return 1;
> 
>         size = 200 * MB;
>         flag = MAP_SHARED;
>         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>         if (p == MAP_FAILED) {
>                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                 return -1;
>         }
> 
>         size = 2 * MB;
>         flag = MAP_ANONYMOUS | MAP_SHARED | MAP_HUGETLB | MAP_NORESERVE;
>         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, -1, 0);
>         if (p == MAP_FAILED) {
>                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>         }
>         p[0] = '0';
>         sleep(10);
> 
> During executing sleep(10), run 'cat /proc/meminfo' on another process.
> 
> HugePages_Free:       99
> HugePages_Rsvd:      100
> 
> Number of free should be higher or equal than number of reserve, but this
> aren't.  This represent that non reserved shared mapping steal a reserved
> page.  Non reserved shared mapping should not eat into reserve space.
> 
> If we consider VM_NORESERVE in vma_has_reserve() and return 0 which mean
> that we don't have reserved pages, then we check that we have enough free
> pages in dequeue_huge_page_vma().  This prevent to steal a reserved page.
> 
> With this change, above test generate a SIGBUG which is correct, because
> all free pages are reserved and non reserved shared mapping can't get a
> free page.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Cc: Michal Hocko <mhocko@suse.cz>

yes this changelog is much better. Thanks!

Ackedy-by: Michal Hocko <mhocko@suse.cz>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>
> Cc: David Gibson <david@gibson.dropbear.id.au>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/hugetlb.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff -puN mm/hugetlb.c~mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves mm/hugetlb.c
> --- a/mm/hugetlb.c~mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves
> +++ a/mm/hugetlb.c
> @@ -464,6 +464,8 @@ void reset_vma_resv_huge_pages(struct vm
>  /* Returns true if the VMA has associated reserve pages */
>  static int vma_has_reserves(struct vm_area_struct *vma)
>  {
> +	if (vma->vm_flags & VM_NORESERVE)
> +		return 0;
>  	if (vma->vm_flags & VM_MAYSHARE)
>  		return 1;
>  	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> _
> 
> Patches currently in -mm which might be from iamjoonsoo.kim@lge.com are
> 
> mm-hugetlb-move-up-the-code-which-check-availability-of-free-huge-page.patch
> mm-hugetlb-trivial-commenting-fix.patch
> mm-hugetlb-clean-up-alloc_huge_page.patch
> mm-hugetlb-fix-and-clean-up-node-iteration-code-to-alloc-or-free.patch
> mm-hugetlb-remove-redundant-list_empty-check-in-gather_surplus_pages.patch
> mm-hugetlb-do-not-use-a-page-in-page-cache-for-cow-optimization.patch
> mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves.patch
> mm-hugetlb-remove-decrement_hugepage_resv_vma.patch
> mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache.patch
> mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
