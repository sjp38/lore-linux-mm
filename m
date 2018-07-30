Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B86326B0010
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:51:54 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v65-v6so11055821qka.23
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 06:51:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h55-v6si3406714qvd.35.2018.07.30.06.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 06:51:52 -0700 (PDT)
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
References: <20180727165454.27292-1-david@redhat.com>
 <20180730113029.GM24267@dhcp22.suse.cz>
 <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com>
 <20180730120529.GN24267@dhcp22.suse.cz>
 <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com>
 <CAGM2reahiWj5LFq1npRpwK2k-4K-L9hr3AHUV9uYcmT2s3Bnuw@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <56e97799-fbe1-9546-46ab-a9b8ee8794e0@redhat.com>
Date: Mon, 30 Jul 2018 15:51:45 +0200
MIME-Version: 1.0
In-Reply-To: <CAGM2reahiWj5LFq1npRpwK2k-4K-L9hr3AHUV9uYcmT2s3Bnuw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: mhocko@kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, gregkh@linuxfoundation.org, mingo@kernel.org, Andrew Morton <akpm@linux-foundation.org>, dan.j.williams@intel.com, jack@suse.cz, mawilcox@microsoft.com, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, kirill.shutemov@linux.intel.com, Vlastimil Babka <vbabka@suse.cz>, osalvador@techadventures.net, yasu.isimatu@gmail.com, malat@debian.org, Mel Gorman <mgorman@suse.de>, iamjoonsoo.kim@lge.com

On 30.07.2018 15:30, Pavel Tatashin wrote:
> On Mon, Jul 30, 2018 at 8:11 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 30.07.2018 14:05, Michal Hocko wrote:
>>> On Mon 30-07-18 13:53:06, David Hildenbrand wrote:
>>>> On 30.07.2018 13:30, Michal Hocko wrote:
>>>>> On Fri 27-07-18 18:54:54, David Hildenbrand wrote:
>>>>>> Right now, struct pages are inititalized when memory is onlined, not
>>>>>> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
>>>>>> memory hotplug")).
>>>>>>
>>>>>> remove_memory() will call arch_remove_memory(). Here, we usually access
>>>>>> the struct page to get the zone of the pages.
>>>>>>
>>>>>> So effectively, we access stale struct pages in case we remove memory that
>>>>>> was never onlined. So let's simply inititalize them earlier, when the
>>>>>> memory is added. We only have to take care of updating the zone once we
>>>>>> know it. We can use a dummy zone for that purpose.
>>>>>
>>>>> I have considered something like this when I was reworking memory
>>>>> hotplug to not associate struct pages with zone before onlining and I
>>>>> considered this to be rather fragile. I would really not like to get
>>>>> back to that again if possible.
>>>>>
>>>>>> So effectively, all pages will already be initialized and set to
>>>>>> reserved after memory was added but before it was onlined (and even the
>>>>>> memblock is added). We only inititalize pages once, to not degrade
>>>>>> performance.
>>>>>
>>>>> To be honest, I would rather see d0dc12e86b31 reverted. It is late in
>>>>> the release cycle and if the patch is buggy then it should be reverted
>>>>> rather than worked around. I found the optimization not really
>>>>> convincing back then and this is still the case TBH.
>>>>>
>>>>
>>>> If I am not wrong, that's already broken in 4.17, no? What about that?
>>>
>>> Ohh, I thought this was merged in 4.18.
>>> $ git describe --contains d0dc12e86b31 --match="v*"
>>> v4.17-rc1~99^2~44
>>>
>>> proves me wrong. This means that the fix is not so urgent as I thought.
>>> If you can figure out a reasonable fix then it should be preferable to
>>> the revert.
>>>
>>> Fake zone sounds too hackish to me though.
>>>
>>
>> If I am not wrong, that's the same we had before d0dc12e86b31 but now it
>> is explicit and only one single value for all kernel configs
>> ("ZONE_NORMAL").
>>
>> Before d0dc12e86b31, struct pages were initialized to 0. So it was
>> (depending on the config) ZONE_DMA, ZONE_DMA32 or ZONE_NORMAL.
>>
>> Now the value is random and might not even be a valid zone.
> 
> Hi David,
> 
> Have you figured out why we access struct pages during hot-unplug for
> offlined memory? Also, a panic trace would be useful in the patch.

__remove_pages() needs a zone as of now (e.g. to recalculate if the zone
is contiguous). This zone is taken from the first page of memory to be
removed. If the struct pages are uninitialized that value is random and
we might even get an invalid zone.

The zone is also used to locate pgdat.

No stack trace available so far, I'm just reading the code and try to
understand how this whole memory hotplug/unplug machinery works.

> 
> As I understand the bug may occur only when hotremove is enabled, and
> default onlining of added memory is disabled. Is this correct? I

Yes, or if onlining fails.

> suspect the reason we have not heard about this bug is that it is rare
> to add memory and not to online it.

I assume so, most distros online all memory that is available as it is
being added.

> 
> Thank you,
> Pavel
> 


-- 

Thanks,

David / dhildenb
