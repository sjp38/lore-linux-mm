Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF2A6B0255
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 07:51:04 -0500 (EST)
Received: by wmec201 with SMTP id c201so131881734wme.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 04:51:03 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id ln5si4189956wjb.201.2015.11.10.04.51.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 04:51:02 -0800 (PST)
Received: by wmdw130 with SMTP id w130so69463044wmd.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 04:51:02 -0800 (PST)
Date: Tue, 10 Nov 2015 13:51:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
Message-ID: <20151110125101.GA8440@dhcp22.suse.cz>
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
 <5641185F.9020104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5641185F.9020104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 09-11-15 23:04:15, Vlastimil Babka wrote:
> On 5.11.2015 17:15, mhocko@kernel.org wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > __GFP_REPEAT has a rather weak semantic but since it has been introduced
> > around 2.6.12 it has been ignored for low order allocations. Yet we have
> > the full kernel tree with its usage for apparently order-0 allocations.
> > This is really confusing because __GFP_REPEAT is explicitly documented
> > to allow allocation failures which is a weaker semantic than the current
> > order-0 has (basically nofail).
> > 
> > Let's simply reap out __GFP_REPEAT from those places. This would allow
> > to identify place which really need allocator to retry harder and
> > formulate a more specific semantic for what the flag is supposed to do
> > actually.
> 
> So at first I thought "yeah that's obvious", but then after some more thinking,
> I'm not so sure anymore.

Thanks for looking into this! The primary purpose of this patch series was
to start the discussion. I've only now realized I forgot to add RFC, sorry
about that.

> I think we should formulate the semantic first, then do any changes. Also, let's
> look at the flag description (which comes from pre-git):

It's rather hard to formulate one without examining the current users...

>  * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
>  * _might_ fail.  This depends upon the particular VM implementation.
> 
> So we say it's implementation detail, and IIRC the same is said about which
> orders are considered costly and which not, and the associated rules. So, can we
> blame callers that happen to use __GFP_REPEAT essentially as a no-op in the
> current implementation? And is it a problem that they do that?

Well, I think that many users simply copy&pasted the code along with the
flag. I have failed to find any justification for adding this flag for
basically all the cases I've checked.

My understanding is that the overal motivation for the flag was to
fortify the allocation requests rather than weaken them. But if we were
literal then __GFP_REPEAT is in fact weaker than GFP_KERNEL for lower
orders. It is true that the later one is so only implicitly - and as an
implementation detail.

Anyway I think that getting rid of those users which couldn't ever see a
difference is a good start.

> So I think we should answer the following questions:
> 
> * What is the semantic of __GFP_REPEAT?
>   - My suggestion would be something like "I would really like this allocation
> to succeed. I still have some fallback but it's so suboptimal I'd rather wait
> for this allocation."

This is very close to the current wording.

> And then we could e.g. change some heuristics to take that
> into account - e.g. direct compaction could ignore the deferred state and
> pageblock skip bits, to make sure it's as thorough as possible. Right now, that
> sort of happens, but not quite - given enough reclaim/compact attempts, the
> compact attempts might break out of deferred state. But pages_reclaimed might
> reach 1 << order before compaction "undefers", and then it breaks out of the
> loop. Is any such heuristic change possible for reclaim as well?

I am not familiar with the compaction code enough to comment on this but
the reclaim part is already having something in should_continue_reclaim.
For low order allocations this doesn't make too much of a difference
because the reclaim is retried anyway from the page allocator path.

> As part of this question we should also keep in mind/rethink __GFP_NORETRY as
> that's supposed to be the opposite flag to __GFP_REPEAT.
> 
> * Can it ever happen that __GFP_REPEAT could make some difference for order-0?

Yes, if you want to try hard but eventually allow to fail the request.
Why just not use __GFP_NORETRY for that purpose? Well, that context is
much weaker. We give up after the first round of the reclaim and we do
not trigger the OOM killer in that context. __GFP_REPEAT should be about
finit retrying.

I am pretty sure there are users who would like to have this semantic.
None of the current low-order users seem to fall into this cathegory
AFAICS though.

>   - Certainly not wrt compaction, how about reclaim?

We can decide to allow the allocation to fail if reclaim progress was
not sufficient _and_ the OOM killer haven't helped rather than start
looping again.

>   - If it couldn't possibly affect order-0, then yeah proceed with Patch 1.

I've split up obviously order-0 from the rest because I think order-0
are really easy to understand. Patch 1 is a bit harder to grasp but I
think it should be safe as well. I am open to discussion of course.

> * Is PAGE_ALLOC_COSTLY_ORDER considered an implementation detail?

Yes, more or less, but I doubt we can change it much considering all the
legacy code which might rely on it. I think we should simply remove the
dependency on the order and act for all orders same semantically.

>   - I would think so, and if yes, then we probably shouldn't remove
> __GFP_NORETRY for order-1+ allocations that happen to be not costly in the
> current implementation?

I guess you meant __GFP_REPEAT here but even then we should really think
about the reason why the flag has been added. Is it to fortify the
request? If yes it never worked that way so it is hard to justify it
that way.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
