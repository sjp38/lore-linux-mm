Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B859E6B0144
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 05:50:34 -0400 (EDT)
Date: Thu, 13 Sep 2012 10:50:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Windows VM slow boot
Message-ID: <20120913095028.GU11266@suse.de>
References: <5034D437.8070106@redhat.com>
 <20120822144150.GA1400@alpha.arachsys.com>
 <5034F8F4.3080301@redhat.com>
 <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120912164615.GA14173@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

On Wed, Sep 12, 2012 at 05:46:15PM +0100, Richard Davies wrote:
> Hi Mel - thanks for replying to my underhand bcc!
> 
> Mel Gorman wrote:
> > I see that this is an old-ish bug but I did not read the full history.
> > Is it now booting faster than 3.5.0 was? I'm asking because I'm
> > interested to see if commit c67fe375 helped your particular case.
> 
> Yes, I think 3.6.0-rc5 is already better than 3.5.x but can still be
> improved, as discussed.
> 

What are the boot times for each kernel?

> <PATCH SNIPPED>
> 
> I have applied and tested again - perf results below.
> 
> isolate_migratepages_range is indeed much reduced.
> 
> There is now a lot of time in isolate_freepages_block and still quite a lot
> of lock contention, although in a different place.
> 

This on top please.

---8<---
From: Shaohua Li <shli@fusionio.com>
compaction: abort compaction loop if lock is contended or run too long

isolate_migratepages_range() might isolate none pages, for example, when
zone->lru_lock is contended and compaction is async. In this case, we should
abort compaction, otherwise, compact_zone will run a useless loop and make
zone->lru_lock is even contended.

V2:
only abort the compaction if lock is contended or run too long
Rearranged the code by Andrea Arcangeli.

[minchan@kernel.org: Putback pages isolated for migration if aborting]
[akpm@linux-foundation.org: Fixup one contended usage site]
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Shaohua Li <shli@fusionio.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   17 ++++++++++++-----
 mm/internal.h   |    2 +-
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 7fcd3a5..a8de20d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -70,8 +70,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 
 		/* async aborts if taking too long or contended */
 		if (!cc->sync) {
-			if (cc->contended)
-				*cc->contended = true;
+			cc->contended = true;
 			return false;
 		}
 
@@ -634,7 +633,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 	/* Perform the isolation */
 	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
-	if (!low_pfn)
+	if (!low_pfn || cc->contended)
 		return ISOLATE_ABORT;
 
 	cc->migrate_pfn = low_pfn;
@@ -787,6 +786,8 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		switch (isolate_migratepages(zone, cc)) {
 		case ISOLATE_ABORT:
 			ret = COMPACT_PARTIAL;
+			putback_lru_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
 			goto out;
 		case ISOLATE_NONE:
 			continue;
@@ -831,6 +832,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync, bool *contended)
 {
+	unsigned long ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -838,12 +840,17 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.contended = contended,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	ret = compact_zone(zone, &cc);
+
+	VM_BUG_ON(!list_empty(&cc.freepages));
+	VM_BUG_ON(!list_empty(&cc.migratepages));
+
+	*contended = cc.contended;
+	return ret;
 }
 
 int sysctl_extfrag_threshold = 500;
diff --git a/mm/internal.h b/mm/internal.h
index b8c91b3..4bd7c0e 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -130,7 +130,7 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool *contended;		/* True if a lock was contended */
+	bool contended;			/* True if a lock was contended */
 };
 
 unsigned long

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
