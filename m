Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id ECE5C8D001A
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:30:42 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 40 of 66] transparent hugepage vmstat
Message-Id: <9634aa34aaa7e02f3831.1288798095@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:28:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
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
@@ -128,7 +131,12 @@ static int meminfo_proc_show(struct seq_
 		K(i.freeswap),
 		K(global_page_state(NR_FILE_DIRTY)),
 		K(global_page_state(NR_WRITEBACK)),
-		K(global_page_state(NR_ANON_PAGES)),
+		K(global_page_state(NR_ANON_PAGES)
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		  + global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
+		  HPAGE_PMD_NR
+#endif
+		  ),
 		K(global_page_state(NR_FILE_MAPPED)),
 		K(global_page_state(NR_SHMEM)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
@@ -151,6 +159,10 @@ static int meminfo_proc_show(struct seq_
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
@@ -114,6 +114,7 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+	NR_ANON_TRANSPARENT_HUGEPAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -747,6 +747,9 @@ static void __split_huge_page_refcount(s
 		lru_add_page_tail(zone, page, page_tail);
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
@@ -882,8 +882,13 @@ void do_page_add_anon_rmap(struct page *
 	struct vm_area_struct *vma, unsigned long address, int exclusive)
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
 
@@ -911,7 +916,10 @@ void page_add_new_anon_rmap(struct page 
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
-	__inc_zone_page_state(page, NR_ANON_PAGES);
+	if (!PageTransHuge(page))
+		__inc_zone_page_state(page, NR_ANON_PAGES);
+	else
+		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__page_set_anon_rmap(page, vma, address, 1);
 	if (page_evictable(page, vma))
 		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
@@ -964,7 +972,11 @@ void page_remove_rmap(struct page *page)
 		return;
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
@@ -761,6 +761,7 @@ static const char * const vmstat_text[] 
 	"numa_local",
 	"numa_other",
 #endif
+	"nr_anon_transparent_hugepages",
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	"pgpgin",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
