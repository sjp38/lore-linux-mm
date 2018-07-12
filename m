Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE3036B0269
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:47:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id w126-v6so24352052qka.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:47:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d9-v6si4034974qtp.114.2018.07.12.09.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:47:04 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v7 3/6] fs/dcache: Add sysctl parameter neg-dentry-limit as a soft limit on negative dentries
Date: Thu, 12 Jul 2018 12:46:02 -0400
Message-Id: <1531413965-5401-4-git-send-email-longman@redhat.com>
In-Reply-To: <1531413965-5401-1-git-send-email-longman@redhat.com>
References: <1531413965-5401-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

A new sysctl parameter "neg-dentry-limit" is added to /proc/sys/fs
whose value represents a soft limit on the total number of negative
dentries allowable in a system as a multiple of one-thousandth of
the total system memory available.  The allowable range of this new
parameter is 0-100 where 0 means no soft limit.

A warning message will be printed if the soft limit is exceeded. Limit
check will only be done for newly created negative dentries, not
existing ones.

When "neg-dentry-limit" is set to 0 (the default), static key is used to
disable the limit checking code. So the dentry code performance should
be the same as if this patch isn't applied.

As for the proper value to be set in "neg-dentry-limit" for those
users who want it enabled, it will be workload dependent. Whenever a
non-zero value is written into "neg-dentry-limit", an informational
message will be printed about what the actual negative dentry limits
will be. It can be compared against the current negative dentry number
(5th number) from "dentry-state" to see if there is enough safe margin
to avoid false positive warning.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt |  11 +++
 fs/dcache.c                 | 187 ++++++++++++++++++++++++++++++++++++++++++--
 include/linux/dcache.h      |   5 ++
 kernel/sysctl.c             |  11 +++
 4 files changed, 207 insertions(+), 7 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index a8e3f1f..6fd43b3 100644
--- a/Documentation/sysctl/fs.txt
+++ b/Documentation/sysctl/fs.txt
@@ -32,6 +32,7 @@ Currently, these files are in /proc/sys/fs:
 - nr_open
 - overflowuid
 - overflowgid
+- neg-dentry-limit
 - pipe-user-pages-hard
 - pipe-user-pages-soft
 - protected_hardlinks
@@ -168,6 +169,16 @@ The default is 65534.
 
 ==============================================================
 
+neg-dentry-limit:
+
+This integer value specifies a soft limit on the total number of
+negative dentries allowed in a system as a percentage of the total
+system memory available. The allowable range for this value is 0-100.
+A value of 0 means there is no limit. Each unit represents 0.1% of
+the total system memory. So 10% is the maximum that can be specified.
+
+==============================================================
+
 pipe-user-pages-hard:
 
 Maximum total number of pages a non-privileged user may allocate for pipes.
diff --git a/fs/dcache.c b/fs/dcache.c
index 0be5972..1fad368 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -14,6 +14,8 @@
  * the dcache entry is deleted or garbage collected.
  */
 
+#define pr_fmt(fmt)	KBUILD_MODNAME ": " fmt
+
 #include <linux/ratelimit.h>
 #include <linux/string.h>
 #include <linux/mm.h>
@@ -117,6 +119,40 @@ struct dentry_stat_t dentry_stat = {
 	.age_limit = 45,
 };
 
+/*
+ * The sysctl parameter "neg-dentry-limit" specifies the limit for the
+ * number of negative dentries allowable in a system as a multiple of
+ * one-thousandth of the total system memory. The default is 0 which
+ * means there is no limit and the valid range is 0-100. So up to 10%
+ * of the total system memory can be used.
+ *
+ * With a limit of 10 (1%) on a 64-bit system with 1G memory, that
+ * translated to about 50k dentries which is quite a lot.
+ *
+ * To avoid performance problem with a global counter on an SMP system,
+ * the tracking is done mostly on a per-cpu basis. The total limit is
+ * distributed equally in a 1/1 ratio to per-cpu counters and a global
+ * free pool.
+ *
+ * If a per-cpu counter runs out of negative dentries, it can borrow extra
+ * ones from the global free pool. If it has more than its percpu limit,
+ * the extra ones will be returned back to the global pool.
+ */
+#define NEG_DENTRY_BATCH	(1 << 8)
+
+static struct static_key limit_neg_key = STATIC_KEY_INIT_FALSE;
+static int neg_dentry_limit_old;
+int neg_dentry_limit;
+EXPORT_SYMBOL_GPL(neg_dentry_limit);
+
+static long neg_dentry_percpu_limit __read_mostly;
+static long neg_dentry_nfree_init __read_mostly; /* Free pool initial value */
+static struct {
+	raw_spinlock_t nfree_lock;
+	long nfree;			/* Negative dentry free pool */
+} ndblk ____cacheline_aligned_in_smp;
+proc_handler proc_neg_dentry_limit;
+
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
 static DEFINE_PER_CPU(long, nr_dentry_neg);
@@ -160,6 +196,7 @@ static long get_nr_dentry_neg(void)
 
 	for_each_possible_cpu(i)
 		sum += per_cpu(nr_dentry_neg, i);
+	sum += neg_dentry_nfree_init - ndblk.nfree;
 	return sum < 0 ? 0 : sum;
 }
 
@@ -226,9 +263,26 @@ static inline int dentry_string_cmp(const unsigned char *cs, const unsigned char
 
 #endif
 
-static inline void __neg_dentry_dec(struct dentry *dentry)
+/*
+ * Decrement negative dentry count if applicable.
+ */
+static void __neg_dentry_dec(struct dentry *dentry)
 {
-	this_cpu_dec(nr_dentry_neg);
+	if (!static_key_false(&limit_neg_key)) {
+		this_cpu_dec(nr_dentry_neg);
+		return;
+	}
+
+	if (unlikely(this_cpu_dec_return(nr_dentry_neg) < 0)) {
+		long *pcnt = get_cpu_ptr(&nr_dentry_neg);
+
+		if ((*pcnt < 0) && raw_spin_trylock(&ndblk.nfree_lock)) {
+			WRITE_ONCE(ndblk.nfree, ndblk.nfree + NEG_DENTRY_BATCH);
+			*pcnt += NEG_DENTRY_BATCH;
+			raw_spin_unlock(&ndblk.nfree_lock);
+		}
+		put_cpu_ptr(&nr_dentry_neg);
+	}
 }
 
 static inline void neg_dentry_dec(struct dentry *dentry)
@@ -237,11 +291,120 @@ static inline void neg_dentry_dec(struct dentry *dentry)
 		__neg_dentry_dec(dentry);
 }
 
-static inline void __neg_dentry_inc(struct dentry *dentry)
+/*
+ * Try to decrement the negative dentry free pool by NEG_DENTRY_BATCH.
+ * The actual decrement returned by the function may be smaller.
+ */
+static long __neg_dentry_nfree_dec(long cnt)
 {
-	this_cpu_inc(nr_dentry_neg);
+	cnt = max_t(long, NEG_DENTRY_BATCH, cnt);
+	raw_spin_lock(&ndblk.nfree_lock);
+	if (ndblk.nfree < cnt)
+		cnt = (ndblk.nfree > 0) ? ndblk.nfree : 0;
+	WRITE_ONCE(ndblk.nfree, ndblk.nfree - cnt);
+	raw_spin_unlock(&ndblk.nfree_lock);
+	return cnt;
 }
 
+static noinline void neg_dentry_inc_slowpath(struct dentry *dentry)
+{
+	long cnt = 0, *pcnt;
+
+	/*
+	 * Try to move some negative dentry quota from the global free
+	 * pool to the percpu count to allow more negative dentries to
+	 * be added to the LRU.
+	 */
+	pcnt = get_cpu_ptr(&nr_dentry_neg);
+	if ((READ_ONCE(ndblk.nfree) > 0) &&
+	    (*pcnt > neg_dentry_percpu_limit)) {
+		cnt = __neg_dentry_nfree_dec(*pcnt - neg_dentry_percpu_limit);
+		*pcnt -= cnt;
+	}
+	put_cpu_ptr(&nr_dentry_neg);
+
+	/*
+	 * Put out a warning if there are too many negative dentries.
+	 */
+	if (!cnt)
+		pr_warn_once("There are too many negative dentries.");
+
+}
+
+/*
+ * Increment negative dentry count if applicable.
+ */
+static void neg_dentry_inc(struct dentry *dentry)
+{
+	if (!static_key_false(&limit_neg_key)) {
+		this_cpu_inc(nr_dentry_neg);
+		return;
+	}
+
+	if (likely(this_cpu_inc_return(nr_dentry_neg) <=
+		   neg_dentry_percpu_limit))
+		return;
+
+	neg_dentry_inc_slowpath(dentry);
+}
+
+/*
+ * Sysctl proc handler for neg_dentry_limit.
+ */
+int proc_neg_dentry_limit(struct ctl_table *ctl, int write,
+			  void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	/* Rough estimate of # of dentries allocated per page */
+	const unsigned int nr_dentry_page = PAGE_SIZE/sizeof(struct dentry) - 1;
+	unsigned long cnt, new_init;
+	int ret, ncpus;
+
+	ret = proc_dointvec_minmax(ctl, write, buffer, lenp, ppos);
+
+	if (!write || ret || (neg_dentry_limit == neg_dentry_limit_old))
+		return ret;
+
+	/*
+	 * Disable limit_neg_key first when transitioning from
+	 * neg_dentry_limit to !neg_dentry_limit. In this case, we freeze
+	 * whatever value is in neg_dentry_nfree_init and return.
+	 */
+	if (!neg_dentry_limit && neg_dentry_limit_old) {
+		static_key_slow_dec(&limit_neg_key);
+		goto out;
+	}
+
+	raw_spin_lock(&ndblk.nfree_lock);
+
+	/* 50% in global pool & 50% in percpu free */
+	new_init = totalram_pages * nr_dentry_page * neg_dentry_limit / 2000;
+	ncpus = num_possible_cpus();
+	cnt = new_init / ncpus;
+	if (cnt < 2 * NEG_DENTRY_BATCH)
+		cnt = 2 * NEG_DENTRY_BATCH;
+	neg_dentry_percpu_limit = cnt;
+
+	/*
+	 * Any change in neg_dentry_nfree_init must be applied to ndblk.nfree
+	 * as well. The ndblk.nfree value may become negative if there is
+	 * a decrease in percentage.
+	 */
+	ndblk.nfree += new_init - neg_dentry_nfree_init;
+	neg_dentry_nfree_init = new_init;
+	raw_spin_unlock(&ndblk.nfree_lock);
+
+	pr_info("Negative dentry limits: percpu = %ld, total = %ld\n",
+		neg_dentry_percpu_limit,
+		neg_dentry_nfree_init + neg_dentry_percpu_limit * ncpus);
+
+	if (!neg_dentry_limit_old)
+		static_key_slow_inc(&limit_neg_key);
+out:
+	neg_dentry_limit_old = neg_dentry_limit;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(proc_neg_dentry_limit);
+
 static inline int dentry_cmp(const struct dentry *dentry, const unsigned char *ct, unsigned tcount)
 {
 	/*
@@ -358,8 +521,10 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
+
+	/* We don't do limit check in pos->neg dentry transitions */
 	if (dentry->d_flags & DCACHE_LRU_LIST)
-		__neg_dentry_inc(dentry);
+		this_cpu_inc(nr_dentry_neg);
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -427,17 +592,23 @@ static void d_lru_add(struct dentry *dentry)
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
 	if (d_is_negative(dentry)) {
-		__neg_dentry_inc(dentry);
 		if (dentry->d_flags & DCACHE_NEW_NEGATIVE) {
+			dentry->d_flags &= ~DCACHE_NEW_NEGATIVE;
+			neg_dentry_inc(dentry);
+
 			/*
 			 * Add the negative dentry to the head once, it
 			 * will be added to the tail next time.
 			 */
 			WARN_ON_ONCE(!list_lru_add_head(
 				&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
-			dentry->d_flags &= ~DCACHE_NEW_NEGATIVE;
 			return;
 		}
+		/*
+		 * We don't do limit check for existing negative
+		 * dentries.
+		 */
+		this_cpu_inc(nr_dentry_neg);
 	}
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
@@ -3200,6 +3371,8 @@ static void __init dcache_init(void)
 		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
 		d_iname);
 
+	raw_spin_lock_init(&ndblk.nfree_lock);
+
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
 		return;
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 89cf348..4216eca 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -611,4 +611,9 @@ struct name_snapshot {
 void take_dentry_name_snapshot(struct name_snapshot *, struct dentry *);
 void release_dentry_name_snapshot(struct name_snapshot *);
 
+/*
+ * Negative dentry related declarations.
+ */
+extern int neg_dentry_limit;
+
 #endif	/* __LINUX_DCACHE_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2d9837c..2877782 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -114,6 +114,8 @@
 extern int sysctl_nr_trim_pages;
 #endif
 
+extern proc_handler proc_neg_dentry_limit;
+
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
 static int sixty = 60;
@@ -1849,6 +1851,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
+	{
+		.procname	= "neg-dentry-limit",
+		.data		= &neg_dentry_limit,
+		.maxlen		= sizeof(neg_dentry_limit),
+		.mode		= 0644,
+		.proc_handler	= proc_neg_dentry_limit,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 	{ }
 };
 
-- 
1.8.3.1
