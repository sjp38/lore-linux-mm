Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 63E946B0068
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 11:52:47 -0400 (EDT)
Date: Fri, 7 Sep 2012 17:52:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/2]compaction: check migrated page number
Message-ID: <20120907155243.GA21894@redhat.com>
References: <20120906104404.GA12718@kernel.org>
 <20120906121725.GQ11266@suse.de>
 <20120906125526.GA1025@kernel.org>
 <20120906132551.GS11266@suse.de>
 <20120907041212.GA31391@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120907041212.GA31391@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, Sep 07, 2012 at 12:12:12PM +0800, Shaohua Li wrote:
> Subject: compaction: check migrated page number
> 
> isolate_migratepages_range() might isolate none pages, for example, when
> zone->lru_lock is contended and compaction is async. In this case, we should
> abort compaction, otherwise, compact_zone will run a useless loop and make
> zone->lru_lock is even contended.
> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  mm/compaction.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux/mm/compaction.c
> ===================================================================
> --- linux.orig/mm/compaction.c	2012-09-06 18:37:52.636413761 +0800
> +++ linux/mm/compaction.c	2012-09-07 10:51:16.734081959 +0800
> @@ -618,7 +618,7 @@ typedef enum {
>  static isolate_migrate_t isolate_migratepages(struct zone *zone,
>  					struct compact_control *cc)
>  {
> -	unsigned long low_pfn, end_pfn;
> +	unsigned long low_pfn, end_pfn, old_low_pfn;
>  
>  	/* Do not scan outside zone boundaries */
>  	low_pfn = max(cc->migrate_pfn, zone->zone_start_pfn);
> @@ -633,8 +633,9 @@ static isolate_migrate_t isolate_migrate
>  	}
>  
>  	/* Perform the isolation */
> +	old_low_pfn = low_pfn;
>  	low_pfn = isolate_migratepages_range(zone, cc, low_pfn, end_pfn);
> -	if (!low_pfn)
> +	if (!low_pfn || old_low_pfn == low_pfn)
>  		return ISOLATE_ABORT;
>  
>  	cc->migrate_pfn = low_pfn;

Looks good to me.

This other below approach should also work:

diff --git a/mm/compaction.c b/mm/compaction.c
index 7fcd3a5..aefb712 100644
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
@@ -831,6 +830,7 @@ static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
 				 bool sync, bool *contended)
 {
+	unsigned long ret;
 	struct compact_control cc = {
 		.nr_freepages = 0,
 		.nr_migratepages = 0,
@@ -838,12 +838,14 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
 		.sync = sync,
-		.contended = contended,
 	};
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	ret = compact_zone(zone, &cc);
+	if (contended)
+		*contended = cc.contended;
+	return ret;
 }
 
 int sysctl_extfrag_threshold = 500;
diff --git a/mm/internal.h b/mm/internal.h
index 53418cd..dbb32ff 100644
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
