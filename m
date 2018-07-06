Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB1A06B0273
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 15:34:31 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id w126-v6so4895843qka.11
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 12:34:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v50-v6si3930680qtv.73.2018.07.06.12.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 12:34:30 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH v6 5/7] fs/dcache: Add negative dentries to LRU head initially
Date: Fri,  6 Jul 2018 15:32:50 -0400
Message-Id: <1530905572-817-6-git-send-email-longman@redhat.com>
In-Reply-To: <1530905572-817-1-git-send-email-longman@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Waiman Long <longman@redhat.com>

For negative dentries that are accessed once and never reused again,
there is not much value in putting the dentries at the tail of the LRU
list and keep it for a long time. So a new DCACHE_LRU_HEAD flag is added
to a negative dentry when it is initially created. When such a dentry
is added to the LRU, it will be added to the head so that it will be
the first to go when a shrinker is running. The flag is then cleared
after the LRU list addition. So if that dentry is accessed again,
it will be put back to the tail like the rest of the dentries.

By running a negative dentry generator for a certain period of time
and let the automatic pruning process to run through its course, the
number of negative and positive dentries discarded were:

	681 iterations, 43503/60 neg/pos dentries freed.
	45115 iterations, 2884992/64 neg/pos dentries freed.

So the number of positive dentries discarded is only 124.

Without this patch, the number of negative and positive dentries
discarded would be:

	20 iterations, 598/483 neg/pos dentries freed.
	60 iterations, 2977/517 neg/pos dentries freed.
	31 iterations, 1060/599 neg/pos dentries freed.
	11 iterations, 447/103 neg/pos dentries freed.
	17 iterations, 682/304 neg/pos dentries freed.
	17 iterations, 555/196 neg/pos dentries freed.
	33008 iterations, 2094860/7624 neg/pos dentries freed.

It can be seen that a lot more positive dentries would have been lost
as collateral damage in this case.

Suggested-by: Larry Woodman <lwoodman@redhat.com>
Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/dcache.c              | 18 +++++++++++++++++-
 include/linux/dcache.h   |  1 +
 include/linux/list_lru.h | 17 +++++++++++++++++
 mm/list_lru.c            | 19 +++++++++++++++++--
 4 files changed, 52 insertions(+), 3 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 3be9246..ec007ac 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -615,10 +615,23 @@ static void dentry_unlink_inode(struct dentry * dentry)
 #define D_FLAG_VERIFY(dentry,x) WARN_ON_ONCE(((dentry)->d_flags & (DCACHE_LRU_LIST | DCACHE_SHRINK_LIST)) != (x))
 static void d_lru_add(struct dentry *dentry)
 {
+	int ret;
+
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
-	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
+	if (unlikely(dentry->d_flags & DCACHE_LRU_HEAD)) {
+		/*
+		 * Add to the head once, it will be added to the tail
+		 * next time.
+		 */
+		ret = list_lru_add_head(&dentry->d_sb->s_dentry_lru,
+					&dentry->d_lru);
+		dentry->d_flags &= ~DCACHE_LRU_HEAD;
+	} else {
+		ret = list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru);
+	}
+	WARN_ON_ONCE(!ret);
 	neg_dentry_inc(dentry);
 }
 
@@ -2988,6 +3001,9 @@ static inline void __d_add(struct dentry *dentry, struct inode *inode)
 		__d_set_inode_and_type(dentry, inode, add_flags);
 		raw_write_seqcount_end(&dentry->d_seq);
 		fsnotify_update_flags(dentry);
+	} else {
+		/* It is a negative dentry, add it to LRU head initially. */
+		dentry->d_flags |= DCACHE_LRU_HEAD;
 	}
 	__d_rehash(dentry);
 	if (dir)
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 44e19d9..317e040 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -215,6 +215,7 @@ struct dentry_operations {
 #define DCACHE_FALLTHRU			0x01000000 /* Fall through to lower layer */
 #define DCACHE_ENCRYPTED_WITH_KEY	0x02000000 /* dir is encrypted with a valid key */
 #define DCACHE_OP_REAL			0x04000000
+#define DCACHE_LRU_HEAD 		0x08000000 /* Add to LRU head initially */
 
 #define DCACHE_PAR_LOOKUP		0x10000000 /* being looked up (with parent locked shared) */
 #define DCACHE_DENTRY_CURSOR		0x20000000
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index a9598a0..7856435 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -87,6 +87,23 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
 bool list_lru_add(struct list_lru *lru, struct list_head *item);
 
 /**
+ * list_lru_add_head: add an element to the lru list's head
+ * @list_lru: the lru pointer
+ * @item: the item to be added.
+ *
+ * This is similar to list_lru_add(). The only difference is the location
+ * where the new item will be added. The list_lru_add() function will add
+ * the new item to the tail as it is the most recently used one. The
+ * list_lru_add_head() will add the new item into the head so that it
+ * will the first to go if a shrinker is running. So this function should
+ * only be used for less important item that can be the first to go if
+ * the system is under memory pressure.
+ *
+ * Return value: true if the list was updated, false otherwise
+ */
+bool list_lru_add_head(struct list_lru *lru, struct list_head *item);
+
+/**
  * list_lru_del: delete an element to the lru list
  * @list_lru: the lru pointer
  * @item: the item to be deleted.
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 2ee5d3a..4ea3c1e 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -107,7 +107,8 @@ static inline bool list_lru_memcg_aware(struct list_lru *lru)
 }
 #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
 
-bool list_lru_add(struct list_lru *lru, struct list_head *item)
+static inline bool __list_lru_add(struct list_lru *lru, struct list_head *item,
+				  const bool add_tail)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
@@ -116,7 +117,10 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 	spin_lock(&nlru->lock);
 	if (list_empty(item)) {
 		l = list_lru_from_kmem(nlru, item);
-		list_add_tail(item, &l->list);
+		if (add_tail)
+			list_add_tail(item, &l->list);
+		else
+			list_add(item, &l->list);
 		l->nr_items++;
 		nlru->nr_items++;
 		spin_unlock(&nlru->lock);
@@ -125,8 +129,19 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 	spin_unlock(&nlru->lock);
 	return false;
 }
+
+bool list_lru_add(struct list_lru *lru, struct list_head *item)
+{
+	return __list_lru_add(lru, item, true);
+}
 EXPORT_SYMBOL_GPL(list_lru_add);
 
+bool list_lru_add_head(struct list_lru *lru, struct list_head *item)
+{
+	return __list_lru_add(lru, item, false);
+}
+EXPORT_SYMBOL_GPL(list_lru_add_head);
+
 bool list_lru_del(struct list_lru *lru, struct list_head *item)
 {
 	int nid = page_to_nid(virt_to_page(item));
-- 
1.8.3.1
