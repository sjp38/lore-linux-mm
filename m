Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 00B226B0039
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 01:28:27 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 6/9] mm, hugetlb: do not use a page in page cache for cow optimization
Date: Mon, 29 Jul 2013 14:28:18 +0900
Message-Id: <1375075701-5998-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075701-5998-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we use a page with mapped count 1 in page cache for cow
optimization. If we find this condition, we don't allocate a new
page and copy contents. Instead, we map this page directly.
This may introduce a problem that writting to private mapping overwrite
hugetlb file directly. You can find this situation with following code.

        size = 20 * MB;
        flag = MAP_SHARED;
        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
        if (p == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
                return -1;
        }
        p[0] = 's';
        fprintf(stdout, "BEFORE STEAL PRIVATE WRITE: %c\n", p[0]);
        munmap(p, size);

        flag = MAP_PRIVATE;
        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
        if (p == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
        }
        p[0] = 'c';
        munmap(p, size);

        flag = MAP_SHARED;
        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
        if (p == MAP_FAILED) {
                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
                return -1;
        }
        fprintf(stdout, "AFTER STEAL PRIVATE WRITE: %c\n", p[0]);
        munmap(p, size);

We can see that "AFTER STEAL PRIVATE WRITE: c", not "AFTER STEAL
PRIVATE WRITE: s". If we turn off this optimization to a page
in page cache, the problem is disappeared.

So, I change the trigger condition of optimization. If this page is not
AnonPage, we don't do optimization. This makes this optimization turning
off for a page cache.

Acked-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2e52afea..1f6b3a6 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2511,7 +2511,6 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
-	int avoidcopy;
 	int outside_reserve = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -2521,10 +2520,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 retry_avoidcopy:
 	/* If no-one else is actually using this page, avoid the copy
 	 * and just make the page writable */
-	avoidcopy = (page_mapcount(old_page) == 1);
-	if (avoidcopy) {
-		if (PageAnon(old_page))
-			page_move_anon_rmap(old_page, vma, address);
+	if (page_mapcount(old_page) == 1 && PageAnon(old_page)) {
+		page_move_anon_rmap(old_page, vma, address);
 		set_huge_ptep_writable(vma, address, ptep);
 		return 0;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
