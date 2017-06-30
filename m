Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0683F2802FE
	for <linux-mm@kvack.org>; Fri, 30 Jun 2017 06:15:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b189so6463496wmb.12
        for <linux-mm@kvack.org>; Fri, 30 Jun 2017 03:15:28 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id u48si5846515wrb.323.2017.06.30.03.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 30 Jun 2017 03:15:27 -0700 (PDT)
Date: Fri, 30 Jun 2017 12:15:21 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm/memory-hotplug: Switch locking to a percpu rwsem
In-Reply-To: <20170630092747.GD22917@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1706301210210.1748@nanos>
References: <alpine.DEB.2.20.1706291803380.1861@nanos> <20170630092747.GD22917@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

On Fri, 30 Jun 2017, Michal Hocko wrote:
> So I like this simplification a lot! Even if we can get rid of the
> stop_machine eventually this patch would be an improvement. A short
> comment on why the per-cpu semaphore over the regular one is better
> would be nice.

Yes, will add one.

The main point is that the current locking construct is evading lockdep due
to the ability to support recursive locking, which I did not observe so
far.

> I cannot give my ack yet, I have to mull over the patch some more because
> this has been an area of subtle bugs (especially the lock dependency with
> the hotplug device locking - look at lock_device_hotplug_sysfs if you
> dare) but it looks good from the first look. Give me few days, please.

Sure. Just to make you to mull over more stuff, find below the patch which
moves all of this to use the cpuhotplug lock.

Thanks,

	tglx

8<--------------------
Subject: mm/memory-hotplug: Use cpu hotplug lock
From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 29 Jun 2017 16:30:00 +0200

Most place which take the memory hotplug lock take the cpu hotplug lock as
well. Avoid the double locking and use the cpu hotplug lock for both.

Not-Yet-Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 drivers/base/memory.c          |    5 ++--
 include/linux/memory_hotplug.h |   12 -----------
 mm/kmemleak.c                  |    4 +--
 mm/memory-failure.c            |    5 ++--
 mm/memory_hotplug.c            |   44 +++++++++--------------------------------
 mm/slab_common.c               |   14 -------------
 mm/slub.c                      |    4 +--
 7 files changed, 20 insertions(+), 68 deletions(-)

Index: b/drivers/base/memory.c
===================================================================
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -21,6 +21,7 @@
 #include <linux/mutex.h>
 #include <linux/stat.h>
 #include <linux/slab.h>
+#include <linux/cpu.h>
 
 #include <linux/atomic.h>
 #include <linux/uaccess.h>
@@ -339,7 +340,7 @@ store_mem_state(struct device *dev,
 	 * inversion, memory_subsys_online() callbacks will be implemented by
 	 * assuming it's already protected.
 	 */
-	mem_hotplug_begin();
+	cpus_write_lock();
 
 	switch (online_type) {
 	case MMOP_ONLINE_KERNEL:
@@ -355,7 +356,7 @@ store_mem_state(struct device *dev,
 		ret = -EINVAL; /* should never happen */
 	}
 
-	mem_hotplug_done();
+	cpus_write_unlock();
 err:
 	unlock_device_hotplug();
 
Index: b/include/linux/memory_hotplug.h
===================================================================
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -193,12 +193,6 @@ extern void put_page_bootmem(struct page
 extern void get_page_bootmem(unsigned long ingo, struct page *page,
 			     unsigned long type);
 
-void get_online_mems(void);
-void put_online_mems(void);
-
-void mem_hotplug_begin(void);
-void mem_hotplug_done(void);
-
 extern void set_zone_contiguous(struct zone *zone);
 extern void clear_zone_contiguous(struct zone *zone);
 
@@ -238,12 +232,6 @@ static inline int try_online_node(int ni
 	return 0;
 }
 
-static inline void get_online_mems(void) {}
-static inline void put_online_mems(void) {}
-
-static inline void mem_hotplug_begin(void) {}
-static inline void mem_hotplug_done(void) {}
-
 #endif /* ! CONFIG_MEMORY_HOTPLUG */
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
Index: b/mm/kmemleak.c
===================================================================
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1428,7 +1428,7 @@ static void kmemleak_scan(void)
 	/*
 	 * Struct page scanning for each node.
 	 */
-	get_online_mems();
+	get_online_cpus();
 	for_each_online_node(i) {
 		unsigned long start_pfn = node_start_pfn(i);
 		unsigned long end_pfn = node_end_pfn(i);
@@ -1446,7 +1446,7 @@ static void kmemleak_scan(void)
 			scan_block(page, page + 1, NULL);
 		}
 	}
-	put_online_mems();
+	put_online_cpus();
 
 	/*
 	 * Scanning the task stacks (may introduce false negatives).
Index: b/mm/memory-failure.c
===================================================================
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -58,6 +58,7 @@
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
 #include <linux/ratelimit.h>
+#include <linux/cpu.h>
 #include "internal.h"
 #include "ras/ras_event.h"
 
@@ -1773,9 +1774,9 @@ int soft_offline_page(struct page *page,
 		return -EBUSY;
 	}
 
-	get_online_mems();
+	get_online_cpus();
 	ret = get_any_page(page, pfn, flags);
-	put_online_mems();
+	put_online_cpus();
 
 	if (ret > 0)
 		ret = soft_offline_in_use_page(page, flags);
Index: b/mm/memory_hotplug.c
===================================================================
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -52,18 +52,6 @@ static void generic_online_page(struct p
 static online_page_callback_t online_page_callback = generic_online_page;
 static DEFINE_MUTEX(online_page_callback_lock);
 
-DEFINE_STATIC_PERCPU_RWSEM(mem_hotplug_lock);
-
-void get_online_mems(void)
-{
-	percpu_down_read(&mem_hotplug_lock);
-}
-
-void put_online_mems(void)
-{
-	percpu_up_read(&mem_hotplug_lock);
-}
-
 #ifndef CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE
 bool memhp_auto_online;
 #else
@@ -82,18 +70,6 @@ static int __init setup_memhp_default_st
 }
 __setup("memhp_default_state=", setup_memhp_default_state);
 
-void mem_hotplug_begin(void)
-{
-	cpus_read_lock();
-	percpu_down_write(&mem_hotplug_lock);
-}
-
-void mem_hotplug_done(void)
-{
-	percpu_up_write(&mem_hotplug_lock);
-	cpus_read_unlock();
-}
-
 /* add this memory to iomem resource */
 static struct resource *register_memory_resource(u64 start, u64 size)
 {
@@ -816,7 +792,7 @@ int set_online_page_callback(online_page
 {
 	int rc = -EINVAL;
 
-	get_online_mems();
+	get_online_cpus();
 	mutex_lock(&online_page_callback_lock);
 
 	if (online_page_callback == generic_online_page) {
@@ -825,7 +801,7 @@ int set_online_page_callback(online_page
 	}
 
 	mutex_unlock(&online_page_callback_lock);
-	put_online_mems();
+	put_online_cpus();
 
 	return rc;
 }
@@ -835,7 +811,7 @@ int restore_online_page_callback(online_
 {
 	int rc = -EINVAL;
 
-	get_online_mems();
+	get_online_cpus();
 	mutex_lock(&online_page_callback_lock);
 
 	if (online_page_callback == callback) {
@@ -844,7 +820,7 @@ int restore_online_page_callback(online_
 	}
 
 	mutex_unlock(&online_page_callback_lock);
-	put_online_mems();
+	put_online_cpus();
 
 	return rc;
 }
@@ -1213,7 +1189,7 @@ int try_online_node(int nid)
 	if (node_online(nid))
 		return 0;
 
-	mem_hotplug_begin();
+	cpus_write_lock();
 	pgdat = hotadd_new_pgdat(nid, 0);
 	if (!pgdat) {
 		pr_err("Cannot online node %d due to NULL pgdat\n", nid);
@@ -1231,7 +1207,7 @@ int try_online_node(int nid)
 	}
 
 out:
-	mem_hotplug_done();
+	cpus_write_unlock();
 	return ret;
 }
 
@@ -1311,7 +1287,7 @@ int __ref add_memory_resource(int nid, s
 		new_pgdat = !p;
 	}
 
-	mem_hotplug_begin();
+	cpus_write_lock();
 
 	/*
 	 * Add new range to memblock so that when hotadd_new_pgdat() is called
@@ -1365,7 +1341,7 @@ int __ref add_memory_resource(int nid, s
 	memblock_remove(start, size);
 
 out:
-	mem_hotplug_done();
+	cpus_write_unlock();
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_memory_resource);
@@ -2117,7 +2093,7 @@ void __ref remove_memory(int nid, u64 st
 
 	BUG_ON(check_hotplug_memory_range(start, size));
 
-	mem_hotplug_begin();
+	cpus_write_lock();
 
 	/*
 	 * All memory blocks must be offlined before removing memory.  Check
@@ -2138,7 +2114,7 @@ void __ref remove_memory(int nid, u64 st
 
 	try_offline_node(nid);
 
-	mem_hotplug_done();
+	cpus_write_lock();
 }
 EXPORT_SYMBOL_GPL(remove_memory);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
Index: b/mm/slab_common.c
===================================================================
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -430,7 +430,6 @@ kmem_cache_create(const char *name, size
 	int err;
 
 	get_online_cpus();
-	get_online_mems();
 	memcg_get_cache_ids();
 
 	mutex_lock(&slab_mutex);
@@ -476,7 +475,6 @@ kmem_cache_create(const char *name, size
 	mutex_unlock(&slab_mutex);
 
 	memcg_put_cache_ids();
-	put_online_mems();
 	put_online_cpus();
 
 	if (err) {
@@ -572,7 +570,6 @@ void memcg_create_kmem_cache(struct mem_
 	int idx;
 
 	get_online_cpus();
-	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
@@ -626,7 +623,6 @@ void memcg_create_kmem_cache(struct mem_
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
-	put_online_mems();
 	put_online_cpus();
 }
 
@@ -636,7 +632,6 @@ static void kmemcg_deactivate_workfn(str
 					    memcg_params.deact_work);
 
 	get_online_cpus();
-	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
@@ -644,7 +639,6 @@ static void kmemcg_deactivate_workfn(str
 
 	mutex_unlock(&slab_mutex);
 
-	put_online_mems();
 	put_online_cpus();
 
 	/* done, put the ref from slab_deactivate_memcg_cache_rcu_sched() */
@@ -699,7 +693,6 @@ void memcg_deactivate_kmem_caches(struct
 	idx = memcg_cache_id(memcg);
 
 	get_online_cpus();
-	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry(s, &slab_root_caches, root_caches_node) {
@@ -714,7 +707,6 @@ void memcg_deactivate_kmem_caches(struct
 	}
 	mutex_unlock(&slab_mutex);
 
-	put_online_mems();
 	put_online_cpus();
 }
 
@@ -723,7 +715,6 @@ void memcg_destroy_kmem_caches(struct me
 	struct kmem_cache *s, *s2;
 
 	get_online_cpus();
-	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 	list_for_each_entry_safe(s, s2, &memcg->kmem_caches,
@@ -736,7 +727,6 @@ void memcg_destroy_kmem_caches(struct me
 	}
 	mutex_unlock(&slab_mutex);
 
-	put_online_mems();
 	put_online_cpus();
 }
 
@@ -817,7 +807,6 @@ void kmem_cache_destroy(struct kmem_cach
 		return;
 
 	get_online_cpus();
-	get_online_mems();
 
 	mutex_lock(&slab_mutex);
 
@@ -837,7 +826,6 @@ void kmem_cache_destroy(struct kmem_cach
 out_unlock:
 	mutex_unlock(&slab_mutex);
 
-	put_online_mems();
 	put_online_cpus();
 }
 EXPORT_SYMBOL(kmem_cache_destroy);
@@ -854,10 +842,8 @@ int kmem_cache_shrink(struct kmem_cache
 	int ret;
 
 	get_online_cpus();
-	get_online_mems();
 	kasan_cache_shrink(cachep);
 	ret = __kmem_cache_shrink(cachep);
-	put_online_mems();
 	put_online_cpus();
 	return ret;
 }
Index: b/mm/slub.c
===================================================================
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4775,7 +4775,7 @@ static ssize_t show_slab_objects(struct
 		}
 	}
 
-	get_online_mems();
+	get_online_cpus();
 #ifdef CONFIG_SLUB_DEBUG
 	if (flags & SO_ALL) {
 		struct kmem_cache_node *n;
@@ -4816,7 +4816,7 @@ static ssize_t show_slab_objects(struct
 			x += sprintf(buf + x, " N%d=%lu",
 					node, nodes[node]);
 #endif
-	put_online_mems();
+	put_online_cpus();
 	kfree(nodes);
 	return x + sprintf(buf + x, "\n");
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
