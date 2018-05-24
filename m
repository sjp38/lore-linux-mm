Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD9F46B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:31:40 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id m65-v6so614960qkh.11
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:31:40 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n63-v6si128402qka.211.2018.05.24.01.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 01:31:39 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
Date: Thu, 24 May 2018 10:31:30 +0200
MIME-Version: 1.0
In-Reply-To: <20180524075327.GU20441@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 24.05.2018 09:53, Michal Hocko wrote:
> I've had some questions before and I am not sure they are fully covered.
> At least not in the cover letter (I didn't get much further yet) which
> should give us a highlevel overview of the feature.

Sure, I can give you more details. Adding all details to the cover
letter will result in a cover letter that nobody will read :)

> 
> On Wed 23-05-18 17:11:41, David Hildenbrand wrote:
>> This is now the !RFC version. I did some additional tests and inspected
>> all memory notifiers. At least page_ext and kasan need fixes.
>>
>> ==========
>>
>> I am right now working on a paravirtualized memory device ("virtio-mem").
>> These devices control a memory region and the amount of memory available
>> via it. Memory will not be indicated/added/onlined via ACPI and friends,
>> the device driver is responsible for it.
>>
>> When the device driver starts up, it will add and online the requested
>> amount of memory from its assigned physical memory region. On request, it
>> can add (online) either more memory or try to remove (offline) memory. As
>> it will be a virtio module, we also want to be able to have it as a loadable
>> kernel module.
> 
> How do you handle the offline case? Do you online all the memory to
> zone_movable?

Right now everything is added to ZONE_NORMAL. I have some plans to
change that, but that will require more work (auto assigning to
ZONE_MOVABLE or ZONE_NORMAL depending on certain heuristics). For now
this showcases that offlining of memory actually works on that
granularity and it can be used in some scenarios. To make unplug more
reliable, more work is needed.

> 
>> Such a device can be thought of like a "resizable DIMM" or a "huge
>> number of 4MB DIMMS" that can be automatically managed.
> 
> Why do we need such a small granularity? The whole memory hotplug is
> centered around memory sections and those are 128MB in size. Smaller
> sizes simply do not fit into that concept. How do you deal with that?

1. Why do we need such a small granularity?

Because we can :) No, honestly, on s390x it is 256MB and if I am not
wrong on certain x86/arm machines it is even 1 or 2GB. This simply gives
more flexibility when plugging memory. (thinking about cloud environments)

Allowing to unplug such small chunks is actually the interesting thing.
Try unplugging a 128MB DIMM. With ZONE_NORMAL: pretty much impossible.
With ZONE_MOVABLE: maybe possible. Try to find one 4MB chunk of a
"128MB" DIMM that can be unplugged: With ZONE_NORMAL
maybe possible. With ZONE_MOVABLE: likely possible.

But let's not go into the discussion of ZONE_MOVABLE vs. ZONE_NORMAL, I
plan to work on that in the future.

Think about it that way: A compromise between section based memory
hotplug and page based ballooning.


2. memory hotplug and 128MB size

Interesting point. One thing to note is that "The whole memory hotplug
is centered around memory sections and those are 128MB in size" is
simply the current state how it is implemented in Linux, nothing more.

E.g. Windows supports 1MB DIMMs So the statement "Smaller sizes simply
do not fit into that concept" is wrong. It simply does not fit
*perfectly* into the way it is implemented right now in Linux. But as
this patch series shows, this is just a minor drawback we can easily
work around.

"How do you deal with that?"

I think the question is answered below: add a section and online only
parts of it.


> 
>> As we want to be able to add/remove small chunks of memory to a VM without
>> fragmenting guest memory ("it's not what the guest pays for" and "what if
>> the hypervisor wants to use huge pages"), it looks like we can do that
>> under Linux in a 4MB granularity by using online_pages()/offline_pages()
> 
> Please expand on this some more. Larger logical units usually lead to a
> smaller fragmentation.

I want to avoid what balloon drivers do: rip out random pages,
fragmenting guest memory until we eventually trigger the OOM killer. So
instead, using 4MB chunks produces no fragmentation. And if I can't find
such a chunk anymore: bad luck. At least I won't be risking stability of
my guest.

Does that answer your question?

> 
>> We add a segment and online only 4MB blocks of it on demand. So the other
>> memory might not be accessible.
> 
> But you still allocate vmemmap for the full memory section, right? That
> would mean that you spend 2MB to online 4MB of memory. Sounds quite
> wasteful to me.

This is true for the first 4MB chunk of a section, but not for the
remaining ones. Of course, I try to minimize the number of such sections
(ideally, this would only be one "open section" for a virtio-mem device
when only plugging memory). So once we online further 4MB chunk, the
overhead gets smaller and smaller.

> 
>> For kdump and onlining/offlining code, we
>> have to mark pages as offline before a new segment is visible to the system
>> (e.g. as these pages might not be backed by real memory in the hypervisor).
> 
> Please expand on the kdump part. That is really confusing because
> hotplug should simply not depend on kdump at all. Moreover why don't you
> simply mark those pages reserved and pull them out from the page
> allocator?

1. "hotplug should simply not depend on kdump at all"

In theory yes. In the current state we already have to trigger kdump to
reload whenever we add/remove a memory block.


2. kdump part

Whenever we offline a page and tell the hypervisor about it ("unplug"),
we should not assume that we can read that page again. Now, if dumping
tools assume they can read all memory that is offline, we are in trouble.

It is the same thing as we already have with Pg_hwpoison. Just a
different meaning - "don't touch this page, it is offline" compared to
"don't touch this page, hw is broken".

Balloon drivers solve this problem by always allowing to read unplugged
memory. In virtio-mem, this cannot and should even not be guaranteed.

And what we have to do to make this work is actually pretty simple: Just
like Pg_hwpoison, track per page if it is online and provide this
information to kdump.


3. Marking pages reserved and pulling them out of the page allocator

This is basically what e.g. the XEN balloon does. I don't see how that
helps related to kdump. Can you explain how that would solve any of the
problems I am trying to solve here? This does neither solve the unplug
part nor the "tell dump tools to not read such memory" part.

Thanks for looking into this.

-- 

Thanks,

David / dhildenb
