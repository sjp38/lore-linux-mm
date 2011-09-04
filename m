Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B88E6B0192
	for <linux-mm@kvack.org>; Sat,  3 Sep 2011 22:13:28 -0400 (EDT)
Message-Id: <20110904020916.841463184@intel.com>
Date: Sun, 04 Sep 2011 09:53:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 17/18] writeback: fix dirtied pages accounting on redirty
References: <20110904015305.367445271@intel.com>
Content-Disposition: inline; filename=writeback-account-redirty
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

De-account the accumulative dirty counters on page redirty.

Page redirties (very common in ext4) will introduce mismatch between
counters (a) and (b)

a) NR_DIRTIED, BDI_DIRTIED, tsk->nr_dirtied
b) NR_WRITTEN, BDI_WRITTEN

This will introduce systematic errors in balanced_rate and result in
dirty page position errors (ie. the dirty pages are no longer balanced
around the global/bdi setpoints).

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/writeback.h |    2 ++
 mm/page-writeback.c       |   12 ++++++++++++
 2 files changed, 14 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-08-29 19:14:36.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-08-29 19:14:38.000000000 +0800
@@ -1836,6 +1836,17 @@ int __set_page_dirty_nobuffers(struct pa
 }
 EXPORT_SYMBOL(__set_page_dirty_nobuffers);
 
+void account_page_redirty(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	if (mapping && mapping_cap_account_dirty(mapping)) {
+		current->nr_dirtied--;
+		dec_zone_page_state(page, NR_DIRTIED);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTIED);
+	}
+}
+EXPORT_SYMBOL(account_page_redirty);
+
 /*
  * When a writepage implementation decides that it doesn't want to write this
  * page for some reason, it should redirty the locked page via
@@ -1844,6 +1855,7 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers
 int redirty_page_for_writepage(struct writeback_control *wbc, struct page *page)
 {
 	wbc->pages_skipped++;
+	account_page_redirty(page);
 	return __set_page_dirty_nobuffers(page);
 }
 EXPORT_SYMBOL(redirty_page_for_writepage);
--- linux-next.orig/include/linux/writeback.h	2011-08-29 19:14:32.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-08-29 19:14:38.000000000 +0800
@@ -175,6 +175,8 @@ void writeback_set_ratelimit(void);
 void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end);
 
+void account_page_redirty(struct page *page);
+
 /* pdflush.c */
 extern int nr_pdflush_threads;	/* Global so it can be exported to sysctl
 				   read-only. */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
