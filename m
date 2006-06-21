Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k5LFksnx030046
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 10:46:54 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k5LG3A7p35969722
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 09:03:10 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k5LFkrnB42437570
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1Ft4ur-0004we-00
	for <linux-mm@kvack.org>; Wed, 21 Jun 2006 08:46:53 -0700
Date: Wed, 21 Jun 2006 08:44:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060621154450.18741.47417.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060621154419.18741.76233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 06/14] Split NR_ANON_PAGES off from NR_FILE_MAPPED
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0606210846530.18960@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Subject: zoned VM stats: Add NR_ANON_PAGES
From: Christoph Lameter <clameter@sgi.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Martin Bligh <mbligh@google.com>, linux-mm@vger.kernel.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

The current NR_FILE_MAPPED is used by zone reclaim and the dirty load
calculation as the number of mapped pagecache pages.  However, that is not
true.  NR_FILE_MAPPED includes the mapped anonymous pages.  This patch
separates those and therefore allows an accurate tracking of the anonymous
pages per zone.

It then becomes possible to determine the number of unmapped pages
per zone and we can avoid scanning for unmapped pages if there
are none.

Also it may now be possible to determine the mapped/unmapped ratio in
get_dirty_limit.  Isnt the number of anonymous pages irrelevant in that
calculation?

Note that this will change the meaning of the number of mapped pages
reported in /proc/vmstat /proc/meminfo and in the per node statistics.
This may affect user space tools that monitor these counters!
NR_FILE_MAPPED works like NR_FILE_DIRTY. It is only valid for pagecache pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

Index: linux-2.6.17-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.17-mm1.orig/fs/proc/proc_misc.c	2006-06-21 08:08:30.098752388 -0700
+++ linux-2.6.17-mm1/fs/proc/proc_misc.c	2006-06-21 08:11:09.531275713 -0700
@@ -168,6 +168,7 @@ static int meminfo_read_proc(char *page,
 		"SwapFree:     %8lu kB\n"
 		"Dirty:        %8lu kB\n"
 		"Writeback:    %8lu kB\n"
+		"AnonPages:    %8lu kB\n"
 		"Mapped:       %8lu kB\n"
 		"Slab:         %8lu kB\n"
 		"CommitLimit:  %8lu kB\n"
@@ -191,6 +192,7 @@ static int meminfo_read_proc(char *page,
 		K(i.freeswap),
 		K(ps.nr_dirty),
 		K(ps.nr_writeback),
+		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
 		K(ps.nr_slab),
 		K(allowed),
Index: linux-2.6.17-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm1.orig/include/linux/mmzone.h	2006-06-21 08:08:30.106564405 -0700
+++ linux-2.6.17-mm1/include/linux/mmzone.h	2006-06-21 08:11:09.532252216 -0700
@@ -48,7 +48,8 @@ struct zone_padding {
 #endif
 
 enum zone_stat_item {
-	NR_FILE_MAPPED,	/* mapped into pagetables.
+	NR_ANON_PAGES,	/* Mapped anonymous pages */
+	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
Index: linux-2.6.17-mm1/mm/rmap.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/rmap.c	2006-06-21 08:06:14.421595498 -0700
+++ linux-2.6.17-mm1/mm/rmap.c	2006-06-21 08:11:09.533228718 -0700
@@ -493,7 +493,7 @@ static void __page_set_anon_rmap(struct 
 	 * nr_mapped state can be updated without turning off
 	 * interrupts because it is not modified via interrupt.
 	 */
-	__inc_zone_page_state(page, NR_FILE_MAPPED);
+	__inc_zone_page_state(page, NR_ANON_PAGES);
 }
 
 /**
@@ -569,7 +569,8 @@ void page_remove_rmap(struct page *page)
 		 */
 		if (page_test_and_clear_dirty(page))
 			set_page_dirty(page);
-		__dec_zone_page_state(page, NR_FILE_MAPPED);
+		__dec_zone_page_state(page,
+				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
 }
 
Index: linux-2.6.17-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmscan.c	2006-06-21 08:11:00.302354268 -0700
+++ linux-2.6.17-mm1/mm/vmscan.c	2006-06-21 08:11:09.535181722 -0700
@@ -725,7 +725,8 @@ static void shrink_active_list(unsigned 
 		 * how much memory
 		 * is mapped.
 		 */
-		mapped_ratio = (global_page_state(NR_FILE_MAPPED) * 100) /
+		mapped_ratio = ((global_page_state(NR_FILE_MAPPED) +
+				global_page_state(NR_ANON_PAGES)) * 100) /
 					total_memory;
 
 		/*
Index: linux-2.6.17-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm1.orig/drivers/base/node.c	2006-06-21 08:10:58.765339946 -0700
+++ linux-2.6.17-mm1/drivers/base/node.c	2006-06-21 08:11:09.535181722 -0700
@@ -70,6 +70,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Writeback:    %8lu kB\n"
 		       "Node %d FilePages:    %8lu kB\n"
 		       "Node %d Mapped:       %8lu kB\n"
+		       "Node %d AnonPages:    %8lu kB\n"
 		       "Node %d Slab:         %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -84,6 +85,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(ps.nr_writeback),
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
+		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
 		       nid, K(ps.nr_slab));
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
Index: linux-2.6.17-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/page-writeback.c	2006-06-21 08:06:14.420618996 -0700
+++ linux-2.6.17-mm1/mm/page-writeback.c	2006-06-21 08:11:09.536158224 -0700
@@ -111,7 +111,8 @@ static void get_writeback_state(struct w
 {
 	wbs->nr_dirty = read_page_state(nr_dirty);
 	wbs->nr_unstable = read_page_state(nr_unstable);
-	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED);
+	wbs->nr_mapped = global_page_state(NR_FILE_MAPPED) +
+				global_page_state(NR_ANON_PAGES);
 	wbs->nr_writeback = read_page_state(nr_writeback);
 }
 
Index: linux-2.6.17-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm1.orig/mm/vmstat.c	2006-06-21 08:08:30.108517409 -0700
+++ linux-2.6.17-mm1/mm/vmstat.c	2006-06-21 08:11:09.537134726 -0700
@@ -457,6 +457,7 @@ struct seq_operations fragmentation_op =
 
 static char *vmstat_text[] = {
 	/* Zoned VM counters */
+	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
