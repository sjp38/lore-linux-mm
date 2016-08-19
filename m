Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46E6D6B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 03:34:03 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so12251556wme.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 00:34:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g79si2896397wme.57.2016.08.19.00.34.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Aug 2016 00:34:01 -0700 (PDT)
Date: Fri, 19 Aug 2016 09:33:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160819073359.GA32619@dhcp22.suse.cz>
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
Cc: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri 19-08-16 08:27:34, Vlastimil Babka wrote:
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

Thanks to both of you! I do agree that we should drop all these
heuristics when we struggle and there is an OOM risk. I have just a
small nit here. I would prefer
s@COMPACT_PRIO_SYNC_FULL@MIN_COMPACT_PRIORITY@ when disabling them
because this would be easier to follow and it would be easier for future
changes. Which brings me to another thing I was suggesting earlier. I
believe we should go to this MIN_COMPACT_PRIORITY only for !costly
requests because costly orders shouldn't get all those exceptions and
risk long term fragmentation issues. We do not have that many costly
requests (except for hugetlb) so it doesn't matter all that much right
now but long term we want to differentiate those I believe.

That being said, let's wait for the feedback on this patch + linux-next.
If it works out I will send a stable 4.7 patch which drops compaction
feedback from should_compact_retry (turn it to the !COMPACTION version)
so that 4.7 users do not suffer from the premature OOM and will ask
Andrew to sneak the compaction patches to 4.8 as they fix a real issue
and the risk is not really high.

Acked-by: Michal Hocko <mhocko@suse.com>

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
>  	};
>  	INIT_LIST_HEAD(&cc.freepages);
>  	INIT_LIST_HEAD(&cc.migratepages);
> diff --git a/mm/internal.h b/mm/internal.h
> index 5214bf8e3171..537ac9951f5f 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -178,6 +178,7 @@ struct compact_control {
>  	unsigned long last_migrated_pfn;/* Not yet flushed page being freed */
>  	enum migrate_mode mode;		/* Async or sync migration mode */
>  	bool ignore_skip_hint;		/* Scan blocks even if marked skip */
> +	bool ignore_block_suitable;	/* Scan blocks considered unsuitable */
>  	bool direct_compaction;		/* False from kcompactd or /proc/... */
>  	bool whole_zone;		/* Whole zone should/has been scanned */
>  	int order;			/* order a direct compactor needs */
> -- 
> 2.9.2
> 
> 
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
