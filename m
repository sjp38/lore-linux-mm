Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2407D6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 02:36:01 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id l89so19542316qgf.3
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 23:36:00 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id u7si21271707qaj.5.2015.01.19.23.35.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 23:35:59 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 20 Jan 2015 00:35:58 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2DA0AC40002
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 00:27:08 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0K7ZsSE36503594
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 00:35:55 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0K7Zsh7000524
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 00:35:54 -0700
Date: Mon, 19 Jan 2015 23:35:50 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH -mm v2] vmscan: move reclaim_state handling to shrink_slab
Message-ID: <20150120073550.GP9719@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1421311073-28130-1-git-send-email-vdavydov@parallels.com>
 <20150115125820.GE7000@dhcp22.suse.cz>
 <20150115132516.GG11264@esperanza>
 <20150115144838.GI7000@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150115144838.GI7000@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 15, 2015 at 03:48:38PM +0100, Michal Hocko wrote:
> On Thu 15-01-15 16:25:16, Vladimir Davydov wrote:
> > On Thu, Jan 15, 2015 at 01:58:20PM +0100, Michal Hocko wrote:
> > > On Thu 15-01-15 11:37:53, Vladimir Davydov wrote:
> > > > current->reclaim_state is only used to count the number of slab pages
> > > > reclaimed by shrink_slab(). So instead of initializing it before we are
> > > > 
> > > > Note that after this patch try_to_free_mem_cgroup_pages() will count not
> > > > only reclaimed user pages, but also slab pages, which is expected,
> > > > because it can reclaim kmem from kmem-active sub cgroups.
> > > 
> > > Except that reclaim_state counts all freed slab objects that have
> > > current->reclaim_state != NULL AFAIR. This includes also kfreed pages
> > > from interrupt context and who knows what else and those pages might be
> > > from a different memcgs, no?
> > 
> > Hmm, true, good point. Can an interrupt handler free a lot of memory
> > though?
> 
> it is drivers so who knows...
> 
> > Does RCU free objects from irq or soft irq context?
> 
> and this is another part which I didn't consider at all. RCU callbacks
> are normally processed from kthread context but rcu_init also does
> open_softirq(RCU_SOFTIRQ, rcu_process_callbacks)
> so something is clearly processed from softirq as well. I am not
> familiar with RCU details enough to tell how many callbacks are
> processed this way. Tiny RCU, on the other hand, seem to be processing
> all callbacks via __rcu_process_callbacks and that seems to be processed
> from softirq only.

RCU invokes all its callbacks with BH disabled, either because they
are running in softirq context or because the rcuo kthreads disable
BH while invoking each callback.  When running in softirq context,
RCU will normally invoke only ten callbacks before letting the other
softirq vectors run.  However, if there are more than 10,000 callbacks
queued on a given CPU (which can happen!), RCU will go into panic mode
and just invoke the callbacks as quickly as it can.

You can of course have your callback schedule a work-queue item or
wake up a kthread to avoid this tradeoff.

							Thanx, Paul

> > > Besides that I am not sure this makes any difference in the end. No
> > > try_to_free_mem_cgroup_pages caller really cares about the exact
> > > number of reclaimed pages. We care only about whether there was any
> > > progress done - and even that not exactly (e.g. try_charge checks
> > > mem_cgroup_margin before retry/oom so if sufficient kmem pages were
> > > uncharged then we will notice that).
> > 
> > Frankly, I thought exactly the same initially, that's why I dropped
> > reclaim_state handling from the initial memcg shrinkers patch set.
> > However, then Hillf noticed that nr_reclaimed is checked right after
> > calling shrink_slab() in the memcg iteration loop in shrink_zone():
> > 
> > 
> > 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
> > 		do {
> > 			[...]
> > 			if (memcg && is_classzone)
> > 				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
> > 					    memcg, sc->nr_scanned - scanned,
> > 					    lru_pages);
> > 
> > 			/*
> > 			 * Direct reclaim and kswapd have to scan all memory
> > 			 * cgroups to fulfill the overall scan target for the
> > 			 * zone.
> > 			 *
> > 			 * Limit reclaim, on the other hand, only cares about
> > 			 * nr_to_reclaim pages to be reclaimed and it will
> > 			 * retry with decreasing priority if one round over the
> > 			 * whole hierarchy is not sufficient.
> > 			 */
> > 			if (!global_reclaim(sc) &&
> > 					sc->nr_reclaimed >= sc->nr_to_reclaim) {
> > 				mem_cgroup_iter_break(root, memcg);
> > 				break;
> > 			}
> > 			memcg = mem_cgroup_iter(root, memcg, &reclaim);
> > 		} while (memcg);
> > 
> > 
> > If we can ignore reclaimed slab pages here (?), let's drop this patch.
> 
> I see what you are trying to achieve but can this lead to a serious
> over-reclaim? We should be reclaiming mostly user pages and kmem should
> be only a small portion I would expect.
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
