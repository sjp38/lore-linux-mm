Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9C6BB6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:08:45 -0400 (EDT)
Date: Tue, 9 Apr 2013 09:08:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 1/3] memcg: integrate soft reclaim tighter with zone
 shrinking code
Message-ID: <20130409130833.GP1953@cmpxchg.org>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <1365509595-665-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365509595-665-2-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue, Apr 09, 2013 at 02:13:13PM +0200, Michal Hocko wrote:
> Memcg soft reclaim has been traditionally triggered from the global
> reclaim paths before calling shrink_zone. mem_cgroup_soft_limit_reclaim
> then picked up a group which exceeds the soft limit the most and
> reclaimed it with 0 priority to reclaim at least SWAP_CLUSTER_MAX pages.
> 
> The infrastructure requires per-node-zone trees which hold over-limit
> groups and keep them up-to-date (via memcg_check_events) which is not
> cost free. Although this overhead hasn't turned out to be a bottle neck
> the implementation is suboptimal because mem_cgroup_update_tree has no
> idea which zones consumed memory over the limit so we could easily end
> up having a group on a node-zone tree having only few pages from that
> node-zone.
> 
> This patch doesn't try to fix node-zone trees management because it
> seems that integrating soft reclaim into zone shrinking sounds much
> easier and more appropriate for several reasons.
> First of all 0 priority reclaim was a crude hack which might lead to
> big stalls if the group's LRUs are big and hard to reclaim (e.g. a lot
> of dirty/writeback pages).
> Soft reclaim should be applicable also to the targeted reclaim which is
> awkward right now without additional hacks.
> Last but not least the whole infrastructure eats a lot of code[1].
> 
> After this patch shrink_zone is done in 2. First it tries to do the
> soft reclaim if appropriate (only for global reclaim for now to keep
> compatible with the current state) and fall back to ignoring soft limit
> if no group is eligible to soft reclaim or nothing has been scanned
> during the first pass. Only groups which are over their soft limit or
> any of their parent up the hierarchy is over the limit are considered
> eligible during the first pass.
> 
> TODO: remove mem_cgroup_tree_per_zone, mem_cgroup_shrink_node_zone and co.
> but maybe it would be easier for review to remove that code in a separate
> patch...

It should be in this series, though, for the diffstat :-)

> ---
> [1] TODO: put size vmlinux before/after whole clean-up

Yes!

> @@ -1984,6 +2003,27 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
>  		} while (memcg);
>  	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
>  					 sc->nr_scanned - nr_scanned, sc));
> +
> +	return nr_shrunk;
> +}
> +
> +
> +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> +{
> +	bool do_soft_reclaim = mem_cgroup_should_soft_reclaim(sc);
> +	unsigned long nr_scanned = sc->nr_scanned;
> +	unsigned nr_shrunk;
> +
> +	nr_shrunk = __shrink_zone(zone, sc, do_soft_reclaim);
> +
> +	/*
> +	 * No group is over the soft limit or those that are do not have
> +	 * pages in the zone we are reclaiming so we have to reclaim everybody
> +	 */
> +	if (do_soft_reclaim && (!nr_shrunk || sc->nr_scanned == nr_scanned)) {

If no pages were scanned you are doing a second pass regardless of
nr_shrunk.  If pages were scanned, nr_shrunk must have been increased
as well.  So I think you can remove all the nr_shrunk counting and
just check for scanned pages, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
