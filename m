Message-Id: <20070816074626.739944000@chello.nl>
References: <20070816074525.065850000@chello.nl>
Date: Thu, 16 Aug 2007 09:45:34 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 09/23] lib: percpu_counter_init error handling
Content-Disposition: inline; filename=percpu_counter_init.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

alloc_percpu can fail, propagate that error.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/ext2/super.c                |   11 ++++++++---
 fs/ext3/super.c                |   11 ++++++++---
 fs/ext4/super.c                |   11 ++++++++---
 include/linux/percpu_counter.h |    5 +++--
 lib/percpu_counter.c           |    8 +++++++-
 5 files changed, 34 insertions(+), 12 deletions(-)

Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c
+++ linux-2.6/fs/ext2/super.c
@@ -725,6 +725,7 @@ static int ext2_fill_super(struct super_
 	int db_count;
 	int i, j;
 	__le32 features;
+	int err;
 
 	sbi = kzalloc(sizeof(*sbi), GFP_KERNEL);
 	if (!sbi)
@@ -996,12 +997,16 @@ static int ext2_fill_super(struct super_
 	sbi->s_rsv_window_head.rsv_goal_size = 0;
 	ext2_rsv_window_add(sb, &sbi->s_rsv_window_head);
 
-	percpu_counter_init(&sbi->s_freeblocks_counter,
+	err = percpu_counter_init(&sbi->s_freeblocks_counter,
 				ext2_count_free_blocks(sb));
-	percpu_counter_init(&sbi->s_freeinodes_counter,
+	err |= percpu_counter_init(&sbi->s_freeinodes_counter,
 				ext2_count_free_inodes(sb));
-	percpu_counter_init(&sbi->s_dirs_counter,
+	err |= percpu_counter_init(&sbi->s_dirs_counter,
 				ext2_count_dirs(sb));
+	if (err) {
+		printk(KERN_ERR "EXT2-fs: insufficient memory\n");
+		goto failed_mount3;
+	}
 	/*
 	 * set up enough so that it can read an inode
 	 */
Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c
+++ linux-2.6/fs/ext3/super.c
@@ -1485,6 +1485,7 @@ static int ext3_fill_super (struct super
 	int i;
 	int needs_recovery;
 	__le32 features;
+	int err;
 
 	sbi = kzalloc(sizeof(*sbi), GFP_KERNEL);
 	if (!sbi)
@@ -1745,12 +1746,16 @@ static int ext3_fill_super (struct super
 	get_random_bytes(&sbi->s_next_generation, sizeof(u32));
 	spin_lock_init(&sbi->s_next_gen_lock);
 
-	percpu_counter_init(&sbi->s_freeblocks_counter,
+	err = percpu_counter_init(&sbi->s_freeblocks_counter,
 		ext3_count_free_blocks(sb));
-	percpu_counter_init(&sbi->s_freeinodes_counter,
+	err |= percpu_counter_init(&sbi->s_freeinodes_counter,
 		ext3_count_free_inodes(sb));
-	percpu_counter_init(&sbi->s_dirs_counter,
+	err |= percpu_counter_init(&sbi->s_dirs_counter,
 		ext3_count_dirs(sb));
+	if (err) {
+		printk(KERN_ERR "EXT3-fs: insufficient memory\n");
+		goto failed_mount3;
+	}
 
 	/* per fileystem reservation list head & lock */
 	spin_lock_init(&sbi->s_rsv_window_lock);
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c
+++ linux-2.6/fs/ext4/super.c
@@ -1576,6 +1576,7 @@ static int ext4_fill_super (struct super
 	int needs_recovery;
 	__le32 features;
 	__u64 blocks_count;
+	int err;
 
 	sbi = kzalloc(sizeof(*sbi), GFP_KERNEL);
 	if (!sbi)
@@ -1857,12 +1858,16 @@ static int ext4_fill_super (struct super
 	get_random_bytes(&sbi->s_next_generation, sizeof(u32));
 	spin_lock_init(&sbi->s_next_gen_lock);
 
-	percpu_counter_init(&sbi->s_freeblocks_counter,
+	err = percpu_counter_init(&sbi->s_freeblocks_counter,
 		ext4_count_free_blocks(sb));
-	percpu_counter_init(&sbi->s_freeinodes_counter,
+	err |= percpu_counter_init(&sbi->s_freeinodes_counter,
 		ext4_count_free_inodes(sb));
-	percpu_counter_init(&sbi->s_dirs_counter,
+	err |= percpu_counter_init(&sbi->s_dirs_counter,
 		ext4_count_dirs(sb));
+	if (err) {
+		printk(KERN_ERR "EXT4-fs: insufficient memory\n");
+		goto failed_mount3;
+	}
 
 	/* per fileystem reservation list head & lock */
 	spin_lock_init(&sbi->s_rsv_window_lock);
Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h
+++ linux-2.6/include/linux/percpu_counter.h
@@ -30,7 +30,7 @@ struct percpu_counter {
 #define FBC_BATCH	(NR_CPUS*4)
 #endif
 
-void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
+int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
 void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
@@ -78,9 +78,10 @@ struct percpu_counter {
 	s64 count;
 };
 
-static inline void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
+static inline int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {
 	fbc->count = amount;
+	return 0;
 }
 
 static inline void percpu_counter_destroy(struct percpu_counter *fbc)
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c
+++ linux-2.6/lib/percpu_counter.c
@@ -68,21 +68,27 @@ s64 __percpu_counter_sum(struct percpu_c
 }
 EXPORT_SYMBOL(__percpu_counter_sum);
 
-void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
+int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {
 	spin_lock_init(&fbc->lock);
 	fbc->count = amount;
 	fbc->counters = alloc_percpu(s32);
+	if (!fbc->counters)
+		return -ENOMEM;
 #ifdef CONFIG_HOTPLUG_CPU
 	mutex_lock(&percpu_counters_lock);
 	list_add(&fbc->list, &percpu_counters);
 	mutex_unlock(&percpu_counters_lock);
 #endif
+	return 0;
 }
 EXPORT_SYMBOL(percpu_counter_init);
 
 void percpu_counter_destroy(struct percpu_counter *fbc)
 {
+	if (!fbc->counters)
+		return;
+
 	free_percpu(fbc->counters);
 #ifdef CONFIG_HOTPLUG_CPU
 	mutex_lock(&percpu_counters_lock);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
