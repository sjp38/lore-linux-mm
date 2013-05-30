Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 556416B0034
	for <linux-mm@kvack.org>; Thu, 30 May 2013 06:05:55 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 2/2] documentation: Document the is_dirty_writeback aops callback
Date: Thu, 30 May 2013 11:05:48 +0100
Message-Id: <1369908348-7943-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1369908348-7943-1-git-send-email-mgorman@suse.de>
References: <1369908348-7943-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Subject says it all.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/filesystems/vfs.txt | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index a173cb7..6b26c75 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -577,6 +577,7 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+	void (*is_dirty_writeback) (struct page *, bool *, bool *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
 	int (*swap_activate)(struct file *);
 	int (*swap_deactivate)(struct file *);
@@ -741,6 +742,15 @@ struct address_space_operations {
 	block is up to date then the read can complete without needing the IO
 	to bring the whole page up to date.
 
+  is_dirty_writeback: Called by the VM when attempting to reclaim a page.
+	The VM uses dirty and writeback information to determine if it needs
+	to stall to allow flushers a chance to complete some IO. Ordinarily
+	it can use PageDirty and PageWriteback but some filesystems have
+	more complex state (unstable pages in NFS prevent reclaim) or
+	do not set those flags due to locking problems (jbd). This callback
+	allows a filesystem to indicate to the VM if a page should be
+	treated as dirty or writeback for the purposes of stalling.
+
   error_remove_page: normally set to generic_error_remove_page if truncation
 	is ok for this address space. Used for memory failure handling.
 	Setting this implies you deal with pages going away under you,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
