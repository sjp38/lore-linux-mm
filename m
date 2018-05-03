Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 150F86B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 21:09:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f19-v6so11220345pgv.4
        for <linux-mm@kvack.org>; Wed, 02 May 2018 18:09:12 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d8-v6si10524905pgt.630.2018.05.02.18.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 18:09:10 -0700 (PDT)
Date: Thu, 3 May 2018 09:08:30 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 RESEND 2/2] mm: ignore memory.min of abandoned memory
 cgroups
Message-ID: <201805030744.raTbhHjm%fengguang.wu@intel.com>
References: <20180502154710.18737-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="pf9I7BMVVzbSWLtt"
Content-Disposition: inline
In-Reply-To: <20180502154710.18737-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Roman,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on mmotm/master]
[also build test ERROR on next-20180502]
[cannot apply to v4.17-rc3]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Roman-Gushchin/mm-introduce-memory-min/20180503-064145
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/vmscan.c: In function 'shrink_node':
>> mm/vmscan.c:2555:9: error: implicit declaration of function 'cgroup_is_populated'; did you mean 'cgroup_bpf_put'? [-Werror=implicit-function-declaration]
        if (cgroup_is_populated(memcg->css.cgroup))
            ^~~~~~~~~~~~~~~~~~~
            cgroup_bpf_put
   mm/vmscan.c:2555:34: error: dereferencing pointer to incomplete type 'struct mem_cgroup'
        if (cgroup_is_populated(memcg->css.cgroup))
                                     ^~
   cc1: some warnings being treated as errors

vim +2555 mm/vmscan.c

  2520	
  2521	static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
  2522	{
  2523		struct reclaim_state *reclaim_state = current->reclaim_state;
  2524		unsigned long nr_reclaimed, nr_scanned;
  2525		bool reclaimable = false;
  2526	
  2527		do {
  2528			struct mem_cgroup *root = sc->target_mem_cgroup;
  2529			struct mem_cgroup_reclaim_cookie reclaim = {
  2530				.pgdat = pgdat,
  2531				.priority = sc->priority,
  2532			};
  2533			unsigned long node_lru_pages = 0;
  2534			struct mem_cgroup *memcg;
  2535	
  2536			memset(&sc->nr, 0, sizeof(sc->nr));
  2537	
  2538			nr_reclaimed = sc->nr_reclaimed;
  2539			nr_scanned = sc->nr_scanned;
  2540	
  2541			memcg = mem_cgroup_iter(root, NULL, &reclaim);
  2542			do {
  2543				unsigned long lru_pages;
  2544				unsigned long reclaimed;
  2545				unsigned long scanned;
  2546	
  2547				switch (mem_cgroup_protected(root, memcg)) {
  2548				case MEMCG_PROT_MIN:
  2549					/*
  2550					 * Hard protection.
  2551					 * If there is no reclaimable memory, OOM.
  2552					 * Abandoned cgroups are loosing protection,
  2553					 * because OOM killer won't release any memory.
  2554					 */
> 2555					if (cgroup_is_populated(memcg->css.cgroup))
  2556						continue;
  2557				case MEMCG_PROT_LOW:
  2558					/*
  2559					 * Soft protection.
  2560					 * Respect the protection only as long as
  2561					 * there is an unprotected supply
  2562					 * of reclaimable memory from other cgroups.
  2563					 */
  2564					if (!sc->memcg_low_reclaim) {
  2565						sc->memcg_low_skipped = 1;
  2566						continue;
  2567					}
  2568					memcg_memory_event(memcg, MEMCG_LOW);
  2569					break;
  2570				case MEMCG_PROT_NONE:
  2571					break;
  2572				}
  2573	
  2574				reclaimed = sc->nr_reclaimed;
  2575				scanned = sc->nr_scanned;
  2576				shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
  2577				node_lru_pages += lru_pages;
  2578	
  2579				if (memcg)
  2580					shrink_slab(sc->gfp_mask, pgdat->node_id,
  2581						    memcg, sc->priority);
  2582	
  2583				/* Record the group's reclaim efficiency */
  2584				vmpressure(sc->gfp_mask, memcg, false,
  2585					   sc->nr_scanned - scanned,
  2586					   sc->nr_reclaimed - reclaimed);
  2587	
  2588				/*
  2589				 * Direct reclaim and kswapd have to scan all memory
  2590				 * cgroups to fulfill the overall scan target for the
  2591				 * node.
  2592				 *
  2593				 * Limit reclaim, on the other hand, only cares about
  2594				 * nr_to_reclaim pages to be reclaimed and it will
  2595				 * retry with decreasing priority if one round over the
  2596				 * whole hierarchy is not sufficient.
  2597				 */
  2598				if (!global_reclaim(sc) &&
  2599						sc->nr_reclaimed >= sc->nr_to_reclaim) {
  2600					mem_cgroup_iter_break(root, memcg);
  2601					break;
  2602				}
  2603			} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
  2604	
  2605			if (global_reclaim(sc))
  2606				shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
  2607					    sc->priority);
  2608	
  2609			if (reclaim_state) {
  2610				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
  2611				reclaim_state->reclaimed_slab = 0;
  2612			}
  2613	
  2614			/* Record the subtree's reclaim efficiency */
  2615			vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
  2616				   sc->nr_scanned - nr_scanned,
  2617				   sc->nr_reclaimed - nr_reclaimed);
  2618	
  2619			if (sc->nr_reclaimed - nr_reclaimed)
  2620				reclaimable = true;
  2621	
  2622			if (current_is_kswapd()) {
  2623				/*
  2624				 * If reclaim is isolating dirty pages under writeback,
  2625				 * it implies that the long-lived page allocation rate
  2626				 * is exceeding the page laundering rate. Either the
  2627				 * global limits are not being effective at throttling
  2628				 * processes due to the page distribution throughout
  2629				 * zones or there is heavy usage of a slow backing
  2630				 * device. The only option is to throttle from reclaim
  2631				 * context which is not ideal as there is no guarantee
  2632				 * the dirtying process is throttled in the same way
  2633				 * balance_dirty_pages() manages.
  2634				 *
  2635				 * Once a node is flagged PGDAT_WRITEBACK, kswapd will
  2636				 * count the number of pages under pages flagged for
  2637				 * immediate reclaim and stall if any are encountered
  2638				 * in the nr_immediate check below.
  2639				 */
  2640				if (sc->nr.writeback && sc->nr.writeback == sc->nr.taken)
  2641					set_bit(PGDAT_WRITEBACK, &pgdat->flags);
  2642	
  2643				/*
  2644				 * Tag a node as congested if all the dirty pages
  2645				 * scanned were backed by a congested BDI and
  2646				 * wait_iff_congested will stall.
  2647				 */
  2648				if (sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
  2649					set_bit(PGDAT_CONGESTED, &pgdat->flags);
  2650	
  2651				/* Allow kswapd to start writing pages during reclaim.*/
  2652				if (sc->nr.unqueued_dirty == sc->nr.file_taken)
  2653					set_bit(PGDAT_DIRTY, &pgdat->flags);
  2654	
  2655				/*
  2656				 * If kswapd scans pages marked marked for immediate
  2657				 * reclaim and under writeback (nr_immediate), it
  2658				 * implies that pages are cycling through the LRU
  2659				 * faster than they are written so also forcibly stall.
  2660				 */
  2661				if (sc->nr.immediate)
  2662					congestion_wait(BLK_RW_ASYNC, HZ/10);
  2663			}
  2664	
  2665			/*
  2666			 * Legacy memcg will stall in page writeback so avoid forcibly
  2667			 * stalling in wait_iff_congested().
  2668			 */
  2669			if (!global_reclaim(sc) && sane_reclaim(sc) &&
  2670			    sc->nr.dirty && sc->nr.dirty == sc->nr.congested)
  2671				set_memcg_congestion(pgdat, root, true);
  2672	
  2673			/*
  2674			 * Stall direct reclaim for IO completions if underlying BDIs
  2675			 * and node is congested. Allow kswapd to continue until it
  2676			 * starts encountering unqueued dirty pages or cycling through
  2677			 * the LRU too quickly.
  2678			 */
  2679			if (!sc->hibernation_mode && !current_is_kswapd() &&
  2680			   current_may_throttle() && pgdat_memcg_congested(pgdat, root))
  2681				wait_iff_congested(BLK_RW_ASYNC, HZ/10);
  2682	
  2683		} while (should_continue_reclaim(pgdat, sc->nr_reclaimed - nr_reclaimed,
  2684						 sc->nr_scanned - nr_scanned, sc));
  2685	
  2686		/*
  2687		 * Kswapd gives up on balancing particular nodes after too
  2688		 * many failures to reclaim anything from them and goes to
  2689		 * sleep. On reclaim progress, reset the failure counter. A
  2690		 * successful direct reclaim run will revive a dormant kswapd.
  2691		 */
  2692		if (reclaimable)
  2693			pgdat->kswapd_failures = 0;
  2694	
  2695		return reclaimable;
  2696	}
  2697	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--pf9I7BMVVzbSWLtt
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--pf9I7BMVVzbSWLtt--
