Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1975E8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:53:30 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id i37so6311971qkh.21
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:53:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q7si3238745qvc.195.2018.12.14.13.53.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 13:53:28 -0800 (PST)
From: Waiman Long <longman@redhat.com>
Subject: [RESEND PATCH v4 3/3] fs/dcache: Track & report number of negative dentries
Date: Fri, 14 Dec 2018 16:53:04 -0500
Message-Id: <1544824384-17668-4-git-send-email-longman@redhat.com>
In-Reply-To: <1544824384-17668-1-git-send-email-longman@redhat.com>
References: <1544824384-17668-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

The current dentry number tracking code doesn't distinguish between
positive & negative dentries. It just reports the total number of
dentries in the LRU lists.

As excessive number of negative dentries can have an impact on system
performance, it will be wise to track the number of positive and
negative dentries separately.

This patch adds tracking for the total number of negative dentries
in the system LRU lists and reports it in the 5th field in the
/proc/sys/fs/dentry-state file. The number, however, does not include
negative dentries that are in flight but not in the LRU yet as well
as those in the shrinker lists which are on the way out anyway.

The number of positive dentries in the LRU lists can be roughly found
by subtracting the number of negative dentries from the unused count.

Matthew Wilcox had confirmed that since the introduction of the
dentry_stat structure in 2.1.60, the dummy array was there, probably for
future extension. They were not replacements of pre-existing fields. So
no sane applications that read the value of /proc/sys/fs/dentry-state
will do dummy thing if the last 2 fields of the sysctl parameter are
not zero. IOW, it will be safe to use one of the dummy array entry for
negative dentry count.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt | 26 ++++++++++++++++----------
 fs/dcache.c                 | 32 ++++++++++++++++++++++++++++++++
 include/linux/dcache.h      |  7 ++++---
 3 files changed, 52 insertions(+), 13 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index 819caf8..58649bd 100644
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
-        int dummy[2];
-} dentry_stat = {0, 0, 45, 0,};
--------------------------------------------------------------- 
-
-Dentries are dynamically allocated and deallocated, and
-nr_dentry seems to be 0 all the time. Hence it's safe to
-assume that only nr_unused, age_limit and want_pages are
-used. Nr_unused seems to be exactly what its name says.
+        int nr_negative;       /* # of unused negative dentries */
+        int dummy;             /* Reserved for future use */
+};
+--------------------------------------------------------------
+
+Dentries are dynamically allocated and deallocated.
+
+nr_dentry shows the total number of dentries allocated (active
++ unused). nr_unused shows the number of dentries that are not
+actively used, but are saved in the LRU list for future reuse.
+
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
index 44e5652..aac41ad 100644
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
@@ -317,6 +329,8 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		this_cpu_inc(nr_dentry_negative);
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -371,6 +385,11 @@ static void dentry_unlink_inode(struct dentry * dentry)
  * The per-cpu "nr_dentry_unused" counters are updated with
  * the DCACHE_LRU_LIST bit.
  *
+ * The per-cpu "nr_dentry_negative" counters are only updated
+ * when deleted from or added to the per-superblock LRU list, not
+ * from/to the shrink list. That is to avoid an unneeded dec/inc
+ * pair when moving from LRU to shrink list in select_collect().
+ *
  * These helper functions make sure we always follow the
  * rules. d_lock must be held by the caller.
  */
@@ -380,6 +399,8 @@ static void d_lru_add(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_inc(nr_dentry_negative);
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -388,6 +409,8 @@ static void d_lru_del(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	WARN_ON_ONCE(!list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -418,6 +441,8 @@ static void d_lru_isolate(struct list_lru_one *lru, struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	list_lru_isolate(lru, &dentry->d_lru);
 }
 
@@ -426,6 +451,8 @@ static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
 {
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	if (d_is_negative(dentry))
+		this_cpu_dec(nr_dentry_negative);
 	list_lru_isolate_move(lru, &dentry->d_lru, list);
 }
 
@@ -1816,6 +1843,11 @@ static void __d_instantiate(struct dentry *dentry, struct inode *inode)
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
index ef4b70f..60996e6 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -62,9 +62,10 @@ struct qstr {
 struct dentry_stat_t {
 	long nr_dentry;
 	long nr_unused;
-	long age_limit;          /* age in seconds */
-	long want_pages;         /* pages requested by system */
-	long dummy[2];
+	long age_limit;		/* age in seconds */
+	long want_pages;	/* pages requested by system */
+	long nr_negative;	/* # of unused negative dentries */
+	long dummy;		/* Reserved for future use */
 };
 extern struct dentry_stat_t dentry_stat;
 
-- 
1.8.3.1
