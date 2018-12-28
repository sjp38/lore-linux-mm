Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D57CC8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 14:44:16 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so26136809eda.12
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 11:44:16 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h9si254344edr.174.2018.12.28.11.44.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 11:44:15 -0800 (PST)
Date: Fri, 28 Dec 2018 20:44:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/1] mm: add a warning about high order allocations
Message-ID: <20181228194412.GW16738@dhcp22.suse.cz>
References: <20181225153927.2873-1-khorenko@virtuozzo.com>
 <20181226083505.GF16738@dhcp22.suse.cz>
 <e7660465-2e1e-b641-5730-448dee45b220@virtuozzo.com>
 <20181227164608.GM16738@dhcp22.suse.cz>
 <82aa3975-160d-5c83-5c9f-c88b9a45a1e8@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <82aa3975-160d-5c83-5c9f-c88b9a45a1e8@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khorenko <khorenko@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>

On Fri 28-12-18 14:23:29, Konstantin Khorenko wrote:
> On 12/27/2018 07:46 PM, Michal Hocko wrote:
> > On Thu 27-12-18 15:18:54, Konstantin Khorenko wrote:
> >> Hi Michal,
> >>
> >> thank you very much for your questions, please see my notes below.
> >>
> >> On 12/26/2018 11:35 AM, Michal Hocko wrote:
> >>> On Tue 25-12-18 18:39:26, Konstantin Khorenko wrote:
> >>>> Q: Why do we need to bother at all?
> >>>> A: If a node is highly loaded and its memory is significantly fragmented
> >>>> (unfortunately almost any node with serious load has highly fragmented memory)
> >>>> then any high order memory allocation can trigger massive memory shrink and
> >>>> result in quite a big allocation latency. And the node becomes less responsive
> >>>> and users don't like it.
> >>>> The ultimate solution here is to get rid of large allocations, but we need an
> >>>> instrument to detect them.
> >>>
> >>> Can you point to an example of the problem you are referring here? At
> >>> least for costly orders we do bail out early and try to not cause
> >>> massive reclaim. So what is the order that you are concerned about?
> >>
> >> Well, this is the most difficult question to answer.
> >> Unfortunately i don't have a reproducer for that, usually we get into situation
> >> when someone experiences significant node slowdown, nodes most often have a lot of RAM,
> >> we check what is going on there and see the node is busy with reclaim.
> >> And almost every time the reason was - fragmented memory and high order allocations.
> >> Mostly of 2nd and 3rd (which is still considered not costly) order.
> >>
> >> Recent related issues we faced were about FUSE dev pipe:
> >> d6d931adce11 ("fuse: use kvmalloc to allocate array of pipe_buffer structs.")
> >>
> >> and about bnx driver + mtu 9000 which for each packet required page of 2nd order
> >> (and it even failed sometimes, though it was not the root cause):
> >>      kswapd0: page allocation failure: order:2, mode:0x4020
> >>      Call Trace:
> >>          dump_stack+0x19/0x1b
> >>          warn_alloc_failed+0x110/0x180
> >>          __alloc_pages_nodemask+0x7bf/0xc60
> >>          alloc_pages_current+0x98/0x110
> >>          kmalloc_order+0x18/0x40
> >>          kmalloc_order_trace+0x26/0xa0
> >>          __kmalloc+0x279/0x290
> >>          bnx2x_frag_alloc.isra.61+0x2a/0x40 [bnx2x]
> >>          bnx2x_rx_int+0x227/0x17c0 [bnx2x]
> >>          bnx2x_poll+0x1dd/0x260 [bnx2x]
> >>          net_rx_action+0x179/0x390
> >>          __do_softirq+0x10f/0x2aa
> >>          call_softirq+0x1c/0x30
> >>          do_softirq+0x65/0xa0
> >>          irq_exit+0x105/0x110
> >>          do_IRQ+0x56/0xe0
> >>          common_interrupt+0x6d/0x6d
> >>
> >> And as both places were called very often - the system latency was high.
> >>
> >> This warning can be also used to catch allocation of 4th order and higher which may
> >> easily fail. Those places which are ready to get allocation errors and have
> >> fallbacks are marked with __GFP_NOWARN.
> >
> > This is not true in general, though.
> 
> Right now - yep, this is not true. Sorry, i was not clear enough here.
> i meant after we catch all high order allocations, we review them and either
> switch to kvmalloc() or mark with NOWARN if we are ready to handle allocation errors
> in that particular place. So this is an ideal situation when we reviewed all the things.

I do not think that making all high order allocations NOWARN is
reasonable or even correct. There allocations which really require
physically contiguous memory range of a larger size. And we migh want to
warn about those and they might be perfectly fine.

[...]
> > I believe that
> > for your particular use case it is much better to simply enable reclaim
> > and page allocator tracepoints which will give you not only the source
> > of the allocation but also a much better picture
> 
> Tracepoints are much better for issues investigation, right. And we do so.
> 
> And warnings are intended not for investigation but for prevention of possible future issues.
> If we spot a big allocation, we can review it in advance, before we face any problem,
> and in most cases just switch it to use kvmalloc() in 90% cases and we never ever have
> a problem with unexpected reclaim due to this allocation. Ever.
> With any reclaim algorithm - the compaction just won't be triggered.

I do not think this is realistic, to be honest. As mentioned before
there are simply valid high order allocations.

[...]

> > But the warning alone will not give us useful information I am afraid.
> > It will only give us, there are warnings but not whether those are
> > actually a problem or not.
> 
> Yes. And even more - a lot of high order allocations which cannot be
> switched to kvmalloc() are in drivers - for DMA zones - so they are very
> rare and most probably won't ever cause a problem.
> 
> But some of them can potentially cause a problem some day. And warning
> does not provide info how to distinguish "bad" and "good" ones.
> But if we switch both "bad" and "good" big allocations to kvmalloc(),
> that won't hurt, right?

Ohh, this is not that simple. Vmalloc doesn't scale. We might work on
changing underlying allocator but there are fundamental perfomance
roadblocks that cannot be removed. You are manipulating page tables
which require TLB flushes for example. E.g. networking code would rather
see higher order allocations and use the vmalloc only as a fallback.
That is the reason why we are supporting __GFP_RETRY_MAYFAIL for
kvmalloc btw.

I do not even want to mention 32b and the restricted vmalloc space
because 32b is on decline.

So really, I think you are right there are many places which could and
should be changed to be less demanding on high order allocations. But I
think that your warning behind a config is not a right direction to go
there. Each performance issue should be debugged and the underlying
culprit found. In many cases it might be just an ineffective or outright
buggy implementation of the page allocator itself. We want to fix those.
Warning about "something's broken" will help us much less than a set of
tracepoints with a better picture.

Thanks!
-- 
Michal Hocko
SUSE Labs
