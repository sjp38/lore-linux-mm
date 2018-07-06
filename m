Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id D36FD6B0274
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:34:32 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id h67-v6so13821131qke.18
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:34:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b57-v6si2210070qte.346.2018.07.06.12.34.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:34:31 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v6 7/7] fs/dcache: Allow deconfiguration of negative dentry code to reduce kernel size
Date: Fri,  6 Jul 2018 15:32:52 -0400
Message-Id: <1530905572-817-8-git-send-email-longman@redhat.com>
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Waiman Long <longman@redhat.com>

The tracking and limit of negative dentries in a filesystem is a useful
addition. However, for users who want to reduce the kernel size as much
as possible, this feature will probably be on the chopping block. To
suit those users, a default-y config option DCACHE_LIMIT_NEG_ENTRY is
added so that the negative dentry tracking and limiting code can be
configured out, if necessary.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/Kconfig             | 10 ++++++++++
 fs/dcache.c            | 33 ++++++++++++++++++++++++++++++++-
 include/linux/dcache.h |  2 ++
 kernel/sysctl.c        |  2 ++
 4 files changed, 46 insertions(+), 1 deletion(-)

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
index 43d49d7..d00761e 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -143,6 +143,7 @@ struct dentry_stat_t dentry_stat = {
 #define NEG_IS_SB_UMOUNTING(sb)	\
 	unlikely(!(sb)->s_root || !((sb)->s_flags & MS_ACTIVE))
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 static struct static_key limit_neg_key = STATIC_KEY_INIT_FALSE;
 static int neg_dentry_pc_old;
 int neg_dentry_pc;
@@ -166,10 +167,11 @@ struct dentry_stat_t dentry_stat = {
 static void d_lru_del(struct dentry *dentry);
 static void prune_negative_dentry(struct work_struct *work);
 static DECLARE_DELAYED_WORK(prune_neg_dentry_work, prune_negative_dentry);
+static DEFINE_PER_CPU(long, nr_dentry_neg);
+#endif /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
 
 static DEFINE_PER_CPU(long, nr_dentry);
 static DEFINE_PER_CPU(long, nr_dentry_unused);
-static DEFINE_PER_CPU(long, nr_dentry_neg);
 
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_PROC_FS)
 
@@ -203,6 +205,7 @@ static long get_nr_dentry_unused(void)
 	return sum < 0 ? 0 : sum;
 }
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 static long get_nr_dentry_neg(void)
 {
 	int i;
@@ -213,6 +216,9 @@ static long get_nr_dentry_neg(void)
 	sum += neg_dentry_nfree_init - ndblk.nfree;
 	return sum < 0 ? 0 : sum;
 }
+#else
+static long get_nr_dentry_neg(void)	{ return 0; }
+#endif
 
 int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
 		   size_t *lenp, loff_t *ppos)
@@ -277,6 +283,7 @@ static inline int dentry_string_cmp(const unsigned char *cs, const unsigned char
 
 #endif
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 /*
  * Decrement negative dentry count if applicable.
  */
@@ -455,6 +462,26 @@ int proc_neg_dentry_pc(struct ctl_table *ctl, int write,
 	return 0;
 }
 EXPORT_SYMBOL_GPL(proc_neg_dentry_pc);
+#else /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
+
+static inline void __neg_dentry_dec(struct dentry *dentry)
+{
+}
+
+static inline void neg_dentry_dec(struct dentry *dentry)
+{
+}
+
+static inline void __neg_dentry_inc(struct dentry *dentry, bool retain)
+{
+}
+
+static inline void neg_dentry_inc(struct dentry *dentry)
+{
+}
+
+#endif /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
+
 
 static inline int dentry_cmp(const struct dentry *dentry, const unsigned char *ct, unsigned tcount)
 {
@@ -1485,6 +1512,7 @@ void shrink_dcache_sb(struct super_block *sb)
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 /*
  * A modified version that attempts to remove a limited number of negative
  * dentries as well as some other non-negative dentries at the front.
@@ -1639,6 +1667,7 @@ static void prune_negative_dentry(struct work_struct *work)
 	deactivate_super(sb);
 	WRITE_ONCE(ndblk.prune_sb, NULL);
 }
+#endif /* CONFIG_DCACHE_LIMIT_NEG_ENTRY */
 
 /**
  * enum d_walk_ret - action to talke during tree walk
@@ -3576,7 +3605,9 @@ static void __init dcache_init(void)
 		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_ACCOUNT,
 		d_iname);
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 	raw_spin_lock_init(&ndblk.nfree_lock);
+#endif
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 71a3315..27ffc35 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -612,10 +612,12 @@ struct name_snapshot {
 void take_dentry_name_snapshot(struct name_snapshot *, struct dentry *);
 void release_dentry_name_snapshot(struct name_snapshot *);
 
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 /*
  * Negative dentry related declarations.
  */
 extern int neg_dentry_pc;
 extern int neg_dentry_enforce;
+#endif
 
 #endif	/* __LINUX_DCACHE_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8c008ae..875d5ef 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1852,6 +1852,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one,
 	},
+#ifdef CONFIG_DCACHE_LIMIT_NEG_ENTRY
 	{
 		.procname	= "neg-dentry-pc",
 		.data		= &neg_dentry_pc,
@@ -1870,6 +1871,7 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &zero,
 		.extra2		= &one,
 	},
+#endif
 	{ }
 };
 
-- 
1.8.3.1
