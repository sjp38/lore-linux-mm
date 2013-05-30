Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 213476B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 06:05:54 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 1/2] documentation: Update address_space_operations
Date: Thu, 30 May 2013 11:05:47 +0100
Message-Id: <1369908348-7943-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1369908348-7943-1-git-send-email-mgorman@suse.de>
References: <1369908348-7943-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The documentation for address_space_operations is partially out of date.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/filesystems/vfs.txt | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index bc4b06b..a173cb7 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -549,12 +549,11 @@ struct address_space_operations
 -------------------------------
 
 This describes how the VFS can manipulate mapping of a file to page cache in
-your filesystem. As of kernel 2.6.22, the following members are defined:
+your filesystem. At the time of writing, the following members are defined:
 
 struct address_space_operations {
 	int (*writepage)(struct page *page, struct writeback_control *wbc);
 	int (*readpage)(struct file *, struct page *);
-	int (*sync_page)(struct page *);
 	int (*writepages)(struct address_space *, struct writeback_control *);
 	int (*set_page_dirty)(struct page *page);
 	int (*readpages)(struct file *filp, struct address_space *mapping,
@@ -576,6 +575,8 @@ struct address_space_operations {
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
+	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
+					unsigned long);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
 	int (*swap_activate)(struct file *);
 	int (*swap_deactivate)(struct file *);
@@ -607,13 +608,6 @@ struct address_space_operations {
        In this case, the page will be relocated, relocked and if
        that all succeeds, ->readpage will be called again.
 
-  sync_page: called by the VM to notify the backing store to perform all
-  	queued I/O operations for a page. I/O operations for other pages
-	associated with this address_space object may also be performed.
-
-	This function is optional and is called only for pages with
-  	PG_Writeback set while waiting for the writeback to complete.
-
   writepages: called by the VM to write out pages associated with the
   	address_space object.  If wbc->sync_mode is WBC_SYNC_ALL, then
   	the writeback_control will specify a range of pages that must be
@@ -742,6 +736,11 @@ struct address_space_operations {
   	prevent redirtying the page, it is kept locked during the whole
 	operation.
 
+  is_partially_uptodate: Called by the VM when reading a file through the
+	pagecache when the underlying blocksize != pagesize. If the required
+	block is up to date then the read can complete without needing the IO
+	to bring the whole page up to date.
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
