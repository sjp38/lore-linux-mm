Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 001216B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 04:08:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id c82so22985570wme.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:08:59 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id mb8si27811101wjb.202.2016.06.20.01.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 01:08:58 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id r201so49597724wme.1
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 01:08:58 -0700 (PDT)
Date: Mon, 20 Jun 2016 10:08:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] xfs: map KM_MAYFAIL to __GFP_RETRY_HARD
Message-ID: <20160620080856.GB4340@dhcp22.suse.cz>
References: <1465212736-14637-1-git-send-email-mhocko@kernel.org>
 <1465212736-14637-3-git-send-email-mhocko@kernel.org>
 <20160616002302.GK12670@dastard>
 <20160616080355.GB6836@dhcp22.suse.cz>
 <20160616112606.GH6836@dhcp22.suse.cz>
 <20160617182235.GC10485@cmpxchg.org>
 <5c0ae2d1-28fc-7ef5-b9ae-a4c8bfa833c7@suse.cz>
 <20160617213931.GA13688@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160617213931.GA13688@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 17-06-16 17:39:31, Johannes Weiner wrote:
> On Fri, Jun 17, 2016 at 10:30:06PM +0200, Vlastimil Babka wrote:
> > On 17.6.2016 20:22, Johannes Weiner wrote:
[...]
> > > - it allows !costly orders to fail
> > > 
> > > While 1. is obvious from the name, 2. is not. Even if we don't want
> > > full-on fine-grained naming for every reclaim methodology and retry
> > > behavior, those two things just shouldn't be tied together.
> > 
> > Well, if allocation is not allowed to fail, it's like trying "indefinitely hard"
> > already. Telling it it should "try hard" then doesn't make any sense without
> > also being able to fail.
> 
> I can see that argument, but it's really anything but obvious at the
> callsite. Dave's response to Michal's patch was a good demonstration.
> And I don't think adding comments fixes an unintuitive interface.

Yeah, I am aware of that. And it is unfortunate but a side effect of our
!costly vs. costly difference in the default behavior. What I wanted
to achieve was to have overrides for the default behavior (whatever it
is). We already have two such flags and having something semantically in
the middle sounds like a consistent way to me.

> > > I don't see us failing !costly order per default anytime soon, and
> > > they are common, so adding a __GFP_MAYFAIL to explicitely override
> > > that behavior seems like a good idea to me. That would make the XFS
> > > callsite here perfectly obvious.
> > > 
> > > And you can still combine it with __GFP_REPEAT.
> > 
> > But that would mean the following meaningful combinations for non-costly orders
> > (assuming e.g. GFP_KERNEL which allows reclaim/compaction in the first place).
> 
> I would ignore order here. Part of what makes this interface
> unintuitive is when we expect different flags to be passed for
> different orders, especially because the orders are often
> variable. Michal's __GFP_RETRY_HARD is an improvement in the sense
> that it ignores the order and tries to do the right thing regardless
> of it. The interface should really be about the intent at the
> callsite, not about implementation details of the allocator.
>
> But adding TRY_HARD to express "this can fail" isn't intuitive.

I am all for a better name but everything else I could come up with was
just more confusing. Take __GFP_MAYFAIL as an example. How it would be
any less confusing? Aren't all the requests which do not have
__GFP_NOFAIL automatically MAYFAIL? RETRY_HARD was an attempt to tell
you can retry as hard as you find reasonable but fail eventually which
should fit quite nicely between NORETRY and NOFAIL.

> > __GFP_NORETRY - that one is well understood hopefully, and implicitly mayfail
> 
> Yeah. Never OOM, never retry etc. The callsite can fall back, and
> prefers that over OOM kills and disruptive allocation latencies.
> 
> > __GFP_MAYFAIL - ???
> 
> May OOM for certain orders and retry a few times, but still fail. The
> callsite can fall back, but it wouldn't come for free. E.g. it might
> have to abort an explicitely requested user operation.
> 
> This is the default for costly orders, so it has an effect only on
> non-costly orders. But that's where I would separate interface from
> implementation: you'd use it e.g. in callsites where you have variable
> orders but always the same fallback. XFS does that extensively.
> 
> > __GFP_MAYFAIL | __GFP_REPEAT - ???
> > 
> > Which one of the last two tries harder? How specifically? Will they differ by
> > (not) allowing OOM? Won't that be just extra confusing?
> 
> Adding __GFP_REPEAT would always be additive. This combination would
> mean: try the hardest not to fail, but don't lock up in cases when the
> order happens to be !costly.
> 
> Again, I'm not too thrilled about that flag as it's so damn vague. But
> that's more about how we communicate latency/success expectations. My
> concern is exclusively about its implication of MAYFAIL.

Our gfp flags space is quite full and additing a new flag while we keep
one with a vague meaning doesn't sound very well to me. So I really
think we should just ditch __GFP_REPEAT. Whether __GFP_MAYFAIL is a
better name for the new flag I dunno. It feels confusing to me but if
that is a general agreement I don't have a big problem with that.

> > > For a generic allocation site like this, __GFP_MAYFAIL | __GFP_REPEAT
> > > does the right thing for all orders, and it's self-explanatory: try
> > > hard, allow falling back.
> > > 
> > > Whether we want a __GFP_REPEAT or __GFP_TRY_HARD at all is a different
> > > topic. In the long term, it might be better to provide best-effort per
> > > default and simply annotate MAYFAIL/NORETRY callsites that want to
> > > give up earlier. Because as I mentioned at LSFMM, it's much easier to
> > > identify callsites that have a convenient fallback than callsites that
> > > need to "try harder." Everybody thinks their allocations are oh so
> > > important. The former is much more specific and uses obvious criteria.
> > 
> > For higher-order allocations, best-effort might also mean significant system
> > disruption, not just latency of the allocation itself. One example is hugeltbfs
> > allocations (echo X > .../nr_hugepages) where the admin is willing to pay this
> > cost. But to do that by default and rely on everyone else passing NORETRY
> > wouldn't go far. So I think the TRY_HARD kind of flag makes sense.
> 
> I think whether the best-effort behavior should be opt-in or opt-out,
> or how fine-grained the latency/success control over the allocator
> should be is a different topic. I'd prefer defaulting to reliability
> and annotating low-latency requirements, but I can see TRY_HARD work
> too. It just shouldn't imply MAY_FAIL.

It is always hard to change the default behavior without breaking
anything. Up to now we had opt-in and as you can see there are not that
many users who really wanted to have higher reliability. I guess this is
because they just do not care and didn't see too many failures. The
opt-out has also a disadvantage that we would need to provide a flag
to tell to try less hard and all we have is NORETRY and that is way too
easy. So to me it sounds like the opt-in fits better with the current
usage.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
