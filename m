Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85F2F6B0008
	for <linux-mm@kvack.org>; Thu, 24 May 2018 06:46:04 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u127-v6so881472qka.9
        for <linux-mm@kvack.org>; Thu, 24 May 2018 03:46:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f13-v6si6768636qtf.75.2018.05.24.03.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 03:46:02 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524093121.GZ20441@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
Date: Thu, 24 May 2018 12:45:50 +0200
MIME-Version: 1.0
In-Reply-To: <20180524093121.GZ20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 24.05.2018 11:31, Michal Hocko wrote:
> On Thu 24-05-18 10:31:30, David Hildenbrand wrote:
>> On 24.05.2018 09:53, Michal Hocko wrote:
>>> I've had some questions before and I am not sure they are fully covered.
>>> At least not in the cover letter (I didn't get much further yet) which
>>> should give us a highlevel overview of the feature.
>>
>> Sure, I can give you more details. Adding all details to the cover
>> letter will result in a cover letter that nobody will read :)
> 
> Well, these are not details. Those are mostly highlevel design points
> and integration with the existing hotplug scheme. I am definitely not
> suggesting describing the code etc...

Will definitely do as we move on.

> 
>>> On Wed 23-05-18 17:11:41, David Hildenbrand wrote:
>>>> This is now the !RFC version. I did some additional tests and inspected
>>>> all memory notifiers. At least page_ext and kasan need fixes.
>>>>
>>>> ==========
>>>>
>>>> I am right now working on a paravirtualized memory device ("virtio-mem").
>>>> These devices control a memory region and the amount of memory available
>>>> via it. Memory will not be indicated/added/onlined via ACPI and friends,
>>>> the device driver is responsible for it.
>>>>
>>>> When the device driver starts up, it will add and online the requested
>>>> amount of memory from its assigned physical memory region. On request, it
>>>> can add (online) either more memory or try to remove (offline) memory. As
>>>> it will be a virtio module, we also want to be able to have it as a loadable
>>>> kernel module.
>>>
>>> How do you handle the offline case? Do you online all the memory to
>>> zone_movable?
>>
>> Right now everything is added to ZONE_NORMAL. I have some plans to
>> change that, but that will require more work (auto assigning to
>> ZONE_MOVABLE or ZONE_NORMAL depending on certain heuristics). For now
>> this showcases that offlining of memory actually works on that
>> granularity and it can be used in some scenarios. To make unplug more
>> reliable, more work is needed.
> 
> Spell that out then. Memory offline is basically unusable for
> zone_normal. So you are talking about adding memory only in practice and
> it would be fair to be explicit about that.

Yes, I will add that. For now hotplugs works (except when already very
tight on memory) reliably. unplug is done on a "best can do basis".
Nothing critical happens if I can't free up a 4MB chunk. Bad luck.

> 
>>>> Such a device can be thought of like a "resizable DIMM" or a "huge
>>>> number of 4MB DIMMS" that can be automatically managed.
>>>
>>> Why do we need such a small granularity? The whole memory hotplug is
>>> centered around memory sections and those are 128MB in size. Smaller
>>> sizes simply do not fit into that concept. How do you deal with that?
>>
>> 1. Why do we need such a small granularity?
>>
>> Because we can :) No, honestly, on s390x it is 256MB and if I am not
>> wrong on certain x86/arm machines it is even 1 or 2GB. This simply gives
>> more flexibility when plugging memory. (thinking about cloud environments)
> 
> We can but if that makes the memory hotplug (cluttered enough in the
> current state) more complicated then we simply won't. Or at least I will
> not ack anything that will go that direction.

I agree, but at least from the current set of patches it doesn't
increase the complexity. At least from my POV. E.g onlining of arbitrary
sizes was always implemented. Offlining was claimed to be supported to
some extend. And I am cleaning that up here (e.g. in offline_pages() or
in the memory notifiers). I am using what the existing interfaces
promised but fix it and clean it up.

>  
>> Allowing to unplug such small chunks is actually the interesting thing.
> 
> Not really. The vmemmap will stay behind and so you are still wasting
> memory. Well, unless you want to have small ptes for the hotplug memory
> which is just too suboptimal
> 
>> Try unplugging a 128MB DIMM. With ZONE_NORMAL: pretty much impossible.
>> With ZONE_MOVABLE: maybe possible.
> 
> It should be always possible. We have some players who pin pages for
> arbitrary amount of time even from zone movable but we should focus on
> fixing them or come with a way to handle that. Zone movable is about
> movable memory pretty much by definition.

You exactly describe what has been the case for way too long. But this
is only the tip of the ice berg. Simply adding all memory to
ZONE_MOVABLE is not going to work (we create an imbalance - e.g. page
tables have to go into ZONE_NORMAL. this imbalance will have to be
managed later on). That's why I am rather thinking about said assignment
to different zones in the future. For now using ZONE_NORMAL is the
easiest approach.

> 
>> Try to find one 4MB chunk of a
>> "128MB" DIMM that can be unplugged: With ZONE_NORMAL
>> maybe possible. With ZONE_MOVABLE: likely possible.
>>
>> But let's not go into the discussion of ZONE_MOVABLE vs. ZONE_NORMAL, I
>> plan to work on that in the future.
>>
>> Think about it that way: A compromise between section based memory
>> hotplug and page based ballooning.
>>
>>
>> 2. memory hotplug and 128MB size
>>
>> Interesting point. One thing to note is that "The whole memory hotplug
>> is centered around memory sections and those are 128MB in size" is
>> simply the current state how it is implemented in Linux, nothing more.
> 
> Yes, and we do care about that because the whole memory hotplug is a
> bunch of hacks duct taped together to address very specific usecases.
> It took me one year to put it into a state that my eyes do not bleed
> anytime I have to look there. There are still way too many problems to
> address. I certainly do not want to add more complication. Quite
> contrary, the whole code cries for cleanups and sanity.

And I highly appreciate your effort. But look at the details: I am even
cleaning up online_pages() and offline_pages(). And this is not the end
of my contributions :) This is one step into that direction. It
showcases what is easily possible right now. With existing interfaces.

>> I want to avoid what balloon drivers do: rip out random pages,
>> fragmenting guest memory until we eventually trigger the OOM killer. So
>> instead, using 4MB chunks produces no fragmentation. And if I can't find
>> such a chunk anymore: bad luck. At least I won't be risking stability of
>> my guest.
>>
>> Does that answer your question?
> 
> So you basically pull out those pages from the page allocator and mark
> them offline (reserved what ever)? Why do you need any integration to
> the hotplug code base then? You should be perfectly fine to work on
> top and only teach that hotplug code to recognize your pages are being
> free when somebody decides to offline the whole section. I can think of
> a callback that would allow that.
> 
> But then you are, well a balloon driver, aren't you?

Pointing you at: [1]

I *cannot* use the page allocator. Using it would be a potential addon
(for special cases!) in the future. I really scan for removable chunks
in the memory region a certain virtio-mem device owns. Why can't I do it:

1. I have to allocate memory in certain physical address range (the
range that belongs to a virtio-mem device). Well, we could write an
allocator.

2. I might have to deal with chunks that are bigger than MAX_ORDER - 1.
Say my virito-mem device has a block size of 8MB and I only can allocate
4MB. I'm out of luck then.

So, no, virtio-mem is not a balloon driver :)

>>>
>>>> For kdump and onlining/offlining code, we
>>>> have to mark pages as offline before a new segment is visible to the system
>>>> (e.g. as these pages might not be backed by real memory in the hypervisor).
>>>
>>> Please expand on the kdump part. That is really confusing because
>>> hotplug should simply not depend on kdump at all. Moreover why don't you
>>> simply mark those pages reserved and pull them out from the page
>>> allocator?
>>
>> 1. "hotplug should simply not depend on kdump at all"
>>
>> In theory yes. In the current state we already have to trigger kdump to
>> reload whenever we add/remove a memory block.
> 
> More details please.

I just had another look at the whole complexity of
makedumfile/kdump/uevents and I'll follow up with a detailed description.

kdump.service is definitely reloaded when setting a memory block
online/offline (not when adding/removing as I wrongly claimed before).

I'll follow up with a more detailed description and all the pointers.

>  
>> 2. kdump part
>>
>> Whenever we offline a page and tell the hypervisor about it ("unplug"),
>> we should not assume that we can read that page again. Now, if dumping
>> tools assume they can read all memory that is offline, we are in trouble.
> 
> Sure. Just make those pages reserved. Nobody should touch those IIRC.

I think I answered that question already (see [1]) in another thread: We
have certain buffers that are marked reserved. Reserved does not imply
don't dump. all dump tools I am aware of will dump reserved pages. I
cannot use reserved to mark sections offline once all pages are offline.

And I don't think the current approach of using a mapcount value is the
problematic part. This is straight forward now.

> 
>> It is the same thing as we already have with Pg_hwpoison. Just a
>> different meaning - "don't touch this page, it is offline" compared to
>> "don't touch this page, hw is broken".
>>
>> Balloon drivers solve this problem by always allowing to read unplugged
>> memory. In virtio-mem, this cannot and should even not be guaranteed.
>>
>> And what we have to do to make this work is actually pretty simple: Just
>> like Pg_hwpoison, track per page if it is online and provide this
>> information to kdump.
> 
> If somebody doesn't check your new flag then you are screwed anyway.

Yes, but that's not a problem in a new environment. We don't modify
existing environments. Same used to be true with Pg_hwpoison.

> Existing code should be quite used to PageReserved.

Please refer to [3]:makedump.c

And the performed checks to exclude pages. No sight of reserved pages.

>  
>> 3. Marking pages reserved and pulling them out of the page allocator
>>
>> This is basically what e.g. the XEN balloon does. I don't see how that
>> helps related to kdump. Can you explain how that would solve any of the
>> problems I am trying to solve here? This does neither solve the unplug
>> part nor the "tell dump tools to not read such memory" part.
> 
> I still do not understand the unplug part, to be honest. And the rest
> should be pretty much solveable. Or what do I miss. Your 4MB can be
> perfectly emulated on top of existing sections and pulling pages out of
> the allocator. How you mark those pages is an implementation detail.
> PageReserved sounds like the easiest way forward.
> 

No allocator. Please refer to the virtio-mem prototype and the
explanation I gave above. That should give you a better idea what I do
in the current prototype.

[1] https://lkml.org/lkml/2018/5/23/803
[2] https://www.spinics.net/lists/linux-mm/msg150029.html
[3] https://github.com/jmesmon/makedumpfile

-- 

Thanks,

David / dhildenb
