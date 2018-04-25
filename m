Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51D7F6B000C
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 13:04:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d4-v6so93256wrn.15
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:04:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y27si3529743edl.345.2018.04.25.10.04.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Apr 2018 10:04:47 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412145702.GB30714@castle.DHCP.thefacebook.com>
 <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
 <69b4dcd8-1925-e0e8-d9b4-776f3405b769@codeaurora.org>
 <20180425125211.GB3410@castle> <db71bf8f-0c76-e304-25c3-d22f1e0d71e5@suse.cz>
 <20180425164845.GA7223@castle>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7fc2986e-b867-eb32-9124-d10ef6c1a3a3@suse.cz>
Date: Wed, 25 Apr 2018 19:02:42 +0200
MIME-Version: 1.0
In-Reply-To: <20180425164845.GA7223@castle>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Vijayanand Jitta <vjitta@codeaurora.org>, vinayak menon <vinayakm.list@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On 04/25/2018 06:48 PM, Roman Gushchin wrote:
> On Wed, Apr 25, 2018 at 05:47:26PM +0200, Vlastimil Babka wrote:
>> On 04/25/2018 02:52 PM, Roman Gushchin wrote:
>>> On Wed, Apr 25, 2018 at 09:19:29AM +0530, Vijayanand Jitta wrote:
>>>>>>>> Idk, I don't like the idea of adding a counter outside of the vm counters
>>>>>>>> infrastructure, and I definitely wouldn't touch the exposed
>>>>>>>> nr_slab_reclaimable and nr_slab_unreclaimable fields.
>>>>>>>
>>>>>>> We would be just making the reported values more precise wrt reality.
>>>>>>
>>>>>> It depends on if we believe that only slab memory can be reclaimable
>>>>>> or not. If yes, this is true, otherwise not.
>>>>>>
>>>>>> My guess is that some drivers (e.g. networking) might have buffers,
>>>>>> which are reclaimable under mempressure, and are allocated using
>>>>>> the page allocator. But I have to look closer...
>>>>>>
>>>>>
>>>>> One such case I have encountered is that of the ION page pool. The page pool
>>>>> registers a shrinker. When not in any memory pressure page pool can go high
>>>>> and thus cause an mmap to fail when OVERCOMMIT_GUESS is set. I can send
>>>>> a patch to account ION page pool pages in NR_INDIRECTLY_RECLAIMABLE_BYTES.
>>
>> FYI, we have discussed this at LSF/MM and agreed to try the kmalloc
>> reclaimable caches idea. The existing counter could then remain for page
>> allocator users such as ION. It's a bit weird to have it in bytes and
>> not pages then, IMHO. What if we hid it from /proc/vmstat now so it
>> doesn't become ABI, and later convert it to page granularity and expose
>> it under a name such as "nr_other_reclaimable" ?
> 
> I've nothing against hiding it from /proc/vmstat, as long as we keep
> the counter in place and the main issue resolved.

Sure.

> Maybe it's better to add nr_reclaimable = nr_slab_reclaimable + nr_other_reclaimable,
> which will have a simpler meaning that nr_other_reclaimable (what is other?).

"other" can be changed, sure. nr_reclaimable is possible if we change
slab to adjust that counter as well - vmstat code doesn't support
arbitrary calculations when printing.

> Thanks!
> 
