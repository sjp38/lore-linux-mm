Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7DA76B4732
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 13:20:01 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id 93-v6so1877198qkq.7
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:20:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id i37-v6si1491275qti.112.2018.08.28.10.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 10:20:00 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [PATCH 2/2] fs/dcache: Make negative dentries easier to be reclaimed
Date: Tue, 28 Aug 2018 13:19:40 -0400
Message-Id: <1535476780-5773-3-git-send-email-longman@redhat.com>
In-Reply-To: <1535476780-5773-1-git-send-email-longman@redhat.com>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>, Waiman Long <longman@redhat.com>

For negative dentries that are accessed once and never used again, they
should be removed first before other dentries when shrinker is running.
This is done by putting negative dentries at the head of the LRU list
instead at the tail.

A new DCACHE_NEW_NEGATIVE flag is now added to a negative dentry when it
is initially created. When such a dentry is added to the LRU, it will be
added to the head so that it will be the first to go when a shrinker is
running if it is never accessed again (DCACHE_REFERENCED bit not set).
The flag is cleared after the LRU list addition.

Suggested-by: Larry Woodman <lwoodman@redhat.com>
Signed-off-by: Waiman Long <longman@redhat.com>
---
 fs/dcache.c              | 25 +++++++++++++++++--------
 include/linux/dcache.h   |  1 +
 include/linux/list_lru.h | 17 +++++++++++++++++
 mm/list_lru.c            | 16 ++++++++++++++--
 4 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 69f5541..ab6a4cf 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -242,12 +242,6 @@ static inline void __neg_dentry_inc(struct dentry *dentry)
 	this_cpu_inc(nr_dentry_neg);
 }
 
-static inline void neg_dentry_inc(struct dentry *dentry)
-{
-	if (unlikely(d_is_negative(dentry)))
-		__neg_dentry_inc(dentry);
-}
-
 static inline int dentry_cmp(const struct dentry *dentry, const unsigned char *ct, unsigned tcount)
 {
 	/*
@@ -353,7 +347,7 @@ static inline void __d_set_inode_and_type(struct dentry *dentry,
 
 	dentry->d_inode = inode;
 	flags = READ_ONCE(dentry->d_flags);
-	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU);
+	flags &= ~(DCACHE_ENTRY_TYPE | DCACHE_FALLTHRU | DCACHE_NEW_NEGATIVE);
 	flags |= type_flags;
 	WRITE_ONCE(dentry->d_flags, flags);
 }
@@ -430,8 +424,20 @@ static void d_lru_add(struct dentry *dentry)
 	D_FLAG_VERIFY(dentry, 0);
 	dentry->d_flags |= DCACHE_LRU_LIST;
 	this_cpu_inc(nr_dentry_unused);
+	if (d_is_negative(dentry)) {
+		__neg_dentry_inc(dentry);
+		if (dentry->d_flags & DCACHE_NEW_NEGATIVE) {
+			/*
+			 * Add the negative dentry to the head once, it
+			 * will be added to the tail next time.
+			 */
+			WARN_ON_ONCE(!list_lru_add_head(
+				&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
+			dentry->d_flags &= ~DCACHE_NEW_NEGATIVE;
+			return;
+		}
+	}
 	WARN_ON_ONCE(!list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru));
-	neg_dentry_inc(dentry);
 }
 
 static void d_lru_del(struct dentry *dentry)
@@ -2620,6 +2626,9 @@ static inline void __d_add(struct dentry *dentry, struct inode *inode)
 		__d_set_inode_and_type(dentry, inode, add_flags);
 		raw_write_seqcount_end(&dentry->d_seq);
 		fsnotify_update_flags(dentry);
+	} else {
+		/* It is a negative dentry, add it to LRU head initially. */
+		dentry->d_flags |= DCACHE_NEW_NEGATIVE;
 	}
 	__d_rehash(dentry);
 	if (dir)
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index df942e5..03a1918 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -214,6 +214,7 @@ struct dentry_operations {
 #define DCACHE_FALLTHRU			0x01000000 /* Fall through to lower layer */
 #define DCACHE_ENCRYPTED_WITH_KEY	0x02000000 /* dir is encrypted with a valid key */
 #define DCACHE_OP_REAL			0x04000000
+#define DCACHE_NEW_NEGATIVE		0x08000000 /* New negative dentry */
 
 #define DCACHE_PAR_LOOKUP		0x10000000 /* being looked up (with parent locked shared) */
 #define DCACHE_DENTRY_CURSOR		0x20000000
diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
index aa5efd9..bfac057 100644
--- a/include/linux/list_lru.h
+++ b/include/linux/list_lru.h
@@ -90,6 +90,23 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
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
index 5b30625..133f41c 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -124,7 +124,8 @@ static inline bool list_lru_memcg_aware(struct list_lru *lru)
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
-bool list_lru_add(struct list_lru *lru, struct list_head *item)
+static inline bool __list_lru_add(struct list_lru *lru, struct list_head *item,
+				  const bool add_tail)
 {
 	int nid = page_to_nid(virt_to_page(item));
 	struct list_lru_node *nlru = &lru->node[nid];
@@ -134,7 +135,7 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
 	spin_lock(&nlru->lock);
 	if (list_empty(item)) {
 		l = list_lru_from_kmem(nlru, item, &memcg);
-		list_add_tail(item, &l->list);
+		(add_tail ? list_add_tail : list_add)(item, &l->list);
 		/* Set shrinker bit if the first element was added */
 		if (!l->nr_items++)
 			memcg_set_shrinker_bit(memcg, nid,
@@ -146,8 +147,19 @@ bool list_lru_add(struct list_lru *lru, struct list_head *item)
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
