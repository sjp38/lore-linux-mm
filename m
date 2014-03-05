Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 28BD76B006E
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 19:29:38 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id md12so283718pbc.23
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 16:29:37 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id j4si499496pad.22.2014.03.04.16.29.35
        for <linux-mm@kvack.org>;
        Tue, 04 Mar 2014 16:29:37 -0800 (PST)
Date: Wed, 5 Mar 2014 09:29:32 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/6] mm: add get_pageblock_migratetype_nolock() for cases
 where locking is undesirable
Message-ID: <20140305002932.GA2340@lge.com>
References: <1393596904-16537-1-git-send-email-vbabka@suse.cz>
 <1393596904-16537-3-git-send-email-vbabka@suse.cz>
 <20140303082227.GA28899@lge.com>
 <53148981.90709@suse.cz>
 <20140304005513.GB32172@lge.com>
 <5315C438.8070504@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5315C438.8070504@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Mar 04, 2014 at 01:16:56PM +0100, Vlastimil Babka wrote:
> On 03/04/2014 01:55 AM, Joonsoo Kim wrote:
> >On Mon, Mar 03, 2014 at 02:54:09PM +0100, Vlastimil Babka wrote:
> >>On 03/03/2014 09:22 AM, Joonsoo Kim wrote:
> >>>On Fri, Feb 28, 2014 at 03:15:00PM +0100, Vlastimil Babka wrote:
> >>>>In order to prevent race with set_pageblock_migratetype, most of calls to
> >>>>get_pageblock_migratetype have been moved under zone->lock. For the remaining
> >>>>call sites, the extra locking is undesirable, notably in free_hot_cold_page().
> >>>>
> >>>>This patch introduces a _nolock version to be used on these call sites, where
> >>>>a wrong value does not affect correctness. The function makes sure that the
> >>>>value does not exceed valid migratetype numbers. Such too-high values are
> >>>>assumed to be a result of race and caller-supplied fallback value is returned
> >>>>instead.
> >>>>
> >>>>Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> >>>>---
> >>>>  include/linux/mmzone.h | 24 ++++++++++++++++++++++++
> >>>>  mm/compaction.c        | 14 +++++++++++---
> >>>>  mm/memory-failure.c    |  3 ++-
> >>>>  mm/page_alloc.c        | 22 +++++++++++++++++-----
> >>>>  mm/vmstat.c            |  2 +-
> >>>>  5 files changed, 55 insertions(+), 10 deletions(-)
> >>>>
> >>>>diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >>>>index fac5509..7c3f678 100644
> >>>>--- a/include/linux/mmzone.h
> >>>>+++ b/include/linux/mmzone.h
> >>>>@@ -75,6 +75,30 @@ enum {
> >>>>
> >>>>  extern int page_group_by_mobility_disabled;
> >>>>
> >>>>+/*
> >>>>+ * When called without zone->lock held, a race with set_pageblock_migratetype
> >>>>+ * may result in bogus values. Use this variant only when this does not affect
> >>>>+ * correctness, and taking zone->lock would be costly. Values >= MIGRATE_TYPES
> >>>>+ * are considered to be a result of this race and the value of race_fallback
> >>>>+ * argument is returned instead.
> >>>>+ */
> >>>>+static inline int get_pageblock_migratetype_nolock(struct page *page,
> >>>>+	int race_fallback)
> >>>>+{
> >>>>+	int ret = get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
> >>>>+
> >>>>+	if (unlikely(ret >= MIGRATE_TYPES))
> >>>>+		ret = race_fallback;
> >>>>+
> >>>>+	return ret;
> >>>>+}
> >>>
> >>>Hello, Vlastimil.
> >>>
> >>>First of all, thanks for nice work!
> >>>I have another opinion about this implementation. It can be wrong, so if it
> >>>is wrong, please let me know.
> >>
> >>Thanks, all opinions/reviewing is welcome :)
> >>
> >>>Although this implementation would close the race which triggers NULL dereference,
> >>>I think that this isn't enough if you have a plan to add more
> >>>{start,undo}_isolate_page_range().
> >>>
> >>>Consider that there are lots of {start,undo}_isolate_page_range() calls
> >>>on the system without CMA.
> >>>
> >>>bit representation of migratetype is like as following.
> >>>
> >>>MIGRATE_MOVABLE = 010
> >>>MIGRATE_ISOLATE = 100
> >>>
> >>>We could read following values as migratetype of the page on movable pageblock
> >>>if race occurs.
> >>>
> >>>start_isolate_page_range() case: 010 -> 100
> >>>010, 000, 100
> >>>
> >>>undo_isolate_page_range() case: 100 -> 010
> >>>100, 110, 010
> >>>
> >>>Above implementation prevents us from getting 110, but, it can't prevent us from
> >>>getting 000, that is, MIGRATE_UNMOVABLE. If this race occurs in free_hot_cold_page(),
> >>>this page would go into unmovable pcp and then allocated for that migratetype.
> >>>It results in more fragmented memory.
> >>
> >>Yes, that can happen. But I would expect it to be negligible to
> >>other causes of fragmentation. But I'm not at this moment sure how
> >>often {start,undo}_isolate_page_range() would be called in the end.
> >>Certainly
> >>not as often as in the development patch which is just to see if
> >>that can improve anything. Because it will have its own overhead
> >>(mostly for zone->lock) that might be too large. But good point, I
> >>will try to quantify this.
> >>
> >>>
> >>>Consider another case that system enables CONFIG_CMA,
> >>>
> >>>MIGRATE_MOVABLE = 010
> >>>MIGRATE_ISOLATE = 101
> >>>
> >>>start_isolate_page_range() case: 010 -> 101
> >>>010, 011, 001, 101
> >>>
> >>>undo_isolate_page_range() case: 101 -> 010
> >>>101, 100, 110, 010
> >>>
> >>>This can results in totally different values and this also makes the problem
> >>>mentioned above. And, although this doesn't cause any problem on CMA for now,
> >>>if another migratetype is introduced or some migratetype is removed, it can cause
> >>>CMA typed page to go into other migratetype and makes CMA permanently failed.
> >>
> >>This should actually be no problem for free_hot_cold_page() as any
> >>migratetype >= MIGRATE_PCPTYPES will defer to free_one_page() which
> >>will reread migratetype under zone->lock. So as long as
> >>MIGRATE_PCPTYPES does not include a migratetype with such dangerous
> >>"permanently failed" properties, it should be good. And I doubt such
> >>migratetype would be added to pcptypes. But of course, anyone adding
> >>new migratetype would have to reconsider each
> >>get_pageblock_migratetype_nolock() call for such potential problems.
> >
> >Please let me explain more.
> >Now CMA page can have following race values.
> >
> >MIGRATE_CMA = 100
> >MIGRATE_ISOLATE = 101
> >
> >start_isolate_page_range(): 100 -> 101
> >100, 101
> >undo_isolate_page_range(): 101 -> 100
> >101, 100
> >
> >So, race doesn't cause any big problem.
> >
> >But, as you mentioned in earlier patch, it could get worse if MIGRATE_RESERVE
> >is removed. It doesn't happen until now, but, it can be possible.
> >
> >In that case,
> >
> >MIGRATE_CMA = 011
> >MIGRATE_ISOLATE = 100
> >
> >start_isolate_page_range(): 011 -> 100
> >011, 010, 000, 100
> >undo_isolate_page_range(): 100 -> 011
> >100, 101, 111, 011
> >
> >If this race happens, CMA page can go into MIGRATE_UNMOVABLE list, because
> >"migratetpye >= MIGRATE_PCPTYPES" can't prevent it, and this could make
> >CMA permanently failed.
> 
> Oh, I understand what you mean now, sorry. And since
> alloc_contig_range() is already doing just this kind of
> CMA->ISOLATE->CMA transitions, it could really be a problem even
> without my pending work. But maybe it would be enough to add just
> extra PG_isolate bit to prevent this, and CMA could stay within the
> current migratetype bits, no? The separate bit could be even useful
> to simplify my work.

Yes, CMA could stay within the current migratetype bits.

> Would you agree that this can be postponed a bit as I develop the
> further compaction series, since CMA currently doesn't have the
> dangerous value? Maybe there will be new concerns that will lead to
> different solution.
> This series already prevents possible panic, which is worse than this issue.

If we introduce separate bit for MIGRATE_ISOLATE and makes bit operation atomic(6/6),
this patchset can be changed. Although I think that it is better to distinguish
lock/nolock case, nolock variant has no effect since there is no possibility
to get strange race values prevented by this patch if we have separate bit for
MIGRATE_ISOLATE. So I would like to see the change at this time. But, I don't
have strong objection to current implementation. :)

> 
> >I think that to dump the responsibility on developer who want to add/remove migratetype
> >is not reasonable and doesn't work well, because they may not have enough background
> >knowledge. I hope to close the possible race more in this time.
> 
> Right, but even if we now added separate bits for ISOLATE and CMA,
> anyone adding new migratetype would still have to think how to
> handle that one (common migratetype bits or also some new bit?) and
> what are the consequences.

Okay.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
