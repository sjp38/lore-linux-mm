Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6B86B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 06:40:41 -0400 (EDT)
Received: by padev16 with SMTP id ev16so66913947pad.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 03:40:40 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ia5si49722244pbc.172.2015.06.26.03.40.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 03:40:40 -0700 (PDT)
Message-ID: <558D2B8B.1060901@huawei.com>
Date: Fri, 26 Jun 2015 18:38:03 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com> <557691E0.5020203@jp.fujitsu.com> <5576BA2B.6060907@huawei.com> <5577A9A9.7010108@jp.fujitsu.com> <558BCD95.2090201@huawei.com> <558C94BB.1060304@jp.fujitsu.com> <558CAE43.4090702@huawei.com> <558D0E9B.8030405@jp.fujitsu.com>
In-Reply-To: <558D0E9B.8030405@jp.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/26 16:34, Kamezawa Hiroyuki wrote:

> On 2015/06/26 10:43, Xishi Qiu wrote:
>> On 2015/6/26 7:54, Kamezawa Hiroyuki wrote:
>>
>>> On 2015/06/25 18:44, Xishi Qiu wrote:
>>>> On 2015/6/10 11:06, Kamezawa Hiroyuki wrote:
>>>>
>>>>> On 2015/06/09 19:04, Xishi Qiu wrote:
>>>>>> On 2015/6/9 15:12, Kamezawa Hiroyuki wrote:
>>>>>>
>>>>>>> On 2015/06/04 22:04, Xishi Qiu wrote:
>>>>>>>> Add the buddy system interface for address range mirroring feature.
>>>>>>>> Allocate mirrored pages in MIGRATE_MIRROR list. If there is no mirrored pages
>>>>>>>> left, use other types pages.
>>>>>>>>
>>>>>>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>>>>>>> ---
>>>>>>>>      mm/page_alloc.c | 40 +++++++++++++++++++++++++++++++++++++++-
>>>>>>>>      1 file changed, 39 insertions(+), 1 deletion(-)
>>>>>>>>
>>>>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>>>>> index d4d2066..0fb55288 100644
>>>>>>>> --- a/mm/page_alloc.c
>>>>>>>> +++ b/mm/page_alloc.c
>>>>>>>> @@ -599,6 +599,26 @@ static inline bool is_mirror_pfn(unsigned long pfn)
>>>>>>>>
>>>>>>>>          return false;
>>>>>>>>      }
>>>>>>>> +
>>>>>>>> +static inline bool change_to_mirror(gfp_t gfp_flags, int high_zoneidx)
>>>>>>>> +{
>>>>>>>> +    /*
>>>>>>>> +     * Do not alloc mirrored memory below 4G, because 0-4G is
>>>>>>>> +     * all mirrored by default, and the list is always empty.
>>>>>>>> +     */
>>>>>>>> +    if (high_zoneidx < ZONE_NORMAL)
>>>>>>>> +        return false;
>>>>>>>> +
>>>>>>>> +    /* Alloc mirrored memory for only kernel */
>>>>>>>> +    if (gfp_flags & __GFP_MIRROR)
>>>>>>>> +        return true;
>>>>>>>
>>>>>>> GFP_KERNEL itself should imply mirror, I think.
>>>>>>>
>>>>>>
>>>>>> Hi Kame,
>>>>>>
>>>>>> How about like this: #define GFP_KERNEL (__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_MIRROR) ?
>>>>>>
>>>>>
>>>>> Hm.... it cannot cover GFP_ATOMIC at el.
>>>>>
>>>>> I guess, mirrored memory should be allocated if !__GFP_HIGHMEM or !__GFP_MOVABLE
>>>>
>>>>
>>>> Hi Kame,
>>>>
>>>> Can we distinguish allocations form user or kernel only by GFP flags?
>>>>
>>>
>>> Allocation from user and file caches are now *always* done with __GFP_MOVABLE.
>>>
>>> By this, pages will be allocated from MIGRATE_MOVABLE migration type.
>>> MOVABLE migration type means it's can
>>> be the target for page compaction or memory-hot-remove.
>>>
>>> Thanks,
>>> -Kame
>>>
>>
>> So if we want all kernel memory allocated from mirror, how about change like this?
>> __alloc_pages_nodemask()
>>    gfpflags_to_migratetype()
>>      if (!(gfp_mask & __GFP_MOVABLE))
>>     return MIGRATE_MIRROR
> 
> Maybe used with jump label can reduce performance impact.

Hi Kame,

I am not understand jump label, but I wil try.

> ==
> static inline bool memory_mirror_enabled(void)
> {
>         return static_key_false(&memory_mirror_enabled);
> }
> 
> 
> 
> gfpflags_to_migratetype()
>   if (memory_mirror_enabled()) { /* We want to mirror all unmovable pages */
>       if (!(gfp_mask & __GFP_MOVABLE))
>            return MIGRATE_MIRROR
>   }
> ==
> 
> BTW, I think current memory compaction code scans ranges of MOVABLE migrate type.
> So, if you use other migration type than MOVABLE for user pages, you may see
> page fragmentation. If you want to expand this MIRROR to user pages, please check
> mm/compaction.c
> 

As Tony said "how can we minimize the run-time impact on systems that don't have
any mirrored memory.", I think the idea "kernel only from MIRROR / user only from
MOVABLE" may be better.

Thanks,
Xishi Qiu



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
