Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64A116B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 07:12:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m45-v6so1055213edc.2
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 04:12:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d26-v6si513457ejc.189.2018.10.09.04.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 04:12:11 -0700 (PDT)
Date: Tue, 9 Oct 2018 13:12:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: Shuffle initial free memory
Message-ID: <20181009111209.GL8528@dhcp22.suse.cz>
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153861932401.2863953.11364943845583542894.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074838.GE22173@dhcp22.suse.cz>
 <CAPcyv4jO_K8g3XRzuYOQPeGT--aPtucwZsqkywxOFO4Zny5Xrg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jO_K8g3XRzuYOQPeGT--aPtucwZsqkywxOFO4Zny5Xrg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu 04-10-18 09:51:37, Dan Williams wrote:
> On Thu, Oct 4, 2018 at 12:48 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 03-10-18 19:15:24, Dan Williams wrote:
> > > Some data exfiltration and return-oriented-programming attacks rely on
> > > the ability to infer the location of sensitive data objects. The kernel
> > > page allocator, especially early in system boot, has predictable
> > > first-in-first out behavior for physical pages. Pages are freed in
> > > physical address order when first onlined.
> > >
> > > Introduce shuffle_free_memory(), and its helper shuffle_zone(), to
> > > perform a Fisher-Yates shuffle of the page allocator 'free_area' lists
> > > when they are initially populated with free memory at boot and at
> > > hotplug time.
> > >
> > > Quoting Kees:
> > >     "While we already have a base-address randomization
> > >      (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
> > >      memory layouts would certainly be using the predictability of
> > >      allocation ordering (i.e. for attacks where the base address isn't
> > >      important: only the relative positions between allocated memory).
> > >      This is common in lots of heap-style attacks. They try to gain
> > >      control over ordering by spraying allocations, etc.
> > >
> > >      I'd really like to see this because it gives us something similar
> > >      to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."
> > >
> > > Another motivation for this change is performance in the presence of a
> > > memory-side cache. In the future, memory-side-cache technology will be
> > > available on generally available server platforms. The proposed
> > > randomization approach has been measured to improve the cache conflict
> > > rate by a factor of 2.5X on a well-known Java benchmark. It avoids
> > > performance peaks and valleys to provide more predictable performance.
> > >
> > > While SLAB_FREELIST_RANDOM reduces the predictability of some local slab
> > > caches it leaves vast bulk of memory to be predictably in order
> > > allocated. That ordering can be detected by a memory side-cache.
> > >
> > > The shuffling is done in terms of 'shuffle_page_order' sized free pages
> > > where the default shuffle_page_order is MAX_ORDER-1 i.e. 10, 4MB this
> > > trades off randomization granularity for time spent shuffling.
> > > MAX_ORDER-1 was chosen to be minimally invasive to the page allocator
> > > while still showing memory-side cache behavior improvements.
> > >
> > > The performance impact of the shuffling appears to be in the noise
> > > compared to other memory initialization work. Also the bulk of the work
> > > is done in the background as a part of deferred_init_memmap().
> >
> > This is the biggest portion of the series and I am wondering why do we
> > need it at all. Why it isn't sufficient to rely on the patch 3 here?
> 
> In fact we started with only patch3 and it had no measurable impact on
> the cache conflict rate.
> 
> > Pages freed from the bootmem allocator go via the same path so they
> > might be shuffled at that time. Or is there any problem with that?
> > Not enough entropy at the time when this is called or the final result
> > is not randomized enough (some numbers would be helpful).
> 
> So the reason front-back randomization is not enough is due to the
> in-order initial freeing of pages. At the start of that process
> putting page1 in front or behind page0 still keeps them close
> together, page2 is still near page1 and has a high chance of being
> adjacent. As more pages are added ordering diversity improves, but
> there is still high page locality for the low address pages and this
> leads to no significant impact to the cache conflict rate. Patch3 is
> enough to keep the entropy sustained over time, but it's not enough
> initially.

That should be in the changelog IMHO.

-- 
Michal Hocko
SUSE Labs
