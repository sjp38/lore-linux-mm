Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF0036B0253
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:18 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z128so15359709qka.8
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:18 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l193si5256401qke.225.2018.04.04.12.19.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:17 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 34/79] fs/journal: add struct inode to jbd2_journal_revoke() arguments.
Date: Wed,  4 Apr 2018 15:18:08 -0400
Message-Id: <20180404191831.5378-19-jglisse@redhat.com>
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
struct super_block to jbd2_journal_revoke() arguments.

spatch --sp-file zemantic-011a.spatch --in-place --dir fs/
----------------------------------------------------------------------
@exists@
expression E1, E2, E3;
identifier I;
@@
struct super_block *I;
...
-jbd2_journal_revoke(E1, E2, E3)
+jbd2_journal_revoke(E1, E2, I, E3)

@exists@
expression E1, E2, E3;
identifier F, I;
@@
F(..., struct super_block *I, ...) {
...
-jbd2_journal_revoke(E1, E2, E3)
+jbd2_journal_revoke(E1, E2, I, E3)
...
}

@exists@
expression E1, E2, E3;
identifier I;
@@
struct inode *I;
...
-jbd2_journal_revoke(E1, E2, E3)
+jbd2_journal_revoke(E1, E2, I->i_sb, E3)

@exists@
expression E1, E2, E3;
identifier F, I;
@@
F(..., struct inode *I, ...) {
...
-jbd2_journal_revoke(E1, E2, E3)
+jbd2_journal_revoke(E1, E2, I->i_sb, E3)
...
}
----------------------------------------------------------------------

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Jan Kara <jack@suse.com>
Cc: linux-ext4@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 fs/ext4/ext4_jbd2.c  | 2 +-
 fs/jbd2/revoke.c     | 2 +-
 include/linux/jbd2.h | 3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/ext4/ext4_jbd2.c b/fs/ext4/ext4_jbd2.c
index 0804d564b529..5529badca994 100644
--- a/fs/ext4/ext4_jbd2.c
+++ b/fs/ext4/ext4_jbd2.c
@@ -237,7 +237,7 @@ int __ext4_forget(const char *where, unsigned int line, handle_t *handle,
 	 * data!=journal && (is_metadata || should_journal_data(inode))
 	 */
 	BUFFER_TRACE(bh, "call jbd2_journal_revoke");
-	err = jbd2_journal_revoke(handle, blocknr, bh);
+	err = jbd2_journal_revoke(handle, blocknr, inode->i_sb, bh);
 	if (err) {
 		ext4_journal_abort_handle(where, line, __func__,
 					  bh, handle, err);
diff --git a/fs/jbd2/revoke.c b/fs/jbd2/revoke.c
index b6e2fd52acd6..71e690ad9d44 100644
--- a/fs/jbd2/revoke.c
+++ b/fs/jbd2/revoke.c
@@ -320,7 +320,7 @@ void jbd2_journal_destroy_revoke(journal_t *journal)
  */
 
 int jbd2_journal_revoke(handle_t *handle, unsigned long long blocknr,
-		   struct buffer_head *bh_in)
+			struct super_block *sb, struct buffer_head *bh_in)
 {
 	struct buffer_head *bh = NULL;
 	journal_t *journal;
diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
index d89749a179eb..c5133df80fd4 100644
--- a/include/linux/jbd2.h
+++ b/include/linux/jbd2.h
@@ -1450,7 +1450,8 @@ extern void	   jbd2_journal_destroy_revoke_caches(void);
 extern int	   jbd2_journal_init_revoke_caches(void);
 
 extern void	   jbd2_journal_destroy_revoke(journal_t *);
-extern int	   jbd2_journal_revoke (handle_t *, unsigned long long, struct buffer_head *);
+extern int	   jbd2_journal_revoke (handle_t *, unsigned long long,
+				struct super_block *, struct buffer_head *);
 extern int	   jbd2_journal_cancel_revoke(handle_t *, struct journal_head *);
 extern void	   jbd2_journal_write_revoke_records(transaction_t *transaction,
 						     struct list_head *log_bufs);
-- 
2.14.3
