Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6C7836B026A
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:21 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q15so12352506qkj.3
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q64si5211887qkh.395.2018.04.04.12.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:20 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 37/79] fs/buffer: add struct super_block to __bforget() arguments
Date: Wed,  4 Apr 2018 15:18:11 -0400
Message-Id: <20180404191831.5378-22-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For the holy crusade to stop relying on struct page mapping field, add
struct super_block to __bforget() arguments.

spatch --sp-file zemantic-013a.spatch --in-place --dir fs/
spatch --sp-file zemantic-013a.spatch --in-place --dir include/ --include-headers
----------------------------------------------------------------------
@exists@
expression E1;
identifier I;
@@
struct super_block *I;
...
-__bforget(E1)
+__bforget(I, E1)

@exists@
expression E1;
identifier F, I;
@@
F(..., struct super_block *I, ...) {
...
-__bforget(E1)
+__bforget(I, E1)
...
}

@exists@
expression E1;
identifier I;
@@
struct inode *I;
...
-__bforget(E1)
+__bforget(I->i_sb, E1)

@exists@
expression E1;
identifier F, I;
@@
F(..., struct inode *I, ...) {
...
-__bforget(E1)
+__bforget(I->i_sb, E1)
...
}
----------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 fs/buffer.c                 | 2 +-
 fs/jbd2/transaction.c       | 2 +-
 include/linux/buffer_head.h | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 9f2c5e90b64d..422204701a3b 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -1168,7 +1168,7 @@ EXPORT_SYMBOL(__brelse);
  * bforget() is like brelse(), except it discards any
  * potentially dirty data.
  */
-void __bforget(struct buffer_head *bh)
+void __bforget(struct super_block *sb, struct buffer_head *bh)
 {
 	clear_buffer_dirty(bh);
 	if (bh->b_assoc_map) {
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index e8c50bb5822c..177616eb793c 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -1560,7 +1560,7 @@ int jbd2_journal_forget (handle_t *handle, struct super_block *sb,
 			if (!buffer_jbd(bh)) {
 				spin_unlock(&journal->j_list_lock);
 				jbd_unlock_bh_state(bh);
-				__bforget(bh);
+				__bforget(sb, bh);
 				goto drop;
 			}
 		}
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index 82faae102ba2..7ae60f59f27e 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -192,7 +192,7 @@ struct buffer_head *__find_get_block(struct block_device *bdev, sector_t block,
 struct buffer_head *__getblk_gfp(struct block_device *bdev, sector_t block,
 				  unsigned size, gfp_t gfp);
 void __brelse(struct buffer_head *);
-void __bforget(struct buffer_head *);
+void __bforget(struct super_block *, struct buffer_head *);
 void __breadahead(struct block_device *, sector_t block, unsigned int size);
 struct buffer_head *__bread_gfp(struct block_device *,
 				sector_t block, unsigned size, gfp_t gfp);
@@ -306,7 +306,7 @@ static inline void brelse(struct buffer_head *bh)
 static inline void bforget(struct super_block *sb, struct buffer_head *bh)
 {
 	if (bh)
-		__bforget(bh);
+		__bforget(sb, bh);
 }
 
 static inline struct buffer_head *
-- 
2.14.3
