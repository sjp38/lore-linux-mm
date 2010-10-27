Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC8BF6B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:16:49 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] Fix ext2 and ext4 buffer-head accounting.
Date: Wed, 27 Oct 2010 10:16:37 -0700
Message-Id: <1288199797-22541-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Paul Turner <pjt@google.com>
List-ID: <linux-mm.kvack.org>

Pages pinned to block group_descriptors in the super_block are non-reclaimable.
Those pages are showed up as file-backed in meminfo which confuse user program
issuing too many drop_caches/ttfp when this memory will never be freed.

The change has us not account for the file system descriptors by taking the pages
off LRU and decrementing the NR_FILE_PAGES counter. The pages are putting back when
the filesystem is being unmounted.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Paul Turner <pjt@google.com>
---
 fs/buffer.c                 |   44 +++++++++++++++++++++++++++++++++++++++++++
 fs/ext2/super.c             |   15 +++++++++++++-
 fs/ext4/super.c             |   12 ++++++++++-
 include/linux/buffer_head.h |    5 ++++
 4 files changed, 74 insertions(+), 2 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 3e7dca2..677d5f1 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -22,6 +22,8 @@
 #include <linux/syscalls.h>
 #include <linux/fs.h>
 #include <linux/mm.h>
+#include <linux/memcontrol.h>
+#include <linux/mm_inline.h>
 #include <linux/percpu.h>
 #include <linux/slab.h>
 #include <linux/capability.h>
@@ -3314,6 +3316,48 @@ int bh_submit_read(struct buffer_head *bh)
 }
 EXPORT_SYMBOL(bh_submit_read);
 
+void bh_disable_accounting(struct buffer_head *bh)
+{
+	struct page *page = bh->b_page;
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+
+	if (buffer_unaccounted(bh))
+		return;
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	/* If someone else is holding it off-LRU we can't safely do anything */
+	if (PageLRU(page)) {
+		BUG_ON(buffer_unaccounted(bh));
+		ClearPageLRU(page);
+		del_page_from_lru(zone, page);
+		__dec_zone_state(zone, NR_FILE_PAGES);
+		set_buffer_unaccounted(bh);
+	}
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+EXPORT_SYMBOL(bh_disable_accounting);
+
+void bh_enable_accounting(struct buffer_head *bh)
+{
+	struct page *page = bh->b_page;
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+
+	if (!buffer_unaccounted(bh))
+		return;
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	if (buffer_unaccounted(bh)) {
+		SetPageLRU(page);
+		add_page_to_lru_list(zone, page, LRU_INACTIVE_FILE);
+		__inc_zone_state(zone, NR_FILE_PAGES);
+		clear_buffer_unaccounted(bh);
+	}
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+EXPORT_SYMBOL(bh_enable_accounting);
+
 void __init buffer_init(void)
 {
 	int nrpages;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index 1ec6026..a4d21ce 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -29,6 +29,7 @@
 #include <linux/vfs.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
+#include <linux/swap.h>
 #include <linux/log2.h>
 #include <linux/quotaops.h>
 #include <asm/uaccess.h>
@@ -135,13 +136,16 @@ static void ext2_put_super (struct super_block * sb)
 	}
 	db_count = sbi->s_gdb_count;
 	for (i = 0; i < db_count; i++)
-		if (sbi->s_group_desc[i])
+		if (sbi->s_group_desc[i]) {
+			bh_enable_accounting(sbi->s_group_desc[i]);
 			brelse (sbi->s_group_desc[i]);
+		}
 	kfree(sbi->s_group_desc);
 	kfree(sbi->s_debts);
 	percpu_counter_destroy(&sbi->s_freeblocks_counter);
 	percpu_counter_destroy(&sbi->s_freeinodes_counter);
 	percpu_counter_destroy(&sbi->s_dirs_counter);
+	bh_enable_accounting(sbi->s_sbh);
 	brelse (sbi->s_sbh);
 	sb->s_fs_info = NULL;
 	kfree(sbi->s_blockgroup_lock);
@@ -1080,9 +1084,18 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 	if (EXT2_HAS_COMPAT_FEATURE(sb, EXT3_FEATURE_COMPAT_HAS_JOURNAL))
 		ext2_msg(sb, KERN_WARNING,
 			"warning: mounting ext3 filesystem as ext2");
+
 	if (ext2_setup_super (sb, es, sb->s_flags & MS_RDONLY))
 		sb->s_flags |= MS_RDONLY;
 	ext2_write_super(sb);
+
+	/* disable accounting of pinned file pages */
+	lru_add_drain_all();
+	db_count = sbi->s_gdb_count;
+	for (i = 0; i < db_count; i++)
+		bh_disable_accounting(sbi->s_group_desc[i]);
+	bh_disable_accounting(sbi->s_sbh);
+
 	return 0;
 
 cantfind_ext2:
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index 2614774..5203476 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -32,6 +32,7 @@
 #include <linux/vfs.h>
 #include <linux/random.h>
 #include <linux/mount.h>
+#include <linux/swap.h>
 #include <linux/namei.h>
 #include <linux/quotaops.h>
 #include <linux/seq_file.h>
@@ -734,8 +735,10 @@ static void ext4_put_super(struct super_block *sb)
 	}
 	kobject_del(&sbi->s_kobj);
 
-	for (i = 0; i < sbi->s_gdb_count; i++)
+	for (i = 0; i < sbi->s_gdb_count; i++) {
+		bh_enable_accounting(sbi->s_group_desc[i]);
 		brelse(sbi->s_group_desc[i]);
+	}
 	kfree(sbi->s_group_desc);
 	if (is_vmalloc_addr(sbi->s_flex_groups))
 		vfree(sbi->s_flex_groups);
@@ -745,6 +748,7 @@ static void ext4_put_super(struct super_block *sb)
 	percpu_counter_destroy(&sbi->s_freeinodes_counter);
 	percpu_counter_destroy(&sbi->s_dirs_counter);
 	percpu_counter_destroy(&sbi->s_dirtyblocks_counter);
+	bh_enable_accounting(sbi->s_sbh);
 	brelse(sbi->s_sbh);
 #ifdef CONFIG_QUOTA
 	for (i = 0; i < MAXQUOTAS; i++)
@@ -3129,6 +3133,12 @@ no_journal:
 		goto failed_mount4;
 	}
 
+	/* disable accounting of pinned file pages */
+	lru_add_drain_all();
+	for (i = 0; i < db_count; i++)
+		bh_disable_accounting(sbi->s_group_desc[i]);
+	bh_disable_accounting(sbi->s_sbh);
+
 	sbi->s_kobj.kset = ext4_kset;
 	init_completion(&sbi->s_kobj_unregister);
 	err = kobject_init_and_add(&sbi->s_kobj, &ext4_ktype, NULL,
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index ec94c12..7d48499 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -34,6 +34,7 @@ enum bh_state_bits {
 	BH_Write_EIO,	/* I/O error on write */
 	BH_Eopnotsupp,	/* operation not supported (barrier) */
 	BH_Unwritten,	/* Buffer is allocated on disk but not written */
+	BH_Unaccounted, /* Backing page has been removed from accounting */
 	BH_Quiet,	/* Buffer Error Prinks to be quiet */
 
 	BH_PrivateStart,/* not a state bit, but the first bit available
@@ -126,6 +127,7 @@ BUFFER_FNS(Boundary, boundary)
 BUFFER_FNS(Write_EIO, write_io_error)
 BUFFER_FNS(Eopnotsupp, eopnotsupp)
 BUFFER_FNS(Unwritten, unwritten)
+BUFFER_FNS(Unaccounted, unaccounted)
 
 #define bh_offset(bh)		((unsigned long)(bh)->b_data & ~PAGE_MASK)
 #define touch_buffer(bh)	mark_page_accessed(bh->b_page)
@@ -234,6 +236,9 @@ int nobh_truncate_page(struct address_space *, loff_t, get_block_t *);
 int nobh_writepage(struct page *page, get_block_t *get_block,
                         struct writeback_control *wbc);
 
+void bh_disable_accounting(struct buffer_head *bh);
+void bh_enable_accounting(struct buffer_head *bh);
+
 void buffer_init(void);
 
 /*
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
