Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 35CE96B00A4
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 06:03:58 -0400 (EDT)
Date: Thu, 13 Sep 2012 11:03:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 1/2 v2]compaction: abort compaction loop if lock is
 contended or run too long
Message-ID: <20120913100352.GV11266@suse.de>
References: <20120910011830.GC3715@kernel.org>
 <20120911163455.bb249a3c.akpm@linux-foundation.org>
 <20120912004840.GI27078@redhat.com>
 <20120912142019.0e06bf52.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120912142019.0e06bf52.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, minchan@kernel.org, Richard Davies <richard@arachsys.com>

On Wed, Sep 12, 2012 at 02:20:19PM -0700, Andrew Morton wrote:
> On Wed, 12 Sep 2012 02:48:40 +0200
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > On Tue, Sep 11, 2012 at 04:34:55PM -0700, Andrew Morton wrote:
> > > On Mon, 10 Sep 2012 09:18:30 +0800
> > > Shaohua Li <shli@kernel.org> wrote:
> > > 
> > > > isolate_migratepages_range() might isolate none pages, for example, when
> > > > zone->lru_lock is contended and compaction is async. In this case, we should
> > > > abort compaction, otherwise, compact_zone will run a useless loop and make
> > > > zone->lru_lock is even contended.
> > > > 
> > > > ...
> > > >
> > > > @@ -838,12 +838,14 @@ static unsigned long compact_zone_order(
> > > >  		.migratetype = allocflags_to_migratetype(gfp_mask),
> > > >  		.zone = zone,
> > > >  		.sync = sync,
> > > > -		.contended = contended,
> > > >  	};
> > > >  	INIT_LIST_HEAD(&cc.freepages);
> > > >  	INIT_LIST_HEAD(&cc.migratepages);
> > > >  
> > > > -	return compact_zone(zone, &cc);
> > > > +	ret = compact_zone(zone, &cc);
> > > > +	if (contended)
> > > > +		*contended = cc.contended;
> > > > +	return ret;
> > > >  }
> > > >  
> > > 
> > > From a quick read, `contended' is never NULL here.  And defining the
> > 
> > "contended" pointer can be null with some caller so the if is
> > needed. The inner code was checking it before. This is also why we
> > couldn't use *contended for the loop break bugfix, because contended
> > could have been null at times.
> 
> Confused.  I can see only two call sites:
> __alloc_pages_slowpath
> ->__alloc_pages_direct_compact
>   ->try_to_compact_pages
>     ->compact_zone_order
> and in both cases, `contended' points at valid storage.
> 

Andrea encountered out an additional bug as well but I preferred
a variant of Minchan's fix for it. Can you replace patches
mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long.patch
mm-compaction-abort-compaction-loop-if-lock-is-contended-or-run-too-long-fix.patch
with this version please? FWIW, I've asked Richard Davies (added to cc)
to test with this version of the patch as he is also reporting contention
problems when booting a windows guest under qemu.

I see you already picked up the documentation patch so I'll ignore the
additional "poke poke" in your mail :)

---8<---
From: Shaohua Li <shli@fusionio.com>
Subject: [PATCH] compaction: abort compaction loop if lock is contended or run too long

Changelog since V2
o Fix BUG_ON triggered due to pages left on cc.migratepages
o Make compact_zone_order() require non-NULL arg `contended'

Changelog since V1
o only abort the compaction if lock is contended or run too long
o Rearranged the code by Andrea Arcangeli.

isolate_migratepages_range() might isolate no pages if for example when
zone->lru_lock is contended and running asynchronous compaction. In this
case, we should abort compaction, otherwise, compact_zone will run a
useless loop and make zone->lru_lock is even contended. An additional
check is added to ensure that cc.migratepages and cc.freepages get
properly drained whan compaction is aborted.

[minchan@kernel.org: Putback pages isolated for migration if aborting]
[akpm@linux-foundation.org: compact_zone_order requires non-NULL arg contended]
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
