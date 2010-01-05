Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E8F416005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 21:05:02 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0524x7P014786
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 5 Jan 2010 11:05:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C56E545DE4F
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:04:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A531345DE4E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:04:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 886051DB803C
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:04:59 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E5B81DB803B
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 11:04:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] vmstat: remove zone->lock from walk_zones_in_node
In-Reply-To: <20100103185957.GB11420@csn.ul.ie>
References: <20091228164451.A687.A69D9226@jp.fujitsu.com> <20100103185957.GB11420@csn.ul.ie>
Message-Id: <20100105105328.96CE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  5 Jan 2010 11:04:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi

> On Mon, Dec 28, 2009 at 04:47:22PM +0900, KOSAKI Motohiro wrote:
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
> 
> It's not clear why you feel this information requires the lock and the
> others do not.

I think above list operation require lock to prevent NULL pointer access. but other parts
doesn't protect anything, because memory-hotplug change them without zone lock.


> For the most part, I agree that the accuracy of the information is
> not critical. Assuming partial writes of the data are not a problem,
> the information is not going to go so badly out of sync that it would be
> noticable, even if the information is out of date within the zone.
> 
> However, inconsistent reads in zoneinfo really could be a problem. I am
> concerned that under heavy allocation load that that "pages free" would
> not match "nr_pages_free" for example. Other examples that adding all the
> counters together may or may not equal the total number of pages in the zone.
> 
> Lets say for example there was a subtle bug related to __inc_zone_page_state()
> that meant that counters were getting slightly out of sync but it was very
> marginal and/or difficult to reproduce. With this patch applied, we could
> not be absolutly sure the counters were correct because it could always have
> raced with someone holding the zone->lock.
> 
> Minimally, I think zoneinfo should be taking the zone lock.

Thanks lots comments. 
hmm.. I'd like to clarily your point. My point is memory-hotplug don't take zone lock,
then zone lock doesn't protect anything. so we have two option

1) Add zone lock to memroy-hotplug
2) Remove zone lock from zoneinfo

I thought (2) is sufficient. Do you mean you prefer to (1)? Or you prefer to ignore rarely event
(of cource, memory hotplug is rarely)?


> Secondly, has increased zone->lock contention due to reading /proc
> really been shown to be a problem? The only situation that I can think
> of is a badly-written monitor program that is copying all of /proc
> instead of the files of interest. If a monitor program is doing
> something like that, it's likely to be incurring performance problems in
> a large number of different areas. If that is not the trigger case, what
> is?

Ah no. I haven't observe such issue. my point is removing meaningless lock.


> >  			seq_printf(m, "%6lu ", freecount);
> >  		}
> >  		seq_putc(m, '\n');
> > @@ -709,6 +710,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
> >  							struct zone *zone)
> >  {
> >  	int i;
> > +
> 
> Unnecessary whitespace change.

Ug. thanks, it's my fault.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
