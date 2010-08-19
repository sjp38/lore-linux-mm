Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 18FFC6B01F2
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 04:16:11 -0400 (EDT)
Date: Thu, 19 Aug 2010 09:15:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100819081554.GY19797@csn.ul.ie>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819074602.GW19797@csn.ul.ie> <20100819080830.GA17899@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100819080830.GA17899@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 04:08:31PM +0800, Wu Fengguang wrote:
> On Thu, Aug 19, 2010 at 03:46:02PM +0800, Mel Gorman wrote:
> > On Thu, Aug 19, 2010 at 04:09:38PM +0900, Iram Shahzad wrote:
> > >> The loop should be waiting for the _other_ processes (doing direct
> > >> reclaims) to proceed.  When there are _lots of_ ongoing page
> > >> allocations/reclaims, it makes sense to wait for them to calm down a bit?
> > >
> > > I have noticed that if I run other process, it helps the loop to exit.
> > > So is this (ie hanging until other process helps) intended behaviour?
> > >
> > 
> > No, it's not but I'm not immediately seeing how it would occur either.
> > too_many_isolated() should only be true when there are multiple
> > processes running that are isolating pages be it due to reclaim or
> > compaction. These should be finishing their work after some time so
> > while a process may stall in too_many_isolated(), it should not stay
> > there forever.
> > 
> > The loop around isolate_migratepages() puts back LRU pages it failed to
> > migrate so it's not the case that the compacting process is isolating a
> > large number of pages and then calling too_many_isolated() against itself.
> 
> It seems the compaction process isolates 128MB pages at a time?

It should be one pageblock at a time for source migration and one pageblock
for target pages. Look at the values for low_pfn and end_pfn here;

static unsigned long isolate_migratepages(struct zone *zone,
                                        struct compact_control *cc)
{
        unsigned long low_pfn, end_pfn;
        struct list_head *migratelist = &cc->migratepages;

        /* Do not scan outside zone boundaries */
        low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);

        /* Only scan within a pageblock boundary */
        end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);

....

and the loop around that looks like

        while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
                unsigned long nr_migrate, nr_remaining;

                if (!isolate_migratepages(zone, cc))
                        continue;

                nr_migrate = cc->nr_migratepages;
                migrate_pages(&cc->migratepages, compaction_alloc,
                                                (unsigned long)cc, 0);
                update_nr_listpages(cc);
                nr_remaining = cc->nr_migratepages;

                count_vm_event(COMPACTBLOCKS);
                count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
                if (nr_remaining)
                        count_vm_events(COMPACTPAGEFAILED, nr_remaining);

                /* Release LRU pages not migrated */
                if (!list_empty(&cc->migratepages)) {
                        putback_lru_pages(&cc->migratepages);
                        cc->nr_migratepages = 0;
                }

        }

Where is it isolating 128MB?

> That
> sounds risky, too_many_isolated() can easily be true, which will stall
> direct reclaim processes. I'm not seeing how exactly it makes
> compaction itself stall infinitely though.
> 
> > > Also, the other process does help the loop to exit, but again it enters
> > > the loop and the compaction is never finished. That is, the process
> > > looks like hanging. Is this intended behaviour?
> > 
> > Infinite loops are never intended behaviour.
> 
> Yup.
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
