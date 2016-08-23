Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 582796B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:56:38 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w136so59596654oie.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 21:56:38 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id e82si20136441itc.46.2016.08.22.21.56.36
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 21:56:37 -0700 (PDT)
Date: Tue, 23 Aug 2016 14:02:52 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: OOM killer changes
Message-ID: <20160823050252.GD17039@js1304-P5Q-DELUXE>
References: <6a22f206-e0e7-67c9-c067-73a55b6fbb41@Quantum.com>
 <a61f01eb-7077-07dd-665a-5125a1f8ef37@suse.cz>
 <0325d79b-186b-7d61-2759-686f8afff0e9@Quantum.com>
 <20160817093323.GB20703@dhcp22.suse.cz>
 <8008b7de-9728-a93c-e3d7-30d4ebeba65a@Quantum.com>
 <0606328a-1b14-0bc9-51cb-36621e3e8758@suse.cz>
 <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
 <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
 <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
 <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Aug 19, 2016 at 08:27:34AM +0200, Vlastimil Babka wrote:
> On 08/19/2016 04:42 AM, Ralf-Peter Rohbeck wrote:
> > On 18.08.2016 13:12, Vlastimil Babka wrote:
> >> On 18.8.2016 22:01, Ralf-Peter Rohbeck wrote:
> >>> On 17.08.2016 23:57, Vlastimil Babka wrote:
> >>>> Vlastimil
> >>> Yes, that change was in my test with linux-next-20160817. Here's the diff:
> >>>
> >>> diff --git a/mm/compaction.c b/mm/compaction.c
> >>> index f94ae67..60a9ca2 100644
> >>> --- a/mm/compaction.c
> >>> +++ b/mm/compaction.c
> >>> @@ -1083,8 +1083,10 @@ static void isolate_freepages(struct
> >>> compact_control *cc)
> >>>                           continue;
> >>>
> >>>                   /* Check the block is suitable for migration */
> >>> +/*
> >>>                   if (!suitable_migration_target(page))
> >>>                           continue;
> >>> +*/
> >> OK, could you please also try if uncommenting the above still works without OOM?
> >> Or just plain linux-next-20160817, I guess we don't need the printk's to test
> >> this difference.
> >>
> >> Thanks a lot!
> >> Vlastimil
> >>
> > With the two lines back in I had OOMs again. See the attached logs.
> 
> Thanks for the confirmation.
> 
> We however shouldn't disable the heuristic completely, so here's a compromise
> patch hooking into the new compaction priorities. Can you please test on top of
> linux-next?
> 
> -----8<-----
> >From 0927cc2a4c6a3247111168eace9012c23d06f9db Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 18 Aug 2016 16:01:14 +0200
> Subject: [PATCH] mm, compaction: make full priority ignore pageblock
>  suitability
> 
> Ralf-Peter Rohbeck has reported premature OOMs for order-2 allocations (stack)
> due to OOM rework in 4.7. In his scenario (parallel kernel build and dd writing
> to two drives) many pageblocks get marked as Unmovable and compaction free
> scanner struggles to isolate free pages. Joonsoo Kim pointed out that the free
> scanner skips pageblocks that are not movable to prevent filling them and
> forcing non-movable allocations to fallback to other pageblocks. Such heuristic
> makes sense to help prevent long-term fragmentation, but premature OOMs are
> relatively more urgent problem. As a compromise, this patch disables the
> heuristic only for the ultimate compaction priority.
> 
> Reported-by: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
> Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  mm/compaction.c | 11 ++++++++---
>  mm/internal.h   |  1 +
>  2 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 0bba270f97ad..884b1baa58df 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -997,8 +997,12 @@ isolate_migratepages_range(struct compact_control *cc, unsigned long start_pfn,
>  #ifdef CONFIG_COMPACTION
>  
>  /* Returns true if the page is within a block suitable for migration to */
> -static bool suitable_migration_target(struct page *page)
> +static bool suitable_migration_target(struct compact_control *cc,
> +							struct page *page)
>  {
> +	if (cc->ignore_block_suitable)
> +		return true;
> +
>  	/* If the page is a large free page, then disallow migration */
>  	if (PageBuddy(page)) {
>  		/*
> @@ -1083,7 +1087,7 @@ static void isolate_freepages(struct compact_control *cc)
>  			continue;
>  
>  		/* Check the block is suitable for migration */
> -		if (!suitable_migration_target(page))
> +		if (!suitable_migration_target(cc, page))
>  			continue;
>  
>  		/* If isolation recently failed, do not retry */
> @@ -1656,7 +1660,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
>  		.classzone_idx = classzone_idx,
>  		.direct_compaction = true,
>  		.whole_zone = (prio == COMPACT_PRIO_SYNC_FULL),
> -		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL)
> +		.ignore_skip_hint = (prio == COMPACT_PRIO_SYNC_FULL),
> +		.ignore_block_suitable = (prio == COMPACT_PRIO_SYNC_FULL)

A year ago, I tested to allow unmovable/reclaimable pageblock for
freescanner in very limited situation and found that it cause long-term
fragmentation. I think that this solution is less tight than mine so
I guess it will cause long-term fragmentation. I agree that allocation
success is even more important but it's better not to cause long-term
fragmentation as much as possible. So, my suggestion is...

How about introducing one more priority (last priority) to allow scanning
unmovable/reclaimable pageblock? If we don't reach that priority,
long-term fragmentation can be avoided.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
