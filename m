From: Emil Medve <Emilian.Medve@Freescale.com>
Subject: [PATCH] Fix a build error when BLOCK=n
Date: Thu, 18 Oct 2007 09:06:03 -0500
Message-Id: <1192716363-31661-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, jens.axboe@oracle.com
Cc: Emil Medve <Emilian.Medve@Freescale.com>
List-ID: <linux-mm.kvack.org>

This happens when we don't use/have any block devices and a NFS root filesystem
is used

mapping_cap_writeback_dirty() is defined in linux/backing-dev.h which used to be
provided in mm/filemap.c by linux/blkdev.h until commit
f5ff8422bbdd59f8c1f699df248e1b7a11073027

Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
---

Also removed some trailing whitespaces

This is against Linus' tree: d85714d81cc0408daddb68c10f7fd69eafe7c213

linux-2.6> scripts/checkpatch.pl 0001-Fix-a-build-error-when-BLOCK-n.patch 
Your patch has no obvious style problems and is ready for submission.

 mm/filemap.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 79f24a9..6f1643d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -27,6 +27,7 @@
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
 #include <linux/blkdev.h>
+#include <linux/backing-dev.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
@@ -537,7 +538,7 @@ void fastcall unlock_page(struct page *page)
 	smp_mb__before_clear_bit();
 	if (!TestClearPageLocked(page))
 		BUG();
-	smp_mb__after_clear_bit(); 
+	smp_mb__after_clear_bit();
 	wake_up_page(page, PG_locked);
 }
 EXPORT_SYMBOL(unlock_page);
@@ -1249,7 +1250,7 @@ asmlinkage ssize_t sys_readahead(int fd, loff_t offset, size_t count)
 static int fastcall page_cache_read(struct file * file, pgoff_t offset)
 {
 	struct address_space *mapping = file->f_mapping;
-	struct page *page; 
+	struct page *page;
 	int ret;
 
 	do {
@@ -1266,7 +1267,7 @@ static int fastcall page_cache_read(struct file * file, pgoff_t offset)
 		page_cache_release(page);
 
 	} while (ret == AOP_TRUNCATED_PAGE);
-		
+
 	return ret;
 }
 
@@ -2302,7 +2303,7 @@ generic_file_buffered_write(struct kiocb *iocb, const struct iovec *iov,
 						OSYNC_METADATA|OSYNC_DATA);
 		}
   	}
-	
+
 	/*
 	 * If we get here for O_DIRECT writes then we must have fallen through
 	 * to buffered writes (block instantiation inside i_size).  So we sync
-- 
1.5.3.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
