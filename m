Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2A686B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:59:42 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k135so5374635qke.6
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:59:42 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n7si168562qtl.243.2018.04.13.07.59.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 07:59:41 -0700 (PDT)
Subject: Re: [PATCH RFC 0/8] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180413131632.1413-1-david@redhat.com>
 <20180413134414.GS17484@dhcp22.suse.cz>
 <3545ef32-14db-25ab-bf1a-56044402add3@redhat.com>
 <20180413142030.GU17484@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e5430631-7bc2-3c42-43b0-2fce220feeeb@redhat.com>
Date: Fri, 13 Apr 2018 16:59:39 +0200
MIME-Version: 1.0
In-Reply-To: <20180413142030.GU17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On 13.04.2018 16:20, Michal Hocko wrote:
> On Fri 13-04-18 16:01:43, David Hildenbrand wrote:
>> On 13.04.2018 15:44, Michal Hocko wrote:
>>> [If you choose to not CC the same set of people on all patches - which
>>> is sometimes a legit thing to do - then please cc them to the cover
>>> letter at least.]
>>>
>>> On Fri 13-04-18 15:16:24, David Hildenbrand wrote:
>>>> I am right now working on a paravirtualized memory device ("virtio-mem").
>>>> These devices control a memory region and the amount of memory available
>>>> via it. Memory will not be indicated via ACPI and friends, the device
>>>> driver is responsible for it.
>>>
>>> How does this compare to other ballooning solutions? And why your driver
>>> cannot simply use the existing sections and maintain subsections on top?
>>>
>>
>> (further down in this mail is a small paragraph about that)
> 
> Sorry, I just stopped right there and didn't even finsh to the end.
> Shame on me! I will do my homework and read it carefully (next week).
> 

Sure, in case you have any questions feel free to ask. And if you are
curious how this is used in practice, let me know and I can post the
current prototype that should run on x86 and s390x.

Have a nice weekend! :)

> [...]
>> "And why your driver cannot simply use the existing sections and
>> maintain subsections on top?"
>>
>> Can you elaborate how that is going to work? What I do as of now, is to
>> remember for each memory block (basically a section because I want to
>> make it as small as possible) which chunks ("subsections") are
>> online/offline. This works just fine. Is this what you are referring to?
> 
> Well, basically yes. I meant to suggest you simply mark pages reserved
> and pull them out. You can reuse some parts of such a struct page for
> your metadata because we should simply ignore those.

I store metadata in a separate structure (basically a uin64_t) right,
because it is easier to track blocks especially when I remove_memory()
again.

Problem with reserved pages is that e.g. kdump will happily think it can
read all pages. So we need some way to indicate that to dumping tools.
Also, offline_pages() has to be thought to not simply offline a memory
section just because a subset of pages has been offlined.

> 
> You still have to allocate memmap for the full section but 128MB
> sections have a nice effect that they fit into a single PMD for
> sparse-vmemmap. So you do not really need to touch mem sections, all you
> need is to keep your metadata on top.

Please keep in mind that we somehow have to get pages out of the system
when trying to remove 4mb chunks. Especially to also make
remove_memory() work once all chunks have been offlined. We cannot use
any current allocator for this ("allocate memory only in a certain
address range"). So the online/offline_pages approach is the cleanest
solution I have found so far. (e.g. offline_pages: isolate+migrate a 4MB
block, flush them out of all data structures, fixup accounting).

Also, please note that the subsection size can very. It could e.g. be
8MB or 16MB. This is not fixed to 4MB. It could be configured
differently by the paravirtualized memory device (e.g. minimum
granularity is 8MB)

The current prototype allows a driver to:
- add/remove >4MB chunks to/from the system cleanly
- add memory blocks that it manages, when needed
- remove memory blocks when no longer needed (removing struct pages)
- teaching kdump not to touch subsections that are offline

Thanks!

-- 

Thanks,

David / dhildenb
