Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B3936B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:11:37 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d14-v6so10158029qtn.12
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:11:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q30-v6si7930626qtb.403.2018.07.30.05.11.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 05:11:36 -0700 (PDT)
Subject: Re: [PATCH v1] mm: inititalize struct pages when adding a section
References: <20180727165454.27292-1-david@redhat.com>
 <20180730113029.GM24267@dhcp22.suse.cz>
 <6cc416e7-522c-a67e-2706-f37aadff084f@redhat.com>
 <20180730120529.GN24267@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <7b58af7b-5187-2c76-b458-b0f49875a1fc@redhat.com>
Date: Mon, 30 Jul 2018 14:11:30 +0200
MIME-Version: 1.0
In-Reply-To: <20180730120529.GN24267@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@kernel.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Souptick Joarder <jrdr.linux@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@techadventures.net>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 30.07.2018 14:05, Michal Hocko wrote:
> On Mon 30-07-18 13:53:06, David Hildenbrand wrote:
>> On 30.07.2018 13:30, Michal Hocko wrote:
>>> On Fri 27-07-18 18:54:54, David Hildenbrand wrote:
>>>> Right now, struct pages are inititalized when memory is onlined, not
>>>> when it is added (since commit d0dc12e86b31 ("mm/memory_hotplug: optimize
>>>> memory hotplug")).
>>>>
>>>> remove_memory() will call arch_remove_memory(). Here, we usually access
>>>> the struct page to get the zone of the pages.
>>>>
>>>> So effectively, we access stale struct pages in case we remove memory that
>>>> was never onlined. So let's simply inititalize them earlier, when the
>>>> memory is added. We only have to take care of updating the zone once we
>>>> know it. We can use a dummy zone for that purpose.
>>>
>>> I have considered something like this when I was reworking memory
>>> hotplug to not associate struct pages with zone before onlining and I
>>> considered this to be rather fragile. I would really not like to get
>>> back to that again if possible.
>>>
>>>> So effectively, all pages will already be initialized and set to
>>>> reserved after memory was added but before it was onlined (and even the
>>>> memblock is added). We only inititalize pages once, to not degrade
>>>> performance.
>>>
>>> To be honest, I would rather see d0dc12e86b31 reverted. It is late in
>>> the release cycle and if the patch is buggy then it should be reverted
>>> rather than worked around. I found the optimization not really
>>> convincing back then and this is still the case TBH.
>>>
>>
>> If I am not wrong, that's already broken in 4.17, no? What about that?
> 
> Ohh, I thought this was merged in 4.18.
> $ git describe --contains d0dc12e86b31 --match="v*"
> v4.17-rc1~99^2~44
> 
> proves me wrong. This means that the fix is not so urgent as I thought.
> If you can figure out a reasonable fix then it should be preferable to
> the revert.
> 
> Fake zone sounds too hackish to me though.
> 

If I am not wrong, that's the same we had before d0dc12e86b31 but now it
is explicit and only one single value for all kernel configs
("ZONE_NORMAL").

Before d0dc12e86b31, struct pages were initialized to 0. So it was
(depending on the config) ZONE_DMA, ZONE_DMA32 or ZONE_NORMAL.

Now the value is random and might not even be a valid zone.

-- 

Thanks,

David / dhildenb
