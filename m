Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 247536B0022
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:08 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p21so15438644qke.20
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:08 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l8si4097850qtb.265.2018.04.04.12.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:06 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 24/79] fs: add struct inode to nobh_writepage() arguments
Date: Wed,  4 Apr 2018 15:17:59 -0400
Message-Id: <20180404191831.5378-10-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>, Jeff Layton <jlayton@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Add struct inode to nobh_writepage(). Note this patch only add arguments
and modify call site conservatily using page->mapping and thus the end
result is as before this patch.

One step toward dropping reliance on page->mapping.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Jeff Layton <jlayton@redhat.com>
---
 fs/buffer.c                 | 5 ++---
 fs/ext2/inode.c             | 2 +-
 fs/gfs2/aops.c              | 3 ++-
 include/linux/buffer_head.h | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index aa7d9be68581..31298f4f0300 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2730,10 +2730,9 @@ EXPORT_SYMBOL(nobh_write_end);
  * that it tries to operate without attaching bufferheads to
  * the page.
  */
-int nobh_writepage(struct page *page, get_block_t *get_block,
-			struct writeback_control *wbc)
+int nobh_writepage(struct inode *inode, struct page *page,
+		get_block_t *get_block, struct writeback_control *wbc)
 {
-	struct inode * const inode = page->mapping->host;
 	loff_t i_size = i_size_read(inode);
 	const pgoff_t end_index = i_size >> PAGE_SHIFT;
 	unsigned offset;
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 37439d1e544c..11b3c3e7ea65 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -926,7 +926,7 @@ static int ext2_nobh_writepage(struct address_space *mapping,
 			struct page *page,
 			struct writeback_control *wbc)
 {
-	return nobh_writepage(page, ext2_get_block, wbc);
+	return nobh_writepage(page->mapping->host, page, ext2_get_block, wbc);
 }
 
 static sector_t ext2_bmap(struct address_space *mapping, sector_t block)
diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
index 8cfd4c7d884c..ff02313b86e6 100644
--- a/fs/gfs2/aops.c
+++ b/fs/gfs2/aops.c
@@ -142,7 +142,8 @@ static int gfs2_writepage(struct address_space *mapping, struct page *page,
 	if (ret <= 0)
 		return ret;
 
-	return nobh_writepage(page, gfs2_get_block_noalloc, wbc);
+	return nobh_writepage(page->mapping->host, page,
+			      gfs2_get_block_noalloc, wbc);
 }
 
 /* This is the same as calling block_write_full_page, but it also
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index cab143668834..fb68a3358330 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -265,8 +265,8 @@ int nobh_write_end(struct file *, struct address_space *,
 				loff_t, unsigned, unsigned,
 				struct page *, void *);
 int nobh_truncate_page(struct address_space *, loff_t, get_block_t *);
-int nobh_writepage(struct page *page, get_block_t *get_block,
-                        struct writeback_control *wbc);
+int nobh_writepage(struct inode *inode, struct page *page,
+		get_block_t *get_block, struct writeback_control *wbc);
 
 void buffer_init(void);
 
-- 
2.14.3
