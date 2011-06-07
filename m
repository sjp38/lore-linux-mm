Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 355436B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 08:25:36 -0400 (EDT)
Date: Tue, 7 Jun 2011 08:25:19 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110607122519.GA18571@infradead.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

A few small nitpicks:

> +struct mem_cgroup *mem_cgroup_hierarchy_walk(struct mem_cgroup *root,
> +					     struct mem_cgroup *prev)
> +{
> +	struct mem_cgroup *mem;
> +
> +	if (mem_cgroup_disabled())
> +		return NULL;
> +
> +	if (!root)
> +		root = root_mem_cgroup;
> +	/*
> +	 * Even without hierarchy explicitely enabled in the root
> +	 * memcg, it is the ultimate parent of all memcgs.
> +	 */
> +	if (!(root == root_mem_cgroup || root->use_hierarchy))
> +		return root;

The logic here reads a bit weird, why not simply:

	 /*
	  * Even without hierarchy explicitely enabled in the root
	  * memcg, it is the ultimate parent of all memcgs.
	  */
	if (!root || root == root_mem_cgroup)
		return root_mem_cgroup;
	if (root->use_hierarchy)
		return root;


>  /*
>   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>   */
> -static void shrink_zone(int priority, struct zone *zone,
> -				struct scan_control *sc)
> +static void do_shrink_zone(int priority, struct zone *zone,
> +			   struct scan_control *sc)

It actually is the per-memcg shrinker now, and thus should be called
shrink_memcg.

> +		sc->mem_cgroup = mem;
> +		do_shrink_zone(priority, zone, sc);

Any passing the mem_cgroup explicitly instead of hiding it in the
scan_control would make that much more obvious.  If there's a good
reason to pass it in the structure the same probably applies to the
zone and priority, too.

Shouldn't we also have a non-cgroups stub of shrink_zone to directly
call do_shrink_zone/shrink_memcg with a NULL memcg and thus optimize
the whole loop away for it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
