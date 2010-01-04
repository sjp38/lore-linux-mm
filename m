Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 03AC4600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 11:05:21 -0500 (EST)
Date: Mon, 4 Jan 2010 17:04:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 25 of 28] transparent hugepage core
Message-ID: <20100104160437.GE17401@random.random>
References: <patchbomb.1261076403@v2.random>
 <4d96699c8fb89a4a22eb.1261076428@v2.random>
 <20100104151649.34f6c469.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100104151649.34f6c469.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jan 04, 2010 at 03:16:49PM +0900, Daisuke Nishimura wrote:
> IIUC, page_add_new_anon_rmap()(and add_page_to_lru_list(), which will be called
> by the call path) will update zone state of NR_ANON_PAGES and NR_ACTIVE_ANON.
> Shouldn't we also modify zone state codes to support transparent hugepage support ?

Correct. I did more changes in the last weeks besides the work on
khugepaged. This is the relevant one that you couldn't see and that
already takes care of the above. Maybe I should send a new update for
this and other bits even if the last bit of khugepaged isn't working
yet. Otherwise wait a little more and get the whole thing working. Let
me know. This is combined with other changes to the split logic that
now transfers the single hugeanonpage to 512 anonpages.

----
Subject: transparent hugepage vmstat

From: Andrea Arcangeli <aarcange@redhat.com>

Add hugepage stat information to /proc/vmstat and /proc/meminfo.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
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
@@ -112,6 +112,9 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	NR_ANON_TRANSPARENT_HUGEPAGES,
+#endif
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -725,6 +725,10 @@ static void __split_huge_page_refcount(s
 		put_page(page_tail);
 	}
 
+	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__mod_zone_page_state(page_zone(page), NR_ANON_PAGES,
+			      HPAGE_PMD_NR);
+
 	ClearPageCompound(page);
 	compound_unlock(page);
 }
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -692,8 +692,13 @@ void page_add_anon_rmap(struct page *pag
 {
 	int first = atomic_inc_and_test(&page->_mapcount);
 	VM_BUG_ON(PageTail(page));
-	if (first)
-		__inc_zone_page_state(page, NR_ANON_PAGES);
+	if (first) {
+		if (!PageCompound(page))
+			__inc_zone_page_state(page, NR_ANON_PAGES);
+		else
+			__inc_zone_page_state(page,
+					      NR_ANON_TRANSPARENT_HUGEPAGES);
+	}
 	if (unlikely(PageKsm(page)))
 		return;
 
@@ -722,7 +727,10 @@ void page_add_new_anon_rmap(struct page 
 	VM_BUG_ON(PageTail(page));
 	SetPageSwapBacked(page);
 	atomic_set(&page->_mapcount, 0); /* increment count (starts at -1) */
-	__inc_zone_page_state(page, NR_ANON_PAGES);
+	if (!PageCompound(page))
+	    __inc_zone_page_state(page, NR_ANON_PAGES);
+	else
+	    __inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__page_set_anon_rmap(page, vma, address);
 	if (page_evictable(page, vma))
 		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
@@ -770,7 +778,11 @@ void page_remove_rmap(struct page *page)
 	}
 	if (PageAnon(page)) {
 		mem_cgroup_uncharge_page(page);
-		__dec_zone_page_state(page, NR_ANON_PAGES);
+		if (!PageCompound(page))
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
@@ -655,6 +655,9 @@ static const char * const vmstat_text[] 
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
