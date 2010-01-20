Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 03BE76B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 04:48:28 -0500 (EST)
Date: Wed, 20 Jan 2010 09:48:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/7] Add /proc trigger for memory compaction
Message-ID: <20100120094813.GC5154@csn.ul.ie>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-6-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071352100.23894@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001071352100.23894@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 07, 2010 at 02:00:16PM -0800, David Rientjes wrote:
> On Wed, 6 Jan 2010, Mel Gorman wrote:
> 
> > This patch adds a proc file /proc/sys/vm/compact_node. When a NID is written
> > to the file, each zone in that node is compacted. This should be done with
> > debugfs but this was what was available to rebase quickly and I suspect
> > debugfs either did not exist or was in development during the first
> > implementation.
> > 
> > If this interface is to exist in the long term, it needs to be thought
> > about carefully. For the moment, it's handy to have to test compaction
> > under a controlled setting.
> > 
> 
> With Lee's work on mempolicy-constrained hugepage allocations, there is a 
> use-case for this explicit trigger to be exported via sysfs in the 
> longterm:

True, although the per-node structures are only available on NUMA making
it necessary to have two interfaces. The per-node one is handy enough
because it would be just

/sys/devices/system/node/nodeX/compact_node
	When written to, this node is compacted by the writing process

But there does not appear to be a "good" way of having a non-NUMA
interface. /sys/devices/system/node does not exist .... Does anyone
remember why !NUMA does not have a /sys/devices/system/node/node0? Is
there a good reason or was there just no point?

> we should be able to determine how successful the allocation of 
> hugepages will be on a particular node without actually allocating them 
> depending on the degree of external fragmentation to form our mempolicy.  

You can guess to some extent but can't know without scanning the pages.
A simple guess would be based on the number of MIGRATE_MOVABLE pageblocks
and the number of LRU pages that are in the node. Something like;

1. Count how many MIGRATE_MOVABLE pageblocks there currently are in the
   zone (examination of a bitmap)

2. Assuming there is little or no mixing of pageblocks (because min_free_kbytes
   was tuned properly), calculate how many MIGRATE_MOVABLE pageblocks
   are required for all the LRU pages in the zone

3. The number of possible hugepages is the difference in the two
   pageblock counts.

> Since node-targeted hugepage allocation and freeing now exists in the 
> kernel and compaction is used primary for the former, I don't see why it 
> shouldn't be exposed.
> 
> I like the (slightly racy) interface that avoids having a trigger for each 
> node under /sys/devices/system/node as well.
> 

So, would you be happy with a proc-interface like this and also having a
sysfs-based trigger for NUMA? Or do we need to come up with a
sysfs-based trigger that works for both NUMA and !NUMA?

> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/compaction.h |    5 ++++
> >  kernel/sysctl.c            |   11 +++++++++
> >  mm/compaction.c            |   52 ++++++++++++++++++++++++++++++++++++++++++++
> >  3 files changed, 68 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> > index 6201371..5965ef2 100644
> > --- a/include/linux/compaction.h
> > +++ b/include/linux/compaction.h
> > @@ -5,4 +5,9 @@
> >  #define COMPACT_INCOMPLETE	0
> >  #define COMPACT_COMPLETE	1
> >  
> > +#ifdef CONFIG_MIGRATION
> > +extern int sysctl_compaction_handler(struct ctl_table *table, int write,
> > +			void __user *buffer, size_t *length, loff_t *ppos);
> > +#endif /* CONFIG_MIGRATION */
> > +
> >  #endif /* _LINUX_COMPACTION_H */
> > diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> > index 8a68b24..6202e95 100644
> > --- a/kernel/sysctl.c
> > +++ b/kernel/sysctl.c
> > @@ -50,6 +50,7 @@
> >  #include <linux/ftrace.h>
> >  #include <linux/slow-work.h>
> >  #include <linux/perf_event.h>
> > +#include <linux/compaction.h>
> >  
> >  #include <asm/uaccess.h>
> >  #include <asm/processor.h>
> > @@ -80,6 +81,7 @@ extern int pid_max;
> >  extern int min_free_kbytes;
> >  extern int pid_max_min, pid_max_max;
> >  extern int sysctl_drop_caches;
> > +extern int sysctl_compact_node;
> >  extern int percpu_pagelist_fraction;
> >  extern int compat_log;
> >  extern int latencytop_enabled;
> > @@ -1109,6 +1111,15 @@ static struct ctl_table vm_table[] = {
> >  		.mode		= 0644,
> >  		.proc_handler	= drop_caches_sysctl_handler,
> >  	},
> > +#ifdef CONFIG_MIGRATION
> > +	{
> > +		.procname	= "compact_node",
> > +		.data		= &sysctl_compact_node,
> > +		.maxlen		= sizeof(int),
> > +		.mode		= 0644,
> 
> This should only need 0200?
> 
> > +		.proc_handler	= sysctl_compaction_handler,
> > +	},
> > +#endif /* CONFIG_MIGRATION */
> >  	{
> >  		.procname	= "min_free_kbytes",
> >  		.data		= &min_free_kbytes,
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index d36760a..a8bcae2 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -11,6 +11,7 @@
> >  #include <linux/migrate.h>
> >  #include <linux/compaction.h>
> >  #include <linux/mm_inline.h>
> > +#include <linux/sysctl.h>
> >  #include "internal.h"
> >  
> >  /*
> > @@ -338,3 +339,54 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
> >  	return ret;
> >  }
> >  
> > +/* Compact all zones within a node */
> > +int compact_node(int nid)
> > +{
> > +	int zoneid;
> > +	pg_data_t *pgdat;
> > +	struct zone *zone;
> > +
> > +	if (nid < 0 || nid > nr_node_ids || !node_online(nid))
> > +		return -EINVAL;
> > +	pgdat = NODE_DATA(nid);
> > +
> > +	/* Flush pending updates to the LRU lists */
> > +	lru_add_drain_all();
> > +
> > +	printk(KERN_INFO "Compacting memory in node %d\n", nid);
> > +	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
> > +		struct compact_control cc;
> > +
> > +		zone = &pgdat->node_zones[zoneid];
> > +		if (!populated_zone(zone))
> > +			continue;
> > +
> > +		cc.nr_freepages = 0;
> > +		cc.nr_migratepages = 0;
> > +		cc.zone = zone;
> > +		INIT_LIST_HEAD(&cc.freepages);
> > +		INIT_LIST_HEAD(&cc.migratepages);
> > +
> > +		compact_zone(zone, &cc);
> > +
> > +		VM_BUG_ON(!list_empty(&cc.freepages));
> > +		VM_BUG_ON(!list_empty(&cc.migratepages));
> > +	}
> > +	printk(KERN_INFO "Compaction of node %d complete\n", nid);
> 
> If it's exposed through sysfs, the printk's should probably be demoted to 
> pr_debug().
> 

I deleted them altogether. The point originally was to measure how long
compaction took. It can just as easily be done by running

time echo 0 > compact_node

Thanks

> > +
> > +	return 0;
> > +}
> > +
> > +/* This is global and fierce ugly but it's straight-forward */
> > +int sysctl_compact_node;
> > +
> > +/* This is the entry point for compacting nodes via /proc/sys/vm */
> > +int sysctl_compaction_handler(struct ctl_table *table, int write,
> > +			void __user *buffer, size_t *length, loff_t *ppos)
> > +{
> > +	proc_dointvec(table, write, buffer, length, ppos);
> > +	if (write)
> > +		return compact_node(sysctl_compact_node);
> > +
> > +	return 0;
> > +}
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
