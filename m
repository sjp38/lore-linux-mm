Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A885F6B0006
	for <linux-mm@kvack.org>; Thu, 24 May 2018 08:03:49 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id m1-v6so1199075wrn.14
        for <linux-mm@kvack.org>; Thu, 24 May 2018 05:03:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o61-v6si1314075edb.107.2018.05.24.05.03.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 05:03:46 -0700 (PDT)
Date: Thu, 24 May 2018 14:03:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180524120341.GF20441@dhcp22.suse.cz>
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524093121.GZ20441@dhcp22.suse.cz>
 <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On Thu 24-05-18 12:45:50, David Hildenbrand wrote:
> On 24.05.2018 11:31, Michal Hocko wrote:
> > On Thu 24-05-18 10:31:30, David Hildenbrand wrote:
[...]
> >> Allowing to unplug such small chunks is actually the interesting thing.
> > 
> > Not really. The vmemmap will stay behind and so you are still wasting
> > memory. Well, unless you want to have small ptes for the hotplug memory
> > which is just too suboptimal
> > 
> >> Try unplugging a 128MB DIMM. With ZONE_NORMAL: pretty much impossible.
> >> With ZONE_MOVABLE: maybe possible.
> > 
> > It should be always possible. We have some players who pin pages for
> > arbitrary amount of time even from zone movable but we should focus on
> > fixing them or come with a way to handle that. Zone movable is about
> > movable memory pretty much by definition.
> 
> You exactly describe what has been the case for way too long. But this
> is only the tip of the ice berg. Simply adding all memory to
> ZONE_MOVABLE is not going to work (we create an imbalance - e.g. page
> tables have to go into ZONE_NORMAL. this imbalance will have to be
> managed later on). That's why I am rather thinking about said assignment
> to different zones in the future. For now using ZONE_NORMAL is the
> easiest approach.

Well, I think it would be fair to say that memory hotplug is not really
suitable for balancing memory between guests. Exactly because of the
offline part. If you want to have a reliable offline you just screw
yourself to the highmem land problems. This is the primary reason why I
really detest any balooning like solutions based on the memory hotplug.
I can see the case for adding memory to increase the initial guests
sizes but that can be achieved with what we have currently without any
additional complexity in the generic code. So you really have to have
some seriously convincing arguments in hands. So far I haven't heard
any, to be honest. This is just yet another thing that can be achieved
with what other ballooning solutions are doing. I might be wrong because
this is not really my area and I might underestimate some nuances but
as already said, you have to be really convincing...

> >> Try to find one 4MB chunk of a
> >> "128MB" DIMM that can be unplugged: With ZONE_NORMAL
> >> maybe possible. With ZONE_MOVABLE: likely possible.
> >>
> >> But let's not go into the discussion of ZONE_MOVABLE vs. ZONE_NORMAL, I
> >> plan to work on that in the future.
> >>
> >> Think about it that way: A compromise between section based memory
> >> hotplug and page based ballooning.
> >>
> >>
> >> 2. memory hotplug and 128MB size
> >>
> >> Interesting point. One thing to note is that "The whole memory hotplug
> >> is centered around memory sections and those are 128MB in size" is
> >> simply the current state how it is implemented in Linux, nothing more.
> > 
> > Yes, and we do care about that because the whole memory hotplug is a
> > bunch of hacks duct taped together to address very specific usecases.
> > It took me one year to put it into a state that my eyes do not bleed
> > anytime I have to look there. There are still way too many problems to
> > address. I certainly do not want to add more complication. Quite
> > contrary, the whole code cries for cleanups and sanity.
> 
> And I highly appreciate your effort. But look at the details: I am even
> cleaning up online_pages() and offline_pages(). And this is not the end
> of my contributions :) This is one step into that direction. It
> showcases what is easily possible right now. With existing interfaces.

If you can bring some cleanups then great. I would suggest pulling those
out and post separately.
 
> >> I want to avoid what balloon drivers do: rip out random pages,
> >> fragmenting guest memory until we eventually trigger the OOM killer. So
> >> instead, using 4MB chunks produces no fragmentation. And if I can't find
> >> such a chunk anymore: bad luck. At least I won't be risking stability of
> >> my guest.
> >>
> >> Does that answer your question?
> > 
> > So you basically pull out those pages from the page allocator and mark
> > them offline (reserved what ever)? Why do you need any integration to
> > the hotplug code base then? You should be perfectly fine to work on
> > top and only teach that hotplug code to recognize your pages are being
> > free when somebody decides to offline the whole section. I can think of
> > a callback that would allow that.
> > 
> > But then you are, well a balloon driver, aren't you?
> 
> Pointing you at: [1]
> 
> I *cannot* use the page allocator. Using it would be a potential addon
> (for special cases!) in the future. I really scan for removable chunks
> in the memory region a certain virtio-mem device owns. Why can't I do it:
> 
> 1. I have to allocate memory in certain physical address range (the
> range that belongs to a virtio-mem device). Well, we could write an
> allocator.

Not really. Why cannot you simply mimic what the hotplug already does?
Scan a pfn range and isolate/migrate it? We can abstract such
functionality to be better usable.

> 2. I might have to deal with chunks that are bigger than MAX_ORDER - 1.
> Say my virito-mem device has a block size of 8MB and I only can allocate
> 4MB. I'm out of luck then.

Confused again. So you are managing 4M chunks in 8M units?

> So, no, virtio-mem is not a balloon driver :)
[...]
> >> 1. "hotplug should simply not depend on kdump at all"
> >>
> >> In theory yes. In the current state we already have to trigger kdump to
> >> reload whenever we add/remove a memory block.
> > 
> > More details please.
> 
> I just had another look at the whole complexity of
> makedumfile/kdump/uevents and I'll follow up with a detailed description.
> 
> kdump.service is definitely reloaded when setting a memory block
> online/offline (not when adding/removing as I wrongly claimed before).
> 
> I'll follow up with a more detailed description and all the pointers.

Please make sure to describe what is the architecture then. I have no
idea what kdump.servise is supposed to do for example.

> >> 2. kdump part
> >>
> >> Whenever we offline a page and tell the hypervisor about it ("unplug"),
> >> we should not assume that we can read that page again. Now, if dumping
> >> tools assume they can read all memory that is offline, we are in trouble.
> > 
> > Sure. Just make those pages reserved. Nobody should touch those IIRC.
> 
> I think I answered that question already (see [1]) in another thread: We
> have certain buffers that are marked reserved. Reserved does not imply
> don't dump. all dump tools I am aware of will dump reserved pages. I
> cannot use reserved to mark sections offline once all pages are offline.

Then fix those dump tools. They shouldn't have any business touching
reserved memory, should they? That memory can be in an arbitrary state.
 
> And I don't think the current approach of using a mapcount value is the
> problematic part. This is straight forward now.

The thing is that struct page space is extremely scarce. Anytime you
take a bit or there somebody else will have to scratch his head much
harder in the future. So if we can go with the existing infrastructure
then it should be preferable. And we do have "this page is mine do not
even think about touching it" - PageReserved.
-- 
Michal Hocko
SUSE Labs
