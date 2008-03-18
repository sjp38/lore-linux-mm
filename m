Message-Id: <20080318185721.611032284@szeredi.hu>
References: <20080318185626.300130296@szeredi.hu>
Date: Tue, 18 Mar 2008 19:56:30 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 4/4] fuse: support writable mmap fix
Content-Disposition: inline; filename=fuse_mmap_write_fix.patch
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Set the BDI_CAP_NO_ACCT_WB capability, so that fuse can do it's own
accounting of writeback pages.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 fs/fuse/file.c  |    3 ++-
 fs/fuse/inode.c |    2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

Index: linux/fs/fuse/file.c
===================================================================
--- linux.orig/fs/fuse/file.c	2008-03-18 19:27:43.000000000 +0100
+++ linux/fs/fuse/file.c	2008-03-18 19:43:40.000000000 +0100
@@ -1145,8 +1145,9 @@ static int fuse_writepage_locked(struct 
 	req->end = fuse_writepage_end;
 	req->inode = inode;
 
+	inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
 	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
-	__end_page_writeback(page, false);
+	end_page_writeback(page);
 
 	spin_lock(&fc->lock);
 	list_add(&req->writepages_entry, &fi->writepages);
Index: linux/fs/fuse/inode.c
===================================================================
--- linux.orig/fs/fuse/inode.c	2008-03-18 19:27:43.000000000 +0100
+++ linux/fs/fuse/inode.c	2008-03-18 19:43:40.000000000 +0100
@@ -483,6 +483,8 @@ static struct fuse_conn *new_conn(struct
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		/* fuse does it's own writeback accounting */
+		fc->bdi.capabilities = BDI_CAP_NO_ACCT_WB;
 		fc->dev = sb->s_dev;
 		err = bdi_init(&fc->bdi);
 		if (err)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
