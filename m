Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 412216B0073
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 12:20:51 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id em10so10730949wid.1
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 09:20:50 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ei4si2703144wib.105.2014.10.14.09.20.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Oct 2014 09:20:49 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] mm: memcontrol: take a css reference for each charged page
Date: Tue, 14 Oct 2014 12:20:34 -0400
Message-Id: <1413303637-23862-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
References: <1413303637-23862-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Charges currently pin the css indirectly by playing tricks during
css_offline(): user pages stall the offlining process until all of
them have been reparented, whereas kmemcg acquires a keep-alive
reference if outstanding kernel pages are detected at that point.

In preparation for removing all this complexity, make the pinning
explicit and acquire a css references for every charged page.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/cgroup.h          | 26 +++++++++++++++++++++++
 include/linux/percpu-refcount.h | 47 +++++++++++++++++++++++++++++++++--------
 mm/memcontrol.c                 | 21 ++++++++++++++----
 3 files changed, 81 insertions(+), 13 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1d5196889048..9f96b25965c2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -113,6 +113,19 @@ static inline void css_get(struct cgroup_subsys_state *css)
 }
 
 /**
+ * css_get_many - obtain references on the specified css
+ * @css: target css
+ * @n: number of references to get
+ *
+ * The caller must already have a reference.
+ */
+static inline void css_get_many(struct cgroup_subsys_state *css, unsigned int n)
+{
+	if (!(css->flags & CSS_NO_REF))
+		percpu_ref_get_many(&css->refcnt, n);
+}
+
+/**
  * css_tryget - try to obtain a reference on the specified css
  * @css: target css
  *
@@ -159,6 +172,19 @@ static inline void css_put(struct cgroup_subsys_state *css)
 		percpu_ref_put(&css->refcnt);
 }
 
+/**
+ * css_put_many - put css references
+ * @css: target css
+ * @n: number of references to put
+ *
+ * Put references obtained via css_get() and css_tryget_online().
+ */
+static inline void css_put_many(struct cgroup_subsys_state *css, unsigned int n)
+{
+	if (!(css->flags & CSS_NO_REF))
+		percpu_ref_put_many(&css->refcnt, n);
+}
+
 /* bits in struct cgroup flags field */
 enum {
 	/* Control Group requires release notifications to userspace */
diff --git a/include/linux/percpu-refcount.h b/include/linux/percpu-refcount.h
index d5c89e0dd0e6..494ab0588b65 100644
--- a/include/linux/percpu-refcount.h
+++ b/include/linux/percpu-refcount.h
@@ -141,28 +141,42 @@ static inline bool __ref_is_percpu(struct percpu_ref *ref,
 }
 
 /**
- * percpu_ref_get - increment a percpu refcount
+ * percpu_ref_get_many - increment a percpu refcount
  * @ref: percpu_ref to get
+ * @nr: number of references to get
  *
- * Analagous to atomic_long_inc().
+ * Analogous to atomic_long_add().
  *
  * This function is safe to call as long as @ref is between init and exit.
  */
-static inline void percpu_ref_get(struct percpu_ref *ref)
+static inline void percpu_ref_get_many(struct percpu_ref *ref, unsigned long nr)
 {
 	unsigned long __percpu *percpu_count;
 
 	rcu_read_lock_sched();
 
 	if (__ref_is_percpu(ref, &percpu_count))
-		this_cpu_inc(*percpu_count);
+		this_cpu_add(*percpu_count, nr);
 	else
-		atomic_long_inc(&ref->count);
+		atomic_long_add(nr, &ref->count);
 
 	rcu_read_unlock_sched();
 }
 
 /**
+ * percpu_ref_get - increment a percpu refcount
+ * @ref: percpu_ref to get
+ *
+ * Analagous to atomic_long_inc().
+ *
+ * This function is safe to call as long as @ref is between init and exit.
+ */
+static inline void percpu_ref_get(struct percpu_ref *ref)
+{
+	percpu_ref_get_many(ref, 1);
+}
+
+/**
  * percpu_ref_tryget - try to increment a percpu refcount
  * @ref: percpu_ref to try-get
  *
@@ -225,29 +239,44 @@ static inline bool percpu_ref_tryget_live(struct percpu_ref *ref)
 }
 
 /**
- * percpu_ref_put - decrement a percpu refcount
+ * percpu_ref_put_many - decrement a percpu refcount
  * @ref: percpu_ref to put
+ * @nr: number of references to put
  *
  * Decrement the refcount, and if 0, call the release function (which was passed
  * to percpu_ref_init())
  *
  * This function is safe to call as long as @ref is between init and exit.
  */
-static inline void percpu_ref_put(struct percpu_ref *ref)
+static inline void percpu_ref_put_many(struct percpu_ref *ref, unsigned long nr)
 {
 	unsigned long __percpu *percpu_count;
 
 	rcu_read_lock_sched();
 
 	if (__ref_is_percpu(ref, &percpu_count))
-		this_cpu_dec(*percpu_count);
-	else if (unlikely(atomic_long_dec_and_test(&ref->count)))
+		this_cpu_sub(*percpu_count, nr);
+	else if (unlikely(atomic_long_sub_and_test(nr, &ref->count)))
 		ref->release(ref);
 
 	rcu_read_unlock_sched();
 }
 
 /**
+ * percpu_ref_put - decrement a percpu refcount
+ * @ref: percpu_ref to put
+ *
+ * Decrement the refcount, and if 0, call the release function (which was passed
+ * to percpu_ref_init())
+ *
+ * This function is safe to call as long as @ref is between init and exit.
+ */
+static inline void percpu_ref_put(struct percpu_ref *ref)
+{
+	percpu_ref_put_many(ref, 1);
+}
+
+/**
  * percpu_ref_is_zero - test whether a percpu refcount reached zero
  * @ref: percpu_ref to test
  *
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 67dabe8b0aa6..a3feead6be15 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2256,6 +2256,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 		page_counter_uncharge(&old->memory, stock->nr_pages);
 		if (do_swap_account)
 			page_counter_uncharge(&old->memsw, stock->nr_pages);
+		css_put_many(&old->css, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
 	stock->cached = NULL;
@@ -2513,6 +2514,7 @@ bypass:
 	return -EINTR;
 
 done_restock:
+	css_get_many(&memcg->css, batch);
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 done:
@@ -2527,6 +2529,8 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
 		page_counter_uncharge(&memcg->memsw, nr_pages);
+
+	css_put_many(&memcg->css, nr_pages);
 }
 
 /*
@@ -2722,6 +2726,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 		page_counter_charge(&memcg->memory, nr_pages);
 		if (do_swap_account)
 			page_counter_charge(&memcg->memsw, nr_pages);
+		css_get_many(&memcg->css, nr_pages);
 		ret = 0;
 	} else if (ret)
 		page_counter_uncharge(&memcg->kmem, nr_pages);
@@ -2737,8 +2742,10 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
 		page_counter_uncharge(&memcg->memsw, nr_pages);
 
 	/* Not down to 0 */
-	if (page_counter_uncharge(&memcg->kmem, nr_pages))
+	if (page_counter_uncharge(&memcg->kmem, nr_pages)) {
+		css_put_many(&memcg->css, nr_pages);
 		return;
+	}
 
 	/*
 	 * Releases a reference taken in kmem_cgroup_css_offline in case
@@ -2750,6 +2757,8 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
 	 */
 	if (memcg_kmem_test_and_clear_dead(memcg))
 		css_put(&memcg->css);
+
+	css_put_many(&memcg->css, nr_pages);
 }
 
 /*
@@ -3377,10 +3386,13 @@ static int mem_cgroup_move_parent(struct page *page,
 	ret = mem_cgroup_move_account(page, nr_pages,
 				pc, child, parent);
 	if (!ret) {
+		if (!mem_cgroup_is_root(parent))
+			css_get_many(&parent->css, nr_pages);
 		/* Take charge off the local counters */
 		page_counter_cancel(&child->memory, nr_pages);
 		if (do_swap_account)
 			page_counter_cancel(&child->memsw, nr_pages);
+		css_put_many(&child->css, nr_pages);
 	}
 
 	if (nr_pages > 1)
@@ -5750,7 +5762,6 @@ static void __mem_cgroup_clear_mc(void)
 {
 	struct mem_cgroup *from = mc.from;
 	struct mem_cgroup *to = mc.to;
-	int i;
 
 	/* we must uncharge all the leftover precharges from mc.to */
 	if (mc.precharge) {
@@ -5778,8 +5789,7 @@ static void __mem_cgroup_clear_mc(void)
 		if (!mem_cgroup_is_root(mc.to))
 			page_counter_uncharge(&mc.to->memory, mc.moved_swap);
 
-		for (i = 0; i < mc.moved_swap; i++)
-			css_put(&mc.from->css);
+		css_put_many(&mc.from->css, mc.moved_swap);
 
 		/* we've already done css_get(mc.to) */
 		mc.moved_swap = 0;
@@ -6326,6 +6336,9 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 	__this_cpu_add(memcg->stat->nr_page_events, nr_anon + nr_file);
 	memcg_check_events(memcg, dummy_page);
 	local_irq_restore(flags);
+
+	if (!mem_cgroup_is_root(memcg))
+		css_put_many(&memcg->css, max(nr_mem, nr_memsw));
 }
 
 static void uncharge_list(struct list_head *page_list)
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
