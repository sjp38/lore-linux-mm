Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 938446B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:13:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id 44so1412263wry.5
        for <linux-mm@kvack.org>; Wed, 31 May 2017 02:13:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e21si15678489edj.155.2017.05.31.02.13.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 02:13:06 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4V99PRf128290
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:13:04 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2assbhcfvt-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:13:04 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 31 May 2017 10:13:02 +0100
Date: Wed, 31 May 2017 11:12:56 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node
 counters
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-3-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530181724.27197-3-hannes@cmpxchg.org>
Message-Id: <20170531091256.GA5914@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

On Tue, May 30, 2017 at 02:17:20PM -0400, Johannes Weiner wrote:
> To re-implement slab cache vs. page cache balancing, we'll need the
> slab counters at the lruvec level, which, ever since lru reclaim was
> moved from the zone to the node, is the intersection of the node, not
> the zone, and the memcg.
> 
> We could retain the per-zone counters for when the page allocator
> dumps its memory information on failures, and have counters on both
> levels - which on all but NUMA node 0 is usually redundant. But let's
> keep it simple for now and just move them. If anybody complains we can
> restore the per-zone counters.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

This patch causes an early boot crash on s390 (linux-next as of today).
CONFIG_NUMA on/off doesn't make any difference. I haven't looked any
further into this yet, maybe you have an idea?

Kernel BUG at 00000000002b0362 [verbose debug info unavailable]
addressing exception: 0005 ilc:3 [#1] SMP
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Not tainted 4.12.0-rc3-00153-gb6bc6724488a #16
Hardware name: IBM 2964 N96 702 (z/VM 6.4.0)
task: 0000000000d75d00 task.stack: 0000000000d60000
Krnl PSW : 0404200180000000 00000000002b0362 (mod_node_page_state+0x62/0x158)
           R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:2 PM:0 RI:0 EA:3
Krnl GPRS: 0000000000000001 000000003d81f000 0000000000000000 0000000000000006
           0000000000000001 0000000000f29b52 0000000000000041 0000000000000000
           0000000000000007 0000000000000040 000000003fe81000 000003d100ffa000
           0000000000ee1cd0 0000000000979040 0000000000300abc 0000000000d63c90
Krnl Code: 00000000002b0350: e31003900004 lg %r1,912
           00000000002b0356: e320f0a80004 lg %r2,168(%r15)
          #00000000002b035c: e31120000090 llgc %r1,0(%r1,%r2)
          >00000000002b0362: b9060011  lgbr %r1,%r1
           00000000002b0366: e32003900004 lg %r2,912
           00000000002b036c: e3c280000090 llgc %r12,0(%r2,%r8)
           00000000002b0372: b90600ac  lgbr %r10,%r12
           00000000002b0376: b904002a  lgr %r2,%r10
Call Trace:
([<0000000000000000>]           (null))
 [<0000000000300abc>] new_slab+0x35c/0x628
 [<000000000030740c>] __kmem_cache_create+0x33c/0x638
 [<0000000000e99c0e>] create_boot_cache+0xae/0xe0
 [<0000000000e9e12c>] kmem_cache_init+0x5c/0x138
 [<0000000000e7999c>] start_kernel+0x24c/0x440
 [<0000000000100020>] _stext+0x20/0x80
Last Breaking-Event-Address:
 [<0000000000300ab6>] new_slab+0x356/0x628

Kernel panic - not syncing: Fatal exception: panic_on_oops

> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 5548f9686016..e57e06e6df4c 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -129,11 +129,11 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
>  		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
>  		       nid, K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
> -				sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
> -		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
> +		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE) +
> +			      node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
> +		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE)),
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
> +		       nid, K(node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
>  		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
>  				       HPAGE_PMD_NR),
>  		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
> @@ -141,7 +141,7 @@ static ssize_t node_read_meminfo(struct device *dev,
>  		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
>  				       HPAGE_PMD_NR));
>  #else
> -		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
> +		       nid, K(node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)));
>  #endif
>  	n += hugetlb_report_node_meminfo(nid, buf + n);
>  	return n;
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index ebaccd4e7d8c..eacadee83964 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -125,8 +125,6 @@ enum zone_stat_item {
>  	NR_ZONE_UNEVICTABLE,
>  	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
>  	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
> -	NR_SLAB_RECLAIMABLE,
> -	NR_SLAB_UNRECLAIMABLE,
>  	NR_PAGETABLE,		/* used for pagetables */
>  	NR_KERNEL_STACK_KB,	/* measured in KiB */
>  	/* Second 128 byte cacheline */
> @@ -152,6 +150,8 @@ enum node_stat_item {
>  	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
>  	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
>  	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
> +	NR_SLAB_RECLAIMABLE,
> +	NR_SLAB_UNRECLAIMABLE,
>  	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
>  	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
>  	WORKINGSET_REFAULT,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f9e450c6b6e4..5f89cfaddc4b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4601,8 +4601,6 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  			" present:%lukB"
>  			" managed:%lukB"
>  			" mlocked:%lukB"
> -			" slab_reclaimable:%lukB"
> -			" slab_unreclaimable:%lukB"
>  			" kernel_stack:%lukB"
>  			" pagetables:%lukB"
>  			" bounce:%lukB"
> @@ -4624,8 +4622,6 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  			K(zone->present_pages),
>  			K(zone->managed_pages),
>  			K(zone_page_state(zone, NR_MLOCK)),
> -			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
> -			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
>  			zone_page_state(zone, NR_KERNEL_STACK_KB),
>  			K(zone_page_state(zone, NR_PAGETABLE)),
>  			K(zone_page_state(zone, NR_BOUNCE)),
> diff --git a/mm/slab.c b/mm/slab.c
> index 2a31ee3c5814..b55853399559 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1425,10 +1425,10 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
>  
>  	nr_pages = (1 << cachep->gfporder);
>  	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> -		add_zone_page_state(page_zone(page),
> +		add_node_page_state(page_pgdat(page),
>  			NR_SLAB_RECLAIMABLE, nr_pages);
>  	else
> -		add_zone_page_state(page_zone(page),
> +		add_node_page_state(page_pgdat(page),
>  			NR_SLAB_UNRECLAIMABLE, nr_pages);
>  
>  	__SetPageSlab(page);
> @@ -1459,10 +1459,10 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
>  	kmemcheck_free_shadow(page, order);
>  
>  	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> -		sub_zone_page_state(page_zone(page),
> +		sub_node_page_state(page_pgdat(page),
>  				NR_SLAB_RECLAIMABLE, nr_freed);
>  	else
> -		sub_zone_page_state(page_zone(page),
> +		sub_node_page_state(page_pgdat(page),
>  				NR_SLAB_UNRECLAIMABLE, nr_freed);
>  
>  	BUG_ON(!PageSlab(page));
> diff --git a/mm/slub.c b/mm/slub.c
> index 57e5156f02be..673e72698d9b 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1615,7 +1615,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
>  	if (!page)
>  		return NULL;
>  
> -	mod_zone_page_state(page_zone(page),
> +	mod_node_page_state(page_pgdat(page),
>  		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
>  		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
>  		1 << oo_order(oo));
> @@ -1655,7 +1655,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
>  
>  	kmemcheck_free_shadow(page, compound_order(page));
>  
> -	mod_zone_page_state(page_zone(page),
> +	mod_node_page_state(page_pgdat(page),
>  		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
>  		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
>  		-pages);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c5f9d1673392..5d187ee618c0 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3815,7 +3815,7 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
>  	 * unmapped file backed pages.
>  	 */
>  	if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
> -	    sum_zone_node_page_state(pgdat->node_id, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
> +	    node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
>  		return NODE_RECLAIM_FULL;
>  
>  	/*
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 76f73670200a..a64f1c764f17 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -928,8 +928,6 @@ const char * const vmstat_text[] = {
>  	"nr_zone_unevictable",
>  	"nr_zone_write_pending",
>  	"nr_mlock",
> -	"nr_slab_reclaimable",
> -	"nr_slab_unreclaimable",
>  	"nr_page_table_pages",
>  	"nr_kernel_stack",
>  	"nr_bounce",
> @@ -952,6 +950,8 @@ const char * const vmstat_text[] = {
>  	"nr_inactive_file",
>  	"nr_active_file",
>  	"nr_unevictable",
> +	"nr_slab_reclaimable",
> +	"nr_slab_unreclaimable",
>  	"nr_isolated_anon",
>  	"nr_isolated_file",
>  	"workingset_refault",
> -- 
> 2.12.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
