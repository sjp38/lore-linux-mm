Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD666B007E
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 04:41:48 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id rs7so34045575lbb.2
        for <linux-mm@kvack.org>; Fri, 03 Jun 2016 01:41:48 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id fm6si6204115wjb.89.2016.06.03.01.41.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jun 2016 01:41:44 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id B424A9914F
	for <linux-mm@kvack.org>; Fri,  3 Jun 2016 08:41:43 +0000 (UTC)
Date: Fri, 3 Jun 2016 09:41:42 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
Message-ID: <20160603084142.GY2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net>
 <574E05B8.3060009@suse.cz>
 <20160601091921.GT2527@techsingularity.net>
 <574EB274.4030408@suse.cz>
 <20160602103936.GU2527@techsingularity.net>
 <0eb1f112-65d4-f2e5-911e-697b21324b9f@suse.cz>
 <20160602121936.GV2527@techsingularity.net>
 <20160602114341.e3b974640fc3f8cbcb54898b@linux-foundation.org>
 <CAMuHMdX07bUE+3QTbFmbxrjkXPBzFLoLQbupL=WAbLXTuN+6Ww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAMuHMdX07bUE+3QTbFmbxrjkXPBzFLoLQbupL=WAbLXTuN+6Ww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@vger.kernel.org>

On Fri, Jun 03, 2016 at 09:57:22AM +0200, Geert Uytterhoeven wrote:
> Hi Andrew, Mel,
> 
> On Thu, Jun 2, 2016 at 8:43 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Thu, 2 Jun 2016 13:19:36 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> >> > >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> >> >
> >> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >> >
> >>
> >> Thanks.
> >
> > I queued this.  A tested-by:Geert would be nice?
> >
> >
> > From: Mel Gorman <mgorman@techsingularity.net>
> > Subject: mm, page_alloc: recalculate the preferred zoneref if the context can ignore memory policies
> >
> > The optimistic fast path may use cpuset_current_mems_allowed instead of of
> > a NULL nodemask supplied by the caller for cpuset allocations.  The
> > preferred zone is calculated on this basis for statistic purposes and as a
> > starting point in the zonelist iterator.
> >
> > However, if the context can ignore memory policies due to being atomic or
> > being able to ignore watermarks then the starting point in the zonelist
> > iterator is no longer correct.  This patch resets the zonelist iterator in
> > the allocator slowpath if the context can ignore memory policies.  This
> > will alter the zone used for statistics but only after it is known that it
> > makes sense for that context.  Resetting it before entering the slowpath
> > would potentially allow an ALLOC_CPUSET allocation to be accounted for
> > against the wrong zone.  Note that while nodemask is not explicitly set to
> > the original nodemask, it would only have been overwritten if
> > cpuset_enabled() and it was reset before the slowpath was entered.
> >
> > Link: http://lkml.kernel.org/r/20160602103936.GU2527@techsingularity.net
> > Fixes: c33d6c06f60f710 ("mm, page_alloc: avoid looking up the first zone in a zonelist twice")
> 
> My understanding was that this was an an additional patch, not fixing
> the problem in-se?
> 

It doesn't fix the problem you had, it is a follow-on patch that
potentially affects.

> Indeed, after applying this patch (without the other one that added
> "z = ac->preferred_zoneref;" to the reset_fair block of
> get_page_from_freelist()) I still get crashes...
> 

The patch you have is the only one required for the crash. This patch
handles a corner case with atomic allocations that can ignore memory
policies.

> Now testing with both applied...

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
