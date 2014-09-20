Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 164226B0037
	for <linux-mm@kvack.org>; Sat, 20 Sep 2014 16:00:47 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id y10so1169400wgg.26
        for <linux-mm@kvack.org>; Sat, 20 Sep 2014 13:00:47 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id lc8si6321249wjb.43.2014.09.20.13.00.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Sep 2014 13:00:46 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: memcontrol: take a css reference for each charged page
Date: Sat, 20 Sep 2014 16:00:33 -0400
Message-Id: <1411243235-24680-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
References: <1411243235-24680-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Charges currently pin the css indirectly by playing tricks during
css_offline(): user pages stall the offlining process until all of
them have been reparented, whereas kmemcg acquires a keep-alive
reference if outstanding kernel pages are detected at that point.

In preparation for removing all this complexity, make the pinning
explicit and acquire a css references for every charged page.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/cgroup.h          | 26 +++++++++++++++++++++++++
 include/linux/percpu-refcount.h | 43 ++++++++++++++++++++++++++++++++---------
 mm/memcontrol.c                 | 17 +++++++++++++++-
 3 files changed, 76 insertions(+), 10 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b5223c570eba..a9fe70d9c7c5 100644
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
 	/*
diff --git a/include/linux/percpu-refcount.h b/include/linux/percpu-refcount.h
index b1973ba1d5f3..a4551456e06f 100644
--- a/include/linux/percpu-refcount.h
+++ b/include/linux/percpu-refcount.h
@@ -112,26 +112,38 @@ static inline bool __pcpu_ref_alive(struct percpu_ref *ref,
 }
 
 /**
- * percpu_ref_get - increment a percpu refcount
+ * percpu_ref_get_many - increment a percpu refcount
  * @ref: percpu_ref to get
+ * @nr: number of references to get
  *
- * Analagous to atomic_inc().
+ * Analagous to atomic_add().
   */
-static inline void percpu_ref_get(struct percpu_ref *ref)
+static inline void percpu_ref_get_many(struct percpu_ref *ref, unsigned long nr)
 {
 	unsigned long __percpu *pcpu_count;
 
 	rcu_read_lock_sched();
 
 	if (__pcpu_ref_alive(ref, &pcpu_count))
-		this_cpu_inc(*pcpu_count);
+		this_cpu_add(*pcpu_count, nr);
 	else
-		atomic_long_inc(&ref->count);
+		atomic_long_add(nr, &ref->count);
 
 	rcu_read_unlock_sched();
 }
 
 /**
+ * percpu_ref_get - increment a percpu refcount
+ * @ref: percpu_ref to get
+ *
+ * Analagous to atomic_inc().
+  */
+static inline void percpu_ref_get(struct percpu_ref *ref)
+{
+	percpu_ref_get_many(ref, 1);
+}
+
+/**
  * percpu_ref_tryget - try to increment a percpu refcount
  * @ref: percpu_ref to try-get
  *
@@ -191,27 +203,40 @@ static inline bool percpu_ref_tryget_live(struct percpu_ref *ref)
 }
 
 /**
- * percpu_ref_put - decrement a percpu refcount
+ * percpu_ref_put_many - decrement a percpu refcount
  * @ref: percpu_ref to put
+ * @nr: number of references to put
  *
  * Decrement the refcount, and if 0, call the release function (which was passed
  * to percpu_ref_init())
  */
-static inline void percpu_ref_put(struct percpu_ref *ref)
+static inline void percpu_ref_put_many(struct percpu_ref *ref, unsigned long nr)
 {
 	unsigned long __percpu *pcpu_count;
 
 	rcu_read_lock_sched();
 
 	if (__pcpu_ref_alive(ref, &pcpu_count))
-		this_cpu_dec(*pcpu_count);
-	else if (unlikely(atomic_long_dec_and_test(&ref->count)))
+		this_cpu_sub(*pcpu_count, nr);
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
index 154161bb7d4c..b832c87ec43b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2317,6 +2317,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
 		page_counter_uncharge(&old->memory, stock->nr_pages);
 		if (do_swap_account)
 			page_counter_uncharge(&old->memsw, stock->nr_pages);
+		css_put_many(&old->css, stock->nr_pages);
 		stock->nr_pages = 0;
 	}
 	stock->cached = NULL;
@@ -2573,6 +2574,7 @@ bypass:
 	return -EINTR;
 
 done_restock:
+	css_get_many(&memcg->css, batch);
 	if (batch > nr_pages)
 		refill_stock(memcg, batch - nr_pages);
 done:
@@ -2587,6 +2589,8 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 	page_counter_uncharge(&memcg->memory, nr_pages);
 	if (do_swap_account)
 		page_counter_uncharge(&memcg->memsw, nr_pages);
+
+	css_put_many(&memcg->css, nr_pages);
 }
 
 /*
@@ -2788,6 +2792,7 @@ static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp,
 		page_counter_charge(&memcg->memory, nr_pages, NULL);
 		if (do_swap_account)
 			page_counter_charge(&memcg->memsw, nr_pages, NULL);
+		css_get_many(&memcg->css, nr_pages);
 		ret = 0;
 	} else if (ret)
 		page_counter_uncharge(&memcg->kmem, nr_pages);
@@ -2803,8 +2808,10 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
 		page_counter_uncharge(&memcg->memsw, nr_pages);
 
 	/* Not down to 0 */
-	if (page_counter_uncharge(&memcg->kmem, nr_pages))
+	if (page_counter_uncharge(&memcg->kmem, nr_pages)) {
+		css_put_many(&memcg->css, nr_pages);
 		return;
+	}
 
 	/*
 	 * Releases a reference taken in kmem_cgroup_css_offline in case
@@ -2816,6 +2823,8 @@ static void memcg_uncharge_kmem(struct mem_cgroup *memcg,
 	 */
 	if (memcg_kmem_test_and_clear_dead(memcg))
 		css_put(&memcg->css);
+
+	css_put_many(&memcg->css, nr_pages);
 }
 
 /*
@@ -3444,10 +3453,13 @@ static int mem_cgroup_move_parent(struct page *page,
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
@@ -6379,6 +6391,9 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 	__this_cpu_add(memcg->stat->nr_page_events, nr_anon + nr_file);
 	memcg_check_events(memcg, dummy_page);
 	local_irq_restore(flags);
+
+	if (!mem_cgroup_is_root(memcg))
+		css_put_many(&memcg->css, max(nr_mem, nr_memsw));
 }
 
 static void uncharge_list(struct list_head *page_list)
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
