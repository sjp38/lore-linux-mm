Date: Fri, 21 Apr 2006 17:05:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] split zonelist and use nodemask for page allocation [1/4]
Message-Id: <20060421170504.e678ab1f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060420235616.b2000f7f.pj@sgi.com>
References: <20060421131147.81477c93.kamezawa.hiroyu@jp.fujitsu.com>
	<20060420231751.f1068112.pj@sgi.com>
	<20060421154916.f1c436d3.kamezawa.hiroyu@jp.fujitsu.com>
	<20060420235616.b2000f7f.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Thu, 20 Apr 2006 23:56:16 -0700
Paul Jackson <pj@sgi.com> wrote:

> > yes, not easy.
> 
> Good luck <grin>.
> 

Maybe the whole look of allocation codes will be like below.
But I noticed try_to_free_pages()/out_of_memory() etc. uses array of zones ;(
The whole modification will be bigger than I thought....

Thanks
--Kame

=
static struct page *
get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int nid,
                nodemask_t *nodemask, int alloc_flags)
{
        pg_data_t *pgdat;
        struct zone **z, *orig_zone;
        struct page *page = NULL;
        int classzone_idx, target_node, index;
        int alloc_type = gfp_zone(gfp_mask);
        /*
         * Go through the all specified zones once, looking for a zone
         * with enough free.
         * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
         */
        index = 0;
        orig_zone = NULL;
        do {
                target_node = NODE_DATA(nid)->nodes_list[index++];
                if (nodemask && !node_isset(target_node, *nodemask))
                        continue;
                if (!node_online(target_node))
                        continue;
                pgdat = NODE_DATA(target_node);
                if (!orig_zone) { /* record the first zone we found for
                                     statistics */
                        z = pgdat->node_zonelists[alloc_type].zones;
                        orig_zone = *z;
                        classzone_idx = zone_idx(orig_zone);
                }
                for(z =pgdat->node_zonelists[alloc_type].zones; *z; ++z) {
                        if ((alloc_flags & ALLOC_CPUSET) &&
                                !cpuset_zone_allowed(*z, gfp_mask))
                                continue;

                        if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
                                unsigned long mark;
                                if (alloc_flags & ALLOC_WMARK_MIN)
                                        mark = (*z)->pages_min;
                                else if (alloc_flags & ALLOC_WMARK_LOW)
                                        mark = (*z)->pages_low;
                                else
                                        mark = (*z)->pages_high;
                                if (!zone_watermark_ok(*z, order, mark,
                                            classzone_idx, alloc_flags))
                                        if (!zone_reclaim_mode ||
                                            !zone_reclaim(*z, gfp_mask, order))
                                                continue;
                        }
                        page = buffered_rmqueue(*z, order, gfp_mask, orig_zone);
                        if (page)
                                return page;
                }
        } while (target_node != -1);
        return page;
}

struct page * fastcall
__alloc_pages(gfp_t gfp_mask, unsigned int order, int nid,
              nodemask_t *nodemask)
{
<snip>
	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, order,
                                nid, nodemask, ALLOC_WMARK_LOW|ALLOC_CPUSET);
        if (page)
                goto got_pg;
        alloc_type = gfp_zone(gfp_mask);
        /* run kswapd for all failed zone */
        for_each_node_mask(node, *nodemask)
                for(z = NODE_DATA(node)->node_zonelists[alloc_type],zones;
                    *z; ++z)
                        if (cpuset_zone_allowed(*z, gfp_mask))
                                wakeup_kswapd(*z, order);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
