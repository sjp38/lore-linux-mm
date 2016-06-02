Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CC9D6B0263
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 08:19:41 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w16so23384471lfd.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:19:40 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id k190si985413wme.85.2016.06.02.05.19.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 05:19:39 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 476461C15B1
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 13:19:38 +0100 (IST)
Date: Thu, 2 Jun 2016 13:19:36 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: BUG: scheduling while atomic: cron/668/0x10c9a0c0
Message-ID: <20160602121936.GV2527@techsingularity.net>
References: <CAMuHMdV00vJJxoA7XABw+mFF+2QUd1MuQbPKKgkmGnK_NySZpg@mail.gmail.com>
 <20160530155644.GP2527@techsingularity.net>
 <574E05B8.3060009@suse.cz>
 <20160601091921.GT2527@techsingularity.net>
 <574EB274.4030408@suse.cz>
 <20160602103936.GU2527@techsingularity.net>
 <0eb1f112-65d4-f2e5-911e-697b21324b9f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <0eb1f112-65d4-f2e5-911e-697b21324b9f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>

On Thu, Jun 02, 2016 at 02:04:42PM +0200, Vlastimil Babka wrote:
> On 06/02/2016 12:39 PM, Mel Gorman wrote:
> >On Wed, Jun 01, 2016 at 12:01:24PM +0200, Vlastimil Babka wrote:
> >>>Why?
> >>>
> >>>The comment is fine but I do not see why the recalculation would occur.
> >>>
> >>>In the original code, the preferred_zoneref for statistics is calculated
> >>>based on either the supplied nodemask or cpuset_current_mems_allowed during
> >>>the initial attempt. It then relies on the cpuset checks in the slowpath
> >>>to encorce mems_allowed but the preferred zone doesn't change.
> >>>
> >>>With your proposed change, it's possible that the
> >>>preferred_zoneref recalculation points to a zoneref disallowed by
> >>>cpuset_current_mems_sllowed. While it'll be skipped during allocation,
> >>>the statistics will still be against a zone that is potentially outside
> >>>what is allowed.
> >>
> >>Hmm that's true and I was ready to agree. But then I noticed  that
> >>gfp_to_alloc_flags() can mask out ALLOC_CPUSET for GFP_ATOMIC. So it's
> >>like a lighter version of the ALLOC_NO_WATERMARKS situation. In that
> >>case it's wrong if we leave ac->preferred_zoneref at a position that has
> >>skipped some zones due to mempolicies?
> >>
> >
> >So both options are wrong then. How about this?
> 
> I wonder if the original patch we're fixing was worth all this trouble (and
> more
> for my compaction priority series :), but yeah this should work.
> 

I considered that option when the bug report first came in. It was a 2%
hit to the page allocator microbenchmark to revert it. More than I expected
but enough to care. If this causes another problem, I'll revert it as
there will be other options later.

> >---8<---
> >mm, page_alloc: Recalculate the preferred zoneref if the context can ignore memory policies
> >
> >The optimistic fast path may use cpuset_current_mems_allowed instead of
> >of a NULL nodemask supplied by the caller for cpuset allocations. The
> >preferred zone is calculated on this basis for statistic purposes and
> >as a starting point in the zonelist iterator.
> >
> >However, if the context can ignore memory policies due to being atomic or
> >being able to ignore watermarks then the starting point in the zonelist
> >iterator is no longer correct. This patch resets the zonelist iterator in
> >the allocator slowpath if the context can ignore memory policies. This will
> >alter the zone used for statistics but only after it is known that it makes
> >sense for that context. Resetting it before entering the slowpath would
> >potentially allow an ALLOC_CPUSET allocation to be accounted for against
> >the wrong zone. Note that while nodemask is not explicitly set to the
> >original nodemask, it would only have been overwritten if cpuset_enabled()
> >and it was reset before the slowpath was entered.
> >
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
