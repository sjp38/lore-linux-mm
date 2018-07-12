Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F49C6B026D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:47:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d14-v6so10916757qtn.12
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:47:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t13-v6si1544995qtj.316.2018.07.12.09.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:47:05 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v7 5/6] fs/dcache: Allow optional enforcement of negative dentry limit
Date: Thu, 12 Jul 2018 12:46:04 -0400
Message-Id: <1531413965-5401-6-git-send-email-longman@redhat.com>
In-Reply-To: <1531413965-5401-1-git-send-email-longman@redhat.com>
References: <1531413965-5401-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

If a rogue application that generates a large number of negative dentries
is running, it is possible that negative dentries will use up most of
the available memory in the system when that application is not under
the control of a memory cgroup that limit kernel memory.

The lack of available memory may significantly impact the operation
of other applications running in the system. It will slow down system
performance and may even work as part of a DoS attack on the system.

To allow system administrators the option to prevent this extreme
situation from happening, a new "neg-dentry-enforce" sysctl parameter
is now added which can be set to to enforce the negative dentry soft
limit set in "neg-dentry-limit" so that it becomes a hard limit. When
the limit is enforced, extra negative dentries that exceed the limit
will be killed after use instead of leaving them in the LRU.

Note that negative dentry killing happens when the global negative
dentry free pool is depleted even if there are space in other percpu
negative dentry counts for more.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/sysctl/fs.txt | 10 +++++++++
 fs/dcache.c                 | 51 ++++++++++++++++++++++++++++++++++++---------
 include/linux/dcache.h      |  2 ++
 kernel/sysctl.c             |  9 ++++++++
 4 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/Documentation/sysctl/fs.txt b/Documentation/sysctl/fs.txt
index 6fd43b3..b073d9a 100644
--- a/Documentation/sysctl/fs.txt
+++ b/Documentation/sysctl/fs.txt
@@ -32,6 +32,7 @@ Currently, these files are in /proc/sys/fs:
 - nr_open
 - overflowuid
 - overflowgid
+- neg-dentry-enforce
 - neg-dentry-limit
 - pipe-user-pages-hard
 - pipe-user-pages-soft
@@ -169,6 +170,15 @@ The default is 65534.
 
 ==============================================================
 
+neg-dentry-enforce:
+
+The file neg-dentry-enforce, if present, contains a boolean flag (0 or
+1) indicating if the negative dentries limit set by the "neg-dentry-limit"
+sysctl parameter should be enforced or not.  If enforced, excess negative
+dentries over the limit will be killed immediately after use.
+
+==============================================================
+
 neg-dentry-limit:
 
 This integer value specifies a soft limit on the total number of
diff --git a/fs/dcache.c b/fs/dcache.c
index b2c1585..843c8be 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -145,6 +145,8 @@ struct dentry_stat_t dentry_stat = {
 static int neg_dentry_limit_old;
 int neg_dentry_limit;
 EXPORT_SYMBOL_GPL(neg_dentry_limit);
+int neg_dentry_enforce;	/* Enforce the negative dentry limit */
+EXPORT_SYMBOL_GPL(neg_dentry_enforce);
 
 static long neg_dentry_percpu_limit __read_mostly;
 static long neg_dentry_nfree_init __read_mostly; /* Free pool initial value */
@@ -308,7 +310,7 @@ static long __neg_dentry_nfree_dec(long cnt)
 	return cnt;
 }
 
-static noinline void neg_dentry_inc_slowpath(struct dentry *dentry)
+static noinline int neg_dentry_inc_slowpath(struct dentry *dentry)
 {
 	long cnt = 0, *pcnt;
 	unsigned long current_time;
@@ -330,6 +332,24 @@ static noinline void neg_dentry_inc_slowpath(struct dentry *dentry)
 		goto out;
 
 	/*
+	 * Kill the dentry by setting the DCACHE_KILL_NEGATIVE flag and
+	 * dec the negative dentry count if the enforcing option is on.
+	 */
+	if (neg_dentry_enforce) {
+		dentry->d_flags |= DCACHE_KILL_NEGATIVE;
+		this_cpu_dec(nr_dentry_neg);
+
+		/*
+		 * When the dentry is not put into the LRU, we
+		 * need to keep the reference count to 1 to
+		 * avoid problem when killing it.
+		 */
+		WARN_ON_ONCE(dentry->d_lockref.count);
+		dentry->d_lockref.count = 1;
+		return -1; /* Kill the dentry now */
+	}
+
+	/*
 	 * Put out a warning every minute or so if there are just too many
 	 * negative dentries.
 	 */
@@ -354,27 +374,28 @@ static noinline void neg_dentry_inc_slowpath(struct dentry *dentry)
 	 */
 	cnt = get_nr_dentry_neg();
 	pr_warn("Warning: Too many negative dentries (%ld). "
-		"This warning can be disabled by writing 0 to \"fs/neg-dentry-limit\" or increasing the limit.\n",
+		"This warning can be disabled by writing 0 to \"fs/neg-dentry-limit\", increasing the limit or writing 1 to \"fs/neg-dentry-enforce\".\n",
 		cnt);
 out:
-	return;
+	return 0;
 }
 
 /*
  * Increment negative dentry count if applicable.
+ * Return: 0 on success, -1 to kill it.
  */
-static void neg_dentry_inc(struct dentry *dentry)
+static int neg_dentry_inc(struct dentry *dentry)
 {
 	if (!static_key_false(&limit_neg_key)) {
 		this_cpu_inc(nr_dentry_neg);
-		return;
+		return 0;
 	}
 
 	if (likely(this_cpu_inc_return(nr_dentry_neg) <=
 		   neg_dentry_percpu_limit))
-		return;
+		return 0;
 
-	neg_dentry_inc_slowpath(dentry);
+	return neg_dentry_inc_slowpath(dentry);
 }
 
 /*
@@ -623,7 +644,11 @@ static void d_lru_add(struct dentry *dentry)
 	if (d_is_negative(dentry)) {
 		if (dentry->d_flags & DCACHE_NEW_NEGATIVE) {
 			dentry->d_flags &= ~DCACHE_NEW_NEGATIVE;
-			neg_dentry_inc(dentry);
+			if (unlikely(neg_dentry_inc(dentry) < 0)) {
+				this_cpu_dec(nr_dentry_unused);
+				dentry->d_flags &= ~DCACHE_LRU_LIST;
+				return;	/* To be killed */
+			}
 
 			/*
 			 * Add the negative dentry to the head once, it
@@ -878,16 +903,22 @@ static inline bool retain_dentry(struct dentry *dentry)
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
index 4216eca..934a6d9 100644
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
 extern int neg_dentry_limit;
+extern int neg_dentry_enforce;
 
 #endif	/* __LINUX_DCACHE_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2877782..a24101e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1860,6 +1860,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
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
