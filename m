Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 838CC6B006C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:25:28 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id fp1so16281253pdb.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 05:25:28 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id fl9si1773180pab.154.2015.01.15.05.25.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 05:25:27 -0800 (PST)
Date: Thu, 15 Jan 2015 16:25:16 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v2] vmscan: move reclaim_state handling to shrink_slab
Message-ID: <20150115132516.GG11264@esperanza>
References: <1421311073-28130-1-git-send-email-vdavydov@parallels.com>
 <20150115125820.GE7000@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150115125820.GE7000@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 15, 2015 at 01:58:20PM +0100, Michal Hocko wrote:
> On Thu 15-01-15 11:37:53, Vladimir Davydov wrote:
> > current->reclaim_state is only used to count the number of slab pages
> > reclaimed by shrink_slab(). So instead of initializing it before we are
> > 
> > Note that after this patch try_to_free_mem_cgroup_pages() will count not
> > only reclaimed user pages, but also slab pages, which is expected,
> > because it can reclaim kmem from kmem-active sub cgroups.
> 
> Except that reclaim_state counts all freed slab objects that have
> current->reclaim_state != NULL AFAIR. This includes also kfreed pages
> from interrupt context and who knows what else and those pages might be
> from a different memcgs, no?

Hmm, true, good point. Can an interrupt handler free a lot of memory
though? Does RCU free objects from irq or soft irq context?

> Besides that I am not sure this makes any difference in the end. No
> try_to_free_mem_cgroup_pages caller really cares about the exact
> number of reclaimed pages. We care only about whether there was any
> progress done - and even that not exactly (e.g. try_charge checks
> mem_cgroup_margin before retry/oom so if sufficient kmem pages were
> uncharged then we will notice that).

Frankly, I thought exactly the same initially, that's why I dropped
reclaim_state handling from the initial memcg shrinkers patch set.
However, then Hillf noticed that nr_reclaimed is checked right after
calling shrink_slab() in the memcg iteration loop in shrink_zone():


		memcg = mem_cgroup_iter(root, NULL, &reclaim);
		do {
			[...]
			if (memcg && is_classzone)
				shrink_slab(sc->gfp_mask, zone_to_nid(zone),
					    memcg, sc->nr_scanned - scanned,
					    lru_pages);

			/*
			 * Direct reclaim and kswapd have to scan all memory
			 * cgroups to fulfill the overall scan target for the
			 * zone.
			 *
			 * Limit reclaim, on the other hand, only cares about
			 * nr_to_reclaim pages to be reclaimed and it will
			 * retry with decreasing priority if one round over the
			 * whole hierarchy is not sufficient.
			 */
			if (!global_reclaim(sc) &&
					sc->nr_reclaimed >= sc->nr_to_reclaim) {
				mem_cgroup_iter_break(root, memcg);
				break;
			}
			memcg = mem_cgroup_iter(root, memcg, &reclaim);
		} while (memcg);


If we can ignore reclaimed slab pages here (?), let's drop this patch.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
