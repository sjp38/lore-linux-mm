Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC6D5280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:06:28 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u134so34960135itb.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:06:28 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l4si14603402itd.39.2016.09.28.23.06.04
        for <linux-mm@kvack.org>;
        Wed, 28 Sep 2016 23:06:04 -0700 (PDT)
Date: Thu, 29 Sep 2016 15:14:33 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: Regression in mobility grouping?
Message-ID: <20160929061433.GF29250@js1304-P5Q-DELUXE>
References: <20160928014148.GA21007@cmpxchg.org>
 <8c3b7dd8-ef6f-6666-2f60-8168d41202cf@suse.cz>
 <20160928153925.GA24966@cmpxchg.org>
 <20160929022540.GA30883@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929022540.GA30883@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 28, 2016 at 10:25:40PM -0400, Johannes Weiner wrote:
> On Wed, Sep 28, 2016 at 11:39:25AM -0400, Johannes Weiner wrote:
> > On Wed, Sep 28, 2016 at 11:00:15AM +0200, Vlastimil Babka wrote:
> > > I guess testing revert of 9c0415e could give us some idea. Commit
> > > 3a1086f shouldn't result in pageblock marking differences and as I said
> > > above, 99592d5 should be just restoring to what 3.10 did.
> > 
> > I can give this a shot, but note that this commit makes only unmovable
> > stealing more aggressive. We see reclaimable blocks up as well.
> 
> Quick update, I reverted back to stealing eagerly only on behalf of
> MIGRATE_RECLAIMABLE allocations in a 4.6 kernel:

Hello, Johannes.

I think that it would be better to check 3.10 with above patches.
Fragmentation depends on not only policy itself but also
allocation/free pattern. There might be a large probability that
allocation/free pattern is changed in this large kernel version
difference.

> 
> static bool can_steal_fallback(unsigned int order, int start_mt)
> {
>         if (order >= pageblock_order / 2 ||
>             start_mt == MIGRATE_RECLAIMABLE ||
>             page_group_by_mobility_disabled)
>                 return true;
> 
>         return false;
> }
> 
> Yet, I still see UNMOVABLE growing to the thousands within minutes,
> whereas 3.10 didn't reach those numbers even after days of uptime.
> 
> Okay, that wasn't it. However, there is something fishy going on,
> because I see extfrag traces like these:
> 
> <idle>-0     [006] d.s.  1110.217281: mm_page_alloc_extfrag: page=ffffea0064142000 pfn=26235008 alloc_order=3 fallback_order=3 pageblock_order=9 alloc_migratetype=0 fallback_migratetype=2 fragmenting=1 change_ownership=1
> 
> enum {
>         MIGRATE_UNMOVABLE,
>         MIGRATE_MOVABLE,
>         MIGRATE_RECLAIMABLE,
>         MIGRATE_PCPTYPES,       /* the number of types on the pcp lists */
>         MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
> 	...
> };
> 
> This is an UNMOVABLE order-3 allocation falling back to RECLAIMABLE.
> According to can_steal_fallback(), this allocation shouldn't steal the
> pageblock, yet change_ownership=1 indicates the block is UNMOVABLE.
> 
> Who converted it? I wonder if there is a bug in ownership management,
> and there was an UNMOVABLE block on the RECLAIMABLE freelist from the
> beginning. AFAICS we never validate list/mt consistency anywhere.

According to my code review, it would be possible. When stealing
happens, we moved those buddy pages to current requested migratetype
buddy list. If the other migratetype allocation request comes and
stealing from the buddy list of previous requested migratetype
happens, change_ownership will show '1' even if there is no ownership
changing.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
