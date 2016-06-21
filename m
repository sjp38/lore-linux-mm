Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4366B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 00:23:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so2731076lfa.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 21:23:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 140si1219352wmt.100.2016.06.20.21.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 21:23:00 -0700 (PDT)
Date: Tue, 21 Jun 2016 00:22:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Message-ID: <20160621042249.GA18870@cmpxchg.org>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard>
 <20160616080355.GB6836@dhcp22.suse.cz>
 <20160616112606.GH6836@dhcp22.suse.cz>
 <20160617182235.GC10485@cmpxchg.org>
 <5c0ae2d1-28fc-7ef5-b9ae-a4c8bfa833c7@suse.cz>
 <20160617213931.GA13688@cmpxchg.org>
 <20160620080856.GB4340@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160620080856.GB4340@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jun 20, 2016 at 10:08:56AM +0200, Michal Hocko wrote:
> On Fri 17-06-16 17:39:31, Johannes Weiner wrote:
> > On Fri, Jun 17, 2016 at 10:30:06PM +0200, Vlastimil Babka wrote:
> > > On 17.6.2016 20:22, Johannes Weiner wrote:
> [...]
> > > > - it allows !costly orders to fail
> > > > 
> > > > While 1. is obvious from the name, 2. is not. Even if we don't want
> > > > full-on fine-grained naming for every reclaim methodology and retry
> > > > behavior, those two things just shouldn't be tied together.
> > > 
> > > Well, if allocation is not allowed to fail, it's like trying "indefinitely hard"
> > > already. Telling it it should "try hard" then doesn't make any sense without
> > > also being able to fail.
> > 
> > I can see that argument, but it's really anything but obvious at the
> > callsite. Dave's response to Michal's patch was a good demonstration.
> > And I don't think adding comments fixes an unintuitive interface.
> 
> Yeah, I am aware of that. And it is unfortunate but a side effect of our
> !costly vs. costly difference in the default behavior. What I wanted
> to achieve was to have overrides for the default behavior (whatever it
> is). We already have two such flags and having something semantically in
> the middle sounds like a consistent way to me.

The "whatever it is" is the problem I'm having. It's one flag that
does two entirely orthogonal things, and it's quite reasonable for
somebody to want to change one behavior without the other.

"I can handle allocation failures, even when they are !costly"

has really nothing to do with

"I am ready to pay high a allocation latency to make costly
allocations succeed."

So while I understand that you want an effort-flag leveled somewhere
between NORETRY and NOFAIL, this looks more like a theoretical thing
than what existing callsites actually would want to use.

> > I think whether the best-effort behavior should be opt-in or opt-out,
> > or how fine-grained the latency/success control over the allocator
> > should be is a different topic. I'd prefer defaulting to reliability
> > and annotating low-latency requirements, but I can see TRY_HARD work
> > too. It just shouldn't imply MAY_FAIL.
> 
> It is always hard to change the default behavior without breaking
> anything. Up to now we had opt-in and as you can see there are not that
> many users who really wanted to have higher reliability. I guess this is
> because they just do not care and didn't see too many failures. The
> opt-out has also a disadvantage that we would need to provide a flag
> to tell to try less hard and all we have is NORETRY and that is way too
> easy. So to me it sounds like the opt-in fits better with the current
> usage.

For costly allocations, the presence of __GFP_NORETRY is exactly the
same as the absence of __GFP_REPEAT. So if we made __GFP_REPEAT the
default (and deleted the flag), the opt-outs would use __GFP_NORETRY
to restore their original behavior.

As for changing the default - remember that we currently warn about
allocation failures as if they were bugs, unless they are explicitely
allocated with the __GFP_NOWARN flag. We can assume that the current
__GFP_NOWARN sites are 1) commonly failing but 2) prefer to fall back
rather than incurring latency (otherwise they would have added the
__GFP_REPEAT flag). These sites would be a good list of candidates to
annotate with __GFP_NORETRY. If we made __GFP_REPEAT then the default,
the sites that would then try harder are the same sites that would now
emit page allocation failure warnings. These are rare, and the only
times I have seen them is under enough load that latency is shot to
hell anyway. So I'm not really convinced by the regression argument.

But that would *actually* clean up the flags, not make them even more
confusing:

Allocations that can't ever handle failure would use __GFP_NOFAIL.

Callers like XFS would use __GFP_MAYFAIL specifically to disable the
implicit __GFP_NOFAIL of !costly allocations.

Callers that would prefer falling back over killing and looping would
use __GFP_NORETRY.

Wouldn't that cover all usecases and be much more intuitive, both in
the default behavior as well as in the names of the flags?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
