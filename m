Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A3CFB6B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:53:21 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so64725239pdj.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:53:21 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id bi1si29861053pbb.130.2015.06.25.18.53.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 25 Jun 2015 18:53:20 -0700 (PDT)
Message-ID: <558CAE43.4090702@huawei.com>
Date: Fri, 26 Jun 2015 09:43:31 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 10/12] mm: add the buddy system interface
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com> <557691E0.5020203@jp.fujitsu.com> <5576BA2B.6060907@huawei.com> <5577A9A9.7010108@jp.fujitsu.com> <558BCD95.2090201@huawei.com> <558C94BB.1060304@jp.fujitsu.com>
In-Reply-To: <558C94BB.1060304@jp.fujitsu.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas
 Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/26 7:54, Kamezawa Hiroyuki wrote:

> On 2015/06/25 18:44, Xishi Qiu wrote:
>> On 2015/6/10 11:06, Kamezawa Hiroyuki wrote:
>>
>>> On 2015/06/09 19:04, Xishi Qiu wrote:
>>>> On 2015/6/9 15:12, Kamezawa Hiroyuki wrote:
>>>>
>>>>> On 2015/06/04 22:04, Xishi Qiu wrote:
>>>>>> Add the buddy system interface for address range mirroring feature.
>>>>>> Allocate mirrored pages in MIGRATE_MIRROR list. If there is no mirrored pages
>>>>>> left, use other types pages.
>>>>>>
>>>>>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>>>>>> ---
>>>>>>     mm/page_alloc.c | 40 +++++++++++++++++++++++++++++++++++++++-
>>>>>>     1 file changed, 39 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>>>>> index d4d2066..0fb55288 100644
>>>>>> --- a/mm/page_alloc.c
>>>>>> +++ b/mm/page_alloc.c
>>>>>> @@ -599,6 +599,26 @@ static inline bool is_mirror_pfn(unsigned long pfn)
>>>>>>
>>>>>>         return false;
>>>>>>     }
>>>>>> +
>>>>>> +static inline bool change_to_mirror(gfp_t gfp_flags, int high_zoneidx)
>>>>>> +{
>>>>>> +    /*
>>>>>> +     * Do not alloc mirrored memory below 4G, because 0-4G is
>>>>>> +     * all mirrored by default, and the list is always empty.
>>>>>> +     */
>>>>>> +    if (high_zoneidx < ZONE_NORMAL)
>>>>>> +        return false;
>>>>>> +
>>>>>> +    /* Alloc mirrored memory for only kernel */
>>>>>> +    if (gfp_flags & __GFP_MIRROR)
>>>>>> +        return true;
>>>>>
>>>>> GFP_KERNEL itself should imply mirror, I think.
>>>>>
>>>>
>>>> Hi Kame,
>>>>
>>>> How about like this: #define GFP_KERNEL (__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_MIRROR) ?
>>>>
>>>
>>> Hm.... it cannot cover GFP_ATOMIC at el.
>>>
>>> I guess, mirrored memory should be allocated if !__GFP_HIGHMEM or !__GFP_MOVABLE
>>
>>
>> Hi Kame,
>>
>> Can we distinguish allocations form user or kernel only by GFP flags?
>>
> 
> Allocation from user and file caches are now *always* done with __GFP_MOVABLE.
> 
> By this, pages will be allocated from MIGRATE_MOVABLE migration type.
> MOVABLE migration type means it's can
> be the target for page compaction or memory-hot-remove.
> 
> Thanks,
> -Kame
> 

So if we want all kernel memory allocated from mirror, how about change like this?
__alloc_pages_nodemask()
  gfpflags_to_migratetype()
    if (!(gfp_mask & __GFP_MOVABLE))
	return MIGRATE_MIRROR

Thanks,
Xishi Qiu

> 
> 
> 
> 
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
