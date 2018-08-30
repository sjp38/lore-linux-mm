Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD8CE6B5398
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 17:55:30 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id a15-v6so10559885qtj.15
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:55:30 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x195-v6si1097481qkx.393.2018.08.30.14.55.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 14:55:29 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v2 4/4] fs/dcache: Eliminate branches in nr_dentry_negative accounting
Date: Thu, 30 Aug 2018 17:55:07 -0400
Message-Id: <1535666107-25699-5-git-send-email-longman@redhat.com>
In-Reply-To: <1535666107-25699-1-git-send-email-longman@redhat.com>
References: <1535666107-25699-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

Because the accounting of nr_dentry_negative depends on whether a dentry
is a negative one or not, branch instructions are introduced to handle
the accounting conditionally. That may potentially slow down the task
by a noticeable amount if that introduces sizeable amount of additional
branch mispredictions.

To avoid that, the accounting code is now modified to use conditional
move instructions instead, if supported by the architecture.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/dcache.c | 41 +++++++++++++++++++++++++++++------------
 1 file changed, 29 insertions(+), 12 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index c1cc956..dfd5628 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -171,6 +171,29 @@ int proc_nr_dentry(struct ctl_table *table, int write, void __user *buffer,
 	dentry_stat.nr_negative = get_nr_dentry_negative();
 	return proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 }
+
+/*
+ * Increment/Decrement nr_dentry_negative if the condition is true.
+ * For architectures that support some kind of conditional move, compiler
+ * should be able generate code to inc/dec negative dentry counter
+ * without any branch instruction.
+ */
+static inline void cond_negative_dentry_inc(bool cond)
+{
+	int val = !!cond;
+
+	this_cpu_add(nr_dentry_negative, val);
+}
+
+static inline void cond_negative_dentry_dec(bool cond)
+{
+	int val = !!cond;
+
+	this_cpu_sub(nr_dentry_negative, val);
+}
+#else
+static inline void cond_negative_dentry_inc(bool cond) { }
+static inline void cond_negative_dentry_dec(bool cond) { }
 #endif
 
 /*
@@ -343,8 +366,7 @@ static inline void __d_clear_type_and_inode(struct dentry *dentry)
 	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
 	WRITE_ONCE(dentry->d_flags, flags);
 	dentry->d_inode = NULL;
-	if (dentry->d_flags & DCACHE_LRU_LIST)
-		this_cpu_inc(nr_dentry_negative);
+	cond_negative_dentry_inc(dentry->d_flags & DCACHE_LRU_LIST);
 }
 
 static void dentry_free(struct dentry *dentry)
@@ -412,8 +434,7 @@ static void d_lru_add(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
-	if (d_is_negative(dentry))
-		this_cpu_inc(nr_dentry_negative);
+	cond_negative_dentry_inc(d_is_negative(dentry));
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -422,8 +443,7 @@ static void d_lru_del(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
-	if (d_is_negative(dentry))
-		this_cpu_dec(nr_dentry_negative);
+	cond_negative_dentry_dec(d_is_negative(dentry));
 	WARN_ON_ONCE(!list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
 }
 
@@ -454,8 +474,7 @@ static void d_lru_isolate(struct list_lru_one *lru, struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags &= ~DCACHE_LRU_LIST;
 	this_cpu_dec(nr_dentry_unused);
-	if (d_is_negative(dentry))
-		this_cpu_dec(nr_dentry_negative);
+	cond_negative_dentry_dec(d_is_negative(dentry));
 	list_lru_isolate(lru, &dentry->d_lru);
 }
 
@@ -464,8 +483,7 @@ static void d_lru_shrink_move(struct list_lru_one *lru, struct dentry *dentry,
 {
 	D_FLAG_VERIFY(dentry, DCACHE_LRU_LIST);
 	dentry->d_flags |= DCACHE_SHRINK_LIST;
-	if (d_is_negative(dentry))
-		this_cpu_dec(nr_dentry_negative);
+	cond_negative_dentry_dec(d_is_negative(dentry));
 	list_lru_isolate_move(lru, &dentry->d_lru, list);
 }
 
@@ -1865,8 +1883,7 @@ static void __d_instantiate(struct dentry *dentry, struct inode *inode)
 	/*
 	 * Decrement negative dentry count if it was in the LRU list.
 	 */
-	if (dentry->d_flags & DCACHE_LRU_LIST)
-		this_cpu_dec(nr_dentry_negative);
+	cond_negative_dentry_dec(dentry->d_flags & DCACHE_LRU_LIST);
 	hlist_add_head(&dentry->d_u.d_alias, &inode->i_dentry);
 	raw_write_seqcount_begin(&dentry->d_seq);
 	__d_set_inode_and_type(dentry, inode, add_flags);
-- 
1.8.3.1
