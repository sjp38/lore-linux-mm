Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D42816B0289
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id e4so178338816pfg.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:57 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j24si1230799pfk.32.2017.01.26.03.58.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:56 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 37/37] ext4, vfs: add huge= mount option
Date: Thu, 26 Jan 2017 14:58:19 +0300
Message-Id: <20170126115819.58875-38-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The same four values as in tmpfs case.

Encyption code is not yet ready to handle huge page, so we disable huge
pages support if the inode has EXT4_INODE_ENCRYPT.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/ext4.h  |  5 +++++
 fs/ext4/inode.c | 32 +++++++++++++++++++++++---------
 fs/ext4/super.c | 24 ++++++++++++++++++++++++
 3 files changed, 52 insertions(+), 9 deletions(-)

diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index 2163c1e69f2a..19bb9995fa96 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1134,6 +1134,11 @@ struct ext4_inode_info {
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
index e24ccf4c3694..120d32bcb6af 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4481,7 +4481,7 @@ int ext4_get_inode_loc(struct inode *inode, struct ext4_iloc *iloc)
 void ext4_set_inode_flags(struct inode *inode)
 {
 	unsigned int flags = EXT4_I(inode)->i_flags;
-	unsigned int new_fl = 0;
+	unsigned int mask, new_fl = 0;
 
 	if (flags & EXT4_SYNC_FL)
 		new_fl |= S_SYNC;
@@ -4493,11 +4493,25 @@ void ext4_set_inode_flags(struct inode *inode)
 		new_fl |= S_NOATIME;
 	if (flags & EXT4_DIRSYNC_FL)
 		new_fl |= S_DIRSYNC;
-	if (test_opt(inode->i_sb, DAX) && S_ISREG(inode->i_mode) &&
-	    !ext4_should_journal_data(inode) && !ext4_has_inline_data(inode) &&
-	    !ext4_encrypted_inode(inode))
-		new_fl |= S_DAX;
-
+	if (S_ISREG(inode->i_mode) && !ext4_encrypted_inode(inode)) {
+		if (test_opt(inode->i_sb, DAX) &&
+				!ext4_should_journal_data(inode) &&
+				!ext4_has_inline_data(inode))
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
 	if ((new_fl & S_HUGE_MODE) != S_HUGE_NEVER &&
 			EXT4_JOURNAL(inode) != NULL) {
 		int bpp = __ext4_journal_blocks_per_page(inode, true);
@@ -4511,9 +4525,9 @@ void ext4_set_inode_flags(struct inode *inode)
 			new_fl &= ~S_HUGE_MODE;
 		}
 	}
-
-	inode_set_flags(inode, new_fl,
-			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX);
+	mask = S_SYNC | S_APPEND | S_IMMUTABLE | S_NOATIME |
+		S_DIRSYNC | S_DAX | S_HUGE_MODE;
+	inode_set_flags(inode, new_fl, mask);
 }
 
 /* Propagate flags from i_flags to EXT4_I(inode)->i_flags */
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 66845a08a87a..13376a72050c 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1296,6 +1296,7 @@ enum {
 	Opt_dioread_nolock, Opt_dioread_lock,
 	Opt_discard, Opt_nodiscard, Opt_init_itable, Opt_noinit_itable,
 	Opt_max_dir_size_kb, Opt_nojournal_checksum,
+	Opt_huge_never, Opt_huge_always, Opt_huge_within_size, Opt_huge_advise,
 };
 
 static const match_table_t tokens = {
@@ -1376,6 +1377,10 @@ static const match_table_t tokens = {
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
@@ -1494,6 +1499,11 @@ static int clear_qf_name(struct super_block *sb, int qtype)
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
@@ -1581,6 +1591,10 @@ static const struct mount_opts {
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
@@ -1662,6 +1676,16 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 		} else
 			return -1;
 	}
+	if (MOPT_HUGE != MOPT_NOSUPPORT && m->flags & MOPT_HUGE) {
+		sbi->s_mount_opt &= ~EXT4_MOUNT_HUGE_MODE;
+		sbi->s_mount_opt |= m->mount_opt;
+		if (m->mount_opt) {
+			ext4_msg(sb, KERN_WARNING, "Warning: "
+					"Support of huge pages is EXPERIMENTAL,"
+					" use at your own risk");
+		}
+		return 1;
+	}
 	if (m->flags & MOPT_CLEAR_ERR)
 		clear_opt(sb, ERRORS_MASK);
 	if (token == Opt_noquota && sb_any_quota_loaded(sb)) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
