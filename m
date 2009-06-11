Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7455D6B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:26:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BAQoWM002514
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 19:26:50 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0660945DE51
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:50 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DAF7845DD79
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2BDB1DB803B
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:49 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 808B11DB803F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:26:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm 2/5] 
In-Reply-To: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
Message-Id: <20090611192600.6D50.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 19:26:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Changes since Wu's original patch
  - adding vmstat
  - rename NR_TMPFS_MAPPED to NR_SWAP_BACKED_FILE_MAPPED


----------------------
Subject: [PATCH] introduce NR_SWAP_BACKED_FILE_MAPPED zone stat

Desirable zone reclaim implementaion want to know the number of
file-backed and unmapped pages.

Thus, we need to know number of swap-backed mapped pages for
calculate above number.


Cc: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mmzone.h |    2 ++
 mm/rmap.c              |    7 +++++++
 mm/vmstat.c            |    1 +
 3 files changed, 10 insertions(+)

Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -88,6 +88,8 @@ enum zone_stat_item {
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
+	NR_SWAP_BACKED_FILE_MAPPED, /* Similar to NR_FILE_MAPPED. but
+				       only account swap-backed pages */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -829,6 +829,10 @@ void page_add_file_rmap(struct page *pag
 {
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		__inc_zone_page_state(page, NR_FILE_MAPPED);
+		if (PageSwapBacked(page))
+			__inc_zone_page_state(page,
+					      NR_SWAP_BACKED_FILE_MAPPED);
+
 		mem_cgroup_update_mapped_file_stat(page, 1);
 	}
 }
@@ -884,6 +888,9 @@ void page_remove_rmap(struct page *page)
 		__dec_zone_page_state(page, NR_ANON_PAGES);
 	} else {
 		__dec_zone_page_state(page, NR_FILE_MAPPED);
+		if (PageSwapBacked(page))
+			__dec_zone_page_state(page,
+					NR_SWAP_BACKED_FILE_MAPPED);
 	}
 	mem_cgroup_update_mapped_file_stat(page, -1);
 	/*
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -633,6 +633,7 @@ static const char * const vmstat_text[] 
 	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
+	"nr_swap_backed_file_mapped",
 	"nr_file_pages",
 	"nr_dirty",
 	"nr_writeback",


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
