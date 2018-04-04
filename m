Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67D1F6B027D
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:29 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q15so12352722qkj.3
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c14si4476714qtn.164.2018.04.04.12.19.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:28 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 69/79] fs/journal: add struct address_space to jbd2_journal_try_to_free_buffers() arguments
Date: Wed,  4 Apr 2018 15:18:21 -0400
Message-Id: <20180404191831.5378-32-jglisse@redhat.com>
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
struct address_space to jbd2_journal_try_to_free_buffers() arguments.

<---------------------------------------------------------------------
@@
type T1, T2, T3;
@@
int
-jbd2_journal_try_to_free_buffers(T1 journal, T2 page, T3 gfp_mask)
+jbd2_journal_try_to_free_buffers(T1 journal, struct address_space *mapping, T2 page, T3 gfp_mask)
{...}

@@
type T1, T2, T3;
@@
int
-jbd2_journal_try_to_free_buffers(T1, T2, T3)
+jbd2_journal_try_to_free_buffers(T1, struct address_space *, T2, T3)
;

@@
expression E1, E2, E3;
@@
-jbd2_journal_try_to_free_buffers(E1, E2, E3)
+jbd2_journal_try_to_free_buffers(E1, NULL, E2, E3)
--------------------------------------------------------------------->

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: "Theodore Ts'o" <tytso@mit.edu>
Cc: Jan Kara <jack@suse.com>
Cc: linux-ext4@vger.kernel.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
---
 fs/ext4/inode.c       | 3 ++-
 fs/ext4/super.c       | 4 ++--
 fs/jbd2/transaction.c | 3 ++-
 include/linux/jbd2.h  | 4 +++-
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 1a44d9acde53..ef53a57d9768 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3413,7 +3413,8 @@ static int ext4_releasepage(struct address_space *mapping,
 	if (PageChecked(page))
 		return 0;
 	if (journal)
-		return jbd2_journal_try_to_free_buffers(journal, page, wait);
+		return jbd2_journal_try_to_free_buffers(journal, NULL, page,
+						        wait);
 	else
 		return try_to_free_buffers(mapping, page);
 }
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 8f98bc886569..cf2b74137fb2 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1138,8 +1138,8 @@ static int bdev_try_to_free_page(struct super_block *sb, struct page *page,
 	if (!_page_has_buffers(page, mapping))
 		return 0;
 	if (journal)
-		return jbd2_journal_try_to_free_buffers(journal, page,
-						wait & ~__GFP_DIRECT_RECLAIM);
+		return jbd2_journal_try_to_free_buffers(journal, NULL, page,
+							wait & ~__GFP_DIRECT_RECLAIM);
 	return try_to_free_buffers(mapping, page);
 }
 
diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
index bf673b33d436..6899e7b4036d 100644
--- a/fs/jbd2/transaction.c
+++ b/fs/jbd2/transaction.c
@@ -1984,7 +1984,8 @@ __journal_try_to_free_buffer(journal_t *journal, struct buffer_head *bh)
  * Return 0 on failure, 1 on success
  */
 int jbd2_journal_try_to_free_buffers(journal_t *journal,
-				struct page *page, gfp_t gfp_mask)
+				     struct address_space *mapping,
+				     struct page *page, gfp_t gfp_mask)
 {
 	struct buffer_head *head;
 	struct buffer_head *bh;
diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
index c5133df80fd4..658a0d2f758f 100644
--- a/include/linux/jbd2.h
+++ b/include/linux/jbd2.h
@@ -1363,7 +1363,9 @@ extern int	 jbd2_journal_forget (handle_t *, struct super_block *sb,
 extern void	 journal_sync_buffer (struct buffer_head *);
 extern int	 jbd2_journal_invalidatepage(journal_t *,
 				struct page *, unsigned int, unsigned int);
-extern int	 jbd2_journal_try_to_free_buffers(journal_t *, struct page *, gfp_t);
+extern int	 jbd2_journal_try_to_free_buffers(journal_t *,
+						    struct address_space *,
+						    struct page *, gfp_t);
 extern int	 jbd2_journal_stop(handle_t *);
 extern int	 jbd2_journal_flush (journal_t *);
 extern void	 jbd2_journal_lock_updates (journal_t *);
-- 
2.14.3
