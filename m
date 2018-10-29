Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 91A5C6B0392
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 13:01:31 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q26-v6so3942929pgk.19
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 10:01:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id j3-v6si20200952pld.231.2018.10.29.10.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 10:01:29 -0700 (PDT)
Message-ID: <18dfc5a0db11650ff31433311da32c95e19944d9.camel@linux.intel.com>
Subject: Re: [PATCH v5 4/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Mon, 29 Oct 2018 10:01:28 -0700
In-Reply-To: <20181029163528.GL32673@dhcp22.suse.cz>
References: <f97de51c-67dd-99b2-754e-0685cac06699@linux.intel.com>
	 <20181010172451.GK5873@dhcp22.suse.cz>
	 <98c35e19-13b9-0913-87d9-b3f1ab738b61@linux.intel.com>
	 <20181010185242.GP5873@dhcp22.suse.cz>
	 <20181011085509.GS5873@dhcp22.suse.cz>
	 <6f32f23c-c21c-9d42-7dda-a1d18613cd3c@linux.intel.com>
	 <20181017075257.GF18839@dhcp22.suse.cz>
	 <971729e6-bcfe-a386-361b-d662951e69a7@linux.intel.com>
	 <20181029141210.GJ32673@dhcp22.suse.cz>
	 <84f09883c16608ddd2ba88103f43ec6a1c649e97.camel@linux.intel.com>
	 <20181029163528.GL32673@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Pasha Tatashin <pavel.tatashin@microsoft.com>, Dave Hansen <dave.hansen@intel.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, rppt@linux.vnet.ibm.com, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, yi.z.zhang@linux.intel.com

On Mon, 2018-10-29 at 17:35 +0100, Michal Hocko wrote:
> On Mon 29-10-18 08:59:34, Alexander Duyck wrote:
> > On Mon, 2018-10-29 at 15:12 +0100, Michal Hocko wrote:
> > > On Wed 17-10-18 08:02:20, Alexander Duyck wrote:
> > > > On 10/17/2018 12:52 AM, Michal Hocko wrote:
> > > > > On Thu 11-10-18 10:38:39, Alexander Duyck wrote:
> > > > > > On 10/11/2018 1:55 AM, Michal Hocko wrote:
> > > > > > > On Wed 10-10-18 20:52:42, Michal Hocko wrote:
> > > > > > > [...]
> > > > > > > > My recollection was that we do clear the reserved bit in
> > > > > > > > move_pfn_range_to_zone and we indeed do in __init_single_page. But then
> > > > > > > > we set the bit back right afterwards. This seems to be the case since
> > > > > > > > d0dc12e86b319 which reorganized the code. I have to study this some more
> > > > > > > > obviously.
> > > > > > > 
> > > > > > > so my recollection was wrong and d0dc12e86b319 hasn't really changed
> > > > > > > much because __init_single_page wouldn't zero out the struct page for
> > > > > > > the hotplug contex. A comment in move_pfn_range_to_zone explains that we
> > > > > > > want the reserved bit because pfn walkers already do see the pfn range
> > > > > > > and the page is not fully associated with the zone until it is onlined.
> > > > > > > 
> > > > > > > I am thinking that we might be overzealous here. With the full state
> > > > > > > initialized we shouldn't actually care. pfn_to_online_page should return
> > > > > > > NULL regardless of the reserved bit and normal pfn walkers shouldn't
> > > > > > > touch pages they do not recognize and a plain page with ref. count 1
> > > > > > > doesn't tell much to anybody. So I _suspect_ that we can simply drop the
> > > > > > > reserved bit setting here.
> > > > > > 
> > > > > > So this has me a bit hesitant to want to just drop the bit entirely. If
> > > > > > nothing else I think I may wan to make that a patch onto itself so that if
> > > > > > we aren't going to set it we just drop it there. That way if it does cause
> > > > > > issues we can bisect it to that patch and pinpoint the cause.
> > > > > 
> > > > > Yes a patch on its own make sense for bisectability.
> > > > 
> > > > For now I think I am going to back off of this. There is a bunch of other
> > > > changes that need to happen in order for us to make this work. As far as I
> > > > can tell there are several places that are relying on this reserved bit.
> > > 
> > > Please be more specific. Unless I misremember, I have added this
> > > PageReserved just to be sure (f1dd2cd13c4bb) because pages where just
> > > half initialized back then. I am not aware anybody is depending on this.
> > > If there is somebody then be explicit about that. The last thing I want
> > > to see is to preserve a cargo cult and build a design around it.
> > 
> > It is mostly just a matter of going through and auditing all the
> > places that are using PageReserved to identify pages that they aren't
> > supposed to touch for whatever reason.
> > 
> > From what I can tell the issue appears to be the fact that the reserved
> > bit is used to identify if a region of memory is "online" or "offline".
> 
> No, this is wrong. pfn_to_online_page does that. PageReserved has
> nothing to do with online vs. offline status. It merely says that you
> shouldn't touch the page unless you own it. Sure we might have few
> places relying on it but nothing should really depend the reserved bit
> check from the MM hotplug POV.
> 
> > So for example the call "online_pages_range" doesn't invoke the
> > online_page_callback unless the first pfn in the range is marked as
> > reserved.
> 
> Yes and there is no fundamental reason to do that. We can easily check
> the online status without that.
> 
> > Another example Dan had pointed out was the saveable_page function in
> > kernel/power/snapshot.c.
> 
> Use pfn_to_online_page there.

Right. Which getting back to my original point, there is a bunch of
other changes that need to happen in order for us to make this work. I
am going to end up with yet another patch set to clean up all the spots
that are using PageReserved that shouldn't be before I can get to the
point of not setting that bit.

> > > > > > > Regarding the post initialization required by devm_memremap_pages and
> > > > > > > potentially others. Can we update the altmap which is already a way how
> > > > > > > to get alternative struct pages by a constructor which we could call
> > > > > > > from memmap_init_zone and do the post initialization? This would reduce
> > > > > > > the additional loop in the caller while it would still fit the overall
> > > > > > > design of the altmap and the core hotplug doesn't have to know anything
> > > > > > > about DAX or whatever needs a special treatment.
> > > > > > > 
> > > > > > > Does that make any sense?
> > > > > > 
> > > > > > I think the only thing that is currently using the altmap is the ZONE_DEVICE
> > > > > > memory init. Specifically I think it is only really used by the
> > > > > > devm_memremap_pages version of things, and then only under certain
> > > > > > circumstances. Also the HMM driver doesn't pass an altmap. What we would
> > > > > > really need is a non-ZONE_DEVICE users of the altmap to really justify
> > > > > > sticking with that as the preferred argument to pass.
> > > > > 
> > > > > I am not aware of any upstream HMM user so I am not sure what are the
> > > > > expectations there. But I thought that ZONE_DEVICE users use altmap. If
> > > > > that is not generally true then we certainly have to think about a
> > > > > better interface.
> > > > 
> > > > I'm just basing my statement on the use of the move_pfn_range_to_zone call.
> > > > The only caller that is actually passing the altmap is devm_memremap_pages
> > > > and if I understand things correctly that is only used when we want to stare
> > > > the vmmemmap on the same memory that we just hotplugged.
> > > 
> > > Yes, and that is what I've called as allocator callback earlier.
> > 
> > I am really not a fan of the callback approach. It just means we will
> > have to do everything multiple times in terms of initialization.
> 
> I do not follow. Could you elaborate?

So there end up being a few different issues with constructors. First
in my mind is that it means we have to initialize the region of memory
and cannot assume what the constructors are going to do for us. As a
result we will have to initialize the LRU pointers, and then overwrite
them with the pgmap and hmm_data. I am generally not a fan of that as
the next patch set I have gets rid of most of the redundancy we already
had in the writes where we were memsetting everything to 0, then
writing the values, and then taking care of the reserved bit and
pgmap/hmm_data fields. Dealing with the init serially like that is just
slow.

Another complication is retpoline making function pointers just more
expensive in general. I know in the networking area we have been
dealing with this for a while as even the DMA ops have been a pain
there.

> > > > That is why it made more sense to me to just create a ZONE_DEVICE specific
> > > > function for handling the page initialization because the one value I do
> > > > have to pass is the dev_pagemap in both HMM and memremap case, and that has
> > > > the altmap already embedded inside of it.
> > > 
> > > And I have argued that this is a wrong approach to the problem. If you
> > > need a very specific struct page initialization then create a init
> > > (constructor) callback.
> > 
> > The callback solution just ends up being more expensive because we lose
> > multiple layers of possible optimization. By putting everything into on
> > initization function we are able to let the compiler go through and
> > optimize things to the point where we are essentially just doing
> > something akin to one bit memcpy/memset where we are able to construct
> > one set of page values and write that to every single page we have to
> > initialize within a given page block.
> 
> You are already doing per-page initialization so I fail to see a larger
> unit to operate on.

I have a patch that makes it so that we can work at a pageblock level
since all of the variables with the exception of only the LRU and page
address fields can be precomputed. Doing that is one of the ways I was
able to reduce page init to 1/3 to 1/4 of the time it was taking
otherwise in the case of deferred page init.

> > My concern is that we are going to see a 2-4x regression if I were to
> > update the current patches I have to improve init performance in order
> > to achieve the purity of the page initilization functions that you are
> > looking for. I feel we are much better off having one function that can
> > handle all cases and do so with high performance, than trying to
> > construct a set of functions that end up having to reinitialize the
> > same memory from the previous step and end up with us wasting cycles
> > and duplicating overhead in multiple spots.
> 
> The memory hotplug is just one pile of unmaintainable mess mostly because
> of this kind of attitude. You just care about _your_ particular usecase
> and not a wee bit beyond that.

I care about all of it. What I am proposing is a solution that works
out best for all memory init. That is why my follow-on patch set had
also improved standard deferred memory initialization.

What I am concerned with is that your insistance that we cannot have
any ZONE_DEVICE information initialized in the generic page init code
is really just you focusing no _your_ particular use case and ignoring
everything else.

The fact is I already gave up quite a bit. With the follow-on patch set
I am only getting it down to about 18s for my 3TB init case. I could
have gotten it down to 12s - 15s, but that would have required moving
the memset and that optimization would have hurt other cases. I opted
not to do that because I wanted to keep the solution generic and as a
net benefit for all cases.
