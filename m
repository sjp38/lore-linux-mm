Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8CC6B0276
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 09:47:46 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a70-v6so3666443qkb.16
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 06:47:46 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n85-v6si3356595qke.353.2018.07.18.06.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 06:47:45 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524093121.GZ20441@dhcp22.suse.cz>
 <c0b8bbd5-6c01-f550-ae13-ef80b2255ea6@redhat.com>
 <20180524120341.GF20441@dhcp22.suse.cz>
 <1a03ac4e-9185-ce8e-a672-c747c3e40ff2@redhat.com>
 <20180524142241.GJ20441@dhcp22.suse.cz>
 <819e45c5-6ae3-1dff-3f1d-c0411b6e2e1d@redhat.com>
 <20180718131905.GB7193@dhcp22.suse.cz>
 <c4c82cd3-c1be-dce8-af2e-fcd177cf7b54@redhat.com>
 <20180718134308.GF7193@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <84568c21-bdbd-5769-56dd-64d5e2378b91@redhat.com>
Date: Wed, 18 Jul 2018 15:47:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180718134308.GF7193@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dave Young <dyoung@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 18.07.2018 15:43, Michal Hocko wrote:
> On Wed 18-07-18 15:39:29, David Hildenbrand wrote:
>> On 18.07.2018 15:19, Michal Hocko wrote:
>>> [got back to this really late. Sorry about that]
>>>
>>> On Thu 24-05-18 23:07:23, David Hildenbrand wrote:
>>>> On 24.05.2018 16:22, Michal Hocko wrote:
>>>>> I will go over the rest of the email later I just wanted to make this
>>>>> point clear because I suspect we are talking past each other.
>>>>
>>>> It sounds like we are now talking about how to solve the problem. I like
>>>> that :)
>>>>
>>>>>
>>>>> On Thu 24-05-18 16:04:38, David Hildenbrand wrote:
>>>>> [...]
>>>>>> The point I was making is: I cannot allocate 8MB/128MB using the buddy
>>>>>> allocator. All I want to do is manage the memory a virtio-mem device
>>>>>> provides as flexible as possible.
>>>>>
>>>>> I didn't mean to use the page allocator to isolate pages from it. We do
>>>>> have other means. Have a look at the page isolation framework and have a
>>>>> look how the current memory hotplug (ab)uses it. In short you mark the
>>>>> desired physical memory range as isolated (nobody can allocate from it)
>>>>> and then simply remove it from the page allocator. And you are done with
>>>>> it. Your particular range is gone, nobody will ever use it. If you mark
>>>>> those struct pages reserved then pfn walkers should already ignore them.
>>>>> If you keep those pages with ref count 0 then even hotplug should work
>>>>> seemlessly (I would have to double check).
>>>>>
>>>>> So all I am arguing is that whatever your driver wants to do can be
>>>>> handled without touching the hotplug code much. You would still need
>>>>> to add new ranges in the mem section units and manage on top of that.
>>>>> You need to do that anyway to keep track of what parts are in use or
>>>>> offlined anyway right? Now the mem sections. You have to do that anyway
>>>>> for memmaps. Our sparse memory model simply works in those units. Even
>>>>> if you make a part of that range unavailable then the section will still
>>>>> be there.
>>>>>
>>>>> Do I make at least some sense or I am completely missing your point?
>>>>>
>>>>
>>>> I think we're heading somewhere. I understand that you want to separate
>>>> this "semi" offline part from the general offlining code. If so, we
>>>> should definitely enforce segment alignment for online_pages/offline_pages.
>>>>
>>>> Importantly, what I need is:
>>>>
>>>> 1. Indicate and prepare memory sections to be used for adding memory
>>>>    chunks (right now add_memory())
>>>
>>> Yes, this is section based. So you will always get memmap (struct page)
>>> for the whole section.
>>>
>>>> 2. Make memory chunks of a section available to the system (right now
>>>>    online_pages())
>>>
>>> Yes, this doesn't have to be section based. All you need is to mark
>>> remaining pages as offline. They are reserved at this moment so nobody
>>> should touch tehem.
>>>
>>>> 3. Remove memory chunks of a section from the system (right now
>>>>    offline_pages())
>>>
>>> Yes. All we need is to note that those reserved pages are actually good
>>> to offline. I have mentioned that reserved pages are yours at this stage
>>> so you can note the special state without an additional page flag.
>>>
>>> The generic hotplug code just have to learn about this new state.
>>> has_unmovable_pages sounds like a proper place to do that. You simply
>>> clear the offline state and the PageReserved and you are done with the
>>> page.
>>>
>>
>> I agree. This would be minimal invassive - notifiers are still called on
>> whole segment.
> 
> That shouldn't matter because notifiers should never step on pages they
> do not manage or own.
> 
>>>> 4. Remove memory sections from the system (right now remove_memory())
>>>
>>> no change needed
>>>
>>>> 5. Hinder dumping tools from reading memory chunks that are logically
>>>>    offline (right now PageOffline())
>>>
>>> I still fail to see why do we even care about some dumping tools. Pages
>>> are reserved so they simply shouldn't touch that memory at all.
>>>
>>
>> Thanks for having a look!
>>
>> I wonder why reserved pages never got excluded by dump tools. So I
>> assume there is some kind of magic hidden in it.
>>
>> `git grep SetPageReserved` returns a number of buffers that are not to
>> be swapped. So "reserved" there is used for:
>>   "PG_reserved is set for special pages, which can never be swapped out"
> 
> That was an ancient menaing of the flag. The flag in general means that
> you shouldn't touch it unless you own it.
> 
>> And my point would be that these pages are still to be dumped (just as
>> it is being done now). They are valid memory.
> 
> Then fix kdump or what ever is touching them.

If the rule is really reserved -> dontouch, then I agree.

> 
>> It seems like this bit is used for two different purposes. My take would
>> be then to have another way of indicating "don't swap" vs. "page not
>> accessible / offline". And that's why I propose PageOffline.
>>
>> I would even go one step further and rename "reserved" to "dontswap".
> 
> No, it really doesn't have that meaning for years.
> 

So would you agree to change the comment in page-flags.h to something like

"PG_reserved is set for special pages, that should never be touched
(read/written). Some of them might not even exist."

Thanks!

-- 

Thanks,

David / dhildenb
