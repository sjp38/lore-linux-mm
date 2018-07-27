Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9627C6B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:01:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x26-v6so4572440qtb.2
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 11:01:50 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h7-v6si846956qkm.150.2018.07.27.11.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 11:01:48 -0700 (PDT)
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
References: <20180727165454.27292-1-david@redhat.com>
 <CAGM2reYOat1bxBi0KCZAKrh0YS2PX=w-AkpesuuNVY26SSDu9A@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7461eb4b-7069-a494-27e3-68c4e1b65a81@redhat.com>
Date: Fri, 27 Jul 2018 20:01:40 +0200
MIME-Version: 1.0
In-Reply-To: <CAGM2reYOat1bxBi0KCZAKrh0YS2PX=w-AkpesuuNVY26SSDu9A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, Michal Hocko <mhocko@suse.com>, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

On 27.07.2018 19:25, Pavel Tatashin wrote:
> Hi David,
> 
> On Fri, Jul 27, 2018 at 12:55 PM David Hildenbrand <david@redhat.com> wrote:
>>
>> Right now, struct pages are inititalized when memory is onlined, not
>> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
>> memory hotplug")).
>>
>> remove_memory() will call arch_remove_memory(). Here, we usually access
>> the struct page to get the zone of the pages.
>>
>> So effectively, we access stale struct pages in case we remove memory that
>> was never onlined.
> 
> Yeah, this is a bug, thank you for catching it.
> 
>> So let's simply inititalize them earlier, when the
>> memory is added. We only have to take care of updating the zone once we
>> know it. We can use a dummy zone for that purpose.
>>
>> So effectively, all pages will already be initialized and set to
>> reserved after memory was added but before it was onlined (and even the
>> memblock is added). We only inititalize pages once, to not degrade
>> performance.
> 
> Yes, but we still add one more npages loop, so there will be some
> performance degradation, but not severe.
> 
> There are many conflicts with linux-next, please sync before sending
> out next patch.

Indeed, although I rebased, I was working on a branch based on Linus
tree ...

[...]

>>  not_early:
>>                 page = pfn_to_page(pfn);
>> -               __init_single_page(page, pfn, zone, nid);
>> -               if (context == MEMMAP_HOTPLUG)
>> -                       SetPageReserved(page);
>> +               if (context == MEMMAP_HOTPLUG) {
>> +                       /* everything but the zone was inititalized */
>> +                       set_page_zone(page, zone);
>> +                       set_page_virtual(page, zone);
>> +               } else
>> +                       init_single_page(page, pfn, zone, nid);
>>
> 
> Please add a new function:
> memmap_init_zone_hotplug() that will handle only the zone and virtual
> fields for onlined hotplug memory.
> 
> Please remove: "enum memmap_context context" from everywhere.

All your comments make sense. Will look into the details next week and
send a new version.

Thanks and enjoy your weekend!


-- 

Thanks,

David / dhildenb
