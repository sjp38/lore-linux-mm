Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3E136B0285
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:58:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 14so307857556pgg.4
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:58:55 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id q83si1234036pfa.19.2017.01.26.03.58.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:58:55 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 35/37] ext4: reserve larger jounral transaction for huge pages
Date: Thu, 26 Jan 2017 14:58:17 +0300
Message-Id: <20170126115819.58875-36-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
References: <20170126115819.58875-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If huge pages enabled, in worst case with 2048 blocks underlying a page,
each possibly in a different block group we have much more metadata to
commit.

Let's update estimates accordingly.

I was not able to trigger bad situation without the patch as it's hard to
construct very fragmented filesystem, but hopefully this change would be
enough to address the concern.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/ext4/ext4_jbd2.h | 16 +++++++++++++---
 fs/ext4/inode.c     | 34 +++++++++++++++++++++++++++-------
 2 files changed, 40 insertions(+), 10 deletions(-)

diff --git a/fs/ext4/ext4_jbd2.h b/fs/ext4/ext4_jbd2.h
index f97611171023..6e4e534d6e98 100644
--- a/fs/ext4/ext4_jbd2.h
+++ b/fs/ext4/ext4_jbd2.h
@@ -353,11 +353,21 @@ static inline int ext4_journal_restart(handle_t *handle, int nblocks)
 	return 0;
 }
 
+static inline int __ext4_journal_blocks_per_page(struct inode *inode, bool thp)
+{
+	int bpp = 0;
+	if (EXT4_JOURNAL(inode) != NULL) {
+		bpp = jbd2_journal_blocks_per_page(inode);
+		if (thp)
+			bpp <<= HPAGE_PMD_ORDER;
+	}
+	return bpp;
+}
+
 static inline int ext4_journal_blocks_per_page(struct inode *inode)
 {
-	if (EXT4_JOURNAL(inode) != NULL)
-		return jbd2_journal_blocks_per_page(inode);
-	return 0;
+	return __ext4_journal_blocks_per_page(inode,
+			(inode->i_flags & S_HUGE_MODE) != S_HUGE_NEVER);
 }
 
 static inline int ext4_journal_force_commit(journal_t *journal)
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5bf68bbe65ec..c30562b6e685 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -141,6 +141,7 @@ static int __ext4_journalled_writepage(struct page *page, unsigned int len);
 static int ext4_bh_delay_or_unwritten(handle_t *handle, struct buffer_head *bh);
 static int ext4_meta_trans_blocks(struct inode *inode, int lblocks,
 				  int pextents);
+static int __ext4_writepage_trans_blocks(struct inode *inode, int bpp);
 
 /*
  * Test whether an inode is a fast symlink.
@@ -4496,6 +4497,21 @@ void ext4_set_inode_flags(struct inode *inode)
 	    !ext4_should_journal_data(inode) && !ext4_has_inline_data(inode) &&
 	    !ext4_encrypted_inode(inode))
 		new_fl |= S_DAX;
+
+	if ((new_fl & S_HUGE_MODE) != S_HUGE_NEVER &&
+			EXT4_JOURNAL(inode) != NULL) {
+		int bpp = __ext4_journal_blocks_per_page(inode, true);
+		int credits = __ext4_writepage_trans_blocks(inode, bpp);
+
+		if (EXT4_JOURNAL(inode)->j_max_transaction_buffers < credits) {
+			pr_warn_once("EXT4-fs (%s): "
+					"journal is too small for huge pages. "
+					"Disable huge pages support.\n",
+					inode->i_sb->s_id);
+			new_fl &= ~S_HUGE_MODE;
+		}
+	}
+
 	inode_set_flags(inode, new_fl,
 			S_SYNC|S_APPEND|S_IMMUTABLE|S_NOATIME|S_DIRSYNC|S_DAX);
 }
@@ -5471,6 +5487,16 @@ static int ext4_meta_trans_blocks(struct inode *inode, int lblocks,
 	return ret;
 }
 
+static int __ext4_writepage_trans_blocks(struct inode *inode, int bpp)
+{
+	int ret = ext4_meta_trans_blocks(inode, bpp, bpp);
+
+	/* Account for data blocks for journalled mode */
+	if (ext4_should_journal_data(inode))
+		ret += bpp;
+	return ret;
+}
+
 /*
  * Calculate the total number of credits to reserve to fit
  * the modification of a single pages into a single transaction,
@@ -5484,14 +5510,8 @@ static int ext4_meta_trans_blocks(struct inode *inode, int lblocks,
 int ext4_writepage_trans_blocks(struct inode *inode)
 {
 	int bpp = ext4_journal_blocks_per_page(inode);
-	int ret;
-
-	ret = ext4_meta_trans_blocks(inode, bpp, bpp);
 
-	/* Account for data blocks for journalled mode */
-	if (ext4_should_journal_data(inode))
-		ret += bpp;
-	return ret;
+	return __ext4_writepage_trans_blocks(inode, bpp);
 }
 
 /*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
