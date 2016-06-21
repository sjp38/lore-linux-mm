Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8C176B0253
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 13:00:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l184so17036405lfl.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:00:56 -0700 (PDT)
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com. [209.85.215.51])
        by mx.google.com with ESMTPS id 96si30421692lft.272.2016.06.21.10.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 10:00:55 -0700 (PDT)
Received: by mail-lf0-f51.google.com with SMTP id f6so32828207lfg.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:00:55 -0700 (PDT)
Date: Tue, 21 Jun 2016 19:00:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Message-ID: <20160621170052.GA24410@dhcp22.suse.cz>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard>
 <20160616080355.GB6836@dhcp22.suse.cz>
 <20160616112606.GH6836@dhcp22.suse.cz>
 <20160617182235.GC10485@cmpxchg.org>
 <5c0ae2d1-28fc-7ef5-b9ae-a4c8bfa833c7@suse.cz>
 <20160617213931.GA13688@cmpxchg.org>
 <20160620080856.GB4340@dhcp22.suse.cz>
 <20160621042249.GA18870@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160621042249.GA18870@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 21-06-16 00:22:49, Johannes Weiner wrote:
[...]
> As for changing the default - remember that we currently warn about
> allocation failures as if they were bugs, unless they are explicitely
> allocated with the __GFP_NOWARN flag. We can assume that the current
> __GFP_NOWARN sites are 1) commonly failing but 2) prefer to fall back
> rather than incurring latency (otherwise they would have added the
> __GFP_REPEAT flag). These sites would be a good list of candidates to
> annotate with __GFP_NORETRY.

This sounds like a good idea at first sight but a brief git grep shows
that many of them are just trying to silence the warning from non
sleeping allocations which are quite likely to fail. This wouldn't
be hard to filter out so we can ignore them.

Then there are things like 8be04b9374e5 ("treewide: Add __GFP_NOWARN
to k.alloc calls with v.alloc fallbacks") where the flag is added to
many places with vmalloc fallbacks. Do we want to weaken them in
favor of the vmalloc in general (note that it is not clear from the size
whether they are costly or !costly)?

I have looked at some random others and they are adding the flag without
any explanation so it is not really clear what was the motivation.

To me it seems like the flag is used quite randomly. I suspect there are
many places which do not have that flag just because nobody bothered to
report the allocation failure which is hard to reproduce.

> If we made __GFP_REPEAT then the default,
> the sites that would then try harder are the same sites that would now
> emit page allocation failure warnings. These are rare, and the only
> times I have seen them is under enough load that latency is shot to
> hell anyway. So I'm not really convinced by the regression argument.

You do not need to be under a heavy load to fail those allocations. It
is sufficient to have the memory fragmented which might be just a matter
of time. I am worried that we have hard to examine number of allocation
requests that might change the overall system behavior because they
might trigger more reclaim/swap and the source of the behavior change
wouldn't be quite obvious. On the other hand we already have some places
already annotated to require a more effort which is the reason I would
find it better to follow up with that.

High order allocations can be really expensive and the current behavior
with the allocation warning has an advantage that we can see the failure
mode and get a bug report with the exact trace (hopefully) without too
much of a background interference. Then the subsystem familiar person
can judge whether that particular allocation is worth more effort or
different fallback.

I am not saying that changing the default behavior for costly
allocations is a no go. I just feel it is too risky and it would be
better to use "override the default because I know what I am doing"
flag. The __GFP_RETRY_HARD might be a terrible name and a better name
would cause less confusion (__GFP_RETRY_MAYFAIL?).

> But that would *actually* clean up the flags, not make them even more
> confusing:
> 
> Allocations that can't ever handle failure would use __GFP_NOFAIL.
> 
> Callers like XFS would use __GFP_MAYFAIL specifically to disable the
> implicit __GFP_NOFAIL of !costly allocations.
>
> Callers that would prefer falling back over killing and looping would
> use __GFP_NORETRY.
> 
> Wouldn't that cover all usecases and be much more intuitive, both in
> the default behavior as well as in the names of the flags?

How do we describe kcompacd vs. page fault THP allocations? We do not
want to cause a lot of reclaim for those but we can wait for compaction
for the first while we would prefer not to for the later.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
