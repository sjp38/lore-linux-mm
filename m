Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E42F6B0270
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:34:32 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m6-v6so14528302qkd.20
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:34:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d21-v6si7782746qtb.232.2018.07.06.12.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:34:31 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v6 6/7] fs/dcache: Allow optional enforcement of negative dentry limit
Date: Fri,  6 Jul 2018 15:32:51 -0400
Message-Id: <1530905572-817-7-git-send-email-longman@redhat.com>
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Waiman Long <longman@redhat.com>

If a rogue application that generates a large number of negative
dentries is running, the automatic negative dentries pruning process
may not be fast enough to clear up the negative dentries in time. In
this case, it is possible that negative dentries will use up most
of the available memory in the system when that application is not
under the control of a memory cgroup that limit kernel memory.

The lack of available memory may significantly impact the operation
of other applications running in the system. It will slow down system
performance and may even work as part of a DoS attack on the system.

To allow system administrators the option to prevent this extreme
situation from happening, a new "neg-dentry-enforce" sysctl parameter
is now added which can be set to to enforce the negative dentry soft
limit set in "neg-dentry-pc" so that it becomes a hard limit. When the
limit is enforced, extra negative dentries that exceed the limit will
be killed after use instead of leaving them in the LRU.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt | 10 ++++++++++
 fs/dcache.c                 | 42 +++++++++++++++++++++++++++++++++++-------
 include/linux/dcache.h      |  2 ++
 kernel/sysctl.c             |  9 +++++++++
 4 files changed, 56 insertions(+), 7 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index 7980ecb..3a3c8fa 100644
--- a/Documentation/sysctl/fs.txt
+++ b/Documentation/sysctl/fs.txt
@@ -32,6 +32,7 @@ Currently, these files are in /proc/sys/fs:
 - nr_open
 - overflowuid
 - overflowgid
+- neg-dentry-enforce
 - neg-dentry-pc
 - pipe-user-pages-hard
 - pipe-user-pages-soft
@@ -169,6 +170,15 @@ The default is 65534.
 
 ==============================================================
 
+neg-dentry-enforce:
+
+The file neg-dentry-enforce, if present, contains a boolean flag (0 or
+1) indicating if the negative dentries limit set by the "neg_dentry_pc"
+sysctl parameter should be enforced or not.  If enforced, excess negative
+dentries over the limit will be killed immediately after use.
+
+==============================================================
+
 neg-dentry-pc:
 
 This integer value specifies a soft limit to the total number of
diff --git a/fs/dcache.c b/fs/dcache.c
index ec007ac..43d49d7 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -147,6 +147,8 @@ struct dentry_stat_t dentry_stat = {
 static int neg_dentry_pc_old;
 int neg_dentry_pc;
 EXPORT_SYMBOL_GPL(neg_dentry_pc);
+int neg_dentry_enforce;	/* Enforce the negative dentry limit */
+EXPORT_SYMBOL_GPL(neg_dentry_enforce);
 
 static long neg_dentry_percpu_limit __read_mostly;
 static long neg_dentry_nfree_init __read_mostly; /* Free pool initial value */
@@ -161,6 +163,7 @@ struct dentry_stat_t dentry_stat = {
 } ndblk ____cacheline_aligned_in_smp;
 proc_handler proc_neg_dentry_pc;
 
+static void d_lru_del(struct dentry *dentry);
 static void prune_negative_dentry(struct work_struct *work);
 static DECLARE_DELAYED_WORK(prune_neg_dentry_work, prune_negative_dentry);
 
@@ -319,8 +322,12 @@ static long __neg_dentry_nfree_dec(long cnt)
 
 /*
  * Increment negative dentry count if applicable.
+ *
+ * The retain flag will only be set when calling from
+ * __d_clear_type_and_inode() so as to retain the entry even
+ * if the negative dentry limit has been exceeded.
  */
-static void __neg_dentry_inc(struct dentry *dentry)
+static void __neg_dentry_inc(struct dentry *dentry, bool retain)
 {
 	long cnt = 0, *pcnt;
 
@@ -347,10 +354,25 @@ static void __neg_dentry_inc(struct dentry *dentry)
 	put_cpu_ptr(&nr_dentry_neg);
 
 	/*
-	 * Put out a warning if there are too many negative dentries.
+	 * Put out a warning if there are too many negative dentries or
+	 * kill it by removing it from the LRU and set the
+	 * DCACHE_KILL_NEGATIVE flag if the enforce option is on.
 	 */
-	if (!cnt)
+	if (!cnt) {
+		if (neg_dentry_enforce && !retain) {
+			dentry->d_flags |= DCACHE_KILL_NEGATIVE;
+			d_lru_del(dentry);
+			/*
+			 * When the dentry is no longer in LRU, we
+			 * need to keep the reference count to 1 to
+			 * avoid problem when killing it.
+			 */
+			WARN_ON_ONCE(dentry->d_lockref.count);
+			dentry->d_lockref.count = 1;
+			return; /* Kill the dentry now */
+		}
 		pr_warn_once("Too many negative dentries.");
+	}
 
 	/*
 	 * Initiate negative dentry pruning if free pool has less than
@@ -376,7 +398,7 @@ static void __neg_dentry_inc(struct dentry *dentry)
 static inline void neg_dentry_inc(struct dentry *dentry)
 {
 	if (unlikely(d_is_negative(dentry)))
-		__neg_dentry_inc(dentry);
+		__neg_dentry_inc(dentry, false);
 }
 
 /*
@@ -551,7 +573,7 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
 	if (dentry->d_flags & DCACHE_LRU_LIST)
-		__neg_dentry_inc(dentry);
+		__neg_dentry_inc(dentry, true);	/* Always retain it */
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -871,16 +893,22 @@ static inline bool retain_dentry(struct dentry *dentry)
 	if (unlikely(dentry->d_flags & DCACHE_DISCONNECTED))
 		return false;
 
+	if (unlikely(dentry->d_flags & DCACHE_KILL_NEGATIVE))
+		return false;
+
 	if (unlikely(dentry->d_flags & DCACHE_OP_DELETE)) {
 		if (dentry->d_op->d_delete(dentry))
 			return false;
 	}
 	/* retain; LRU fodder */
 	dentry->d_lockref.count--;
-	if (unlikely(!(dentry->d_flags & DCACHE_LRU_LIST)))
+	if (unlikely(!(dentry->d_flags & DCACHE_LRU_LIST))) {
 		d_lru_add(dentry);
-	else if (unlikely(!(dentry->d_flags & DCACHE_REFERENCED)))
+		if (unlikely(dentry->d_flags & DCACHE_KILL_NEGATIVE))
+			return false;
+	} else if (unlikely(!(dentry->d_flags & DCACHE_REFERENCED))) {
 		dentry->d_flags |= DCACHE_REFERENCED;
+	}
 	return true;
 }
 
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 317e040..71a3315 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -219,6 +219,7 @@ struct dentry_operations {
 
 #define DCACHE_PAR_LOOKUP		0x10000000 /* being looked up (with parent locked shared) */
 #define DCACHE_DENTRY_CURSOR		0x20000000
+#define DCACHE_KILL_NEGATIVE		0x40000000 /* Kill negative dentry */
 
 extern seqlock_t rename_lock;
 
@@ -615,5 +616,6 @@ struct name_snapshot {
  * Negative dentry related declarations.
  */
 extern int neg_dentry_pc;
+extern int neg_dentry_enforce;
 
 #endif	/* __LINUX_DCACHE_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b46cb35..8c008ae 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1861,6 +1861,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &zero,
 		.extra2		= &ten,
 	},
+	{
+		.procname	= "neg-dentry-enforce",
+		.data		= &neg_dentry_enforce,
+		.maxlen		= sizeof(neg_dentry_enforce),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 	{ }
 };
 
-- 
1.8.3.1
