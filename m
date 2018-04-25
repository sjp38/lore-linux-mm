Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 706E16B0003
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 23:49:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c4so9087148pfg.22
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 20:49:41 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id b123si14905713pfb.189.2018.04.24.20.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 20:49:39 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412145702.GB30714@castle.DHCP.thefacebook.com>
 <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
From: Vijayanand Jitta <vjitta@codeaurora.org>
Message-ID: <69b4dcd8-1925-e0e8-d9b4-776f3405b769@codeaurora.org>
Date: Wed, 25 Apr 2018 09:19:29 +0530
MIME-Version: 1.0
In-Reply-To: <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>, Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>



On 4/13/2018 5:43 PM, vinayak menon wrote:
> On Thu, Apr 12, 2018 at 8:27 PM, Roman Gushchin <guro@fb.com> wrote:
>> On Thu, Apr 12, 2018 at 08:52:52AM +0200, Vlastimil Babka wrote:
>>> On 04/11/2018 03:56 PM, Roman Gushchin wrote:
>>>> On Wed, Apr 11, 2018 at 03:16:08PM +0200, Vlastimil Babka wrote:
>>>>> [+CC linux-api]
>>>>>
>>>>> On 03/05/2018 02:37 PM, Roman Gushchin wrote:
>>>>>> This patch introduces a concept of indirectly reclaimable memory
>>>>>> and adds the corresponding memory counter and /proc/vmstat item.
>>>>>>
>>>>>> Indirectly reclaimable memory is any sort of memory, used by
>>>>>> the kernel (except of reclaimable slabs), which is actually
>>>>>> reclaimable, i.e. will be released under memory pressure.
>>>>>>
>>>>>> The counter is in bytes, as it's not always possible to
>>>>>> count such objects in pages. The name contains BYTES
>>>>>> by analogy to NR_KERNEL_STACK_KB.
>>>>>>
>>>>>> Signed-off-by: Roman Gushchin <guro@fb.com>
>>>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>>>> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
>>>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>>>> Cc: linux-fsdevel@vger.kernel.org
>>>>>> Cc: linux-kernel@vger.kernel.org
>>>>>> Cc: linux-mm@kvack.org
>>>>>> Cc: kernel-team@fb.com
>>>>>
>>>>> Hmm, looks like I'm late and this user-visible API change was just
>>>>> merged. But it's for rc1, so we can still change it, hopefully?
>>>>>
>>>>> One problem I see with the counter is that it's in bytes, but among
>>>>> counters that use pages, and the name doesn't indicate it.
>>>>
>>>> Here I just followed "nr_kernel_stack" path, which is measured in kB,
>>>> but this is not mentioned in the field name.
>>>
>>> Oh, didn't know. Bad example to follow :P
>>>
>>>>> Then, I don't
>>>>> see why users should care about the "indirectly" part, as that's just an
>>>>> implementation detail. It is reclaimable and that's what matters, right?
>>>>> (I also wanted to complain about lack of Documentation/... update, but
>>>>> looks like there's no general file about vmstat, ugh)
>>>>
>>>> I agree, that it's a bit weird, and it's probably better to not expose
>>>> it at all; but this is how all vm counters work. We do expose them all
>>>> in /proc/vmstat. A good number of them is useless until you are not a
>>>> mm developer, so it's arguable more "debug info" rather than "api".
>>>
>>> Yeah the problem is that once tools start rely on them, they fall under
>>> the "do not break userspace" rule, however we call them. So being
>>> cautious and conservative can't hurt.
>>>
>>>> It's definitely not a reason to make them messy.
>>>> Does "nr_indirectly_reclaimable_bytes" look better to you?
>>>
>>> It still has has the "indirecly" part and feels arbitrary :/
>>>
>>>>>
>>>>> I also kind of liked the idea from v1 rfc posting that there would be a
>>>>> separate set of reclaimable kmalloc-X caches for these kind of
>>>>> allocations. Besides accounting, it should also help reduce memory
>>>>> fragmentation. The right variant of cache would be detected via
>>>>> __GFP_RECLAIMABLE.
>>>>
>>>> Well, the downside is that we have to introduce X new caches
>>>> just for this particular problem. I'm not strictly against the idea,
>>>> but not convinced that it's much better.
>>>
>>> Maybe we can find more cases that would benefit from it. Heck, even slab
>>> itself allocates some management structures from the generic kmalloc
>>> caches, and if they are used for reclaimable caches, they could be
>>> tracked as reclaimable as well.
>>
>> This is a good catch!
>>
>>>
>>>>>
>>>>> With that in mind, can we at least for now put the (manually maintained)
>>>>> byte counter in a variable that's not directly exposed via /proc/vmstat,
>>>>> and then when printing nr_slab_reclaimable, simply add the value
>>>>> (divided by PAGE_SIZE), and when printing nr_slab_unreclaimable,
>>>>> subtract the same value. This way we would be simply making the existing
>>>>> counters more precise, in line with their semantics.
>>>>
>>>> Idk, I don't like the idea of adding a counter outside of the vm counters
>>>> infrastructure, and I definitely wouldn't touch the exposed
>>>> nr_slab_reclaimable and nr_slab_unreclaimable fields.
>>>
>>> We would be just making the reported values more precise wrt reality.
>>
>> It depends on if we believe that only slab memory can be reclaimable
>> or not. If yes, this is true, otherwise not.
>>
>> My guess is that some drivers (e.g. networking) might have buffers,
>> which are reclaimable under mempressure, and are allocated using
>> the page allocator. But I have to look closer...
>>
> 
> One such case I have encountered is that of the ION page pool. The page pool
> registers a shrinker. When not in any memory pressure page pool can go high
> and thus cause an mmap to fail when OVERCOMMIT_GUESS is set. I can send
> a patch to account ION page pool pages in NR_INDIRECTLY_RECLAIMABLE_BYTES.
> 
> Thanks,
> Vinayak
> 

As Vinayak mentioned NR_INDIRECTLY_RECLAIMABLE_BYTES can be used to solve the issue
with ION page pool when OVERCOMMIT_GUESS is set, the patch for the same can be 
found here https://lkml.org/lkml/2018/4/24/1288
