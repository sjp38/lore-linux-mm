Date: Fri, 26 Jan 2007 14:17:24 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bug 7889] an oops inside kmem_get_pages
Message-Id: <20070126141724.6095899a.akpm@osdl.org>
In-Reply-To: <200701262153.l0QLr26V018224@fire-2.osdl.org>
References: <200701262153.l0QLr26V018224@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pluto@pld-linux.org
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007 13:53:02 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7889
> 
> 
> 
> 
> 
> ------- Additional Comments From pluto@pld-linux.org  2007-01-26 13:44 -------
> here's an stack unwind chain:

OK, thanks.  Please use email (reply-to-all) on this bug from now on.  I'm
hoping that someone else will look into this, as I'm not exactly brimming
with spare time at present.



> 0xffffffff802d27be is in __rmqueue (mm/page_alloc.c:633).
> 628                             continue;
> 629
> 630                     page = list_entry(area->free_list.next, struct page, 
> lru);
> 631                     list_del(&page->lru);
> 632                     rmv_page_order(page);
> 633                     area->nr_free--;
> 634                     zone->free_pages -= 1UL << order;
> 635                     expand(zone, page, order, current_order, area);
> 636                     return page;
> 637             }
> 
> 0xffffffff8020a52f is in get_page_from_freelist (mm/page_alloc.c:870).
> 865                     list_del(&page->lru);
> 866                     pcp->count--;
> 867             } else {
> 868                     spin_lock_irqsave(&zone->lock, flags);
> 869                     page = __rmqueue(zone, order);
> 870                     spin_unlock(&zone->lock);
> 871                     if (!page)
> 872                             goto failed;
> 873             }
> 
> 0xffffffff8020f593 is in __alloc_pages (mm/page_alloc.c:1241).
> 1236                    return NULL;
> 1237            }
> 1238
> 1239            page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
> 1240                                    zonelist, ALLOC_WMARK_LOW|
> ALLOC_CPUSET);
> 1241            if (page)
> 1242                    goto got_pg;
> 1243
> 1244            /*
> 1245             * GFP_THISNODE (meaning __GFP_THISNODE, __GFP_NORETRY and
> 
> 0xffffffff802e68d0 is in kmem_getpages (mm/slab.c:1627).
> 1622
> 1623            page = alloc_pages_node(nodeid, flags, cachep->gfporder);
> 1624            if (!page)
> 1625                    return NULL;
> 1626
> 1627            nr_pages = (1 << cachep->gfporder);
> 1628            if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> 1629                    add_zone_page_state(page_zone(page),
> 1630                            NR_SLAB_RECLAIMABLE, nr_pages);
> 1631            else
> 
> 0xffffffff80217de0 is in cache_grow (mm/slab.c:2774).
> 2769             * Get mem for the objs.  Attempt to allocate a physical page 
> from
> 2770             * 'nodeid'.
> 2771             */
> 2772            if (!objp)
> 2773                    objp = kmem_getpages(cachep, flags, nodeid);
> 2774            if (!objp)
> 2775                    goto failed;
> 2776
> 2777            /* Get slab management. */
> 2778            slabp = alloc_slabmgmt(cachep, objp, offset,
> 
> 0xffffffff80261e9b is in cache_alloc_refill (mm/slab.c:773).
> 768
> 769     static DEFINE_PER_CPU(struct delayed_work, reap_work);
> 770
> 771     static inline struct array_cache *cpu_cache_get(struct kmem_cache 
> *cachep)
> 772     {
> 773             return cachep->array[smp_processor_id()];
> 774     }
> 775
> 776     static inline struct kmem_cache *__find_general_cachep(size_t size,
> 777                                                             gfp_t 
> gfpflags)
> 
> 0xffffffff802e7d7c is in do_tune_cpucache (mm/slab.c:3891).
> 3886
> 3887            new = kzalloc(sizeof(*new), GFP_KERNEL);
> 3888            if (!new)
> 3889                    return -ENOMEM;
> 3890
> 3891            for_each_online_cpu(i) {
> 3892                    new->new[i] = alloc_arraycache(cpu_to_node(i), limit,
> 3893                                                    batchcount);
> 3894                    if (!new->new[i]) {
> 3895                            for (i--; i >= 0; i--)
> 
> 0xffffffff802e721d is in kmem_cache_zalloc (mm/slab.c:3221).
> 3216            /*
> 3217             * We may just have run out of memory on the local node.
> 3218             * ____cache_alloc_node() knows how to locate memory on other 
> nodes
> 3219             */
> 3220            if (NUMA_BUILD && !objp)
> 3221                    objp = ____cache_alloc_node(cachep, flags, 
> numa_node_id());
> 3222            local_irq_restore(save_flags);
> 3223            objp = cache_alloc_debugcheck_after(cachep, flags, objp,
> 3224                                                caller);
> 3225            prefetchw(objp);
> 
> 0xffffffff802e7d7c is in do_tune_cpucache (mm/slab.c:3891).
> 3886
> 3887            new = kzalloc(sizeof(*new), GFP_KERNEL);
> 3888            if (!new)
> 3889                    return -ENOMEM;
> 3890
> 3891            for_each_online_cpu(i) {
> 3892                    new->new[i] = alloc_arraycache(cpu_to_node(i), limit,
> 3893                                                    batchcount);
> 3894                    if (!new->new[i]) {
> 3895                            for (i--; i >= 0; i--)
> 
> 0xffffffff802e835a is in enable_cpucache (mm/slab.c:3974).
> 3969            if (limit > 32)
> 3970                    limit = 32;
> 3971    #endif
> 3972            err = do_tune_cpucache(cachep, limit, (limit + 1) / 2, 
> shared);
> 3973            if (err)
> 3974                    printk(KERN_ERR "enable_cpucache failed for %s, 
> error %d.\n",
> 3975                           cachep->name, -err);
> 3976            return err;
> 3977    }
> 
> 0xffffffff8062bc0a is in kmem_cache_init (mm/slab.c:1563).
> 1558            /* 6) resize the head arrays to their final sizes */
> 1559            {
> 1560                    struct kmem_cache *cachep;
> 1561                    mutex_lock(&cache_chain_mutex);
> 1562                    list_for_each_entry(cachep, &cache_chain, next)
> 1563                            if (enable_cpucache(cachep))
> 1564                                    BUG();
> 1565                    mutex_unlock(&cache_chain_mutex);
> 1566            }
> 
> 0xffffffff8061773c is in start_kernel (init/main.c:583).
> 578             }
> 579     #endif
> 580             vfs_caches_init_early();
> 581             cpuset_init_early();
> 582             mem_init();
> 583             kmem_cache_init();
> 584             setup_per_cpu_pageset();
> 585             numa_policy_init();
> 586             if (late_time_init)
> 587                     late_time_init();
> 
> 0xffffffff8061716d is in x86_64_start_kernel (arch/x86_64/kernel/head64.c:84).
> 79              copy_bootdata(real_mode_data);
> 80      #ifdef CONFIG_SMP
> 81              cpu_set(0, cpu_online_map);
> 82      #endif
> 83              start_kernel();
> 84      }
> 
> 
> ------- You are receiving this mail because: -------
> You are the assignee for the bug, or are watching the assignee.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
