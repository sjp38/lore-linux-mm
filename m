Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DAADD60021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 07:50:20 -0500 (EST)
Date: Wed, 30 Dec 2009 21:49:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmstat: remove zone->lock from walk_zones_in_node
In-Reply-To: <20091229063436.GM3601@balbir.in.ibm.com>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com> <20091229063436.GM3601@balbir.in.ibm.com>
Message-Id: <20091230214506.1A0D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-12-28 16:47:22]:
> 
> > The zone->lock is one of performance critical locks. Then, it shouldn't
> > be hold for long time. Currently, we have four walk_zones_in_node()
> > usage and almost use-case don't need to hold zone->lock.
> > 
> > Thus, this patch move locking responsibility from walk_zones_in_node
> > to its sub function. Also this patch kill unnecessary zone->lock taking.
> > 
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmstat.c |    8 +++++---
> >  1 files changed, 5 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 6051fba..a5d45bc 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -418,15 +418,12 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
> >  {
> >  	struct zone *zone;
> >  	struct zone *node_zones = pgdat->node_zones;
> > -	unsigned long flags;
> > 
> >  	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
> >  		if (!populated_zone(zone))
> >  			continue;
> > 
> > -		spin_lock_irqsave(&zone->lock, flags);
> >  		print(m, pgdat, zone);
> > -		spin_unlock_irqrestore(&zone->lock, flags);
> >  	}
> >  }
> >
> 
> > @@ -455,6 +452,7 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
> >  					pg_data_t *pgdat, struct zone *zone)
> >  {
> >  	int order, mtype;
> > +	unsigned long flags;
> > 
> >  	for (mtype = 0; mtype < MIGRATE_TYPES; mtype++) {
> >  		seq_printf(m, "Node %4d, zone %8s, type %12s ",
> > @@ -468,8 +466,11 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
> > 
> >  			area = &(zone->free_area[order]);
> > 
> > +			spin_lock_irqsave(&zone->lock, flags);
> >  			list_for_each(curr, &area->free_list[mtype])
> >  				freecount++;
> > +			spin_unlock_irqrestore(&zone->lock, flags);
> > +
> >  			seq_printf(m, "%6lu ", freecount);
> >  		}
> >  		seq_putc(m, '\n');
> > @@ -709,6 +710,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
> >  							struct zone *zone)
> >  {
> >  	int i;
> > +
> >  	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
> >  	seq_printf(m,
> >  		   "\n  pages free     %lu"
> 
> While this is a noble cause, is printing all this information correct
> without the lock, I am not worried about old 
> information, but incorrect data. Should the read side be rcu'ed. Is
> just removing the lock and accessing data safe across architectures?

Hm. 
Actually,current memory-hotplug implementation change various zone data without zone->lock.
then, my patch doesn't cause regression. I'm not sure rcu protection is very worth or not.
but I think it can separate this patch.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
