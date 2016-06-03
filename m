Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AAFDF6B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 03:57:23 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h144so146515345ita.1
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 00:57:23 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id t134si5432273ita.33.2016.06.03.00.57.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 00:57:22 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id z123so5643796itg.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 00:57:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160602114341.e3b974640fc3f8cbcb54898b@linux-foundation.org>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net> <574E05B8.3060009@suse.cz>
 <20160601091921.GT2527@techsingularity.net> <574EB274.4030408@suse.cz>
 <20160602103936.GU2527@techsingularity.net> <0eb1f112-65d4-f2e5-911e-697b21324b9f@suse.cz>
 <20160602121936.GV2527@techsingularity.net> <20160602114341.e3b974640fc3f8cbcb54898b@linux-foundation.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 3 Jun 2016 09:57:22 +0200
Message-ID: <CAMuHMdX07bUE+3QTbFmbxrjkXPBzFLoLQbupL=WAbLXTuN+6Ww@mail.gmail.com>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@vger.kernel.org>

Hi Andrew, Mel,

On Thu, Jun 2, 2016 at 8:43 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 2 Jun 2016 13:19:36 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
>> > >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>> >
>> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> >
>>
>> Thanks.
>
> I queued this.  A tested-by:Geert would be nice?
>
>
> From: Mel Gorman <mgorman@techsingularity.net>
> Subject: mm, page_alloc: recalculate the preferred zoneref if the context can ignore memory policies
>
> The optimistic fast path may use cpuset_current_mems_allowed instead of of
> a NULL nodemask supplied by the caller for cpuset allocations.  The
> preferred zone is calculated on this basis for statistic purposes and as a
> starting point in the zonelist iterator.
>
> However, if the context can ignore memory policies due to being atomic or
> being able to ignore watermarks then the starting point in the zonelist
> iterator is no longer correct.  This patch resets the zonelist iterator in
> the allocator slowpath if the context can ignore memory policies.  This
> will alter the zone used for statistics but only after it is known that it
> makes sense for that context.  Resetting it before entering the slowpath
> would potentially allow an ALLOC_CPUSET allocation to be accounted for
> against the wrong zone.  Note that while nodemask is not explicitly set to
> the original nodemask, it would only have been overwritten if
> cpuset_enabled() and it was reset before the slowpath was entered.
>
> Link: http://lkml.kernel.org/r/20160602103936.GU2527@techsingularity.net
> Fixes: c33d6c06f60f710 ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")

My understanding was that this was an an additional patch, not fixing
the problem in-se?

Indeed, after applying this patch (without the other one that added
"z = ac->preferred_zoneref;" to the reset_fair block of
get_page_from_freelist()) I still get crashes...

Now testing with both applied...

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/page_alloc.c |   23 ++++++++++++++++-------
>  1 file changed, 16 insertions(+), 7 deletions(-)
>
> diff -puN mm/page_alloc.c~mm-page_alloc-recalculate-the-preferred-zoneref-if-the-context-can-ignore-memory-policies mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-page_alloc-recalculate-the-preferred-zoneref-if-the-context-can-ignore-memory-policies
> +++ a/mm/page_alloc.c
> @@ -3604,6 +3604,17 @@ retry:
>          */
>         alloc_flags = gfp_to_alloc_flags(gfp_mask);
>
> +       /*
> +        * Reset the zonelist iterators if memory policies can be ignored.
> +        * These allocations are high priority and system rather than user
> +        * orientated.
> +        */
> +       if ((alloc_flags & ALLOC_NO_WATERMARKS) || !(alloc_flags & ALLOC_CPUSET)) {
> +               ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
> +               ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
> +                                       ac->high_zoneidx, ac->nodemask);
> +       }
> +
>         /* This is the last chance, in general, before the goto nopage. */
>         page = get_page_from_freelist(gfp_mask, order,
>                                 alloc_flags & ~ALLOC_NO_WATERMARKS, ac);
> @@ -3612,12 +3623,6 @@ retry:
>
>         /* Allocate without watermarks if the context allows */
>         if (alloc_flags & ALLOC_NO_WATERMARKS) {
> -               /*
> -                * Ignore mempolicies if ALLOC_NO_WATERMARKS on the grounds
> -                * the allocation is high priority and these type of
> -                * allocations are system rather than user orientated
> -                */
> -               ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
>                 page = get_page_from_freelist(gfp_mask, order,
>                                                 ALLOC_NO_WATERMARKS, ac);
>                 if (page)
> @@ -3816,7 +3821,11 @@ retry_cpuset:
>         /* Dirty zone balancing only done in the fast path */
>         ac.spread_dirty_pages = (gfp_mask & __GFP_WRITE);
>
> -       /* The preferred zone is used for statistics later */
> +       /*
> +        * The preferred zone is used for statistics but crucially it is
> +        * also used as the starting point for the zonelist iterator. It
> +        * may get reset for allocations that ignore memory policies.
> +        */
>         ac.preferred_zoneref = first_zones_zonelist(ac.zonelist,
>                                         ac.high_zoneidx, ac.nodemask);
>         if (!ac.preferred_zoneref) {
> _
>



-- 
Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
