Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 24A256B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 02:51:32 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so4561150pdj.9
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 23:51:31 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id a8si22192491pbs.457.2014.04.21.23.51.29
        for <linux-mm@kvack.org>;
        Mon, 21 Apr 2014 23:51:31 -0700 (PDT)
Date: Tue, 22 Apr 2014 15:52:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/compaction: cleanup isolate_freepages()
Message-ID: <20140422065224.GE24292@bbox>
References: <5342BA34.8050006@suse.cz>
 <1397553507-15330-1-git-send-email-vbabka@suse.cz>
 <1397553507-15330-2-git-send-email-vbabka@suse.cz>
 <20140417000745.GF27534@bbox>
 <20140421124146.c8beacf0d58aafff2085a461@linux-foundation.org>
 <535590FC.10607@suse.cz>
 <20140421235319.GD7178@bbox>
 <53560D3F.2030002@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53560D3F.2030002@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Tue, Apr 22, 2014 at 08:33:35AM +0200, Vlastimil Babka wrote:
> On 22.4.2014 1:53, Minchan Kim wrote:
> >On Mon, Apr 21, 2014 at 11:43:24PM +0200, Vlastimil Babka wrote:
> >>On 21.4.2014 21:41, Andrew Morton wrote:
> >>>On Thu, 17 Apr 2014 09:07:45 +0900 Minchan Kim <minchan@kernel.org> wrote:
> >>>
> >>>>Hi Vlastimil,
> >>>>
> >>>>Below just nitpicks.
> >>>It seems you were ignored ;)
> >>Oops, I managed to miss your e-mail, sorry.
> >>
> >>>>>  {
> >>>>>  	struct page *page;
> >>>>>-	unsigned long high_pfn, low_pfn, pfn, z_end_pfn;
> >>>>>+	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
> >>>>Could you add comment for each variable?
> >>>>
> >>>>unsigned long pfn; /* scanning cursor */
> >>>>unsigned long low_pfn; /* lowest pfn free scanner is able to scan */
> >>>>unsigned long next_free_pfn; /* start pfn for scaning at next truen */
> >>>>unsigned long z_end_pfn; /* zone's end pfn */
> >>>>
> >>>>
> >>>>>@@ -688,11 +688,10 @@ static void isolate_freepages(struct zone *zone,
> >>>>>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
> >>>>>  	/*
> >>>>>-	 * Take care that if the migration scanner is at the end of the zone
> >>>>>-	 * that the free scanner does not accidentally move to the next zone
> >>>>>-	 * in the next isolation cycle.
> >>>>>+	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
> >>>>>+	 * none, the pfn < low_pfn check will kick in.
> >>>>        "none" what? I'd like to clear more.
> >>If there are no updates to next_free_pfn within the for cycle. Which
> >>matches Andrew's formulation below.
> >>
> >>>I did this:
> >>Thanks!
> >>
> >>>--- a/mm/compaction.c~mm-compaction-cleanup-isolate_freepages-fix
> >>>+++ a/mm/compaction.c
> >>>@@ -662,7 +662,10 @@ static void isolate_freepages(struct zon
> >>>  				struct compact_control *cc)
> >>>  {
> >>>  	struct page *page;
> >>>-	unsigned long pfn, low_pfn, next_free_pfn, z_end_pfn;
> >>>+	unsigned long pfn;	     /* scanning cursor */
> >>>+	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
> >>>+	unsigned long next_free_pfn; /* start pfn for scaning at next round */
> >>>+	unsigned long z_end_pfn;     /* zone's end pfn */
> >>Yes that works.
> >>
> >>>  	int nr_freepages = cc->nr_freepages;
> >>>  	struct list_head *freelist = &cc->freepages;
> >>>@@ -679,8 +682,8 @@ static void isolate_freepages(struct zon
> >>>  	low_pfn = ALIGN(cc->migrate_pfn + 1, pageblock_nr_pages);
> >>>  	/*
> >>>-	 * Seed the value for max(next_free_pfn, pfn) updates. If there are
> >>>-	 * none, the pfn < low_pfn check will kick in.
> >>>+	 * Seed the value for max(next_free_pfn, pfn) updates. If no pages are
> >>>+	 * isolated, the pfn < low_pfn check will kick in.
> >>OK.
> >>
> >>>  	 */
> >>>  	next_free_pfn = 0;
> >>>>>@@ -766,9 +765,9 @@ static void isolate_freepages(struct zone *zone,
> >>>>>  	 * so that compact_finished() may detect this
> >>>>>  	 */
> >>>>>  	if (pfn < low_pfn)
> >>>>>-		cc->free_pfn = max(pfn, zone->zone_start_pfn);
> >>>>>-	else
> >>>>>-		cc->free_pfn = high_pfn;
> >>>>>+		next_free_pfn = max(pfn, zone->zone_start_pfn);
> >>>>Why we need max operation?
> >>>>IOW, what's the problem if we do (next_free_pfn = pfn)?
> >>>An answer to this would be useful, thanks.
> >>The idea (originally, not new here) is that the free scanner wants
> >>to remember the highest-pfn
> >>block where it managed to isolate some pages. If the following page
> >>migration fails, these isolated
> >>pages might be put back and would be skipped in further compaction
> >>attempt if we used just
> >>"next_free_pfn = pfn", until the scanners get reset.
> >>
> >>The question of course is if such situations are frequent and makes
> >>any difference to compaction
> >>outcome. And the downsides are potentially useless rescans and code
> >>complexity. Maybe Mel
> >>remembers how important this is? It should probably be profiled
> >>before changes are made.
> >I didn't mean it. What I mean is code snippet you introduced in 7ed695e069c3c.
> >At that time, I didn't Cced so I missed that code so let's ask this time.
> >In that patch, you added this.
> >
> >if (pfn < low_pfn)
> >   cc->free_pfn = max(pfn, zone->zone_start_pfn);
> >else
> >   cc->free_pfn = high_pfn;
> 
> Oh, right, this max(), not the one in the for loop. Sorry, I should
> have read more closely.
> But still maybe it's a good opportunity to kill the other max() as
> well. I'll try some testing.
> 
> Anyway, this is what I answered to Mel when he asked the same thing
> when I sent
> that 7ed695069c3c patch:
> 
> If a zone starts in a middle of a pageblock and migrate scanner isolates
> enough pages early to stay within that pageblock, low_pfn will be at the
> end of that pageblock and after the for cycle in this function ends, pfn
> might be at the beginning of that pageblock. It might not be an actual
> problem (this compaction will finish at this point, and if someone else
> is racing, he will probably check the boundaries himself), but I played
> it safe.
> 
> 
> >So the purpose of max(pfn, zone->zone_start_pfn) is to be detected by
> >compact_finished to stop compaction. And your [1/2] patch in this patchset
> >always makes free page scanner start on pageblock boundary so when the
> >loop in isolate_freepages is finished and pfn is lower low_pfn, the pfn
> >would be lower than migration scanner so compact_finished will always detect
> >it so I think you could just do
> >
> >if (pfn < low_pfn)
> >   next_free_pfn = pfn;
> >
> >cc->free_pfn = next_free_pfn;
> 
> That could work. I was probably wrong about danger of racing in the
> reply to Mel,
> because free_pfn is stored in cc (private), not zone (shared).
> 
> >
> >Or, if you want to clear *reset*,
> >if (pfn < lown_pfn)
> >   next_free_pfn = zone->zone_start_pfn;
> >
> >cc->free_pfn = next_free_pfn;
> 
> That would work as well but is less straightforward I think. Might
> be misleading if
> someone added tracepoints to track the free scanner progress with
> pfn's (which
> might happen soon...)

My preference is to add following with pair of compact_finished

static inline void finish_compact(struct compact_control *cc)
{
  cc->free_pfn = cc->migrate_pfn;
}

But I don't care.
If you didn't send this patch as clean up, I would never interrupt
on the way but you said it's cleanup patch and the one made me spend a
few minutes to understand the code so it's not a clean up patch. ;-).
So, IMO, it's worth to tidy it up.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
