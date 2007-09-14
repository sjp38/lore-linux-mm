From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:55:12 -0400
Message-Id: <20070914205512.6536.89432.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 11/14] Reclaim Scalability: swap backed pages are nonreclaimable when no swap space available
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC  11/14 Reclaim Scalability: treat swap backed pages as
	non-reclaimable when no swap space is available.

Against:  2.6.23-rc4-mm1

Move swap backed pages [anon, shmem/tmpfs] to noreclaim list when
nr_swap_pages goes to zero.   Use Rik van Riel's page_anon() 
function in page_reclaimable() to detect swap backed pages.

Depends on NORECLAIM_NO_SWAP Kconfig sub-option of NORECLAIM

TODO:   Splice zones' noreclaim list when "sufficient" swap becomes
available--either by being freed by other pages or by additional 
swap being added.  How much is "sufficient" swap?  Don't want to
splice huge noreclaim lists every time a swap page gets freed.

Might want to track per zone "unswappable" pages as a separate
statistic to make intelligent decisions here.  That will complicate
page_reclaimable() and non-reclaimable page culling in vmscan.  E.g.,
where to keep "reason" while page is on the "hold" list?  Not
necessary if we don't cull in shrink_active_list(), but then we get
to visit non-reclaimable pages more often.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/Kconfig  |   11 +++++++++++
 mm/vmscan.c |    9 +++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

Index: Linux/mm/Kconfig
===================================================================
--- Linux.orig/mm/Kconfig	2007-09-14 10:23:52.000000000 -0400
+++ Linux/mm/Kconfig	2007-09-14 10:23:53.000000000 -0400
@@ -215,3 +215,14 @@ config NORECLAIM_ANON_VMA
 	  anonymous pages in such tasks are very expensive [sometimes almost
 	  impossible] to reclaim.  Treating them as non-reclaimable avoids
 	  the overhead of attempting to reclaim them.
+
+config NORECLAIM_NO_SWAP
+	bool "Exclude anon/shmem pages when no swap space available"
+	depends on NORECLAIM
+	help
+	  Treats swap backed pages [anonymous, shmem, tmpfs] as non-reclaimable
+	  when no swap space exists.  Removing these pages from the LRU lists
+	  avoids the overhead of attempting to reclaim them.  Pages marked
+	  non-reclaimable for this reason will become reclaimable again when/if
+	  sufficient swap space is added to the system.
+
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-14 10:23:52.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:23:53.000000000 -0400
@@ -2169,8 +2169,9 @@ int anon_vma_reclaim_limit = DEFAULT_ANO
  *
  * Reasons page might not be reclaimable:
  * 1) page's mapping marked non-reclaimable
- * 2) anon_vma [if any] has too many related vmas
- * [more TBD.  e.g., anon page and no swap available, page mlocked, ...]
+ * 2) anon/shmem/tmpfs page, but no swap space avail
+ * 3) anon_vma [if any] has too many related vmas
+ * [more TBD.  e.g., page mlocked, ...]
  *
  * TODO:  specify locking assumptions
  */
@@ -2182,6 +2183,10 @@ int page_reclaimable(struct page *page, 
 	if (mapping_non_reclaimable(page_mapping(page)))
 		return 0;
 
+#ifdef CONFIG_NORECLAIM_NO_SWAP
+	if (page_anon(page) && !PageSwapCache(page) && !nr_swap_pages)
+		return 0;
+#endif
 #ifdef CONFIG_NORECLAIM_ANON_VMA
 	if (PageAnon(page)) {
 		struct anon_vma *anon_vma;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
