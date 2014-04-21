Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AB3766B0035
	for <linux-mm@kvack.org>; Mon, 21 Apr 2014 19:52:16 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so4285663pad.29
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 16:52:16 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tv5si21649472pbc.244.2014.04.21.16.52.14
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 16:52:15 -0700 (PDT)
Date: Tue, 22 Apr 2014 08:53:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
Message-ID: <20140421235319.GD7178@bbox>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
 <1397553507-15330-2-git-send-email-vbabka@suse.cz>
 <20140417000745.GF27534@bbox>
 <20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org>
 <535590FC.10607@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <535590FC.10607@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, Apr 21, 2014 at 11:43:24PM +0200, Vlastimil Babka wrote:
> On 21.4.2014 21:41, Andrew Morton wrote:
> >On Thu, 17 Apr 2014 09:07:45 +0900 Minchan Kim <minchan@kernel.org> wrote:
> >
> >>Hi Vlastimil,
> >>
> >>Below just nitpicks.
> >It seems you were ignored ;)
> 
> Oops, I managed to miss your e-mail, sorry.
> 
> >>>  {
> >>>  	struct page *page;
> >>>-	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
> >>>+	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
> >>Could you add comment for each variable?
> >>
> >>unsigned long pfn; /* scanning cursor */
> >>unsigned long low_pfn; /* lowest pfn free scanner is able to scan */
> >>unsigned long next_free_pfn; /* start pfn for scaning at next truen */
> >>unsigned long z_end_pfn; /* zone's end pfn */
> >>
> >>
> >>>@@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
> >>>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
> >>>  	/*
> >>>-	 * Take care that if the migration scanner is at the end of the zone
> >>>-	 * that the free scanner does not accidentally move to the next zone
> >>>-	 * in the next isolation cycle.
> >>>+	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
> >>>+	 * none, the pfn < low_pfn check will kick in.
> >>        "none" what? I'd like to clear more.
> 
> If there are no updates to next_free_pfn within the for cycle. Which
> matches Andrew's formulation below.
> 
> >I did this:
> 
> Thanks!
> 
> >
> >--- a/mm/compaction.c~mm-compaction-cleanup-isolate_freepages-fix
> >+++ a/mm/compaction.c
> >@@ -662,7 +662,10 @@ static void isolate_freepages(struct zon
> >  				struct compact_control *cc)
> >  {
> >  	struct page *page;
> >-	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
> >+	unsigned long pfn;	     /* scanning cursor */
> >+	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
> >+	unsigned long next_free_pfn; /* start pfn for scaning at next round */
> >+	unsigned long z_end_pfn;     /* zone's end pfn */
> 
> Yes that works.
> 
> >  	int nr_freepages = cc->nr_freepages;
> >  	struct list_head *freelist = &cc->freepages;
> >@@ -679,8 +682,8 @@ static void isolate_freepages(struct zon
> >  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
> >  	/*
> >-	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
> >-	 * none, the pfn < low_pfn check will kick in.
> >+	 * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
> >+	 * isolated, the pfn < low_pfn check will kick in.
> 
> OK.
> 
> >  	 */
> >  	next_free_pfn = 0;
> >>>@@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
> >>>  	 * so that compact_finished() may detect this
> >>>  	 */
> >>>  	if (pfn < low_pfn)
> >>>-		cc->free_pfn = max(pfn, zone->zone_start_pfn);
> >>>-	else
> >>>-		cc->free_pfn = high_pfn;
> >>>+		next_free_pfn = max(pfn, zone->zone_start_pfn);
> >>Why we need max operation?
> >>IOW, what's the problem if we do (next_free_pfn = pfn)?
> >An answer to this would be useful, thanks.
> 
> The idea (originally, not new here) is that the free scanner wants
> to remember the highest-pfn
> block where it managed to isolate some pages. If the following page
> migration fails, these isolated
> pages might be put back and would be skipped in further compaction
> attempt if we used just
> "next_free_pfn = pfn", until the scanners get reset.
> 
> The question of course is if such situations are frequent and makes
> any difference to compaction
> outcome. And the downsides are potentially useless rescans and code
> complexity. Maybe Mel
> remembers how important this is? It should probably be profiled
> before changes are made.

I didn't mean it. What I mean is code snippet you introduced in 7ed695e069c3c.
At that time, I didn't Cced so I missed that code so let's ask this time.
In that patch, you added this.

if (pfn < low_pfn)
  cc->free_pfn = max(pfn, zone->zone_start_pfn);
else
  cc->free_pfn = high_pfn;

So the purpose of max(pfn, zone->zone_start_pfn) is to be detected by
compact_finished to stop compaction. And your [1/2] patch in this patchset
always makes free page scanner start on pageblock boundary so when the
loop in isolate_freepages is finished and pfn is lower low_pfn, the pfn
would be lower than migration scanner so compact_finished will always detect
it so I think you could just do

if (pfn < low_pfn)
  next_free_pfn = pfn;

cc->free_pfn = next_free_pfn;

Or, if you want to clear *reset*,
if (pfn < lown_pfn)
  next_free_pfn = zone->zone_start_pfn;

cc->free_pfn = next_free_pfn;

That's why I asked about max operation. What am I missing?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
