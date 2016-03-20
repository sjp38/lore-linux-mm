Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id A538C82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:47:17 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so237543610pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:47:17 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fd9si7103985pad.134.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 43/71] jbd2: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:50 +0300
Message-Id: <1458499278-1516-44-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Jan Kara <jack@suse.com>
---
 fs/jbd2/commit.c      | 4 ++--
 fs/jbd2/journal.c     | 2 +-
 fs/jbd2/transaction.c | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/jbd2/commit.c b/fs/jbd2/commit.c
index 517f2de784cf..2ad98d6e19f4 100644
--- a/fs/jbd2/commit.c
+++ b/fs/jbd2/commit.c
@@ -81,11 +81,11 @@ static void release_buffer_page(struct buffer_head *bh)
 	if (!trylock_page(page))
 		goto nope;
 
-	page_cache_get(page);
+	get_page(page);
 	__brelse(bh);
 	try_to_free_buffers(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return;
 
 nope:
diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index de73a9516a54..435f0b26ac20 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2221,7 +2221,7 @@ void jbd2_journal_ack_err(journal_t *journal)
 
 int jbd2_journal_blocks_per_page(struct inode *inode)
 {
-	return 1 << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
+	return 1 << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 }
 
 /*
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index 01e4652d88f6..67c103867bf8 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -2263,7 +2263,7 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 	struct buffer_head *head, *bh, *next;
 	unsigned int stop = offset + length;
 	unsigned int curr_off = 0;
-	int partial_page = (offset || length < PAGE_CACHE_SIZE);
+	int partial_page = (offset || length < PAGE_SIZE);
 	int may_free = 1;
 	int ret = 0;
 
@@ -2272,7 +2272,7 @@ int jbd2_journal_invalidatepage(journal_t *journal,
 	if (!page_has_buffers(page))
 		return 0;
 
-	BUG_ON(stop > PAGE_CACHE_SIZE || stop < length);
+	BUG_ON(stop > PAGE_SIZE || stop < length);
 
 	/* We will potentially be playing with lists other than just the
 	 * data lists (especially for journaled data mode), so be
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
