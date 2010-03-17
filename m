Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A9BE36B0138
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 11:21:11 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 33 of 34] transparent hugepage vmstat
Message-Id: <a77ac13a589bc92a94b4.1268839175@v2.random>
In-Reply-To: <patchbomb.1268839142@v2.random>
References: <patchbomb.1268839142@v2.random>
Date: Wed, 17 Mar 2010 16:19:35 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Add hugepage stat information to /proc/vmstat and /proc/meminfo.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -101,6 +101,9 @@ static int meminfo_proc_show(struct seq_
 #ifdef CONFIG_MEMORY_FAILURE
 		"HardwareCorrupted: %5lu kB\n"
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		"AnonHugePages:  %8lu kB\n"
+#endif
 		,
 		K(i.totalram),
 		K(i.freeram),
@@ -151,6 +154,10 @@ static int meminfo_proc_show(struct seq_
 #ifdef CONFIG_MEMORY_FAILURE
 		,atomic_long_read(&mce_bad_pages) << (PAGE_SHIFT - 10)
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
+		   HPAGE_PMD_NR)
+#endif
 		);
 
 	hugetlb_report_meminfo(m);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -112,6 +112,7 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -724,6 +724,9 @@ static void __split_huge_page_refcount(s
 		put_page(page_tail);
 	}
 
+	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__mod_zone_page_state(zone, NR_ANON_PAGES, HPAGE_PMD_NR);
+
 	ClearPageCompound(page);
 	compound_unlock(page);
 	spin_unlock_irq(&zone->lru_lock);
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -795,8 +795,13 @@ void page_add_anon_rmap(struct page *pag
 	struct vm_area_struct *vma, unsigned long address)
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
-	if (first)
-		__inc_zone_page_state(page, NR_ANON_PAGES);
+	if (first) {
+		if (!PageTransHuge(page))
+			__inc_zone_page_state(page, NR_ANON_PAGES);
+		else
+			__inc_zone_page_state(page,
+					      NR_ANON_TRANSPARENT_HUGEPAGES);
+	}
 	if (unlikely(PageKsm(page)))
 		return;
 
@@ -824,7 +829,10 @@ void page_add_new_anon_rmap(struct page 
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
-	__inc_zone_page_state(page, NR_ANON_PAGES);
+	if (!PageTransHuge(page))
+	    __inc_zone_page_state(page, NR_ANON_PAGES);
+	else
+	    __inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__page_set_anon_rmap(page, vma, address);
 	if (page_evictable(page, vma))
 		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
@@ -871,7 +879,11 @@ void page_remove_rmap(struct page *page)
 	}
 	if (PageAnon(page)) {
 		mem_cgroup_uncharge_page(page);
-		__dec_zone_page_state(page, NR_ANON_PAGES);
+		if (!PageTransHuge(page))
+			__dec_zone_page_state(page, NR_ANON_PAGES);
+		else
+			__dec_zone_page_state(page,
+					      NR_ANON_TRANSPARENT_HUGEPAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
 		mem_cgroup_update_file_mapped(page, -1);
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -657,6 +657,9 @@ static const char * const vmstat_text[] 
 	"numa_local",
 	"numa_other",
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	"nr_anon_transparent_hugepages",
+#endif
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
