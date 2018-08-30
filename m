Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6516B5395
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 17:55:30 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e14-v6so10379427qtp.17
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:55:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id z74-v6si6504328qkg.148.2018.08.30.14.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 14:55:29 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 3/4] fs/dcache: Track & report number of negative dentries
Date: Thu, 30 Aug 2018 17:55:06 -0400
Message-Id: <1535666107-25699-4-git-send-email-longman@redhat.com>
In-Reply-To: <1535666107-25699-1-git-send-email-longman@redhat.com>
References: <1535666107-25699-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

The current dentry number tracking code doesn't distinguish between
positive & negative dentries. It just reports the total number of
dentries in the LRU lists.

As excessive number of negative dentries can have an impact on system
performance, it will be wise to track the number of positive and
negative dentries separately.

This patch adds tracking for the total number of negative dentries
in the system LRU lists and reports it in the 7th field in the
/proc/sys/fs/dentry-state file. The number, however, does not include
negative dentries that are in flight but not in the LRU yet as well
as those in the shrinker lists.

The number of positive dentries in the LRU lists can be roughly found
by subtracting the number of negative dentries from the unused count.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt | 22 ++++++++++++++--------
 fs/dcache.c                 | 31 +++++++++++++++++++++++++++++++
 include/linux/dcache.h      |  5 +++--
 kernel/sysctl.c             |  2 +-
 4 files changed, 49 insertions(+), 11 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index 819caf8..21679d0 100644
--- a/Documentation/sysctl/fs.txt
+++ b/Documentation/sysctl/fs.txt
@@ -56,26 +56,32 @@ of any kernel data structures.
 
 dentry-state:
 
-From linux/fs/dentry.c:
+From linux/include/linux/dcache.h:
 --------------------------------------------------------------
-struct {
+struct dentry_stat_t dentry_stat {
         int nr_dentry;
         int nr_unused;
         int age_limit;         /* age in seconds */
         int want_pages;        /* pages requested by system */
         int dummy[2];
-} dentry_stat = {0, 0, 45, 0,};
--------------------------------------------------------------- 
+        int nr_negative;       /* # of unused negative dentries */
+};
+--------------------------------------------------------------
+
+Dentries are dynamically allocated and deallocated.
+
+nr_dentry shows the total number of dentries allocated (active
++ unused). nr_unused shows the number of dentries that are not
+actively used, but are saved in the LRU list for future reuse.
 
-Dentries are dynamically allocated and deallocated, and
-nr_dentry seems to be 0 all the time. Hence it's safe to
-assume that only nr_unused, age_limit and want_pages are
-used. Nr_unused seems to be exactly what its name says.
 Age_limit is the age in seconds after which dcache entries
 can be reclaimed when memory is short and want_pages is
 nonzero when shrink_dcache_pages() has been called and the
 dcache isn't pruned yet.
 
+nr_negative shows the number of unused dentries that are also
+negative dentries which do not mapped to actual files.
+
 ==============================================================
 
 dquot-max & dquot-nr:
diff --git a/fs/dcache.c b/fs/dcache.c
index cb515f1..c1cc956 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -119,6 +119,7 @@ struct dentry_stat_t dentry_stat = {
 
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
+static DEFINE_PER_CPU(long, nr_dentry_negative);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
 
@@ -152,11 +153,22 @@ static long get_nr_dentry_unused(void)
 	return sum < 0 ? 0 : sum;
 }
 
+static long get_nr_dentry_negative(void)
+{
+	int i;
+	long sum = 0;
+
+	for_each_possible_cpu(i)
+		sum += per_cpu(nr_dentry_negative, i);
+	return sum < 0 ? 0 : sum;
+}
+
 int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
 		   size_t *lenp, loff_t *ppos)
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
 	dentry_stat.nr_unused = get_nr_dentry_unused();
+	dentry_stat.nr_negative = get_nr_dentry_negative();
 	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
 #endif
@@ -331,6 +343,8 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		this_cpu_inc(nr_dentry_negative);
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -385,6 +399,10 @@ static void dentry_unlink_inode(struct dentry * dentry)
  * The per-cpu "nr_dentry_unused" counters are updated with
  * the DCACHE_LRU_LIST bit.
  *
+ * The per-cpu "nr_dentry_negative" counters are only updated
+ * when deleted or added to the per-superblock LRU list, not
+ * on the shrink list.
+ *
  * These helper functions make sure we always follow the
  * rules. d_lock must be held by the caller.
  */
@@ -394,6 +412,8 @@ static void d_lru_add(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_inc(nr_dentry_negative);
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -402,6 +422,8 @@ static void d_lru_del(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	WARN_ON_ONCE(!list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -432,6 +454,8 @@ static void d_lru_isolate(struct list_lru_one *lru, struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	list_lru_isolate(lru, &dentry->d_lru);
 }
 
@@ -440,6 +464,8 @@ static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
 {
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	list_lru_isolate_move(lru, &dentry->d_lru, list);
 }
 
@@ -1836,6 +1862,11 @@ static void __d_instantiate(struct dentry *dentry, struct inode *inode)
 	WARN_ON(d_in_lookup(dentry));
 
 	spin_lock(&dentry->d_lock);
+	/*
+	 * Decrement negative dentry count if it was in the LRU list.
+	 */
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		this_cpu_dec(nr_dentry_negative);
 	hlist_add_head(&dentry->d_u.d_alias, &inode->i_dentry);
 	raw_write_seqcount_begin(&dentry->d_seq);
 	__d_set_inode_and_type(dentry, inode, add_flags);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index ef4b70f..619a249 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -62,9 +62,10 @@ struct qstr {
 struct dentry_stat_t {
 	long nr_dentry;
 	long nr_unused;
-	long age_limit;          /* age in seconds */
-	long want_pages;         /* pages requested by system */
+	long age_limit;		/* age in seconds */
+	long want_pages;	/* pages requested by system */
 	long dummy[2];
+	long nr_negative;	/* # of unused negative dentries */
 };
 extern struct dentry_stat_t dentry_stat;
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index cc02050..77ff61c 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1708,7 +1708,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 	{
 		.procname	= "dentry-state",
 		.data		= &dentry_stat,
-		.maxlen		= 6*sizeof(long),
+		.maxlen		= 7*sizeof(long),
 		.mode		= 0444,
 		.proc_handler	= proc_nr_dentry,
 	},
-- 
1.8.3.1
