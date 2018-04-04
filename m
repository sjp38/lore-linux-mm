Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2826B0062
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:18 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f10so16386231qtc.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a4si1529372qth.103.2018.04.04.12.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:17 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 33/79] fs/journal: add struct super_block to jbd2_journal_forget() arguments.
Date: Wed,  4 Apr 2018 15:18:07 -0400
Message-Id: <20180404191831.5378-18-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

For the holy crusade to stop relying on struct page mapping field, add
struct super_block to jbd2_journal_forget() arguments.

spatch --sp-file zemantic-010a.spatch --in-place --dir fs/
----------------------------------------------------------------------
@exists@
expression E1, E2;
identifier I;
@@
struct super_block *I;
...
-jbd2_journal_forget(E1, E2)
+jbd2_journal_forget(E1, I, E2)

@exists@
expression E1, E2;
identifier F, I;
@@
F(..., struct super_block *I, ...) {
...
-jbd2_journal_forget(E1, E2)
+jbd2_journal_forget(E1, I, E2)
...
}

@exists@
expression E1, E2;
identifier I;
@@
struct block_device *I;
...
-jbd2_journal_forget(E1, E2)
+jbd2_journal_forget(E1, I->bd_super, E2)

@exists@
expression E1, E2;
identifier F, I;
@@
F(..., struct block_device *I, ...) {
...
-jbd2_journal_forget(E1, E2)
+jbd2_journal_forget(E1, I->bd_super, E2)
...
}

@exists@
expression E1, E2;
identifier I;
@@
struct inode *I;
...
-jbd2_journal_forget(E1, E2)
+jbd2_journal_forget(E1, I->i_sb, E2)

@exists@
expression E1, E2;
identifier F, I;
@@
F(..., struct inode *I, ...) {
...
-jbd2_journal_forget(E1, E2)
+jbd2_journal_forget(E1, I->i_sb, E2)
...
}
----------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Jan Kara <jack@suse.com>
Cc: linux-ext4@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
---
 fs/ext4/ext4_jbd2.c   | 2 +-
 fs/jbd2/revoke.c      | 2 +-
 fs/jbd2/transaction.c | 3 ++-
 include/linux/jbd2.h  | 3 ++-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
index 2d593201cf7a..0804d564b529 100644
--- a/fs/ext4/ext4_jbd2.c
+++ b/fs/ext4/ext4_jbd2.c
@@ -224,7 +224,7 @@ int __ext4_forget(const char *where, unsigned int line, handle_t *handle,
 	    (!is_metadata && !ext4_should_journal_data(inode))) {
 		if (bh) {
 			BUFFER_TRACE(bh, "call jbd2_journal_forget");
-			err = jbd2_journal_forget(handle, bh);
+			err = jbd2_journal_forget(handle, inode->i_sb, bh);
 			if (err)
 				ext4_journal_abort_handle(where, line, __func__,
 							  bh, handle, err);
diff --git a/fs/jbd2/revoke.c b/fs/jbd2/revoke.c
index 696ef15ec942..b6e2fd52acd6 100644
--- a/fs/jbd2/revoke.c
+++ b/fs/jbd2/revoke.c
@@ -381,7 +381,7 @@ int jbd2_journal_revoke(handle_t *handle, unsigned long long blocknr,
 		set_buffer_revokevalid(bh);
 		if (bh_in) {
 			BUFFER_TRACE(bh_in, "call jbd2_journal_forget");
-			jbd2_journal_forget(handle, bh_in);
+			jbd2_journal_forget(handle, bdev->bd_super, bh_in);
 		} else {
 			BUFFER_TRACE(bh, "call brelse");
 			__brelse(bh);
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index ac311037d7a5..e8c50bb5822c 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -1482,7 +1482,8 @@ int jbd2_journal_dirty_metadata(handle_t *handle, struct buffer_head *bh)
  * Allow this call even if the handle has aborted --- it may be part of
  * the caller's cleanup after an abort.
  */
-int jbd2_journal_forget (handle_t *handle, struct buffer_head *bh)
+int jbd2_journal_forget (handle_t *handle, struct super_block *sb,
+			 struct buffer_head *bh)
 {
 	transaction_t *transaction = handle->h_transaction;
 	journal_t *journal;
diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
index b708e5169d1d..d89749a179eb 100644
--- a/include/linux/jbd2.h
+++ b/include/linux/jbd2.h
@@ -1358,7 +1358,8 @@ extern int	 jbd2_journal_get_undo_access(handle_t *, struct buffer_head *);
 void		 jbd2_journal_set_triggers(struct buffer_head *,
 					   struct jbd2_buffer_trigger_type *type);
 extern int	 jbd2_journal_dirty_metadata (handle_t *, struct buffer_head *);
-extern int	 jbd2_journal_forget (handle_t *, struct buffer_head *);
+extern int	 jbd2_journal_forget (handle_t *, struct super_block *sb,
+					struct buffer_head *);
 extern void	 journal_sync_buffer (struct buffer_head *);
 extern int	 jbd2_journal_invalidatepage(journal_t *,
 				struct page *, unsigned int, unsigned int);
-- 
2.14.3
