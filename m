Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E1F398E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 11:46:12 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p15so20996144pfk.7
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 08:46:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i63si33563459pgc.116.2018.12.27.08.46.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Dec 2018 08:46:11 -0800 (PST)
Date: Thu, 27 Dec 2018 17:46:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/1] mm: add a warning about high order allocations
Message-ID: <20181227164608.GM16738@dhcp22.suse.cz>
References: <20181225153927.2873-1-khorenko@virtuozzo.com>
 <20181226083505.GF16738@dhcp22.suse.cz>
 <e7660465-2e1e-b641-5730-448dee45b220@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e7660465-2e1e-b641-5730-448dee45b220@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khorenko <khorenko@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>

On Thu 27-12-18 15:18:54, Konstantin Khorenko wrote:
> Hi Michal,
> 
> thank you very much for your questions, please see my notes below.
> 
> On 12/26/2018 11:35 AM, Michal Hocko wrote:
> > On Tue 25-12-18 18:39:26, Konstantin Khorenko wrote:
> >> Q: Why do we need to bother at all?
> >> A: If a node is highly loaded and its memory is significantly fragmented
> >> (unfortunately almost any node with serious load has highly fragmented memory)
> >> then any high order memory allocation can trigger massive memory shrink and
> >> result in quite a big allocation latency. And the node becomes less responsive
> >> and users don't like it.
> >> The ultimate solution here is to get rid of large allocations, but we need an
> >> instrument to detect them.
> >
> > Can you point to an example of the problem you are referring here? At
> > least for costly orders we do bail out early and try to not cause
> > massive reclaim. So what is the order that you are concerned about?
> 
> Well, this is the most difficult question to answer.
> Unfortunately i don't have a reproducer for that, usually we get into situation
> when someone experiences significant node slowdown, nodes most often have a lot of RAM,
> we check what is going on there and see the node is busy with reclaim.
> And almost every time the reason was - fragmented memory and high order allocations.
> Mostly of 2nd and 3rd (which is still considered not costly) order.
> 
> Recent related issues we faced were about FUSE dev pipe:
> d6d931adce11 ("fuse: use kvmalloc to allocate array of pipe_buffer structs.")
> 
> and about bnx driver + mtu 9000 which for each packet required page of 2nd order
> (and it even failed sometimes, though it was not the root cause):
>      kswapd0: page allocation failure: order:2, mode:0x4020
>      Call Trace:
>          dump_stack+0x19/0x1b
>          warn_alloc_failed+0x110/0x180
>          __alloc_pages_nodemask+0x7bf/0xc60
>          alloc_pages_current+0x98/0x110
>          kmalloc_order+0x18/0x40
>          kmalloc_order_trace+0x26/0xa0
>          __kmalloc+0x279/0x290
>          bnx2x_frag_alloc.isra.61+0x2a/0x40 [bnx2x]
>          bnx2x_rx_int+0x227/0x17c0 [bnx2x]
>          bnx2x_poll+0x1dd/0x260 [bnx2x]
>          net_rx_action+0x179/0x390
>          __do_softirq+0x10f/0x2aa
>          call_softirq+0x1c/0x30
>          do_softirq+0x65/0xa0
>          irq_exit+0x105/0x110
>          do_IRQ+0x56/0xe0
>          common_interrupt+0x6d/0x6d
> 
> And as both places were called very often - the system latency was high.
>
> This warning can be also used to catch allocation of 4th order and higher which may
> easily fail. Those places which are ready to get allocation errors and have
> fallbacks are marked with __GFP_NOWARN.

This is not true in general, though.

[...]
> But after it's done and there are no (almost) unmarked high order allocations -
> why not? This will reveal new cases of high order allocations soon.

There will always be legitimate high order allocations. I believe that
for your particular use case it is much better to simply enable reclaim
and page allocator tracepoints which will give you not only the source
of the allocation but also a much better picture

> i think people who run systems with "kernel.panic_on_warn" enabled do care
> about reporting issues.

You surely do not want to put the system down just because of the high
order allocation though, right?

> >> Q: Why compile time config option?
> >> A: In order not to decrease the performance even a bit in case someone does not
> >> want to hunt for large allocations.
> >> In an ideal life i'd prefer this check/warning is enabled by default and may be
> >> even without a config option so it works on every node. Once we find and rework
> >> or mark all large allocations that would be good by default. Until that though
> >> it will be noisy.
> >
> > So who is going to enable this option?
> 
> At the beginning - people who want to debug kernel and verify their fallbacks on
> memory allocations failures in the code or just speed up their code on nodes
> with fragmented memory - for 2nd and 3rd orders.
> 
> mm performance issues are tough, you know, and this is just another way to
> gain more performance. It won't avoid the necessity of digging mm for sure,
> but might decrease the pressure level.

But the warning alone will not give us useful information I am afraid.
It will only give us, there are warnings but not whether those are
actually a problem or not. So I really believe that using existing
tracepoints or add some that will fill missing gaps will be much more
better long term. And we do not have to add another config and touch the
code as a bonus.
-- 
Michal Hocko
SUSE Labs
