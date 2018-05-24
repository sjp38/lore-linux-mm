Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEA56B000D
	for <linux-mm@kvack.org>; Thu, 24 May 2018 05:31:30 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id s21-v6so694826plq.4
        for <linux-mm@kvack.org>; Thu, 24 May 2018 02:31:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e187-v6si16761877pgc.127.2018.05.24.02.31.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 02:31:27 -0700 (PDT)
Date: Thu, 24 May 2018 11:31:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
Message-ID: <20180524093121.GZ20441@dhcp22.suse.cz>
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On Thu 24-05-18 10:31:30, David Hildenbrand wrote:
> On 24.05.2018 09:53, Michal Hocko wrote:
> > I've had some questions before and I am not sure they are fully covered.
> > At least not in the cover letter (I didn't get much further yet) which
> > should give us a highlevel overview of the feature.
> 
> Sure, I can give you more details. Adding all details to the cover
> letter will result in a cover letter that nobody will read :)

Well, these are not details. Those are mostly highlevel design points
and integration with the existing hotplug scheme. I am definitely not
suggesting describing the code etc...

> > On Wed 23-05-18 17:11:41, David Hildenbrand wrote:
> >> This is now the !RFC version. I did some additional tests and inspected
> >> all memory notifiers. At least page_ext and kasan need fixes.
> >>
> >> ==========
> >>
> >> I am right now working on a paravirtualized memory device ("virtio-mem").
> >> These devices control a memory region and the amount of memory available
> >> via it. Memory will not be indicated/added/onlined via ACPI and friends,
> >> the device driver is responsible for it.
> >>
> >> When the device driver starts up, it will add and online the requested
> >> amount of memory from its assigned physical memory region. On request, it
> >> can add (online) either more memory or try to remove (offline) memory. As
> >> it will be a virtio module, we also want to be able to have it as a loadable
> >> kernel module.
> > 
> > How do you handle the offline case? Do you online all the memory to
> > zone_movable?
> 
> Right now everything is added to ZONE_NORMAL. I have some plans to
> change that, but that will require more work (auto assigning to
> ZONE_MOVABLE or ZONE_NORMAL depending on certain heuristics). For now
> this showcases that offlining of memory actually works on that
> granularity and it can be used in some scenarios. To make unplug more
> reliable, more work is needed.

Spell that out then. Memory offline is basically unusable for
zone_normal. So you are talking about adding memory only in practice and
it would be fair to be explicit about that.

> >> Such a device can be thought of like a "resizable DIMM" or a "huge
> >> number of 4MB DIMMS" that can be automatically managed.
> > 
> > Why do we need such a small granularity? The whole memory hotplug is
> > centered around memory sections and those are 128MB in size. Smaller
> > sizes simply do not fit into that concept. How do you deal with that?
> 
> 1. Why do we need such a small granularity?
> 
> Because we can :) No, honestly, on s390x it is 256MB and if I am not
> wrong on certain x86/arm machines it is even 1 or 2GB. This simply gives
> more flexibility when plugging memory. (thinking about cloud environments)

We can but if that makes the memory hotplug (cluttered enough in the
current state) more complicated then we simply won't. Or at least I will
not ack anything that will go that direction.
 
> Allowing to unplug such small chunks is actually the interesting thing.

Not really. The vmemmap will stay behind and so you are still wasting
memory. Well, unless you want to have small ptes for the hotplug memory
which is just too suboptimal

> Try unplugging a 128MB DIMM. With ZONE_NORMAL: pretty much impossible.
> With ZONE_MOVABLE: maybe possible.

It should be always possible. We have some players who pin pages for
arbitrary amount of time even from zone movable but we should focus on
fixing them or come with a way to handle that. Zone movable is about
movable memory pretty much by definition.

> Try to find one 4MB chunk of a
> "128MB" DIMM that can be unplugged: With ZONE_NORMAL
> maybe possible. With ZONE_MOVABLE: likely possible.
> 
> But let's not go into the discussion of ZONE_MOVABLE vs. ZONE_NORMAL, I
> plan to work on that in the future.
> 
> Think about it that way: A compromise between section based memory
> hotplug and page based ballooning.
> 
> 
> 2. memory hotplug and 128MB size
> 
> Interesting point. One thing to note is that "The whole memory hotplug
> is centered around memory sections and those are 128MB in size" is
> simply the current state how it is implemented in Linux, nothing more.

Yes, and we do care about that because the whole memory hotplug is a
bunch of hacks duct taped together to address very specific usecases.
It took me one year to put it into a state that my eyes do not bleed
anytime I have to look there. There are still way too many problems to
address. I certainly do not want to add more complication. Quite
contrary, the whole code cries for cleanups and sanity.
 
> E.g. Windows supports 1MB DIMMs So the statement "Smaller sizes simply
> do not fit into that concept" is wrong. It simply does not fit
> *perfectly* into the way it is implemented right now in Linux. But as
> this patch series shows, this is just a minor drawback we can easily
> work around.
> 
> "How do you deal with that?"
> 
> I think the question is answered below: add a section and online only
> parts of it.
> 
> 
> > 
> >> As we want to be able to add/remove small chunks of memory to a VM without
> >> fragmenting guest memory ("it's not what the guest pays for" and "what if
> >> the hypervisor wants to use huge pages"), it looks like we can do that
> >> under Linux in a 4MB granularity by using online_pages()/offline_pages()
> > 
> > Please expand on this some more. Larger logical units usually lead to a
> > smaller fragmentation.
> 
> I want to avoid what balloon drivers do: rip out random pages,
> fragmenting guest memory until we eventually trigger the OOM killer. So
> instead, using 4MB chunks produces no fragmentation. And if I can't find
> such a chunk anymore: bad luck. At least I won't be risking stability of
> my guest.
> 
> Does that answer your question?

So you basically pull out those pages from the page allocator and mark
them offline (reserved what ever)? Why do you need any integration to
the hotplug code base then? You should be perfectly fine to work on
top and only teach that hotplug code to recognize your pages are being
free when somebody decides to offline the whole section. I can think of
a callback that would allow that.

But then you are, well a balloon driver, aren't you?
 
> >> We add a segment and online only 4MB blocks of it on demand. So the other
> >> memory might not be accessible.
> > 
> > But you still allocate vmemmap for the full memory section, right? That
> > would mean that you spend 2MB to online 4MB of memory. Sounds quite
> > wasteful to me.
> 
> This is true for the first 4MB chunk of a section, but not for the
> remaining ones. Of course, I try to minimize the number of such sections
> (ideally, this would only be one "open section" for a virtio-mem device
> when only plugging memory). So once we online further 4MB chunk, the
> overhead gets smaller and smaller.
> 
> > 
> >> For kdump and onlining/offlining code, we
> >> have to mark pages as offline before a new segment is visible to the system
> >> (e.g. as these pages might not be backed by real memory in the hypervisor).
> > 
> > Please expand on the kdump part. That is really confusing because
> > hotplug should simply not depend on kdump at all. Moreover why don't you
> > simply mark those pages reserved and pull them out from the page
> > allocator?
> 
> 1. "hotplug should simply not depend on kdump at all"
> 
> In theory yes. In the current state we already have to trigger kdump to
> reload whenever we add/remove a memory block.

More details please.
 
> 2. kdump part
> 
> Whenever we offline a page and tell the hypervisor about it ("unplug"),
> we should not assume that we can read that page again. Now, if dumping
> tools assume they can read all memory that is offline, we are in trouble.

Sure. Just make those pages reserved. Nobody should touch those IIRC.

> It is the same thing as we already have with Pg_hwpoison. Just a
> different meaning - "don't touch this page, it is offline" compared to
> "don't touch this page, hw is broken".
> 
> Balloon drivers solve this problem by always allowing to read unplugged
> memory. In virtio-mem, this cannot and should even not be guaranteed.
> 
> And what we have to do to make this work is actually pretty simple: Just
> like Pg_hwpoison, track per page if it is online and provide this
> information to kdump.

If somebody doesn't check your new flag then you are screwed anyway.
Existing code should be quite used to PageReserved.
 
> 3. Marking pages reserved and pulling them out of the page allocator
> 
> This is basically what e.g. the XEN balloon does. I don't see how that
> helps related to kdump. Can you explain how that would solve any of the
> problems I am trying to solve here? This does neither solve the unplug
> part nor the "tell dump tools to not read such memory" part.

I still do not understand the unplug part, to be honest. And the rest
should be pretty much solveable. Or what do I miss. Your 4MB can be
perfectly emulated on top of existing sections and pulling pages out of
the allocator. How you mark those pages is an implementation detail.
PageReserved sounds like the easiest way forward.
-- 
Michal Hocko
SUSE Labs
