Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D11146B026F
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 12:47:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id 13-v6so30232326qtt.7
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 09:47:06 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u42-v6si9899373qth.262.2018.07.12.09.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 09:47:05 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v7 6/6] fs/dcache: Allow deconfiguration of negative dentry code to reduce kernel size
Date: Thu, 12 Jul 2018 12:46:05 -0400
Message-Id: <1531413965-5401-7-git-send-email-longman@redhat.com>
In-Reply-To: <1531413965-5401-1-git-send-email-longman@redhat.com>
References: <1531413965-5401-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

The tracking and limit of negative dentries in a filesystem is a useful
addition. However, for users who want to reduce the kernel size as much
as possible, this feature will probably be on the chopping block. To
suit those users, a default-y config option DCACHE_LIMIT_NEG_ENTRY is
added so that the negative dentry limiting code can be configured out,
if necessary.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/Kconfig             | 10 ++++++++++
 fs/dcache.c            | 29 +++++++++++++++++++++++------
 include/linux/dcache.h |  2 ++
 kernel/sysctl.c        |  2 ++
 4 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index ac474a6..b521941 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -113,6 +113,16 @@ source "fs/autofs/Kconfig"
 source "fs/fuse/Kconfig"
 source "fs/overlayfs/Kconfig"
 
+#
+# Track and limit the number of negative dentries allowed in the system.
+#
+config DCACHE_LIMIT_NEG_ENTRY
+	bool "Track & limit negative dcache entries"
+	default y
+	help
+	  This option enables the tracking and limiting of the total
+	  number of negative dcache entries allowable in the filesystem.
+
 menu "Caches"
 
 source "fs/fscache/Kconfig"
diff --git a/fs/dcache.c b/fs/dcache.c
index 843c8be..dccfe39 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -141,6 +141,7 @@ struct dentry_stat_t dentry_stat = {
 #define NEG_DENTRY_BATCH	(1 << 8)
 #define NEG_WARN_PERIOD 	(60 * HZ)	/* Print a warning every min */
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 static struct static_key limit_neg_key = STATIC_KEY_INIT_FALSE;
 static int neg_dentry_limit_old;
 int neg_dentry_limit;
@@ -156,6 +157,7 @@ struct dentry_stat_t dentry_stat = {
 	unsigned long warn_jiffies;	/* Time when last warning is printed */
 } ndblk ____cacheline_aligned_in_smp;
 proc_handler proc_neg_dentry_limit;
+#endif /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
 
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
@@ -200,7 +202,9 @@ static long get_nr_dentry_neg(void)
 
 	for_each_possible_cpu(i)
 		sum += per_cpu(nr_dentry_neg, i);
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 	sum += neg_dentry_nfree_init - ndblk.nfree;
+#endif
 	return sum < 0 ? 0 : sum;
 }
 
@@ -267,6 +271,7 @@ static inline int dentry_string_cmp(const unsigned char *cs, const unsigned char
 
 #endif
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 /*
  * Decrement negative dentry count if applicable.
  */
@@ -289,12 +294,6 @@ static void __neg_dentry_dec(struct dentry *dentry)
 	}
 }
 
-static inline void neg_dentry_dec(struct dentry *dentry)
-{
-	if (unlikely(d_is_negative(dentry)))
-		__neg_dentry_dec(dentry);
-}
-
 /*
  * Try to decrement the negative dentry free pool by NEG_DENTRY_BATCH.
  * The actual decrement returned by the function may be smaller.
@@ -454,6 +453,20 @@ int proc_neg_dentry_limit(struct ctl_table *ctl, int write,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(proc_neg_dentry_limit);
+#else /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
+
+static inline void __neg_dentry_dec(struct dentry *dentry)
+{
+	 this_cpu_dec(nr_dentry_neg);
+}
+
+#endif /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
+
+static inline void neg_dentry_dec(struct dentry *dentry)
+{
+	if (unlikely(d_is_negative(dentry)))
+		__neg_dentry_dec(dentry);
+}
 
 static inline int dentry_cmp(const struct dentry *dentry, const unsigned char *ct, unsigned tcount)
 {
@@ -642,6 +655,7 @@ static void d_lru_add(struct dentry *dentry)
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
 	if (d_is_negative(dentry)) {
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 		if (dentry->d_flags & DCACHE_NEW_NEGATIVE) {
 			dentry->d_flags &= ~DCACHE_NEW_NEGATIVE;
 			if (unlikely(neg_dentry_inc(dentry) < 0)) {
@@ -658,6 +672,7 @@ static void d_lru_add(struct dentry *dentry)
 				&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 			return;
 		}
+#endif
 		/*
 		 * We don't do limit check for existing negative
 		 * dentries.
@@ -3431,7 +3446,9 @@ static void __init dcache_init(void)
 		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
 		d_iname);
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 	raw_spin_lock_init(&ndblk.nfree_lock);
+#endif
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 934a6d9..11729a1 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -612,10 +612,12 @@ struct name_snapshot {
 void take_dentry_name_snapshot(struct name_snapshot *, struct dentry *);
 void release_dentry_name_snapshot(struct name_snapshot *);
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 /*
  * Negative dentry related declarations.
  */
 extern int neg_dentry_limit;
 extern int neg_dentry_enforce;
+#endif
 
 #endif	/* __LINUX_DCACHE_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index a24101e..732c624 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1851,6 +1851,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 	{
 		.procname	= "neg-dentry-limit",
 		.data		= &neg_dentry_limit,
@@ -1869,6 +1870,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+#endif
 	{ }
 };
 
-- 
1.8.3.1
