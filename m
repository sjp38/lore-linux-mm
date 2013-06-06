Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 8DD1D6B0034
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:32 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 01/25] fs: bump inode and dentry counters to long
Date: Fri,  7 Jun 2013 00:34:34 +0400
Message-Id: <1370550898-26711-2-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>

There are situations in very large machines in which we can have a large
quantity of dirty inodes, unused dentries, etc. This is particularly
true when umounting a filesystem, where eventually since every live
object will eventually be discarded.

Dave Chinner reported a problem with this while experimenting with the
shrinker revamp patchset. So we believe it is time for a change. This
patch just moves int to longs. Machines where it matters should have a
big long anyway.

Signed-off-by: Glauber Costa <glommer@openvz.org>
CC: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c             |  8 ++++----
 fs/inode.c              | 18 +++++++++---------
 fs/internal.h           |  2 +-
 include/linux/dcache.h  | 10 +++++-----
 include/linux/fs.h      |  4 ++--
 include/uapi/linux/fs.h |  6 +++---
 kernel/sysctl.c         |  6 +++---
 7 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f09b908..aca4e4b 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -117,13 +117,13 @@ struct dentry_stat_t dentry_stat = {
 	.age_limit = 45,
 };
 
-static DEFINE_PER_CPU(unsigned int, nr_dentry);
+static DEFINE_PER_CPU(long, nr_dentry);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
-static int get_nr_dentry(void)
+static long get_nr_dentry(void)
 {
 	int i;
-	int sum = 0;
+	long sum = 0;
 	for_each_possible_cpu(i)
 		sum += per_cpu(nr_dentry, i);
 	return sum < 0 ? 0 : sum;
@@ -133,7 +133,7 @@ int proc_nr_dentry(ctl_table *table, int write, void __user *buffer,
 		   size_t *lenp, loff_t *ppos)
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
-	return proc_dointvec(table, write, buffer, lenp, ppos);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
 #endif
 
diff --git a/fs/inode.c b/fs/inode.c
index 00d5fc3..ff29765 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -70,33 +70,33 @@ EXPORT_SYMBOL(empty_aops);
  */
 struct inodes_stat_t inodes_stat;
 
-static DEFINE_PER_CPU(unsigned int, nr_inodes);
-static DEFINE_PER_CPU(unsigned int, nr_unused);
+static DEFINE_PER_CPU(unsigned long, nr_inodes);
+static DEFINE_PER_CPU(unsigned long, nr_unused);
 
 static struct kmem_cache *inode_cachep __read_mostly;
 
-static int get_nr_inodes(void)
+static long get_nr_inodes(void)
 {
 	int i;
-	int sum = 0;
+	long sum = 0;
 	for_each_possible_cpu(i)
 		sum += per_cpu(nr_inodes, i);
 	return sum < 0 ? 0 : sum;
 }
 
-static inline int get_nr_inodes_unused(void)
+static inline long get_nr_inodes_unused(void)
 {
 	int i;
-	int sum = 0;
+	long sum = 0;
 	for_each_possible_cpu(i)
 		sum += per_cpu(nr_unused, i);
 	return sum < 0 ? 0 : sum;
 }
 
-int get_nr_dirty_inodes(void)
+long get_nr_dirty_inodes(void)
 {
 	/* not actually dirty inodes, but a wild approximation */
-	int nr_dirty = get_nr_inodes() - get_nr_inodes_unused();
+	long nr_dirty = get_nr_inodes() - get_nr_inodes_unused();
 	return nr_dirty > 0 ? nr_dirty : 0;
 }
 
@@ -109,7 +109,7 @@ int proc_nr_inodes(ctl_table *table, int write,
 {
 	inodes_stat.nr_inodes = get_nr_inodes();
 	inodes_stat.nr_unused = get_nr_inodes_unused();
-	return proc_dointvec(table, write, buffer, lenp, ppos);
+	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
 #endif
 
diff --git a/fs/internal.h b/fs/internal.h
index eaa75f7..cd5009f 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -117,7 +117,7 @@ extern void inode_add_lru(struct inode *inode);
  */
 extern void inode_wb_list_del(struct inode *inode);
 
-extern int get_nr_dirty_inodes(void);
+extern long get_nr_dirty_inodes(void);
 extern void evict_inodes(struct super_block *);
 extern int invalidate_inodes(struct super_block *, bool);
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 1a6bb81..1a82bdb 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -54,11 +54,11 @@ struct qstr {
 #define hashlen_len(hashlen)  ((u32)((hashlen) >> 32))
 
 struct dentry_stat_t {
-	int nr_dentry;
-	int nr_unused;
-	int age_limit;          /* age in seconds */
-	int want_pages;         /* pages requested by system */
-	int dummy[2];
+	long nr_dentry;
+	long nr_unused;
+	long age_limit;          /* age in seconds */
+	long want_pages;         /* pages requested by system */
+	long dummy[2];
 };
 extern struct dentry_stat_t dentry_stat;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a4c9fbe..ad3eb76 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1266,12 +1266,12 @@ struct super_block {
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
 	/* s_dentry_lru, s_nr_dentry_unused protected by dcache.c lru locks */
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
-	int			s_nr_dentry_unused;	/* # of dentry on lru */
+	long			s_nr_dentry_unused;	/* # of dentry on lru */
 
 	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
 	spinlock_t		s_inode_lru_lock ____cacheline_aligned_in_smp;
 	struct list_head	s_inode_lru;		/* unused inode lru */
-	int			s_nr_inodes_unused;	/* # of inodes on lru */
+	long			s_nr_inodes_unused;	/* # of inodes on lru */
 
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
index a4ed56c..6c28b61 100644
--- a/include/uapi/linux/fs.h
+++ b/include/uapi/linux/fs.h
@@ -49,9 +49,9 @@ struct files_stat_struct {
 };
 
 struct inodes_stat_t {
-	int nr_inodes;
-	int nr_unused;
-	int dummy[5];		/* padding for sysctl ABI compatibility */
+	long nr_inodes;
+	long nr_unused;
+	long dummy[5];		/* padding for sysctl ABI compatibility */
 };
 
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 9edcf45..fb90f7c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1456,14 +1456,14 @@ static struct ctl_table fs_table[] = {
 	{
 		.procname	= "inode-nr",
 		.data		= &inodes_stat,
-		.maxlen		= 2*sizeof(int),
+		.maxlen		= 2*sizeof(long),
 		.mode		= 0444,
 		.proc_handler	= proc_nr_inodes,
 	},
 	{
 		.procname	= "inode-state",
 		.data		= &inodes_stat,
-		.maxlen		= 7*sizeof(int),
+		.maxlen		= 7*sizeof(long),
 		.mode		= 0444,
 		.proc_handler	= proc_nr_inodes,
 	},
@@ -1493,7 +1493,7 @@ static struct ctl_table fs_table[] = {
 	{
 		.procname	= "dentry-state",
 		.data		= &dentry_stat,
-		.maxlen		= 6*sizeof(int),
+		.maxlen		= 6*sizeof(long),
 		.mode		= 0444,
 		.proc_handler	= proc_nr_dentry,
 	},
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
