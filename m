Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 049C56B000E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 11:49:36 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v14so11072744pgq.11
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:49:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s88si809715pfa.339.2018.04.25.08.49.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Apr 2018 08:49:34 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412145702.GB30714@castle.DHCP.thefacebook.com>
 <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
 <69b4dcd8-1925-e0e8-d9b4-776f3405b769@codeaurora.org>
 <20180425125211.GB3410@castle>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <db71bf8f-0c76-e304-25c3-d22f1e0d71e5@suse.cz>
Date: Wed, 25 Apr 2018 17:47:26 +0200
MIME-Version: 1.0
In-Reply-To: <20180425125211.GB3410@castle>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Vijayanand Jitta <vjitta@codeaurora.org>
Cc: vinayak menon <vinayakm.list@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On 04/25/2018 02:52 PM, Roman Gushchin wrote:
> On Wed, Apr 25, 2018 at 09:19:29AM +0530, Vijayanand Jitta wrote:
>>>>>> Idk, I don't like the idea of adding a counter outside of the vm counters
>>>>>> infrastructure, and I definitely wouldn't touch the exposed
>>>>>> nr_slab_reclaimable and nr_slab_unreclaimable fields.
>>>>>
>>>>> We would be just making the reported values more precise wrt reality.
>>>>
>>>> It depends on if we believe that only slab memory can be reclaimable
>>>> or not. If yes, this is true, otherwise not.
>>>>
>>>> My guess is that some drivers (e.g. networking) might have buffers,
>>>> which are reclaimable under mempressure, and are allocated using
>>>> the page allocator. But I have to look closer...
>>>>
>>>
>>> One such case I have encountered is that of the ION page pool. The page pool
>>> registers a shrinker. When not in any memory pressure page pool can go high
>>> and thus cause an mmap to fail when OVERCOMMIT_GUESS is set. I can send
>>> a patch to account ION page pool pages in NR_INDIRECTLY_RECLAIMABLE_BYTES.

FYI, we have discussed this at LSF/MM and agreed to try the kmalloc
reclaimable caches idea. The existing counter could then remain for page
allocator users such as ION. It's a bit weird to have it in bytes and
not pages then, IMHO. What if we hid it from /proc/vmstat now so it
doesn't become ABI, and later convert it to page granularity and expose
it under a name such as "nr_other_reclaimable" ?

Vlastimil

> Perfect!
> This is exactly what I've expected.
> 
>>>
>>> Thanks,
>>> Vinayak
>>>
>>
>> As Vinayak mentioned NR_INDIRECTLY_RECLAIMABLE_BYTES can be used to solve the issue
>> with ION page pool when OVERCOMMIT_GUESS is set, the patch for the same can be 
>> found here https://lkml.org/lkml/2018/4/24/1288
> 
> This makes perfect sense to me.
> 
> Please, fell free to add:
> Acked-by: Roman Gushchin <guro@fb.com>
> 
> Thank you!
> 
