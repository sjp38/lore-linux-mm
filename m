Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 424526B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 02:53:27 -0400 (EDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH] fs: ramfs: file-nommu: add SetPageUptodate()
Date: Wed, 27 Jun 2012 22:55:12 +0800
Message-ID: <1340808912-4722-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, dhowells@redhat.com, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

There is a bug in below scene for platform !CONFIG_MMU:
1. create a new file
2. mmap the file and write to it
3. read the file can't get the correct value

Because
sys_read() > generic_file_aio_read() > simple_readpage() > clear_page()
which make the page be zeroed.

Add SetPageUptodate() to ramfs_nommu_expand_for_mapping() so that
generic_file_aio_read() do not call simple_readpage().

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 fs/ramfs/file-nommu.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index fbb0b47..d5378d0 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -110,6 +110,7 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 
 		/* prevent the page from being discarded on memory pressure */
 		SetPageDirty(page);
+		SetPageUptodate(page);
 
 		unlock_page(page);
 		put_page(page);
-- 
1.7.9.5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
