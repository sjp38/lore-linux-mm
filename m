Message-Id: <20070816074626.229992000@chello.nl>
References: <20070816074525.065850000@chello.nl>
Date: Thu, 16 Aug 2007 09:45:32 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 07/23] lib: percpu_counter_sum_positive
Content-Disposition: inline; filename=percpu_counter_sum_positive.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Because its consitent with percpu_counter_read*

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/ext3/super.c                |    4 ++--
 fs/ext4/super.c                |    4 ++--
 fs/file_table.c                |    2 +-
 include/linux/percpu_counter.h |    4 ++--
 lib/percpu_counter.c           |    4 ++--
 5 files changed, 9 insertions(+), 9 deletions(-)

Index: linux-2.6/fs/ext3/super.c
===================================================================
--- linux-2.6.orig/fs/ext3/super.c
+++ linux-2.6/fs/ext3/super.c
@@ -2472,13 +2472,13 @@ static int ext3_statfs (struct dentry * 
 	buf->f_type = EXT3_SUPER_MAGIC;
 	buf->f_bsize = sb->s_blocksize;
 	buf->f_blocks = le32_to_cpu(es->s_blocks_count) - sbi->s_overhead_last;
-	buf->f_bfree = percpu_counter_sum(&sbi->s_freeblocks_counter);
+	buf->f_bfree = percpu_counter_sum_positive(&sbi->s_freeblocks_counter);
 	es->s_free_blocks_count = cpu_to_le32(buf->f_bfree);
 	buf->f_bavail = buf->f_bfree - le32_to_cpu(es->s_r_blocks_count);
 	if (buf->f_bfree < le32_to_cpu(es->s_r_blocks_count))
 		buf->f_bavail = 0;
 	buf->f_files = le32_to_cpu(es->s_inodes_count);
-	buf->f_ffree = percpu_counter_sum(&sbi->s_freeinodes_counter);
+	buf->f_ffree = percpu_counter_sum_positive(&sbi->s_freeinodes_counter);
 	es->s_free_inodes_count = cpu_to_le32(buf->f_ffree);
 	buf->f_namelen = EXT3_NAME_LEN;
 	fsid = le64_to_cpup((void *)es->s_uuid) ^
Index: linux-2.6/fs/ext4/super.c
===================================================================
--- linux-2.6.orig/fs/ext4/super.c
+++ linux-2.6/fs/ext4/super.c
@@ -2592,13 +2592,13 @@ static int ext4_statfs (struct dentry * 
 	buf->f_type = EXT4_SUPER_MAGIC;
 	buf->f_bsize = sb->s_blocksize;
 	buf->f_blocks = ext4_blocks_count(es) - sbi->s_overhead_last;
-	buf->f_bfree = percpu_counter_sum(&sbi->s_freeblocks_counter);
+	buf->f_bfree = percpu_counter_sum_positive(&sbi->s_freeblocks_counter);
 	es->s_free_blocks_count = cpu_to_le32(buf->f_bfree);
 	buf->f_bavail = buf->f_bfree - ext4_r_blocks_count(es);
 	if (buf->f_bfree < ext4_r_blocks_count(es))
 		buf->f_bavail = 0;
 	buf->f_files = le32_to_cpu(es->s_inodes_count);
-	buf->f_ffree = percpu_counter_sum(&sbi->s_freeinodes_counter);
+	buf->f_ffree = percpu_counter_sum_positive(&sbi->s_freeinodes_counter);
 	es->s_free_inodes_count = cpu_to_le32(buf->f_ffree);
 	buf->f_namelen = EXT4_NAME_LEN;
 	fsid = le64_to_cpup((void *)es->s_uuid) ^
Index: linux-2.6/fs/file_table.c
===================================================================
--- linux-2.6.orig/fs/file_table.c
+++ linux-2.6/fs/file_table.c
@@ -98,7 +98,7 @@ struct file *get_empty_filp(void)
 		 * percpu_counters are inaccurate.  Do an expensive check before
 		 * we go and fail.
 		 */
-		if (percpu_counter_sum(&nr_files) >= files_stat.max_files)
+		if (percpu_counter_sum_positive(&nr_files) >= files_stat.max_files)
 			goto over;
 	}
 
Index: linux-2.6/include/linux/percpu_counter.h
===================================================================
--- linux-2.6.orig/include/linux/percpu_counter.h
+++ linux-2.6/include/linux/percpu_counter.h
@@ -34,7 +34,7 @@ void percpu_counter_init(struct percpu_c
 void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
-s64 percpu_counter_sum(struct percpu_counter *fbc);
+s64 percpu_counter_sum_positive(struct percpu_counter *fbc);
 
 static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
@@ -102,7 +102,7 @@ static inline s64 percpu_counter_read_po
 	return fbc->count;
 }
 
-static inline s64 percpu_counter_sum(struct percpu_counter *fbc)
+static inline s64 percpu_counter_sum_positive(struct percpu_counter *fbc)
 {
 	return percpu_counter_read_positive(fbc);
 }
Index: linux-2.6/lib/percpu_counter.c
===================================================================
--- linux-2.6.orig/lib/percpu_counter.c
+++ linux-2.6/lib/percpu_counter.c
@@ -52,7 +52,7 @@ EXPORT_SYMBOL(__percpu_counter_add);
  * Add up all the per-cpu counts, return the result.  This is a more accurate
  * but much slower version of percpu_counter_read_positive()
  */
-s64 percpu_counter_sum(struct percpu_counter *fbc)
+s64 percpu_counter_sum_positive(struct percpu_counter *fbc)
 {
 	s64 ret;
 	int cpu;
@@ -66,7 +66,7 @@ s64 percpu_counter_sum(struct percpu_cou
 	spin_unlock(&fbc->lock);
 	return ret < 0 ? 0 : ret;
 }
-EXPORT_SYMBOL(percpu_counter_sum);
+EXPORT_SYMBOL(percpu_counter_sum_positive);
 
 void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
