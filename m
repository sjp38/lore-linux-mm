Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A7E96B7799
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 03:42:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q12-v6so5118639pgp.6
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:42:14 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d11-v6si4533723plo.91.2018.09.06.00.42.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 00:42:13 -0700 (PDT)
Date: Thu, 6 Sep 2018 15:42:07 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2] mm: slowly shrink slabs with a relatively small
 number of objects
Message-ID: <201809061523.HXrJKywf%fengguang.wu@intel.com>
References: <20180904224707.10356-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/04w6evG8XlLl3ft"
Content-Disposition: inline
In-Reply-To: <20180904224707.10356-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Rik van Riel <riel@surriel.com>, Josef Bacik <jbacik@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>


--/04w6evG8XlLl3ft
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Roman,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.19-rc2 next-20180905]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Roman-Gushchin/mm-slowly-shrink-slabs-with-a-relatively-small-number-of-objects/20180906-142351
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 6.0.0 20160327 (experimental)
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

All warnings (new ones prefixed by >>):

   In file included from include/asm-generic/bug.h:18:0,
                    from ./arch/openrisc/include/generated/asm/bug.h:1,
                    from include/linux/bug.h:5,
                    from include/linux/mmdebug.h:5,
                    from include/linux/mm.h:9,
                    from mm/vmscan.c:17:
   mm/vmscan.c: In function 'do_shrink_slab':
   include/linux/kernel.h:845:29: warning: comparison of distinct pointer types lacks a cast
      (!!(sizeof((typeof(x) *)1 == (typeof(y) *)1)))
                                ^
   include/linux/kernel.h:859:4: note: in expansion of macro '__typecheck'
      (__typecheck(x, y) && __no_side_effects(x, y))
       ^~~~~~~~~~~
   include/linux/kernel.h:869:24: note: in expansion of macro '__safe_cmp'
     __builtin_choose_expr(__safe_cmp(x, y), \
                           ^~~~~~~~~~
   include/linux/kernel.h:885:19: note: in expansion of macro '__careful_cmp'
    #define max(x, y) __careful_cmp(x, y, >)
                      ^~~~~~~~~~~~~
>> mm/vmscan.c:488:10: note: in expansion of macro 'max'
     delta = max(delta, min(freeable, batch_size));
             ^~~

vim +/max +488 mm/vmscan.c

   446	
   447	static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
   448					    struct shrinker *shrinker, int priority)
   449	{
   450		unsigned long freed = 0;
   451		unsigned long long delta;
   452		long total_scan;
   453		long freeable;
   454		long nr;
   455		long new_nr;
   456		int nid = shrinkctl->nid;
   457		long batch_size = shrinker->batch ? shrinker->batch
   458						  : SHRINK_BATCH;
   459		long scanned = 0, next_deferred;
   460	
   461		if (!(shrinker->flags & SHRINKER_NUMA_AWARE))
   462			nid = 0;
   463	
   464		freeable = shrinker->count_objects(shrinker, shrinkctl);
   465		if (freeable == 0 || freeable == SHRINK_EMPTY)
   466			return freeable;
   467	
   468		/*
   469		 * copy the current shrinker scan count into a local variable
   470		 * and zero it so that other concurrent shrinker invocations
   471		 * don't also do this scanning work.
   472		 */
   473		nr = atomic_long_xchg(&shrinker->nr_deferred[nid], 0);
   474	
   475		total_scan = nr;
   476		delta = freeable >> priority;
   477		delta *= 4;
   478		do_div(delta, shrinker->seeks);
   479	
   480		/*
   481		 * Make sure we apply some minimal pressure even on
   482		 * small cgroups. This is necessary because some of
   483		 * belonging objects can hold a reference to a dying
   484		 * child cgroup. If we don't scan them, the dying
   485		 * cgroup can't go away unless the memory pressure
   486		 * (and the scanning priority) raise significantly.
   487		 */
 > 488		delta = max(delta, min(freeable, batch_size));
   489	
   490		total_scan += delta;
   491		if (total_scan < 0) {
   492			pr_err("shrink_slab: %pF negative objects to delete nr=%ld\n",
   493			       shrinker->scan_objects, total_scan);
   494			total_scan = freeable;
   495			next_deferred = nr;
   496		} else
   497			next_deferred = total_scan;
   498	
   499		/*
   500		 * We need to avoid excessive windup on filesystem shrinkers
   501		 * due to large numbers of GFP_NOFS allocations causing the
   502		 * shrinkers to return -1 all the time. This results in a large
   503		 * nr being built up so when a shrink that can do some work
   504		 * comes along it empties the entire cache due to nr >>>
   505		 * freeable. This is bad for sustaining a working set in
   506		 * memory.
   507		 *
   508		 * Hence only allow the shrinker to scan the entire cache when
   509		 * a large delta change is calculated directly.
   510		 */
   511		if (delta < freeable / 4)
   512			total_scan = min(total_scan, freeable / 2);
   513	
   514		/*
   515		 * Avoid risking looping forever due to too large nr value:
   516		 * never try to free more than twice the estimate number of
   517		 * freeable entries.
   518		 */
   519		if (total_scan > freeable * 2)
   520			total_scan = freeable * 2;
   521	
   522		trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
   523					   freeable, delta, total_scan, priority);
   524	
   525		/*
   526		 * Normally, we should not scan less than batch_size objects in one
   527		 * pass to avoid too frequent shrinker calls, but if the slab has less
   528		 * than batch_size objects in total and we are really tight on memory,
   529		 * we will try to reclaim all available objects, otherwise we can end
   530		 * up failing allocations although there are plenty of reclaimable
   531		 * objects spread over several slabs with usage less than the
   532		 * batch_size.
   533		 *
   534		 * We detect the "tight on memory" situations by looking at the total
   535		 * number of objects we want to scan (total_scan). If it is greater
   536		 * than the total number of objects on slab (freeable), we must be
   537		 * scanning at high prio and therefore should try to reclaim as much as
   538		 * possible.
   539		 */
   540		while (total_scan >= batch_size ||
   541		       total_scan >= freeable) {
   542			unsigned long ret;
   543			unsigned long nr_to_scan = min(batch_size, total_scan);
   544	
   545			shrinkctl->nr_to_scan = nr_to_scan;
   546			shrinkctl->nr_scanned = nr_to_scan;
   547			ret = shrinker->scan_objects(shrinker, shrinkctl);
   548			if (ret == SHRINK_STOP)
   549				break;
   550			freed += ret;
   551	
   552			count_vm_events(SLABS_SCANNED, shrinkctl->nr_scanned);
   553			total_scan -= shrinkctl->nr_scanned;
   554			scanned += shrinkctl->nr_scanned;
   555	
   556			cond_resched();
   557		}
   558	
   559		if (next_deferred >= scanned)
   560			next_deferred -= scanned;
   561		else
   562			next_deferred = 0;
   563		/*
   564		 * move the unused scan count back into the shrinker in a
   565		 * manner that handles concurrent updates. If we exhausted the
   566		 * scan, there is no need to do an update.
   567		 */
   568		if (next_deferred > 0)
   569			new_nr = atomic_long_add_return(next_deferred,
   570							&shrinker->nr_deferred[nid]);
   571		else
   572			new_nr = atomic_long_read(&shrinker->nr_deferred[nid]);
   573	
   574		trace_mm_shrink_slab_end(shrinker, nid, freed, nr, new_nr, total_scan);
   575		return freed;
   576	}
   577	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--/04w6evG8XlLl3ft
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
RzVKAKFCEERUuyH5/wfZa5fGiHMAAA==

--/04w6evG8XlLl3ft--
