Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 088146B0271
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id h89so16216422qtd.18
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m91si1848180qte.151.2018.04.04.12.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:24 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 51/79] fs: stop relying on mapping field of struct page, get it from context
Date: Wed,  4 Apr 2018 15:18:15 -0400
Message-Id: <20180404191831.5378-26-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Holy grail, remove all usage of mapping field of struct page inside
common fs code. This is the manual conversion patch (so much can be
done with coccinelle).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/buffer.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 39d8c7315b55..3c424b7af5af 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -570,7 +570,9 @@ void write_boundary_block(struct block_device *bdev,
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode)
 {
 	struct address_space *mapping = inode->i_mapping;
-	struct address_space *buffer_mapping = bh->b_page->mapping;
+	struct address_space *buffer_mapping;
+
+	buffer_mapping = fs_page_mapping_get_with_bh(bh->b_page, bh);
 
 	mark_buffer_dirty(bh);
 	if (!mapping->private_data) {
@@ -1138,10 +1140,13 @@ EXPORT_SYMBOL(mark_buffer_dirty);
 void mark_buffer_write_io_error(struct address_space *mapping,
 		struct page *page, struct buffer_head *bh)
 {
+	BUG_ON(page != bh->b_page);
+	BUG_ON(mapping != bh->b_page->mapping);
+
 	set_buffer_write_io_error(bh);
 	/* FIXME: do we need to set this in both places? */
-	if (bh->b_page && !page_is_truncated(bh->b_page, bh->b_page->mapping))
-		mapping_set_error(bh->b_page->mapping, -EIO);
+	if (bh->b_page && !page_is_truncated(page, mapping))
+		mapping_set_error(mapping, -EIO);
 	if (bh->b_assoc_map)
 		mapping_set_error(bh->b_assoc_map, -EIO);
 }
@@ -1172,7 +1177,10 @@ void __bforget(struct super_block *sb, struct buffer_head *bh)
 {
 	clear_buffer_dirty(bh);
 	if (bh->b_assoc_map) {
-		struct address_space *buffer_mapping = bh->b_page->mapping;
+		struct address_space *buffer_mapping;
+
+		buffer_mapping = sb->s_bdev->bd_inode->i_mapping;
+		BUG_ON(buffer_mapping != bh->b_page->mapping);
 
 		spin_lock(&buffer_mapping->private_lock);
 		list_del_init(&bh->b_assoc_buffers);
@@ -1543,7 +1551,7 @@ void create_empty_buffers(struct address_space *mapping, struct page *page,
 	} while (bh);
 	tail->b_this_page = head;
 
-	spin_lock(&page->mapping->private_lock);
+	spin_lock(&mapping->private_lock);
 	if (PageUptodate(page) || PageDirty(page)) {
 		bh = head;
 		do {
@@ -1555,7 +1563,7 @@ void create_empty_buffers(struct address_space *mapping, struct page *page,
 		} while (bh != head);
 	}
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&mapping->private_lock);
 }
 EXPORT_SYMBOL(create_empty_buffers);
 
@@ -1833,7 +1841,7 @@ int __block_write_full_page(struct inode *inode, struct page *page,
 	} while ((bh = bh->b_this_page) != head);
 	SetPageError(page);
 	BUG_ON(PageWriteback(page));
-	mapping_set_error(page->mapping, err);
+	mapping_set_error(inode->i_mapping, err);
 	set_page_writeback(page);
 	do {
 		struct buffer_head *next = bh->b_this_page;
@@ -2541,7 +2549,7 @@ static void attach_nobh_buffers(struct address_space *mapping,
 
 	BUG_ON(!PageLocked(page));
 
-	spin_lock(&page->mapping->private_lock);
+	spin_lock(&mapping->private_lock);
 	bh = head;
 	do {
 		if (PageDirty(page))
@@ -2551,7 +2559,7 @@ static void attach_nobh_buffers(struct address_space *mapping,
 		bh = bh->b_this_page;
 	} while (bh != head);
 	attach_page_buffers(page, head);
-	spin_unlock(&page->mapping->private_lock);
+	spin_unlock(&mapping->private_lock);
 }
 
 /*
-- 
2.14.3
