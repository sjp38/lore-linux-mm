Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 699596B0036
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:28:28 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 7/9] mm, hugetlb: add VM_NORESERVE check in vma_has_reserves()
Date: Mon, 29 Jul 2013 14:28:19 +0900
Message-Id: <1375075701-5998-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

If we map the region with MAP_NORESERVE and MAP_SHARED,
we can skip to check reserve counting and eventually we cannot be ensured
to allocate a huge page in fault time.
With following example code, you can easily find this situation.

Assume 2MB, nr_hugepages = 100

        fd = hugetlbfs_unlinked_fd();
        if (fd < 0)
                return 1;

        size = 200 * MB;
        flag = MAP_SHARED;
        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
        if (p == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
                return -1;
        }

        size = 2 * MB;
        flag = MAP_ANONYMOUS | MAP_SHARED | MAP_HUGETLB | MAP_NORESERVE;
        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, -1, 0);
        if (p == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
        }
        p[0] = '0';
        sleep(10);

During executing sleep(10), run 'cat /proc/meminfo' on another process.

HugePages_Free:       99
HugePages_Rsvd:      100

Number of free should be higher or equal than number of reserve,
but this aren't. This represent that non reserved shared mapping steal
a reserved page. Non reserved shared mapping should not eat into
reserve space.

If we consider VM_NORESERVE in vma_has_reserve() and return 0 which mean
that we don't have reserved pages, then we check that we have enough
free pages in dequeue_huge_page_vma(). This prevent to steal
a reserved page.

With this change, above test generate a SIGBUG which is correct,
because all free pages are reserved and non reserved shared mapping
can't get a free page.

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1f6b3a6..ca15854 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -464,6 +464,8 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
 /* Returns true if the VMA has associated reserve pages */
 static int vma_has_reserves(struct vm_area_struct *vma)
 {
+	if (vma->vm_flags & VM_NORESERVE)
+		return 0;
 	if (vma->vm_flags & VM_MAYSHARE)
 		return 1;
 	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
