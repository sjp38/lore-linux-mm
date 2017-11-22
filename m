Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 919A06B025E
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:07:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 199so11234754pgg.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:07:50 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 91si14266625ply.498.2017.11.22.13.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:07:48 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 07/62] idr: Rewrite extended IDR API
Date: Wed, 22 Nov 2017 13:06:44 -0800
Message-Id: <20171122210739.29916-8-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Rename the API to be 'ul' for unsigned long instead of 'ext'.  This fits
better with other usage in the Linux kernel.

 - idr_replace(), idr_remove() and idr_find() can simply take an unsigned
   long index instead of an int.
 - idr_alloc() turns back into a regular function.
 - idr_alloc_ul() takes 'nextid' as an in-out parameter like idr_get_next(),
   instead of having 'index' as an out-only parameter.
 - idr_alloc_ul() needs a __must_check to ensure that users don't look at
   the result without checking whether the function succeeded.
 - idr_alloc_ul() takes 'max' rather than 'end', or it is impossible to
   allocate the ULONG_MAX id.  This differs from idr_alloc(), but so do
   many other things.
 - We don't need separate idr_get_free() and idr_get_free_ext().
 - Add kerneldoc for idr_alloc_ul().
 - Add an idr_alloc_u32() helper for the majority of existing users.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/idr.h        |  80 ++++++++----------------------------
 include/linux/radix-tree.h |  17 +-------
 lib/idr.c                  | 100 +++++++++++++++++++++++++++++++++------------
 lib/radix-tree.c           |   2 +-
 net/sched/act_api.c        |  60 +++++++++++++--------------
 net/sched/cls_basic.c      |  20 ++++-----
 net/sched/cls_bpf.c        |  20 ++++-----
 net/sched/cls_flower.c     |  32 ++++++---------
 net/sched/cls_u32.c        |  44 +++++++++-----------
 9 files changed, 171 insertions(+), 204 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 10bfe62423df..87ae635fcee6 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -54,73 +54,30 @@ struct idr {
 
 void idr_preload(gfp_t gfp_mask);
 
-int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
-		  unsigned long start, unsigned long end, gfp_t gfp,
-		  bool ext);
-
-/**
- * idr_alloc - allocate an id
- * @idr: idr handle
- * @ptr: pointer to be associated with the new id
- * @start: the minimum id (inclusive)
- * @end: the maximum id (exclusive)
- * @gfp: memory allocation flags
- *
- * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
- * if there are no unused IDs in that range.
- *
- * Note that @end is treated as max when <= 0.  This is to always allow
- * using @start + N as @end as long as N is inside integer range.
- *
- * Simultaneous modifications to the @idr are not allowed and should be
- * prevented by the user, usually with a lock.  idr_alloc() may be called
- * concurrently with read-only accesses to the @idr, such as idr_find() and
- * idr_for_each_entry().
- */
-static inline int idr_alloc(struct idr *idr, void *ptr,
-			    int start, int end, gfp_t gfp)
-{
-	unsigned long id;
-	int ret;
-
-	if (WARN_ON_ONCE(start < 0))
-		return -EINVAL;
-
-	ret = idr_alloc_cmn(idr, ptr, &id, start, end, gfp, false);
-
-	if (ret)
-		return ret;
-
-	return id;
-}
-
-static inline int idr_alloc_ext(struct idr *idr, void *ptr,
-				unsigned long *index,
-				unsigned long start,
-				unsigned long end,
-				gfp_t gfp)
-{
-	return idr_alloc_cmn(idr, ptr, index, start, end, gfp, true);
-}
-
+int idr_alloc(struct idr *, void *, int start, int end, gfp_t);
+int __must_check idr_alloc_ul(struct idr *, void *, unsigned long *nextid,
+			unsigned long max, gfp_t);
 int idr_alloc_cyclic(struct idr *, int *cursor, void *entry,
 			int start, int end, gfp_t);
 int idr_for_each(const struct idr *,
 		 int (*fn)(int id, void *p, void *data), void *data);
 void *idr_get_next(struct idr *, int *nextid);
-void *idr_get_next_ext(struct idr *idr, unsigned long *nextid);
-void *idr_replace(struct idr *, void *, int id);
-void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id);
+void *idr_get_next_ul(struct idr *, unsigned long *nextid);
+void *idr_replace(struct idr *, void *, unsigned long id);
 void idr_destroy(struct idr *);
 
-static inline void *idr_remove_ext(struct idr *idr, unsigned long id)
+static inline int __must_check idr_alloc_u32(struct idr *idr, void *ptr,
+				u32 *nextid, unsigned long max, gfp_t gfp)
 {
-	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
+	unsigned long tmp = *nextid;
+	int ret = idr_alloc_ul(idr, ptr, &tmp, max, gfp);
+	*nextid = tmp;
+	return ret;
 }
 
-static inline void *idr_remove(struct idr *idr, int id)
+static inline void *idr_remove(struct idr *idr, unsigned long id)
 {
-	return idr_remove_ext(idr, id);
+	return radix_tree_delete_item(&idr->idr_rt, id, NULL);
 }
 
 static inline void idr_init(struct idr *idr)
@@ -157,16 +114,11 @@ static inline void idr_preload_end(void)
  * This function can be called under rcu_read_lock(), given that the leaf
  * pointers lifetimes are correctly managed.
  */
-static inline void *idr_find_ext(const struct idr *idr, unsigned long id)
+static inline void *idr_find(const struct idr *idr, unsigned long id)
 {
 	return radix_tree_lookup(&idr->idr_rt, id);
 }
 
-static inline void *idr_find(const struct idr *idr, int id)
-{
-	return idr_find_ext(idr, id);
-}
-
 /**
  * idr_for_each_entry - iterate over an idr's elements of a given type
  * @idr:     idr handle
@@ -179,8 +131,8 @@ static inline void *idr_find(const struct idr *idr, int id)
  */
 #define idr_for_each_entry(idr, entry, id)			\
 	for (id = 0; ((entry) = idr_get_next(idr, &(id))) != NULL; ++id)
-#define idr_for_each_entry_ext(idr, entry, id)			\
-	for (id = 0; ((entry) = idr_get_next_ext(idr, &(id))) != NULL; ++id)
+#define idr_for_each_entry_ul(idr, entry, id)			\
+	for (id = 0; ((entry) = idr_get_next_ul(idr, &(id))) != NULL; ++id)
 
 /**
  * idr_for_each_entry_continue - continue iteration over an idr's elements of a given type
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 23a9c89c7ad9..fc55ff31eca7 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -356,24 +356,9 @@ int radix_tree_split(struct radix_tree_root *, unsigned long index,
 int radix_tree_join(struct radix_tree_root *, unsigned long index,
 			unsigned new_order, void *);
 
-void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
+void __rcu **idr_get_free(struct radix_tree_root *root,
 			      struct radix_tree_iter *iter, gfp_t gfp,
 			      unsigned long max);
-static inline void __rcu **idr_get_free(struct radix_tree_root *root,
-					struct radix_tree_iter *iter,
-					gfp_t gfp,
-					int end)
-{
-	return idr_get_free_cmn(root, iter, gfp, end > 0 ? end - 1 : INT_MAX);
-}
-
-static inline void __rcu **idr_get_free_ext(struct radix_tree_root *root,
-					    struct radix_tree_iter *iter,
-					    gfp_t gfp,
-					    unsigned long end)
-{
-	return idr_get_free_cmn(root, iter, gfp, end - 1);
-}
 
 enum {
 	RADIX_TREE_ITER_TAG_MASK = 0x0f,	/* tag index in lower nybble */
diff --git a/lib/idr.c b/lib/idr.c
index 26cb99412b8f..35678388e134 100644
--- a/lib/idr.c
+++ b/lib/idr.c
@@ -7,9 +7,26 @@
 DEFINE_PER_CPU(struct ida_bitmap *, ida_bitmap);
 static DEFINE_SPINLOCK(simple_ida_lock);
 
-int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
-		  unsigned long start, unsigned long end, gfp_t gfp,
-		  bool ext)
+/**
+ * idr_alloc_ul() - allocate a large ID
+ * @idr: idr handle
+ * @ptr: pointer to be associated with the new ID
+ * @nextid: Pointer to minimum ID to allocate
+ * @max: the maximum ID (inclusive)
+ * @gfp: memory allocation flags
+ *
+ * Allocates an unused ID in the range [*nextid, end] and stores it in
+ * @nextid.  Note that @max differs from the @end parameter to idr_alloc().
+ *
+ * Simultaneous modifications to the @idr are not allowed and should be
+ * prevented by the user, usually with a lock.  idr_alloc_ul() may be called
+ * concurrently with read-only accesses to the @idr, such as idr_find() and
+ * idr_for_each_entry().
+ *
+ * Return: 0 on success or a negative errno on failure (ENOMEM or ENOSPC)
+ */
+int idr_alloc_ul(struct idr *idr, void *ptr, unsigned long *nextid,
+			unsigned long max, gfp_t gfp)
 {
 	struct radix_tree_iter iter;
 	void __rcu **slot;
@@ -20,22 +37,54 @@ int idr_alloc_cmn(struct idr *idr, void *ptr, unsigned long *index,
 	if (WARN_ON_ONCE(!(idr->idr_rt.gfp_mask & ROOT_IS_IDR)))
 		idr->idr_rt.gfp_mask |= IDR_RT_MARKER;
 
-	radix_tree_iter_init(&iter, start);
-	if (ext)
-		slot = idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
-	else
-		slot = idr_get_free(&idr->idr_rt, &iter, gfp, end);
+	radix_tree_iter_init(&iter, *nextid);
+	slot = idr_get_free(&idr->idr_rt, &iter, gfp, max);
 	if (IS_ERR(slot))
 		return PTR_ERR(slot);
 
 	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
 	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
 
-	if (index)
-		*index = iter.index;
+	*nextid = iter.index;
 	return 0;
 }
-EXPORT_SYMBOL_GPL(idr_alloc_cmn);
+EXPORT_SYMBOL_GPL(idr_alloc_ul);
+
+/**
+ * idr_alloc - allocate an id
+ * @idr: idr handle
+ * @ptr: pointer to be associated with the new id
+ * @start: the minimum id (inclusive)
+ * @end: the maximum id (exclusive)
+ * @gfp: memory allocation flags
+ *
+ * Allocates an unused ID in the range [start, end).  Returns -ENOSPC
+ * if there are no unused IDs in that range.
+ *
+ * Note that @end is treated as max when <= 0.  This is to always allow
+ * using @start + N as @end as long as N is inside integer range.
+ *
+ * Simultaneous modifications to the @idr are not allowed and should be
+ * prevented by the user, usually with a lock.  idr_alloc() may be called
+ * concurrently with read-only accesses to the @idr, such as idr_find() and
+ * idr_for_each_entry().
+ */
+int idr_alloc(struct idr *idr, void *ptr, int start, int end, gfp_t gfp)
+{
+	unsigned long id = start;
+	int ret;
+
+	if (WARN_ON_ONCE(start < 0))
+		return -EINVAL;
+
+	ret = idr_alloc_ul(idr, ptr, &id, end > 0 ? end - 1 : INT_MAX, gfp);
+
+	if (ret)
+		return ret;
+
+	return id;
+}
+EXPORT_SYMBOL_GPL(idr_alloc);
 
 /**
  * idr_alloc_cyclic() - Allocate new idr entry in a cyclical fashion.
@@ -126,7 +175,17 @@ void *idr_get_next(struct idr *idr, int *nextid)
 }
 EXPORT_SYMBOL(idr_get_next);
 
-void *idr_get_next_ext(struct idr *idr, unsigned long *nextid)
+/**
+ * idr_get_next_ul - Find next populated entry
+ * @idr: idr handle
+ * @nextid: Pointer to lowest possible ID to return
+ *
+ * Returns the next populated entry in the tree with an ID greater than
+ * or equal to the value pointed to by @nextid.  On exit, @nextid is updated
+ * to the ID of the found value.  To use in a loop, the value pointed to by
+ * nextid must be incremented by the user.
+ */
+void *idr_get_next_ul(struct idr *idr, unsigned long *nextid)
 {
 	struct radix_tree_iter iter;
 	void __rcu **slot;
@@ -138,7 +197,7 @@ void *idr_get_next_ext(struct idr *idr, unsigned long *nextid)
 	*nextid = iter.index;
 	return rcu_dereference_raw(*slot);
 }
-EXPORT_SYMBOL(idr_get_next_ext);
+EXPORT_SYMBOL(idr_get_next_ul);
 
 /**
  * idr_replace - replace pointer for given id
@@ -154,16 +213,7 @@ EXPORT_SYMBOL(idr_get_next_ext);
  * Returns: the old value on success.  %-ENOENT indicates that @id was not
  * found.  %-EINVAL indicates that @id or @ptr were not valid.
  */
-void *idr_replace(struct idr *idr, void *ptr, int id)
-{
-	if (id < 0)
-		return ERR_PTR(-EINVAL);
-
-	return idr_replace_ext(idr, ptr, id);
-}
-EXPORT_SYMBOL(idr_replace);
-
-void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id)
+void *idr_replace(struct idr *idr, void *ptr, unsigned long id)
 {
 	struct radix_tree_node *node;
 	void __rcu **slot = NULL;
@@ -180,7 +230,7 @@ void *idr_replace_ext(struct idr *idr, void *ptr, unsigned long id)
 
 	return entry;
 }
-EXPORT_SYMBOL(idr_replace_ext);
+EXPORT_SYMBOL(idr_replace);
 
 /**
  * DOC: IDA description
@@ -240,7 +290,7 @@ EXPORT_SYMBOL(idr_replace_ext);
  * bitmap, which is excessive.
  */
 
-#define IDA_MAX (0x80000000U / IDA_BITMAP_BITS)
+#define IDA_MAX (0x80000000U / IDA_BITMAP_BITS - 1)
 
 /**
  * ida_get_new_above - allocate new ID above or equal to a start id
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f00303e0b216..6d29ca4c8db0 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -2135,7 +2135,7 @@ int ida_pre_get(struct ida *ida, gfp_t gfp)
 }
 EXPORT_SYMBOL(ida_pre_get);
 
-void __rcu **idr_get_free_cmn(struct radix_tree_root *root,
+void __rcu **idr_get_free(struct radix_tree_root *root,
 			      struct radix_tree_iter *iter, gfp_t gfp,
 			      unsigned long max)
 {
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 4d33a50a8a6d..a6aa606b5e99 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -78,7 +78,7 @@ static void free_tcf(struct tc_action *p)
 static void tcf_idr_remove(struct tcf_idrinfo *idrinfo, struct tc_action *p)
 {
 	spin_lock_bh(&idrinfo->lock);
-	idr_remove_ext(&idrinfo->action_idr, p->tcfa_index);
+	idr_remove(&idrinfo->action_idr, p->tcfa_index);
 	spin_unlock_bh(&idrinfo->lock);
 	gen_kill_estimator(&p->tcfa_rate_est);
 	free_tcf(p);
@@ -124,7 +124,7 @@ static int tcf_dump_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 
 	s_i = cb->args[0];
 
-	idr_for_each_entry_ext(idr, p, id) {
+	idr_for_each_entry_ul(idr, p, id) {
 		index++;
 		if (index < s_i)
 			continue;
@@ -181,7 +181,7 @@ static int tcf_del_walker(struct tcf_idrinfo *idrinfo, struct sk_buff *skb,
 	if (nla_put_string(skb, TCA_KIND, ops->kind))
 		goto nla_put_failure;
 
-	idr_for_each_entry_ext(idr, p, id) {
+	idr_for_each_entry_ul(idr, p, id) {
 		ret = __tcf_idr_release(p, false, true);
 		if (ret == ACT_P_DELETED) {
 			module_put(ops->owner);
@@ -219,10 +219,10 @@ EXPORT_SYMBOL(tcf_generic_walker);
 
 static struct tc_action *tcf_idr_lookup(u32 index, struct tcf_idrinfo *idrinfo)
 {
-	struct tc_action *p = NULL;
+	struct tc_action *p;
 
 	spin_lock_bh(&idrinfo->lock);
-	p = idr_find_ext(&idrinfo->action_idr, index);
+	p = idr_find(&idrinfo->action_idr, index);
 	spin_unlock_bh(&idrinfo->lock);
 
 	return p;
@@ -274,7 +274,6 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 	struct tcf_idrinfo *idrinfo = tn->idrinfo;
 	struct idr *idr = &idrinfo->action_idr;
 	int err = -ENOMEM;
-	unsigned long idr_index;
 
 	if (unlikely(!p))
 		return -ENOMEM;
@@ -284,45 +283,34 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 
 	if (cpustats) {
 		p->cpu_bstats = netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
-		if (!p->cpu_bstats) {
-err1:
-			kfree(p);
-			return err;
-		}
-		p->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
-		if (!p->cpu_qstats) {
-err2:
-			free_percpu(p->cpu_bstats);
+		if (!p->cpu_bstats)
 			goto err1;
-		}
+		p->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
+		if (!p->cpu_qstats)
+			goto err2;
 	}
 	spin_lock_init(&p->tcfa_lock);
 	/* user doesn't specify an index */
 	if (!index) {
+		index = 1;
 		idr_preload(GFP_KERNEL);
 		spin_lock_bh(&idrinfo->lock);
-		err = idr_alloc_ext(idr, NULL, &idr_index, 1, 0,
-				    GFP_ATOMIC);
+		err = idr_alloc_u32(idr, NULL, &index, UINT_MAX, GFP_ATOMIC);
 		spin_unlock_bh(&idrinfo->lock);
 		idr_preload_end();
-		if (err) {
-err3:
-			free_percpu(p->cpu_qstats);
-			goto err2;
-		}
-		p->tcfa_index = idr_index;
+		if (err)
+			goto err3;
 	} else {
 		idr_preload(GFP_KERNEL);
 		spin_lock_bh(&idrinfo->lock);
-		err = idr_alloc_ext(idr, NULL, NULL, index, index + 1,
-				    GFP_ATOMIC);
+		err = idr_alloc_u32(idr, NULL, &index, index, GFP_ATOMIC);
 		spin_unlock_bh(&idrinfo->lock);
 		idr_preload_end();
 		if (err)
 			goto err3;
-		p->tcfa_index = index;
 	}
 
+	p->tcfa_index = index;
 	p->tcfa_tm.install = jiffies;
 	p->tcfa_tm.lastuse = jiffies;
 	p->tcfa_tm.firstuse = 0;
@@ -330,9 +318,8 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 		err = gen_new_estimator(&p->tcfa_bstats, p->cpu_bstats,
 					&p->tcfa_rate_est,
 					&p->tcfa_lock, NULL, est);
-		if (err) {
-			goto err3;
-		}
+		if (err)
+			goto err4;
 	}
 
 	p->idrinfo = idrinfo;
@@ -340,6 +327,15 @@ int tcf_idr_create(struct tc_action_net *tn, u32 index, struct nlattr *est,
 	INIT_LIST_HEAD(&p->list);
 	*a = p;
 	return 0;
+err4:
+	idr_remove(idr, index);
+err3:
+	free_percpu(p->cpu_qstats);
+err2:
+	free_percpu(p->cpu_bstats);
+err1:
+	kfree(p);
+	return err;
 }
 EXPORT_SYMBOL(tcf_idr_create);
 
@@ -348,7 +344,7 @@ void tcf_idr_insert(struct tc_action_net *tn, struct tc_action *a)
 	struct tcf_idrinfo *idrinfo = tn->idrinfo;
 
 	spin_lock_bh(&idrinfo->lock);
-	idr_replace_ext(&idrinfo->action_idr, a, a->tcfa_index);
+	idr_replace(&idrinfo->action_idr, a, a->tcfa_index);
 	spin_unlock_bh(&idrinfo->lock);
 }
 EXPORT_SYMBOL(tcf_idr_insert);
@@ -361,7 +357,7 @@ void tcf_idrinfo_destroy(const struct tc_action_ops *ops,
 	int ret;
 	unsigned long id = 1;
 
-	idr_for_each_entry_ext(idr, p, id) {
+	idr_for_each_entry_ul(idr, p, id) {
 		ret = __tcf_idr_release(p, false, true);
 		if (ret == ACT_P_DELETED)
 			module_put(ops->owner);
diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
index 5f169ded347e..c2ff835639ed 100644
--- a/net/sched/cls_basic.c
+++ b/net/sched/cls_basic.c
@@ -120,7 +120,7 @@ static void basic_destroy(struct tcf_proto *tp)
 	list_for_each_entry_safe(f, n, &head->flist, link) {
 		list_del_rcu(&f->link);
 		tcf_unbind_filter(tp, &f->res);
-		idr_remove_ext(&head->handle_idr, f->handle);
+		idr_remove(&head->handle_idr, f->handle);
 		if (tcf_exts_get_net(&f->exts))
 			call_rcu(&f->rcu, basic_delete_filter);
 		else
@@ -137,7 +137,7 @@ static int basic_delete(struct tcf_proto *tp, void *arg, bool *last)
 
 	list_del_rcu(&f->link);
 	tcf_unbind_filter(tp, &f->res);
-	idr_remove_ext(&head->handle_idr, f->handle);
+	idr_remove(&head->handle_idr, f->handle);
 	tcf_exts_get_net(&f->exts);
 	call_rcu(&f->rcu, basic_delete_filter);
 	*last = list_empty(&head->flist);
@@ -182,7 +182,6 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	struct nlattr *tb[TCA_BASIC_MAX + 1];
 	struct basic_filter *fold = (struct basic_filter *) *arg;
 	struct basic_filter *fnew;
-	unsigned long idr_index;
 
 	if (tca[TCA_OPTIONS] == NULL)
 		return -EINVAL;
@@ -208,30 +207,29 @@ static int basic_change(struct net *net, struct sk_buff *in_skb,
 	if (handle) {
 		fnew->handle = handle;
 		if (!fold) {
-			err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
-					    handle, handle + 1, GFP_KERNEL);
+			err = idr_alloc_u32(&head->handle_idr, fnew, &handle,
+						handle, GFP_KERNEL);
 			if (err)
 				goto errout;
 		}
 	} else {
-		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
-				    1, 0x7FFFFFFF, GFP_KERNEL);
-		if (err)
+		err = idr_alloc(&head->handle_idr, fnew, 1, 0, GFP_KERNEL);
+		if (err < 0)
 			goto errout;
-		fnew->handle = idr_index;
+		fnew->handle = err;
 	}
 
 	err = basic_set_parms(net, tp, fnew, base, tb, tca[TCA_RATE], ovr);
 	if (err < 0) {
 		if (!fold)
-			idr_remove_ext(&head->handle_idr, fnew->handle);
+			idr_remove(&head->handle_idr, fnew->handle);
 		goto errout;
 	}
 
 	*arg = fnew;
 
 	if (fold) {
-		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
+		idr_replace(&head->handle_idr, fnew, fnew->handle);
 		list_replace_rcu(&fold->link, &fnew->link);
 		tcf_unbind_filter(tp, &fold->res);
 		tcf_exts_get_net(&fold->exts);
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index fb680dafac5a..b575d41543df 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -294,7 +294,7 @@ static void __cls_bpf_delete(struct tcf_proto *tp, struct cls_bpf_prog *prog)
 {
 	struct cls_bpf_head *head = rtnl_dereference(tp->root);
 
-	idr_remove_ext(&head->handle_idr, prog->handle);
+	idr_remove(&head->handle_idr, prog->handle);
 	cls_bpf_stop_offload(tp, prog);
 	list_del_rcu(&prog->link);
 	tcf_unbind_filter(tp, &prog->res);
@@ -469,7 +469,6 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_bpf_prog *oldprog = *arg;
 	struct nlattr *tb[TCA_BPF_MAX + 1];
 	struct cls_bpf_prog *prog;
-	unsigned long idr_index;
 	int ret;
 
 	if (tca[TCA_OPTIONS] == NULL)
@@ -496,15 +495,14 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	}
 
 	if (handle == 0) {
-		ret = idr_alloc_ext(&head->handle_idr, prog, &idr_index,
-				    1, 0x7FFFFFFF, GFP_KERNEL);
-		if (ret)
+		ret = idr_alloc(&head->handle_idr, prog, 1, 0, GFP_KERNEL);
+		if (ret < 0)
 			goto errout;
-		prog->handle = idr_index;
+		prog->handle = ret;
 	} else {
 		if (!oldprog) {
-			ret = idr_alloc_ext(&head->handle_idr, prog, &idr_index,
-					    handle, handle + 1, GFP_KERNEL);
+			ret = idr_alloc_u32(&head->handle_idr, prog, &handle,
+						handle, GFP_KERNEL);
 			if (ret)
 				goto errout;
 		}
@@ -518,7 +516,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 	ret = cls_bpf_offload(tp, prog, oldprog);
 	if (ret) {
 		if (!oldprog)
-			idr_remove_ext(&head->handle_idr, prog->handle);
+			idr_remove(&head->handle_idr, prog->handle);
 		__cls_bpf_delete_prog(prog);
 		return ret;
 	}
@@ -527,7 +525,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 		prog->gen_flags |= TCA_CLS_FLAGS_NOT_IN_HW;
 
 	if (oldprog) {
-		idr_replace_ext(&head->handle_idr, prog, handle);
+		idr_replace(&head->handle_idr, prog, handle);
 		list_replace_rcu(&oldprog->link, &prog->link);
 		tcf_unbind_filter(tp, &oldprog->res);
 		tcf_exts_get_net(&oldprog->exts);
@@ -541,7 +539,7 @@ static int cls_bpf_change(struct net *net, struct sk_buff *in_skb,
 
 errout_idr:
 	if (!oldprog)
-		idr_remove_ext(&head->handle_idr, prog->handle);
+		idr_remove(&head->handle_idr, prog->handle);
 errout:
 	tcf_exts_destroy(&prog->exts);
 	kfree(prog);
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 543a3e875d05..0867fa7bef5b 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -283,7 +283,7 @@ static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 
-	idr_remove_ext(&head->handle_idr, f->handle);
+	idr_remove(&head->handle_idr, f->handle);
 	list_del_rcu(&f->list);
 	if (!tc_skip_hw(f->flags))
 		fl_hw_destroy_filter(tp, f);
@@ -329,7 +329,7 @@ static void *fl_get(struct tcf_proto *tp, u32 handle)
 {
 	struct cls_fl_head *head = rtnl_dereference(tp->root);
 
-	return idr_find_ext(&head->handle_idr, handle);
+	return idr_find(&head->handle_idr, handle);
 }
 
 static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
@@ -858,7 +858,6 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	struct cls_fl_filter *fnew;
 	struct nlattr **tb;
 	struct fl_flow_mask mask = {};
-	unsigned long idr_index;
 	int err;
 
 	if (!tca[TCA_OPTIONS])
@@ -889,21 +888,15 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 		goto errout;
 
 	if (!handle) {
-		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
-				    1, 0x80000000, GFP_KERNEL);
-		if (err)
-			goto errout;
-		fnew->handle = idr_index;
-	}
-
-	/* user specifies a handle and it doesn't exist */
-	if (handle && !fold) {
-		err = idr_alloc_ext(&head->handle_idr, fnew, &idr_index,
-				    handle, handle + 1, GFP_KERNEL);
-		if (err)
-			goto errout;
-		fnew->handle = idr_index;
+		err = idr_alloc(&head->handle_idr, fnew, 1, 0, GFP_KERNEL);
+	} else if (!fold) {
+		/* user specifies a handle and it doesn't exist */
+		err = idr_alloc_u32(&head->handle_idr, fnew, &handle,
+				    handle, GFP_KERNEL);
 	}
+	if (err < 0)
+		goto errout;
+	fnew->handle = handle;
 
 	if (tb[TCA_FLOWER_FLAGS]) {
 		fnew->flags = nla_get_u32(tb[TCA_FLOWER_FLAGS]);
@@ -957,8 +950,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 	*arg = fnew;
 
 	if (fold) {
-		fnew->handle = handle;
-		idr_replace_ext(&head->handle_idr, fnew, fnew->handle);
+		idr_replace(&head->handle_idr, fnew, fnew->handle);
 		list_replace_rcu(&fold->list, &fnew->list);
 		tcf_unbind_filter(tp, &fold->res);
 		tcf_exts_get_net(&fold->exts);
@@ -972,7 +964,7 @@ static int fl_change(struct net *net, struct sk_buff *in_skb,
 
 errout_idr:
 	if (fnew->handle)
-		idr_remove_ext(&head->handle_idr, fnew->handle);
+		idr_remove(&head->handle_idr, fnew->handle);
 errout:
 	tcf_exts_destroy(&fnew->exts);
 	kfree(fnew);
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index ac152b4f4247..9260f7d14ab9 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -316,19 +316,16 @@ static void *u32_get(struct tcf_proto *tp, u32 handle)
 	return u32_lookup_key(ht, handle);
 }
 
+/*
+ * This is only used inside rtnl lock it is safe to increment
+ * without read _copy_ update semantics
+ */
 static u32 gen_new_htid(struct tc_u_common *tp_c, struct tc_u_hnode *ptr)
 {
-	unsigned long idr_index;
-	int err;
-
-	/* This is only used inside rtnl lock it is safe to increment
-	 * without read _copy_ update semantics
-	 */
-	err = idr_alloc_ext(&tp_c->handle_idr, ptr, &idr_index,
-			    1, 0x7FF, GFP_KERNEL);
-	if (err)
+	int id = idr_alloc(&tp_c->handle_idr, ptr, 1, 0x7FF, GFP_KERNEL);
+	if (id < 0)
 		return 0;
-	return (u32)(idr_index | 0x800) << 20;
+	return ((u32)id | 0x800) << 20;
 }
 
 static struct hlist_head *tc_u_common_hash;
@@ -591,7 +588,7 @@ static void u32_clear_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 					 rtnl_dereference(n->next));
 			tcf_unbind_filter(tp, &n->res);
 			u32_remove_hw_knode(tp, n->handle);
-			idr_remove_ext(&ht->handle_idr, n->handle);
+			idr_remove(&ht->handle_idr, n->handle);
 			if (tcf_exts_get_net(&n->exts))
 				call_rcu(&n->rcu, u32_delete_key_freepf_rcu);
 			else
@@ -617,7 +614,7 @@ static int u32_destroy_hnode(struct tcf_proto *tp, struct tc_u_hnode *ht)
 		if (phn == ht) {
 			u32_clear_hw_hnode(tp, ht);
 			idr_destroy(&ht->handle_idr);
-			idr_remove_ext(&tp_c->handle_idr, ht->handle);
+			idr_remove(&tp_c->handle_idr, ht->handle);
 			RCU_INIT_POINTER(*hn, ht->next);
 			kfree_rcu(ht, rcu);
 			return 0;
@@ -736,15 +733,15 @@ static int u32_delete(struct tcf_proto *tp, void *arg, bool *last)
 
 static u32 gen_new_kid(struct tc_u_hnode *ht, u32 htid)
 {
-	unsigned long idr_index;
 	u32 start = htid | 0x800;
 	u32 max = htid | 0xFFF;
 	u32 min = htid;
+	unsigned long idr_index = start;
 
-	if (idr_alloc_ext(&ht->handle_idr, NULL, &idr_index,
-			  start, max + 1, GFP_KERNEL)) {
-		if (idr_alloc_ext(&ht->handle_idr, NULL, &idr_index,
-				  min + 1, max + 1, GFP_KERNEL))
+	if (idr_alloc_ul(&ht->handle_idr, NULL, &idr_index, max, GFP_KERNEL)) {
+		idr_index = min + 1;
+		if (idr_alloc_ul(&ht->handle_idr, NULL, &idr_index, max,
+					GFP_KERNEL))
 			return max;
 	}
 
@@ -833,7 +830,7 @@ static void u32_replace_knode(struct tcf_proto *tp, struct tc_u_common *tp_c,
 		if (pins->handle == n->handle)
 			break;
 
-	idr_replace_ext(&ht->handle_idr, n, n->handle);
+	idr_replace(&ht->handle_idr, n, n->handle);
 	RCU_INIT_POINTER(n->next, pins->next);
 	rcu_assign_pointer(*ins, n);
 }
@@ -976,8 +973,8 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 				return -ENOMEM;
 			}
 		} else {
-			err = idr_alloc_ext(&tp_c->handle_idr, ht, NULL,
-					    handle, handle + 1, GFP_KERNEL);
+			err = idr_alloc_u32(&tp_c->handle_idr, ht, &handle,
+						handle, GFP_KERNEL);
 			if (err) {
 				kfree(ht);
 				return err;
@@ -992,7 +989,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 
 		err = u32_replace_hw_hnode(tp, ht, flags);
 		if (err) {
-			idr_remove_ext(&tp_c->handle_idr, handle);
+			idr_remove(&tp_c->handle_idr, handle);
 			kfree(ht);
 			return err;
 		}
@@ -1026,8 +1023,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		if (TC_U32_HTID(handle) && TC_U32_HTID(handle^htid))
 			return -EINVAL;
 		handle = htid | TC_U32_NODE(handle);
-		err = idr_alloc_ext(&ht->handle_idr, NULL, NULL,
-				    handle, handle + 1,
+		err = idr_alloc_u32(&ht->handle_idr, NULL, &handle, handle,
 				    GFP_KERNEL);
 		if (err)
 			return err;
@@ -1120,7 +1116,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 #endif
 	kfree(n);
 erridr:
-	idr_remove_ext(&ht->handle_idr, handle);
+	idr_remove(&ht->handle_idr, handle);
 	return err;
 }
 
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
