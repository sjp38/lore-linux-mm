Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0FABD8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 22:49:47 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id p79so2122244qki.15
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 19:49:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y186sor28910250qkd.21.2019.01.07.19.49.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 19:49:45 -0800 (PST)
Subject: Re: [PATCH v2] kmemleak: survive in a low-memory situation
From: Qian Cai <cai@lca.pw>
References: <20190102165931.GB6584@arrakis.emea.arm.com>
 <20190102180619.12392-1-cai@lca.pw> <20190103093201.GB31793@dhcp22.suse.cz>
 <9197d86b-a684-c7f4-245b-63c890f1104f@lca.pw>
 <20190103170735.GV31793@dhcp22.suse.cz> <20190107104314.uugftsqcjsi5j6g2@mbp>
 <47dbc0fc-5322-10fb-a8c4-698a4b17e3b3@lca.pw>
Message-ID: <ecb5d958-1e86-7725-e271-def315265537@lca.pw>
Date: Mon, 7 Jan 2019 22:49:43 -0500
MIME-Version: 1.0
In-Reply-To: <47dbc0fc-5322-10fb-a8c4-698a4b17e3b3@lca.pw>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/7/19 9:06 PM, Qian Cai wrote:
> 
> 
> On 1/7/19 5:43 AM, Catalin Marinas wrote:
>> On Thu, Jan 03, 2019 at 06:07:35PM +0100, Michal Hocko wrote:
>>>>> On Wed 02-01-19 13:06:19, Qian Cai wrote:
>>>>> [...]
>>>>>> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
>>>>>> index f9d9dc250428..9e1aa3b7df75 100644
>>>>>> --- a/mm/kmemleak.c
>>>>>> +++ b/mm/kmemleak.c
>>>>>> @@ -576,6 +576,16 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
>>>>>>  	struct rb_node **link, *rb_parent;
>>>>>>  
>>>>>>  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
>>>>>> +#ifdef CONFIG_PREEMPT_COUNT
>>>>>> +	if (!object) {
>>>>>> +		/* last-ditch effort in a low-memory situation */
>>>>>> +		if (irqs_disabled() || is_idle_task(current) || in_atomic())
>>>>>> +			gfp = GFP_ATOMIC;
>>>>>> +		else
>>>>>> +			gfp = gfp_kmemleak_mask(gfp) | __GFP_DIRECT_RECLAIM;
>>>>>> +		object = kmem_cache_alloc(object_cache, gfp);
>>>>>> +	}
>>>>>> +#endif
>> [...]
>>> I will not object to this workaround but I strongly believe that
>>> kmemleak should rethink the metadata allocation strategy to be really
>>> robust.
>>
>> This would be nice indeed and it was discussed last year. I just haven't
>> got around to trying anything yet:
>>
>> https://marc.info/?l=linux-mm&m=152812489819532
>>
> 
> It could be helpful to apply this 10-line patch first if has no fundamental
> issue, as it survives probably 50 times running LTP oom* workloads without a
> single kmemleak allocation failure.
> 
> Of course, if someone is going to embed kmemleak metadata into slab objects
> itself soon, this workaround is not needed.
> 

Well, it is really hard to tell even if someone get eventually redesign kmemleak
to embed the metadata into slab objects alone would survive LTP oom* workloads,
because it seems still use separate metadata for non-slab objects where kmemleak
allocation could fail like it right now and disable itself again.
