Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4A06B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:38:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l1-v6so3116282edi.11
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 23:38:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a24-v6si2716761eda.125.2018.07.30.23.38.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jul 2018 23:38:02 -0700 (PDT)
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
References: <67d5e4ef-c040-6852-ad93-6f2528df0982@suse.cz>
 <20180726074219.GU28386@dhcp22.suse.cz>
 <36043c6b-4960-8001-4039-99525dcc3e05@suse.cz>
 <20180726080301.GW28386@dhcp22.suse.cz>
 <ed7090ad-5004-3133-3faf-607d2a9fa90a@suse.cz>
 <d69d7a82-5b70-051f-a517-f602c3ef1fd7@suse.cz>
 <98788618-94dc-5837-d627-8bbfa1ddea57@icdsoft.com>
 <ff19099f-e0f5-d2b2-e124-cc12d2e05dc1@icdsoft.com>
 <20180730135744.GT24267@dhcp22.suse.cz>
 <89ea4f56-6253-4f51-0fb7-33d7d4b60cfa@icdsoft.com>
 <20180730183820.GA24267@dhcp22.suse.cz>
 <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6838c342-2d07-3047-e723-2b641bc6bf79@suse.cz>
Date: Tue, 31 Jul 2018 08:38:00 +0200
MIME-Version: 1.0
In-Reply-To: <56597af4-73c6-b549-c5d5-b3a2e6441b8e@icdsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Georgi Nikolov <gnikolov@icdsoft.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On 07/30/2018 08:51 PM, Georgi Nikolov wrote:
> On 07/30/2018 09:38 PM, Michal Hocko wrote:
>> On Mon 30-07-18 18:54:24, Georgi Nikolov wrote:
>> [...]
>>> No i was wrong. The regression starts actually with 0537250fdc6c8.
>>> - old code, which opencodes kvmalloc, is masking error but error is there
>>> - kvmalloc without GFP_NORETRY works fine, but probably can consume a
>>> lot of memory - commit: eacd86ca3b036
>>> - kvmalloc with GFP_NORETRY shows error - commit: 0537250fdc6c8
>> OK.
>>
>>>>> What is correct way to fix it.
>>>>> - inside xt_alloc_table_info remove GFP_NORETRY from kvmalloc or add
>>>>> this flag only for sizes bigger than some threshold
>>>> This would reintroduce issue fixed by 0537250fdc6c8. Note that
>>>> kvmalloc(GFP_KERNEL | __GFP_NORETRY) is more or less equivalent to the
>>>> original code (well, except for __GFP_NOWARN).
>>> So probably we should pass GFP_NORETRY only for large requests (above
>>> some threshold).
>> What would be the treshold? This is not really my area so I just wanted
>> to keep the original code semantic.
>>  
>>>>> - inside kvmalloc_node remove GFP_NORETRY from
>>>>> __vmalloc_node_flags_caller (i don't know if it honors this flag, or
>>>>> the problem is elsewhere)
>>>> No, not really. This is basically equivalent to kvmalloc(GFP_KERNEL).
>>>>
>>>> I strongly suspect that this is not a regression in this code but rather
>>>> a side effect of larger memory fragmentation caused by something else.
>>>> In any case do you see this failure also without artificial test case
>>>> with a standard workload?
>>> Yes i can see failures with standard workload, in fact it was hard to
>>> reproduce it.
>>> Here is the error from production servers where allocation is smaller:
>>> iptables: vmalloc: allocation failure, allocated 131072 of 225280 bytes,
>>> mode:0x14010c0(GFP_KERNEL|__GFP_NORETRY), nodemask=(null)
>>>
>>> I didn't understand if vmalloc honors GFP_NORETRY.
>> 0537250fdc6c8 changelog tries to explain. kvmalloc doesn't really
>> support the GFP_NORETRY remantic because that would imply the request
>> wouldn't trigger the oom killer but in rare cases this might happen
>> (e.g. when page tables are allocated because those are hardcoded GFP_KERNEL).
>>
>> That being said, I have no objection to use GFP_KERNEL if it helps real
>> workloads but we probably need some cap...
> 
> Probably Vlastimil Babka can propose some limit:

No, I think that's rather for the netfilter folks to decide. However, it
seems there has been the debate already [1] and it was not found. The
conclusion was that __GFP_NORETRY worked fine before, so it should work
again after it's added back. But now we know that it doesn't...

[1] https://lore.kernel.org/lkml/20180130140104.GE21609@dhcp22.suse.cz/T/#u

> On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
> This is likely the kvmalloc() in xt_alloc_table_info(). Between 4.13 and
> 4.17 it shouldn't use __GFP_NORETRY, but looks like commit 0537250fdc6c
> ("netfilter: x_tables: make allocation less aggressive") was backported
> to 4.14. Removing __GFP_NORETRY might help here, but bring back other
> issues. Less than 4MB is not that much though, maybe find some "sane"
> limit and use __GFP_NORETRY only above that?
> 
> 
> Regards,
> 
> --
> Georgi Nikolov
> 
> 
