Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 29F026B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 00:12:21 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1653785dad.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 21:12:20 -0700 (PDT)
Date: Fri, 7 Sep 2012 12:12:12 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/2]compaction: check migrated page number
Message-ID: <20120907041212.GA31391@kernel.org>
References: <20120906104404.GA12718@kernel.org>
 <20120906121725.GQ11266@suse.de>
 <20120906125526.GA1025@kernel.org>
 <20120906132551.GS11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120906132551.GS11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On Thu, Sep 06, 2012 at 02:25:51PM +0100, Mel Gorman wrote:
> On Thu, Sep 06, 2012 at 08:55:26PM +0800, Shaohua Li wrote:
> > On Thu, Sep 06, 2012 at 01:17:25PM +0100, Mel Gorman wrote:
> > > On Thu, Sep 06, 2012 at 06:44:04PM +0800, Shaohua Li wrote:
> > > > 
> > > > isolate_migratepages_range() might isolate none pages, for example, when
> > > > zone->lru_lock is contended and compaction is async. In this case, we should
> > > > abort compaction, otherwise, compact_zone will run a useless loop and make
> > > > zone->lru_lock is even contended.
> > > > 
> > > 
> > > It might also isolate no pages because the range was 100% allocated and
> > > there were no free pages to isolate. This is perfectly normal and I suspect
> > > this patch effectively disables compaction. What problem did you observe
> > > that this patch is aimed at?
> > 
> > I'm running a random swapin/out workload. When memory is fragmented enough, I
> > saw 100% cpu usage. perf shows zone->lru_lock is heavily contended in
> > isolate_migratepages_range. I'm using slub(I didn't see the problem with slab),
> > the allocation is for radix_tree_node slab, which needs 4 pages.
> 
> Ok, the fragmentaiton is due to high-order unmovable kernel allocations from
> SLUB which will have diminishing returns over time.  One option to address
> this is to check if it's a high-order kernel allocation that can fail and
> not compact in that case. SLUB will fall back to using order-0 instead.

I tried actually, and it doesn't help. The problem is compact_zone keeps
running isolate_migratepages_range, which does nothing except doing a
lock/unlock.
 
> > Even If I just
> > apply the second patch, the system is still in 100% cpu usage. The
> > spin_is_contended check can't cure the problem completely.
> 
> Are you sure it's really contention in that case and not just a lot of
> time is spent in compaction trying to satisfy the radix_tree_node
> allocation requests?

certainly it's the contention.
 
> > Trace shows
> > compact_zone will run a useless loop and each loop contend the lru_lock. With
> > this patch, the cpu usage becomes normal (about 20% utilization).
> 
> I suspect the reason why this patch has an effect is because compaction is
> no longer running. It finds a 100% full pageblock quickly and then aborts and
> that is not the right fix. Can you try something like this instead please?

That debug patch doesn't help. My system just hang.

I thought your worry is valid, we shouldn't abort if 100% full pageblock is
found. How about this one? With it, the cpu usage is normal in my workload.
Occassionally I saw cpu usage reaches high (up to 80%), but recovered
immediately. Without the patch, the cpu usage keeps in 100%.

Thanks,
Shaohua


Subject: compaction: check migrated page number

isolate_migratepages_range() might isolate none pages, for example, when
zone->lru_lock is contended and compaction is async. In this case, we should
abort compaction, otherwise, compact_zone will run a useless loop and make
zone->lru_lock is even contended.

Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/compaction.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux/mm/compaction.c
===================================================================
--- linux.orig/mm/compaction.c	2012-09-06 18:37:52.636413761 +0800
+++ linux/mm/compaction.c	2012-09-07 10:51:16.734081959 +0800
@@ -618,7 +618,7 @@ typedef enum {
 static isolate_migrate_t isolate_migratepages(struct zone *zone,
 					struct compact_control *cc)
 {
-	unsigned long low_pfn, end_pfn;
+	unsigned long low_pfn, end_pfn, old_low_pfn;
 
 	/* Do not scan outside zone boundaries */
 	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
@@ -633,8 +633,9 @@ static isolate_migrate_t isolate_migrate
 	}
 
 	/* Perform the isolation */
+	old_low_pfn = low_pfn;
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
+	if (!low_pfn || old_low_pfn == low_pfn)
 		return ISOLATE_ABORT;
 
 	cc->migrate_pfn = low_pfn;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
