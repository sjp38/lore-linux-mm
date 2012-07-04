Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id C3AE66B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 07:19:39 -0400 (EDT)
Date: Wed, 4 Jul 2012 12:19:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 1/3 V1] mm, page_alloc: use __rmqueue_smallest when
 borrow memory from MIGRATE_CMA
Message-ID: <20120704111935.GN13141@csn.ul.ie>
References: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
 <1341386778-8002-2-git-send-email-laijs@cn.fujitsu.com>
 <20120704101737.GL13141@csn.ul.ie>
 <4FF41E63.4020303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4FF41E63.4020303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <andi@firstfloor.org>, Julia Lawall <julia@diku.dk>, David Howells <dhowells@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kay Sievers <kay.sievers@vrfy.org>, Ingo Molnar <mingo@elte.hu>, Paul Gortmaker <paul.gortmaker@windriver.com>, Daniel Kiper <dkiper@net-space.pl>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Bjorn Helgaas <bhelgaas@google.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 04, 2012 at 06:43:47PM +0800, Lai Jiangshan wrote:
> On 07/04/2012 06:17 PM, Mel Gorman wrote:
> > On Wed, Jul 04, 2012 at 03:26:16PM +0800, Lai Jiangshan wrote:
> >> The pages of MIGRATE_CMA can't not be changed to the other type,
> >> nor be moved to the other free list. 
> >>
> >> ==>
> >> So when we use __rmqueue_fallback() to borrow memory from MIGRATE_CMA,
> >> one of the highest order page is borrowed and it is split.
> >> But the free pages resulted by splitting can NOT
> >> be moved to MIGRATE_MOVABLE.
> >>
> >> ==>
> >> So in the next time of allocation, we NEED to borrow again,
> >> another one of the highest order page is borrowed from CMA and it is split.
> >> and results some other new split free pages.
> >>
> > 
> > Then special case __rmqueue_fallback() to move pages stolen from
> > MIGRATE_CMA to the MIGRATE_MOVABLE lists but do not change the pageblock
> > type.
> 
> Because unmovable-page-requirement can allocate page from
> MIGRATE_MOVABLE free list. So We can not move MIGRATE_CMA pages
> to the MIGRATE_MOVABLE free list.
> 

Ok, good point.

> See here:
> 
> MOVABLE list is empty
> UNMOVABLE list is empty
> movable-page-requirement
> 	borrow from CMA list
> 	split it, others are put into UNMOVABLE list
> unmovable-page-requiremnt
> 	borrow from UNMOVABLE list
> 	NOW, it is BUG, we use CMA pages for unmovable usage.
> 

The patch still looks unnecessarily complex for what you are trying to
achieve and as a result I'm not reviewing it as carefully as I should.
It looks like the entire patch boiled down to this hunk here

+#ifdef CONFIG_CMA
+	if (unlikely(!page) && migratetype == MIGRATE_MOVABLE)
+		page = __rmqueue_smallest(zone, order, MIGRATE_CMA);
+#endif
+

With that in place, this would would need to change from

[MIGRATE_MOVABLE]     = { MIGRATE_CMA, MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },

to

[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },

because the fallback is already being handled as a special case. Leave
the other fallback logic as it is.

This is not tested at all and is only meant to illustrate why I think
your patch looks excessively complex for what you are trying to
achieve.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4beb7ae..0063e93 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -895,11 +895,9 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
 #ifdef CONFIG_CMA
-	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
 	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
-#else
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
 #endif
 	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
 	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
@@ -1076,6 +1074,20 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 
 retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
+#ifdef CONFIG_CMA
+	if (!unlikely(!page) && migratetype == MIGRATE_MOVABLE) {
+
+		/*
+		 * CMA is a special case where we want to use
+		 * the smallest available page instead of splitting
+		 * the largest chunks. We still must avoid the pages
+		 * moving to MIGRATE_MOVABLE where they might be
+		 * used for UNRECLAIMABLE or UNMOVABLE allocations
+		 */
+		migratetype = MIGRATE_CMA;
+		goto retry_reserve;
+	}
+#endif /* CONFIG_CMA */
 
 	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
 		page = __rmqueue_fallback(zone, order, migratetype);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
