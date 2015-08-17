Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE056B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 05:53:19 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so76006295wib.0
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 02:53:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bx18si26052402wjb.125.2015.08.17.02.53.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Aug 2015 02:53:17 -0700 (PDT)
Subject: Re: [RFC PATCH kernel vfio] mm: vfio: Move pages out of CMA before
 pinning
References: <1438762094-17747-1-git-send-email-aik@ozlabs.ru>
 <55D1910C.7070006@suse.cz> <55D1A525.5090706@ozlabs.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D1AF06.5090703@suse.cz>
Date: Mon, 17 Aug 2015 11:53:10 +0200
MIME-Version: 1.0
In-Reply-To: <55D1A525.5090706@ozlabs.ru>
Content-Type: text/plain; charset=koi8-r; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Kardashevskiy <aik@ozlabs.ru>, linux-mm@kvack.org
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Gibson <david@gibson.dropbear.id.au>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paul Mackerras <paulus@samba.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>, Alexander Graf <agraf@suse.de>, Paolo Bonzini <pbonzini@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On 08/17/2015 11:11 AM, Alexey Kardashevskiy wrote:
> On 08/17/2015 05:45 PM, Vlastimil Babka wrote:
>> On 08/05/2015 10:08 AM, Alexey Kardashevskiy wrote:
>>> This is about VFIO aka PCI passthrough used from QEMU.
>>> KVM is irrelevant here.
>>>
>>> QEMU is a machine emulator. It allocates guest RAM from anonymous memory
>>> and these pages are movable which is ok. They may happen to be allocated
>>> from the contiguous memory allocation zone (CMA). Which is also ok as
>>> long they are movable.
>>>
>>> However if the guest starts using VFIO (which can be hotplugged into
>>> the guest), in most cases it involves DMA which requires guest RAM pages
>>> to be pinned and not move once their addresses are programmed to
>>> the hardware for DMA.
>>>
>>> So we end up in a situation when quite many pages in CMA are not movable
>>> anymore. And we get bunch of these:
>>>
>>> [77306.513966] alloc_contig_range: [1f3800, 1f78c4) PFNs busy
>>> [77306.514448] alloc_contig_range: [1f3800, 1f78c8) PFNs busy
>>> [77306.514927] alloc_contig_range: [1f3800, 1f78cc) PFNs busy
>>
>> IIRC CMA was for mobile devices and their camera/codec drivers and you
>> don't use QEMU on those? What do you need CMA for in your case?
>
>
> I do not want QEMU to get memory from CMA, this is my point. It just
> happens sometime that the kernel allocates movable pages from there.

I meant why the kernel used for QEMU has also CMA enabled and used (for 
something else)? CMA is mostly used on mobile devices and they don't run 
QEMU?

>
>>
>>> This is a very rough patch to start the conversation about how to move
>>> pages properly. mm/page_alloc.c does this and
>>> arch/powerpc/mm/mmu_context_iommu.c exploits it.
>>
>> OK such conversation should probably start by mentioning the VM_PINNED
>> effort by Peter Zijlstra: https://lkml.org/lkml/2014/5/26/345
>>
>> It's more general approach to dealing with pinned pages, and moving them
>> out of CMA area (and compacting them in general) prior pinning is one of
>> the things that should be done within that framework.
>
>
> And I assume these patches did not go anywhere, right?...

Not yet :)

>> Then there's the effort to enable migrating pages other than LRU during
>> compaction (and thus CMA allocation): https://lwn.net/Articles/650864/
>> I don't know if that would be applicable in your use case, i.e. are the
>> pins for DMA short-lived and can the isolation/migration code wait a bit
>> for the transfer to finish so it can grab them, or something?
>
>
> Pins for DMA are long-lived, pretty much as long as the guest is running.
> So this "compaction" is too late.

Oh, OK.

>>>
>>> Please do not comment on the style and code placement,
>>> this is just to give some context :)
>>>
>>> Obviously, this does not work well - it manages to migrate only few pages
>>> and crashes as it is missing locks/disabling interrupts and I probably
>>> should not just remove pages from LRU list (normally, I guess, only these
>>> can migrate) and a million of other things.
>>>
>>> The questions are:
>>>
>>> - what is the correct way of telling if the page is in CMA?
>>> is (get_pageblock_migratetype(page) == MIGRATE_CMA) good enough?
>>
>> Should be.
>>
>>> - how to tell MM to move page away? I am calling migrate_pages() with
>>> an get_new_page callback which allocates a page with GFP_USER but without
>>> GFP_MOVABLE which should allocate new page out of CMA which seems ok but
>>> there is a little convern that we might want to add MOVABLE back when
>>> VFIO device is unplugged from the guest.
>>
>> Hmm, once the page is allocated, then the migratetype is not tracked
>> anywhere (except in page_owner debug data). But the unmovable allocations
>> might exhaust available unmovable pageblocks and lead to fragmentation. So
>> "add MOVABLE back" would be too late. Instead we would need to tell the
>> allocator somehow to give us movable page but outside of CMA.
>
> It is it movable, why do we care if it is in CMA or not?

I did assume your pages are mostly movable, but with some temporary pins 
they might not be movable reliably at arbitrary time. But if you say the 
pins are long lived then it's probably best allocated without MOVABLE. 
If the device is later unplugged, sync compaction will eventually move 
the pages out of unmovable pageblocks.

>> CMA's own
>> __alloc_contig_migrate_range() avoids this problem by allocating movable
>> pages, but the range has been already page-isolated and thus the allocator
>> won't see the pages there.You obviously can't take this approach and
>> isolate all CMA pageblocks like that.  That smells like a new __GFP_FLAG, meh.
>
>
> I understood (more or less) all of it except the __GFP_FLAG - when/what
> would use it?

Nevermind, wrt above.

>>> - do I need to isolate pages by using isolate_migratepages_range,
>>> reclaim_clean_pages_from_list like __alloc_contig_migrate_range does?
>>> I dropped them for now and the patch uses only @migratepages from
>>> the compact_control struct.
>>
>> You don't have to do reclaim_clean_pages_from_list(), but the isolation has
>> to be careful, yeah.
>
>
> The isolation here means the whole CMA zone isolation which I "obviously
> can't take this approach"? :)

Ah no, that's isolation from lru lists in this context. Unfortunately 
the same word is used for both.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
