Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41283828E4
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:37:05 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ez1so359942506pab.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:37:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id u3si36044024pay.67.2016.07.25.17.36.33
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 33/33] ext4, vfs: add huge= mount option
Date: Tue, 26 Jul 2016 03:35:35 +0300
Message-Id: <1469493335-3622-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The same four values as in tmpfs case.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/ext4.h  |  5 +++++
 fs/ext4/inode.c | 26 +++++++++++++++++++++-----
 fs/ext4/super.c | 19 +++++++++++++++++++
 3 files changed, 45 insertions(+), 5 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index ea31931386ec..feece2d1f646 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1123,6 +1123,11 @@ struct ext4_inode_info {
 #define EXT4_MOUNT_DIOREAD_NOLOCK	0x400000 /* Enable support for dio read nolocking */
 #define EXT4_MOUNT_JOURNAL_CHECKSUM	0x800000 /* Journal checksums */
 #define EXT4_MOUNT_JOURNAL_ASYNC_COMMIT	0x1000000 /* Journal Async Commit */
+#define EXT4_MOUNT_HUGE_MODE		0x6000000 /* Huge support mode: */
+#define EXT4_MOUNT_HUGE_NEVER		0x0000000
+#define EXT4_MOUNT_HUGE_ALWAYS		0x2000000
+#define EXT4_MOUNT_HUGE_WITHIN_SIZE	0x4000000
+#define EXT4_MOUNT_HUGE_ADVISE		0x6000000
 #define EXT4_MOUNT_DELALLOC		0x8000000 /* Delalloc support */
 #define EXT4_MOUNT_DATA_ERR_ABORT	0x10000000 /* Abort on file data write */
 #define EXT4_MOUNT_BLOCK_VALIDITY	0x20000000 /* Block validity checking */
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 7c53e490849f..9219734fc7cd 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4348,7 +4348,7 @@ int ext4_get_inode_loc(struct inode *inode, struct ext4_iloc *iloc)
 void ext4_set_inode_flags(struct inode *inode)
 {
 	unsigned int flags = EXT4_I(inode)->i_flags;
-	unsigned int new_fl = 0;
+	unsigned int mask, new_fl = 0;
 
 	if (flags & EXT4_SYNC_FL)
 		new_fl |= S_SYNC;
@@ -4360,10 +4360,26 @@ void ext4_set_inode_flags(struct inode *inode)
 		new_fl |= S_NOATIME;
 	if (flags & EXT4_DIRSYNC_FL)
 		new_fl |= S_DIRSYNC;
-	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode))
-		new_fl |= S_DAX;
-	inode_set_flags(inode, new_fl,
-			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX);
+	if (S_ISREG(inode->i_mode)) {
+		if (test_opt(inode->i_sb, DAX))
+			new_fl |= S_DAX;
+		switch (test_opt(inode->i_sb, HUGE_MODE)) {
+		case EXT4_MOUNT_HUGE_NEVER:
+			break;
+		case EXT4_MOUNT_HUGE_ALWAYS:
+			new_fl |= S_HUGE_ALWAYS;
+			break;
+		case EXT4_MOUNT_HUGE_WITHIN_SIZE:
+			new_fl |= S_HUGE_WITHIN_SIZE;
+			break;
+		case EXT4_MOUNT_HUGE_ADVISE:
+			new_fl |= S_HUGE_ADVISE;
+			break;
+		}
+	}
+	mask = S_SYNC | S_APPEND | S_IMMUTABLE | S_NOATIME |
+		S_DIRSYNC | S_DAX | S_HUGE_MODE;
+	inode_set_flags(inode, new_fl, mask);
 }
 
 /* Propagate flags from i_flags to EXT4_I(inode)->i_flags */
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 1c593aa0218e..0c6ae81f6c1c 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1275,6 +1275,7 @@ enum {
 	Opt_dioread_nolock, Opt_dioread_lock,
 	Opt_discard, Opt_nodiscard, Opt_init_itable, Opt_noinit_itable,
 	Opt_max_dir_size_kb, Opt_nojournal_checksum,
+	Opt_huge_never, Opt_huge_always, Opt_huge_within_size, Opt_huge_advise,
 };
 
 static const match_table_t tokens = {
@@ -1354,6 +1355,10 @@ static const match_table_t tokens = {
 	{Opt_init_itable, "init_itable"},
 	{Opt_noinit_itable, "noinit_itable"},
 	{Opt_max_dir_size_kb, "max_dir_size_kb=%u"},
+	{Opt_huge_never, "huge=never"},
+	{Opt_huge_always, "huge=always"},
+	{Opt_huge_within_size, "huge=within_size"},
+	{Opt_huge_advise, "huge=advise"},
 	{Opt_test_dummy_encryption, "test_dummy_encryption"},
 	{Opt_removed, "check=none"},	/* mount option from ext2/3 */
 	{Opt_removed, "nocheck"},	/* mount option from ext2/3 */
@@ -1472,6 +1477,11 @@ static int clear_qf_name(struct super_block *sb, int qtype)
 #define MOPT_NO_EXT3	0x0200
 #define MOPT_EXT4_ONLY	(MOPT_NO_EXT2 | MOPT_NO_EXT3)
 #define MOPT_STRING	0x0400
+#ifdef CONFIG_TRANSPARENT_HUGE_PAGECACHE
+#define MOPT_HUGE	0x1000
+#else
+#define MOPT_HUGE	MOPT_NOSUPPORT
+#endif
 
 static const struct mount_opts {
 	int	token;
@@ -1556,6 +1566,10 @@ static const struct mount_opts {
 	{Opt_jqfmt_vfsv0, QFMT_VFS_V0, MOPT_QFMT},
 	{Opt_jqfmt_vfsv1, QFMT_VFS_V1, MOPT_QFMT},
 	{Opt_max_dir_size_kb, 0, MOPT_GTE0},
+	{Opt_huge_never, EXT4_MOUNT_HUGE_NEVER, MOPT_HUGE},
+	{Opt_huge_always, EXT4_MOUNT_HUGE_ALWAYS, MOPT_HUGE},
+	{Opt_huge_within_size, EXT4_MOUNT_HUGE_WITHIN_SIZE, MOPT_HUGE},
+	{Opt_huge_advise, EXT4_MOUNT_HUGE_ADVISE, MOPT_HUGE},
 	{Opt_test_dummy_encryption, 0, MOPT_GTE0},
 	{Opt_err, 0, 0}
 };
@@ -1637,6 +1651,11 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		} else
 			return -1;
 	}
+	if (MOPT_HUGE != MOPT_NOSUPPORT && m->flags & MOPT_HUGE) {
+		sbi->s_mount_opt &= ~EXT4_MOUNT_HUGE_MODE;
+		sbi->s_mount_opt |= m->mount_opt;
+		return 1;
+	}
 	if (m->flags & MOPT_CLEAR_ERR)
 		clear_opt(sb, ERRORS_MASK);
 	if (token == Opt_noquota && sb_any_quota_loaded(sb)) {
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
