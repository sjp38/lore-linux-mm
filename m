Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC978D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 03:38:33 -0500 (EST)
Received: by gxk2 with SMTP id 2so2950066gxk.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 00:38:26 -0800 (PST)
From: Liu Yuan <namei.unix@gmail.com>
Subject: [RFC PATCH 2/5] block: Add functions and data types for Page Cache Accounting
Date: Wed,  2 Mar 2011 16:38:07 +0800
Message-Id: <1299055090-23976-2-git-send-email-namei.unix@gmail.com>
In-Reply-To: <no>
References: <no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

From: Liu Yuan <tailai.ly@taobao.com>

These functions and data types are based on the percpu
disk stats infrastructure.

Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
---
 include/linux/genhd.h |   56 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 56 insertions(+), 0 deletions(-)

diff --git a/include/linux/genhd.h b/include/linux/genhd.h
index c0d5f69..4f0257c 100644
--- a/include/linux/genhd.h
+++ b/include/linux/genhd.h
@@ -86,6 +86,11 @@ struct disk_stats {
 	unsigned long ticks[2];
 	unsigned long io_ticks;
 	unsigned long time_in_queue;
+#ifdef CONFIG_PAGE_CACHE_ACCT
+	unsigned long page_cache_readpages;
+	unsigned long page_cache_hit[2];
+	unsigned long page_cache_missed[2];
+#endif
 };
 
 #define PARTITION_META_INFO_VOLNAMELTH	64
@@ -400,6 +405,57 @@ static inline void free_part_info(struct hd_struct *part)
 	kfree(part->info);
 }
 
+#ifdef CONFIG_PAGE_CACHE_ACCT
+static inline void page_cache_acct_readpages(struct super_block *sb, int nr_pages)
+{
+	struct block_device *bdev = sb->s_bdev;
+	struct hd_struct *part;
+	int cpu;
+	if (likely(bdev) && likely(part = bdev->bd_part)) {
+		cpu = part_stat_lock();
+		part_stat_add(cpu, part, page_cache_readpages, nr_pages);
+		part_stat_unlock();
+	}
+}
+static inline void page_cache_acct_hit(struct super_block *sb, int rw)
+{
+	struct block_device *bdev = sb->s_bdev;
+	struct hd_struct *part;
+	int cpu;
+	if (likely(bdev) && likely(part = bdev->bd_part)) {
+		cpu = part_stat_lock();
+		part_stat_inc(cpu, part, page_cache_hit[rw]);
+		part_stat_unlock();
+	}
+}
+
+static inline void page_cache_acct_missed(struct super_block *sb, int rw)
+{
+	struct block_device *bdev = sb->s_bdev;
+	struct hd_struct *part;
+	int cpu;
+	if (likely(bdev) && likely(part = bdev->bd_part)) {
+		cpu = part_stat_lock();
+		part_stat_inc(cpu, part, page_cache_missed[rw]);
+		part_stat_unlock();
+	}
+}
+
+#else /* !CONFIG_PAGE_CACHE_ACCT */
+static inline void page_cache_acct_readpages(struct super_block *sb, int nr_pages)
+{
+}
+
+static inline void page_cache_acct_hit(struct super_block *sb, int rw)
+{
+}
+
+static inline void page_cache_acct_missed(struct super_block *sb, int rw)
+{
+}
+
+#endif /* CONFIG_PAGE_CACHE_ACCT */
+
 /* block/blk-core.c */
 extern void part_round_stats(int cpu, struct hd_struct *part);
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
