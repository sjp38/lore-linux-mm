Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 898A56B025E
	for <linux-mm@kvack.org>; Fri, 10 Jun 2016 12:14:12 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h144so134008779ita.1
        for <linux-mm@kvack.org>; Fri, 10 Jun 2016 09:14:12 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0103.outbound.protection.outlook.com. [157.55.234.103])
        by mx.google.com with ESMTPS id x143si6066484oif.121.2016.06.10.09.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 10 Jun 2016 09:14:11 -0700 (PDT)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH RFC] slub: reap free slabs periodically
Date: Fri, 10 Jun 2016 19:14:03 +0300
Message-ID: <1465575243-18882-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

SLUB stores a small number of free objects/slabs in per cpu/node caches
to reduce contention on per node locks. The amount of memory wasted by
this is limited by cpu_partial/min_partial tunables and is usually not
more than one-two slabs per cpu per cache. Assuming a slab's average
size being 4 pages, for a 24 cpu host with 20 actively used caches we
get ~10 MB overhead, which is not bad.

Things get substantially worse when cgroups get involved. Every cgroup
receives its own copy of each accounted kmem cache. As a result, if
there are hundreds of active containers, the overhead will be counted in
gigabytes, gigabytes of essentially free memory that cannot be reused,
even on memory pressure, and can only be released by writing 1 to
/sys/kernel/slab/<cache>/shrink. This effectively reduces the maximal
number of containers that can be packed in a physical server.

To cope with this problem, this patch introduces cache_reap for SLUB,
which acts similarly to SLAB's version: it drains per cpu caches every 2
seconds and per node caches every 4 seconds. In order to not affect
performance of frequently used caches, it skips those that have been
allocated from since the last scan, just like in case of SLAB.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/slub_def.h |   1 +
 mm/slab.h                |   2 +
 mm/slub.c                | 132 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 135 insertions(+)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d1faa019c02a..a73b86d450c8 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -42,6 +42,7 @@ struct kmem_cache_cpu {
 	unsigned long tid;	/* Globally unique transaction id */
 	struct page *page;	/* The slab from which we are allocating */
 	struct page *partial;	/* Partially allocated frozen slabs */
+	bool touched;
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
diff --git a/mm/slab.h b/mm/slab.h
index dedb1a920fb8..a8de23ce6b67 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -433,6 +433,8 @@ struct kmem_cache_node {
 #ifdef CONFIG_SLUB
 	unsigned long nr_partial;
 	struct list_head partial;
+	unsigned long next_reap;
+	bool touched;
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_t nr_slabs;
 	atomic_long_t total_objects;
diff --git a/mm/slub.c b/mm/slub.c
index 825ff4505336..375697783578 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -168,6 +168,11 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
  */
 #define MAX_PARTIAL 10
 
+#define REAPTIMEOUT_CPU		(2 * HZ)
+#define REAPTIMEOUT_NODE	(4 * HZ)
+
+static DEFINE_PER_CPU(struct delayed_work, cache_reap_work);
+
 #define DEBUG_DEFAULT_FLAGS (SLAB_CONSISTENCY_CHECKS | SLAB_RED_ZONE | \
 				SLAB_POISON | SLAB_STORE_USER)
 
@@ -1672,6 +1677,10 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 	int available = 0;
 	int objects;
 
+	/* Prevent cache_reap from draining this per node cache */
+	if (unlikely(!n->touched))
+		n->touched = true;
+
 	/*
 	 * Racy check. If we mistakenly see no partial slabs then we
 	 * just allocate an empty slab. If we mistakenly try to get a
@@ -2515,6 +2524,10 @@ redo:
 	} while (IS_ENABLED(CONFIG_PREEMPT) &&
 		 unlikely(tid != READ_ONCE(c->tid)));
 
+	/* Prevent cache_reap from draining this per cpu cache */
+	if (unlikely(!c->touched))
+		c->touched = true;
+
 	/*
 	 * Irqless object alloc/free algorithm used here depends on sequence
 	 * of fetching cpu_slab's data. tid should be fetched before anything
@@ -3119,6 +3132,9 @@ init_kmem_cache_node(struct kmem_cache_node *n)
 	n->nr_partial = 0;
 	spin_lock_init(&n->list_lock);
 	INIT_LIST_HEAD(&n->partial);
+	n->next_reap = jiffies + REAPTIMEOUT_NODE +
+			((unsigned long)n) % REAPTIMEOUT_NODE;
+	n->touched = false;
 #ifdef CONFIG_SLUB_DEBUG
 	atomic_long_set(&n->nr_slabs, 0);
 	atomic_long_set(&n->total_objects, 0);
@@ -3663,6 +3679,108 @@ void kfree(const void *x)
 }
 EXPORT_SYMBOL(kfree);
 
+static void cache_reap(struct work_struct *w)
+{
+	struct delayed_work *work = to_delayed_work(w);
+	int cpu = smp_processor_id();
+	int node = numa_mem_id();
+	struct kmem_cache *s;
+
+	BUG_ON(irqs_disabled());
+
+	if (!mutex_trylock(&slab_mutex))
+		/* Give up. Setup the next iteration. */
+		goto out;
+
+	list_for_each_entry(s, &slab_caches, list) {
+		struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
+		struct kmem_cache_node *n = get_node(s, node);
+		struct page *page, *t;
+		LIST_HEAD(discard);
+		int scanned = 0;
+
+		/* This cpu's cache was used recently, do not touch. */
+		if (c->touched) {
+			c->touched = false;
+			goto next;
+		}
+
+		local_irq_disable();
+		if (c->page)
+			flush_slab(s, c);
+		unfreeze_partials(s, c);
+		local_irq_enable();
+
+		/*
+		 * These are racy checks but it does not matter
+		 * if we skip one check or scan twice.
+		 */
+		if (time_after(n->next_reap, jiffies))
+			goto next;
+
+		n->next_reap = jiffies + REAPTIMEOUT_NODE;
+
+		/* This node's cache was used recently, do not touch. */
+		if (n->touched) {
+			n->touched = false;
+			goto next;
+		}
+
+		if (!n->nr_partial || !s->min_partial)
+			goto next;
+
+		spin_lock_irq(&n->list_lock);
+		list_for_each_entry_safe(page, t, &n->partial, lru) {
+			if (!page->inuse) {
+				list_move(&page->lru, &discard);
+				n->nr_partial--;
+			}
+			/*
+			 * Do not spend too much time trying to find all empty
+			 * slabs - if there are a lot of slabs on the partial
+			 * list, empty slabs shouldn't be a big problem, as
+			 * their number is limited by min_partial.
+			 */
+			if (++scanned >= s->min_partial * 4)
+				break;
+		}
+		spin_unlock_irq(&n->list_lock);
+
+		list_for_each_entry_safe(page, t, &discard, lru)
+			discard_slab(s, page);
+next:
+		cond_resched();
+	}
+
+	mutex_unlock(&slab_mutex);
+out:
+	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_CPU));
+}
+
+static void start_cache_reap(int cpu)
+{
+	struct delayed_work *work = &per_cpu(cache_reap_work, cpu);
+
+	schedule_delayed_work_on(cpu, work, __round_jiffies_relative(HZ, cpu));
+}
+
+static void stop_cache_reap(int cpu)
+{
+	struct delayed_work *work = &per_cpu(cache_reap_work, cpu);
+
+	cancel_delayed_work_sync(work);
+}
+
+static int __init init_cache_reap(void)
+{
+	int i;
+
+	for_each_online_cpu(i)
+		start_cache_reap(i);
+	return 0;
+}
+__initcall(init_cache_reap);
+
 #define SHRINK_PROMOTE_MAX 32
 
 /*
@@ -3914,6 +4032,7 @@ void __init kmem_cache_init(void)
 {
 	static __initdata struct kmem_cache boot_kmem_cache,
 		boot_kmem_cache_node;
+	int i;
 
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
@@ -3947,6 +4066,9 @@ void __init kmem_cache_init(void)
 	setup_kmalloc_cache_index_table();
 	create_kmalloc_caches(0);
 
+	for_each_possible_cpu(i)
+		INIT_DEFERRABLE_WORK(&per_cpu(cache_reap_work, i), cache_reap);
+
 #ifdef CONFIG_SMP
 	register_cpu_notifier(&slab_notifier);
 #endif
@@ -4026,6 +4148,16 @@ static int slab_cpuup_callback(struct notifier_block *nfb,
 	unsigned long flags;
 
 	switch (action) {
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+		stop_cache_reap(cpu);
+		break;
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+	case CPU_DOWN_FAILED:
+	case CPU_DOWN_FAILED_FROZEN:
+		start_cache_reap(cpu);
+		break;
 	case CPU_UP_CANCELED:
 	case CPU_UP_CANCELED_FROZEN:
 	case CPU_DEAD:
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
