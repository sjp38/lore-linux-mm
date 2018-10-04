Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9912A6B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 12:51:49 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id v188-v6so6666378oie.3
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:51:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u126-v6sor2141544oib.13.2018.10.04.09.51.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 09:51:48 -0700 (PDT)
MIME-Version: 1.0
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153861932401.2863953.11364943845583542894.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074838.GE22173@dhcp22.suse.cz>
In-Reply-To: <20181004074838.GE22173@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 4 Oct 2018 09:51:37 -0700
Message-ID: <CAPcyv4jO_K8g3XRzuYOQPeGT--aPtucwZsqkywxOFO4Zny5Xrg@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm: Shuffle initial free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Oct 4, 2018 at 12:48 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 03-10-18 19:15:24, Dan Williams wrote:
> > Some data exfiltration and return-oriented-programming attacks rely on
> > the ability to infer the location of sensitive data objects. The kernel
> > page allocator, especially early in system boot, has predictable
> > first-in-first out behavior for physical pages. Pages are freed in
> > physical address order when first onlined.
> >
> > Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> > perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> > when they are initially populated with free memory at boot and at
> > hotplug time.
> >
> > Quoting Kees:
> >     "While we already have a base-address randomization
> >      (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
> >      memory layouts would certainly be using the predictability of
> >      allocation ordering (i.e. for attacks where the base address isn't
> >      important: only the relative positions between allocated memory).
> >      This is common in lots of heap-style attacks. They try to gain
> >      control over ordering by spraying allocations, etc.
> >
> >      I'd really like to see this because it gives us something similar
> >      to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."
> >
> > Another motivation for this change is performance in the presence of a
> > memory-side cache. In the future, memory-side-cache technology will be
> > available on generally available server platforms. The proposed
> > randomization approach has been measured to improve the cache conflict
> > rate by a factor of 2.5X on a well-known Java benchmark. It avoids
> > performance peaks and valleys to provide more predictable performance.
> >
> > While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> > caches it leaves vast bulk of memory to be predictably in order
> > allocated. That ordering can be detected by a memory side-cache.
> >
> > The shuffling is done in terms of 'shuffle_page_order' sized free pages
> > where the default shuffle_page_order is MAX_ORDER-1 i.e. 10, 4MB this
> > trades off randomization granularity for time spent shuffling.
> > MAX_ORDER-1 was chosen to be minimally invasive to the page allocator
> > while still showing memory-side cache behavior improvements.
> >
> > The performance impact of the shuffling appears to be in the noise
> > compared to other memory initialization work. Also the bulk of the work
> > is done in the background as a part of deferred_init_memmap().
>
> This is the biggest portion of the series and I am wondering why do we
> need it at all. Why it isn't sufficient to rely on the patch 3 here?

In fact we started with only patch3 and it had no measurable impact on
the cache conflict rate.

> Pages freed from the bootmem allocator go via the same path so they
> might be shuffled at that time. Or is there any problem with that?
> Not enough entropy at the time when this is called or the final result
> is not randomized enough (some numbers would be helpful).

So the reason front-back randomization is not enough is due to the
in-order initial freeing of pages. At the start of that process
putting page1 in front or behind page0 still keeps them close
together, page2 is still near page1 and has a high chance of being
adjacent. As more pages are added ordering diversity improves, but
there is still high page locality for the low address pages and this
leads to no significant impact to the cache conflict rate. Patch3 is
enough to keep the entropy sustained over time, but it's not enough
initially.
