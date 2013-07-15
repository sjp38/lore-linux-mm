Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id B03AD6B00B5
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:52:53 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 7/9] mm, hugetlb: add VM_NORESERVE check in vma_has_reserves()
Date: Mon, 15 Jul 2013 18:52:45 +0900
Message-Id: <1373881967-16153-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
You'll find a mentioned problem.

Solution is simple. We should check VM_NORESERVE in vma_has_reserves().
This prevent to use a pre-allocated huge page if free count is under
the reserve count.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6c1eb9b..f6a7a4e 100644
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
