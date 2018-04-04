Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D13196B005D
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:17 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v187so7761673qka.5
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x63si1344161qkc.92.2018.04.04.12.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:16 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 32/79] fs/block: do not rely on page->mapping get it from the context
Date: Wed,  4 Apr 2018 15:18:06 -0400
Message-Id: <20180404191831.5378-17-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch remove most dereference of page->mapping and get the mapping
from the call context (either already available in the function or by
adding it to function arguments).

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/block_dev.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 502b6643bc74..dd9da97615e3 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -564,14 +564,14 @@ EXPORT_SYMBOL(thaw_bdev);
 static int blkdev_writepage(struct address_space *mapping, struct page *page,
 			    struct writeback_control *wbc)
 {
-	return block_write_full_page(page->mapping->host, page,
+	return block_write_full_page(mapping->host, page,
 				     blkdev_get_block, wbc);
 }
 
 static int blkdev_readpage(struct file * file, struct address_space *mapping,
 			   struct page * page)
 {
-	return block_read_full_page(page->mapping->host,page,blkdev_get_block);
+	return block_read_full_page(mapping->host,page,blkdev_get_block);
 }
 
 static int blkdev_readpages(struct file *file, struct address_space *mapping,
@@ -1941,7 +1941,7 @@ EXPORT_SYMBOL_GPL(blkdev_read_iter);
 static int blkdev_releasepage(struct address_space *mapping,
 			      struct page *page, gfp_t wait)
 {
-	struct super_block *super = BDEV_I(page->mapping->host)->bdev.bd_super;
+	struct super_block *super = BDEV_I(mapping->host)->bdev.bd_super;
 
 	if (super && super->s_op->bdev_try_to_free_page)
 		return super->s_op->bdev_try_to_free_page(super, page, wait);
-- 
2.14.3
