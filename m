Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 525266B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 00:17:35 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m18-v6so2974298lfj.1
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 21:17:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c7sor2563309ljj.44.2018.04.22.21.17.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 21:17:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
References: <1524243513-29118-1-git-send-email-chuhu@redhat.com>
 <20180420175023.3c4okuayrcul2bom@armageddon.cambridge.arm.com>
 <20180422125141.GF17484@dhcp22.suse.cz> <CACT4Y+YWUgyzCBadg+Oe8wDkFCaBzmcKDgu3rKjQxim7NXNLpg@mail.gmail.com>
From: Chunyu Hu <chuhu.ncepu@gmail.com>
Date: Mon, 23 Apr 2018 12:17:32 +0800
Message-ID: <CABATaM6eWtssvuj3UW9LHLK3HWo8P9g0z9VzFnuqKPKO5KMJ3A@mail.gmail.com>
Subject: Re: [RFC] mm: kmemleak: replace __GFP_NOFAIL to GFP_NOWAIT in gfp_kmemleak_mask
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Chunyu Hu <chuhu@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 22 April 2018 at 23:00, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Sun, Apr 22, 2018 at 2:51 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> On Fri 20-04-18 18:50:24, Catalin Marinas wrote:
>>> On Sat, Apr 21, 2018 at 12:58:33AM +0800, Chunyu Hu wrote:
>>> > __GFP_NORETRY and  __GFP_NOFAIL are combined in gfp_kmemleak_mask now.
>>> > But it's a wrong combination. As __GFP_NOFAIL is blockable, but
>>> > __GFP_NORETY is not blockable, make it self-contradiction.
>>> >
>>> > __GFP_NOFAIL means 'The VM implementation _must_ retry infinitely'. But
>>> > it's not the real intention, as kmemleak allow alloc failure happen in
>>> > memory pressure, in that case kmemleak just disables itself.
>>>
>>> Good point. The __GFP_NOFAIL flag was added by commit d9570ee3bd1d
>>> ("kmemleak: allow to coexist with fault injection") to keep kmemleak
>>> usable under fault injection.
>>>
>>> > commit 9a67f6488eca ("mm: consolidate GFP_NOFAIL checks in the allocator
>>> > slowpath") documented that what user wants here should use GFP_NOWAIT, and
>>> > the WARN in __alloc_pages_slowpath caught this weird usage.
>>> >
>>> >  <snip>
>>> >  WARNING: CPU: 3 PID: 64 at mm/page_alloc.c:4261 __alloc_pages_slowpath+0x1cc3/0x2780
>>> [...]
>>> > Replace the __GFP_NOFAIL with GFP_NOWAIT in gfp_kmemleak_mask, __GFP_NORETRY
>>> > and GFP_NOWAIT are in the gfp_kmemleak_mask. So kmemleak object allocaion
>>> > is no blockable and no reclaim, making kmemleak less disruptive to user
>>> > processes in pressure.
>>>
>>> It doesn't solve the fault injection problem for kmemleak (unless we
>>> change __should_failslab() somehow, not sure yet). An option would be to
>>> replace __GFP_NORETRY with __GFP_NOFAIL in kmemleak when fault injection
>>> is enabled.
>>
>> Cannot we simply have a disable_fault_injection knob around the
>> allocation rather than playing this dirty tricks with gfp flags which do
>> not make any sense?

To this way, looks like we need to change the attrs. but what we have stored in
attr is also gfp flags, even we define a new member, ignore_flags, we still
need a new flag, or did I miss something?  But looks like a new flag is simple.

For slab, it supports cache_filter, so it's possible to add a
filer_out slab flag,
and skip it.  But for page, it's just has gfp flag and size info for
filter, no other info.

#ifdef CONFIG_FAIL_PAGE_ALLOC

static struct {
    struct fault_attr attr;

    bool ignore_gfp_highmem;
    bool ignore_gfp_reclaim;
    u32 min_order;
} fail_page_alloc = {
    .attr = FAULT_ATTR_INITIALIZER,
    .ignore_gfp_reclaim = true,
    .ignore_gfp_highmem = true,
    .min_order = 1,
};


static struct {
    struct fault_attr attr;
    bool ignore_gfp_reclaim;
    bool cache_filter;
} failslab = {
    .attr = FAULT_ATTR_INITIALIZER,
    .ignore_gfp_reclaim = true,
    .cache_filter = false,
};

>>
>>> BTW, does the combination of NOWAIT and NORETRY make kmemleak
>>> allocations more likely to fail?
>>
>> NOWAIT + NORETRY simply doesn't make much sesne. It is equivalent to
>> NOWAIT.
>
> Specifying a flag that says "don't do fault injection for this
> allocation" looks like a reasonable solution. Fewer lines of code and
> no need to switch on interrupts. __GFP_NOFAIL seems to mean more than
> that, so perhaps we need a separate flag that affects only fault
> injection and should be used only in debugging code (no-op without
> fault injection anyway).


Got the  two places for skipping fault injection, both they check the gfp flags
as part of the work.  If we have the new no fault inject flag, and
define the wrapper
as below, then it will look like.
#define _GFP_NOFAULTINJECT (__GFP_NOFAIL|___GFP_NOFAULTINJECT)

bool __should_failslab(struct kmem_cache *s, gfp_t gfpflags)
{
    /* No fault-injection for bootstrap cache */
    if (unlikely(s == kmem_cache))
        return false;

    if (gfpflags &  _GFP_NOFAULTINJECTL)
        return false;

    if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
        return false;

    if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
        return false;

    return should_fail(&failslab.attr, s->object_size);
}


static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
{
    if (order < fail_page_alloc.min_order)
        return false;
    if (gfp_mask &  _GFP_NOFAULTINJECT)
        return false;
    if (fail_page_alloc.ignore_gfp_highmem && (gfp_mask & __GFP_HIGHMEM))
        return false;
    if (fail_page_alloc.ignore_gfp_reclaim &&
            (gfp_mask & __GFP_DIRECT_RECLAIM))
        return false;

    return should_fail(&fail_page_alloc.attr, 1 << order);
}

the gfp flags defined in linux/gfp.h. we have now 24 flags already, and we have
an precedent ___GFP_NOLOCKDEP for skipping lockdep.

/* Plain integer GFP bitmasks. Do not use this directly. */
#define ___GFP_DMA      0x01u
#define ___GFP_HIGHMEM      0x02u
#define ___GFP_DMA32        0x04u
#define ___GFP_MOVABLE      0x08u
#define ___GFP_RECLAIMABLE  0x10u
#define ___GFP_HIGH     0x20u
#define ___GFP_IO       0x40u
#define ___GFP_FS       0x80u
#define ___GFP_NOWARN       0x200u
#define ___GFP_RETRY_MAYFAIL    0x400u
#define ___GFP_NOFAIL       0x800u
#define ___GFP_NORETRY      0x1000u
#define ___GFP_MEMALLOC     0x2000u
#define ___GFP_COMP     0x4000u
#define ___GFP_ZERO     0x8000u
#define ___GFP_NOMEMALLOC   0x10000u
#define ___GFP_HARDWALL     0x20000u
#define ___GFP_THISNODE     0x40000u
#define ___GFP_ATOMIC       0x80000u
#define ___GFP_ACCOUNT      0x100000u
#define ___GFP_DIRECT_RECLAIM   0x400000u
#define ___GFP_WRITE        0x800000u
#define ___GFP_KSWAPD_RECLAIM   0x1000000u
#ifdef CONFIG_LOCKDEP
#define ___GFP_NOLOCKDEP    0x2000000u
#else
#define ___GFP_NOLOCKDEP    0
#endif

So if there is a new flag, it would be the 25th bits.

#ifdef CONFIG_KMEMLEAK
#define ___GFP_NOFAULTINJECT    0x4000000u
#else
#define ___GFP_NOFAULT_INJECT    0
#endif
