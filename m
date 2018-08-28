Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B51B36B472F
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:20:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c14-v6so1948765qtc.7
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:20:00 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 49-v6si1498766qvd.58.2018.08.28.10.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 10:19:59 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH 1/2] fs/dcache: Track & report number of negative dentries
Date: Tue, 28 Aug 2018 13:19:39 -0400
Message-Id: <1535476780-5773-2-git-send-email-longman@redhat.com>
In-Reply-To: <1535476780-5773-1-git-send-email-longman@redhat.com>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
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

This patch adds tracking for the total number of negative dentries in
the system LRU lists and reports it in the /proc/sys/fs/dentry-state
file. The number, however, does not include negative dentries that are
in flight but not in the LRU yet.

The number of positive dentries in the LRU lists can be roughly found
by subtracting the number of negative dentries from the total.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt | 19 +++++++++++++------
 fs/dcache.c                 | 45 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/dcache.h      |  7 ++++---
 3 files changed, 62 insertions(+), 9 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index 819caf8..118bb93 100644
--- a/Documentation/sysctl/fs.txt
+++ b/Documentation/sysctl/fs.txt
@@ -63,19 +63,26 @@ struct {
         int nr_unused;
         int age_limit;         /* age in seconds */
         int want_pages;        /* pages requested by system */
-        int dummy[2];
+        int nr_negative;       /* # of unused negative dentries */
+        int dummy;
 } dentry_stat = {0, 0, 45, 0,};
--------------------------------------------------------------- 
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
+negative dentries which do not mapped to actual files if negative
+dentries tracking is enabled.
+
 ==============================================================
 
 dquot-max & dquot-nr:
diff --git a/fs/dcache.c b/fs/dcache.c
index 2e7e8d8..69f5541 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -119,6 +119,7 @@ struct dentry_stat_t dentry_stat = {
 
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
+static DEFINE_PER_CPU(long, nr_dentry_neg);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
 
@@ -152,11 +153,22 @@ static long get_nr_dentry_unused(void)
 	return sum < 0 ? 0 : sum;
 }
 
+static long get_nr_dentry_neg(void)
+{
+	int i;
+	long sum = 0;
+
+	for_each_possible_cpu(i)
+		sum += per_cpu(nr_dentry_neg, i);
+	return sum < 0 ? 0 : sum;
+}
+
 int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
 		   size_t *lenp, loff_t *ppos)
 {
 	dentry_stat.nr_dentry = get_nr_dentry();
 	dentry_stat.nr_unused = get_nr_dentry_unused();
+	dentry_stat.nr_negative = get_nr_dentry_neg();
 	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
 #endif
@@ -214,6 +226,28 @@ static inline int dentry_string_cmp(const unsigned char *cs, const unsigned char
 
 #endif
 
+static inline void __neg_dentry_dec(struct dentry *dentry)
+{
+	this_cpu_dec(nr_dentry_neg);
+}
+
+static inline void neg_dentry_dec(struct dentry *dentry)
+{
+	if (unlikely(d_is_negative(dentry)))
+		__neg_dentry_dec(dentry);
+}
+
+static inline void __neg_dentry_inc(struct dentry *dentry)
+{
+	this_cpu_inc(nr_dentry_neg);
+}
+
+static inline void neg_dentry_inc(struct dentry *dentry)
+{
+	if (unlikely(d_is_negative(dentry)))
+		__neg_dentry_inc(dentry);
+}
+
 static inline int dentry_cmp(const struct dentry *dentry, const unsigned char *ct, unsigned tcount)
 {
 	/*
@@ -331,6 +365,8 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		__neg_dentry_inc(dentry);
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -395,6 +431,7 @@ static void d_lru_add(struct dentry *dentry)
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
+	neg_dentry_inc(dentry);
 }
 
 static void d_lru_del(struct dentry *dentry)
@@ -403,6 +440,7 @@ static void d_lru_del(struct dentry *dentry)
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
 	WARN_ON_ONCE(!list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
+	neg_dentry_dec(dentry);
 }
 
 static void d_shrink_del(struct dentry *dentry)
@@ -433,6 +471,7 @@ static void d_lru_isolate(struct list_lru_one *lru, struct dentry *dentry)
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
 	list_lru_isolate(lru, &dentry->d_lru);
+	neg_dentry_dec(dentry);
 }
 
 static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
@@ -441,6 +480,7 @@ static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags |= DCACHE_SHRINK_LIST;
 	list_lru_isolate_move(lru, &dentry->d_lru, list);
+	neg_dentry_dec(dentry);
 }
 
 /**
@@ -1840,6 +1880,11 @@ static void __d_instantiate(struct dentry *dentry, struct inode *inode)
 	WARN_ON(d_in_lookup(dentry));
 
 	spin_lock(&dentry->d_lock);
+	/*
+	 * Decrement negative dentry count if it was in the LRU list.
+	 */
+	if (dentry->d_flags & DCACHE_LRU_LIST)
+		__neg_dentry_dec(dentry);
 	hlist_add_head(&dentry->d_u.d_alias, &inode->i_dentry);
 	raw_write_seqcount_begin(&dentry->d_seq);
 	__d_set_inode_and_type(dentry, inode, add_flags);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index ef4b70f..df942e5 100644
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
+	long dummy;
 };
 extern struct dentry_stat_t dentry_stat;
 
-- 
1.8.3.1
