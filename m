Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA616B04F0
	for <linux-mm@kvack.org>; Thu, 17 May 2018 09:51:27 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b5-v6so2002339lff.3
        for <linux-mm@kvack.org>; Thu, 17 May 2018 06:51:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y6-v6sor1359805lfe.112.2018.05.17.06.51.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 06:51:25 -0700 (PDT)
Date: Thu, 17 May 2018 16:51:21 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v5 11/13] mm: Iterate only over charged shrinkers during
 memcg shrink_slab()
Message-ID: <20180517135121.wtaiuj6pqxzodrlr@esperanza>
References: <152594582808.22949.8353313986092337675.stgit@localhost.localdomain>
 <152594603565.22949.12428911301395699065.stgit@localhost.localdomain>
 <20180515054445.nhe4zigtelkois4p@esperanza>
 <5c0dbd12-8100-61a2-34fd-8878c57195a3@virtuozzo.com>
 <20180517041634.lgkym6gdctya3oq6@esperanza>
 <f2dec4fb-6107-5d6c-62b3-8b680895c5c1@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f2dec4fb-6107-5d6c-62b3-8b680895c5c1@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Thu, May 17, 2018 at 02:49:26PM +0300, Kirill Tkhai wrote:
> On 17.05.2018 07:16, Vladimir Davydov wrote:
> > On Tue, May 15, 2018 at 05:49:59PM +0300, Kirill Tkhai wrote:
> >>>> @@ -589,13 +647,7 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
> >>>>  			.memcg = memcg,
> >>>>  		};
> >>>>  
> >>>> -		/*
> >>>> -		 * If kernel memory accounting is disabled, we ignore
> >>>> -		 * SHRINKER_MEMCG_AWARE flag and call all shrinkers
> >>>> -		 * passing NULL for memcg.
> >>>> -		 */
> >>>> -		if (memcg_kmem_enabled() &&
> >>>> -		    !!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> >>>> +		if (!!memcg != !!(shrinker->flags & SHRINKER_MEMCG_AWARE))
> >>>>  			continue;
> >>>
> >>> I want this check gone. It's easy to achieve, actually - just remove the
> >>> following lines from shrink_node()
> >>>
> >>> 		if (global_reclaim(sc))
> >>> 			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
> >>> 				    sc->priority);
> >>
> >> This check is not related to the patchset.
> > 
> > Yes, it is. This patch modifies shrink_slab which is used only by
> > shrink_node. Simplifying shrink_node along the way looks right to me.
> 
> shrink_slab() is used not only in this place.

drop_slab_node() doesn't really count as it is an extract from shrink_node()

> I does not seem a trivial change for me.
> 
> >> Let's don't mix everything in the single series of patches, because
> >> after your last remarks it will grow at least up to 15 patches.
> > 
> > Most of which are trivial so I don't see any problem here.
> > 
> >> This patchset can't be responsible for everything.
> > 
> > I don't understand why you balk at simplifying the code a bit while you
> > are patching related functions anyway.
> 
> Because this function is used in several places, and we have some particulars
> on root_mem_cgroup initialization, and this function called from these places
> with different states of root_mem_cgroup. It does not seem trivial fix for me.

Let me do it for you then:

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9b697323a88c..e778569538de 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -486,10 +486,8 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
  * @nid is passed along to shrinkers with SHRINKER_NUMA_AWARE set,
  * unaware shrinkers will receive a node id of 0 instead.
  *
- * @memcg specifies the memory cgroup to target. If it is not NULL,
- * only shrinkers with SHRINKER_MEMCG_AWARE set will be called to scan
- * objects from the memory cgroup specified. Otherwise, only unaware
- * shrinkers are called.
+ * @memcg specifies the memory cgroup to target. Unaware shrinkers
+ * are called only if it is the root cgroup.
  *
  * @priority is sc->priority, we take the number of objects and >> by priority
  * in order to get the scan target.
@@ -554,6 +552,7 @@ void drop_slab_node(int nid)
 		struct mem_cgroup *memcg = NULL;
 
 		freed = 0;
+		memcg = mem_cgroup_iter(NULL, NULL, NULL);
 		do {
 			freed += shrink_slab(GFP_KERNEL, nid, memcg, 0);
 		} while ((memcg = mem_cgroup_iter(NULL, memcg, NULL)) != NULL);
@@ -2557,9 +2556,8 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			shrink_node_memcg(pgdat, memcg, sc, &lru_pages);
 			node_lru_pages += lru_pages;
 
-			if (memcg)
-				shrink_slab(sc->gfp_mask, pgdat->node_id,
-					    memcg, sc->priority);
+			shrink_slab(sc->gfp_mask, pgdat->node_id,
+				    memcg, sc->priority);
 
 			/* Record the group's reclaim efficiency */
 			vmpressure(sc->gfp_mask, memcg, false,
@@ -2583,10 +2581,6 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
 			}
 		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
 
-		if (global_reclaim(sc))
-			shrink_slab(sc->gfp_mask, pgdat->node_id, NULL,
-				    sc->priority);
-
 		if (reclaim_state) {
 			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;


Seems simple enough to fold it into this patch, doesn't it?
