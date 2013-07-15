Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id A3E8C6B00D1
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 06:45:07 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/8] thp: account anon transparent huge pages into NR_ANON_PAGES
Date: Mon, 15 Jul 2013 13:47:49 +0300
Message-Id: <1373885274-25249-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We use NR_ANON_PAGES as base for reporting AnonPages to user.
There's not much sense in not accounting transparent huge pages there, but
add them on printing to user.

Let's account transparent huge pages in NR_ANON_PAGES in the first place.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 drivers/base/node.c |  6 ------
 fs/proc/meminfo.c   |  6 ------
 mm/huge_memory.c    |  1 -
 mm/rmap.c           | 18 +++++++++---------
 4 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 7616a77..bc9f43b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -125,13 +125,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(node_page_state(nid, NR_ANON_PAGES)
-			+ node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
-			HPAGE_PMD_NR),
-#else
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
-#endif
 		       nid, K(node_page_state(nid, NR_SHMEM)),
 		       nid, node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 5aa847a..59d85d6 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -132,13 +132,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
 		K(global_page_state(NR_WRITEBACK)),
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		K(global_page_state(NR_ANON_PAGES)
-		  + global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
-		  HPAGE_PMD_NR),
-#else
 		K(global_page_state(NR_ANON_PAGES)),
-#endif
 		K(global_page_state(NR_FILE_MAPPED)),
 		K(global_page_state(NR_SHMEM)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a92012a..04f0749 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1661,7 +1661,6 @@ static void __split_huge_page_refcount(struct page *page,
 	BUG_ON(atomic_read(&page->_count) <= 0);
 
 	__mod_zone_page_state(zone, NR_ANON_TRANSPARENT_HUGEPAGES, -1);
-	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
 
 	ClearPageCompound(page);
 	compound_unlock(page);
diff --git a/mm/rmap.c b/mm/rmap.c
index cd356df..7066470 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1055,11 +1055,11 @@ void do_page_add_anon_rmap(struct page *page,
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
 	if (first) {
-		if (!PageTransHuge(page))
-			__inc_zone_page_state(page, NR_ANON_PAGES);
-		else
+		if (PageTransHuge(page))
 			__inc_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+				hpage_nr_pages(page));
 	}
 	if (unlikely(PageKsm(page)))
 		return;
@@ -1088,10 +1088,10 @@ void page_add_new_anon_rmap(struct page *page,
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
-	if (!PageTransHuge(page))
-		__inc_zone_page_state(page, NR_ANON_PAGES);
-	else
+	if (PageTransHuge(page))
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+			hpage_nr_pages(page));
 	__page_set_anon_rmap(page, vma, address, 1);
 	if (!mlocked_vma_newpage(vma, page)) {
 		SetPageActive(page);
@@ -1151,11 +1151,11 @@ void page_remove_rmap(struct page *page)
 		goto out;
 	if (anon) {
 		mem_cgroup_uncharge_page(page);
-		if (!PageTransHuge(page))
-			__dec_zone_page_state(page, NR_ANON_PAGES);
-		else
+		if (PageTransHuge(page))
 			__dec_zone_page_state(page,
 					      NR_ANON_TRANSPARENT_HUGEPAGES);
+		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+				hpage_nr_pages(page));
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_dec_page_stat(page, MEMCG_NR_FILE_MAPPED);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
