Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4946B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 19:15:10 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id di3so70276545pab.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 16:15:10 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id ab11si1460997pac.38.2016.06.02.16.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 16:15:09 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id g64so36716986pfb.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 16:15:08 -0700 (PDT)
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox> <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527051432.GF2322@bbox> <20160527060839.GC13661@js1304-P5Q-DELUXE>
 <20160527081108.GG2322@bbox>
 <aa33f1e4-5a91-aaaf-70f1-557148b29b38@linaro.org>
 <20160530061117.GB28624@bbox>
 <b8858801-af06-9b80-1b29-f9ece515d1bf@linaro.org>
 <20160602050039.GA3304@bbox>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <aa2d97a8-d90c-9f81-00ee-55aab665a514@linaro.org>
Date: Thu, 2 Jun 2016 16:15:02 -0700
MIME-Version: 1.0
In-Reply-To: <20160602050039.GA3304@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 6/1/2016 10:00 PM, Minchan Kim wrote:
> On Wed, Jun 01, 2016 at 01:40:48PM -0700, Shi, Yang wrote:
>> On 5/29/2016 11:11 PM, Minchan Kim wrote:
>>> On Fri, May 27, 2016 at 11:16:41AM -0700, Shi, Yang wrote:
>>>
>>> <snip>
>>>
>>>>>
>>>>> If we goes this way, how to guarantee this race?
>>>>
>>>> Thanks for pointing out this. It sounds reasonable. However, this
>>>> should be only possible to happen on 32 bit since just 32 bit
>>>> version page_is_idle() calls lookup_page_ext(), it doesn't do it on
>>>> 64 bit.
>>>>
>>>> And, such race condition should exist regardless of whether DEBUG_VM
>>>> is enabled or not, right?
>>>>
>>>> rcu might be good enough to protect it.
>>>>
>>>> A quick fix may look like:
>>>>
>>>> diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
>>>> index 8f5d4ad..bf0cd6a 100644
>>>> --- a/include/linux/page_idle.h
>>>> +++ b/include/linux/page_idle.h
>>>> @@ -77,8 +77,12 @@ static inline bool
>>>> test_and_clear_page_young(struct page *page)
>>>> static inline bool page_is_idle(struct page *page)
>>>> {
>>>>        struct page_ext *page_ext;
>>>> +
>>>> +       rcu_read_lock();
>>>>        page_ext = lookup_page_ext(page);
>>>> +       rcu_read_unlock();
>>>> +
>>>> 	if (unlikely(!page_ext))
>>>>                return false;
>>>>
>>>> diff --git a/mm/page_ext.c b/mm/page_ext.c
>>>> index 56b160f..94927c9 100644
>>>> --- a/mm/page_ext.c
>>>> +++ b/mm/page_ext.c
>>>> @@ -183,7 +183,6 @@ struct page_ext *lookup_page_ext(struct page *page)
>>>> {
>>>>        unsigned long pfn = page_to_pfn(page);
>>>>        struct mem_section *section = __pfn_to_section(pfn);
>>>> -#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
>>>>        /*
>>>>         * The sanity checks the page allocator does upon freeing a
>>>>         * page can reach here before the page_ext arrays are
>>>> @@ -195,7 +194,7 @@ struct page_ext *lookup_page_ext(struct page *page)
>>>>         */
>>>>        if (!section->page_ext)
>>>>                return NULL;
>>>> -#endif
>>>> +
>>>>        return section->page_ext + pfn;
>>>> }
>>>>
>>>> @@ -279,7 +278,8 @@ static void __free_page_ext(unsigned long pfn)
>>>>                return;
>>>>        base = ms->page_ext + pfn;
>>>>        free_page_ext(base);
>>>> -       ms->page_ext = NULL;
>>>> +       rcu_assign_pointer(ms->page_ext, NULL);
>>>> +       synchronize_rcu();
>>>
>>> How does it fix the problem?
>>> I cannot understand your point.
>>
>> Assigning NULL pointer to page_Ext will be blocked until
>> rcu_read_lock critical section is done, so the lookup and writing
>> operations will be serialized. And, rcu_read_lock disables preempt
>> too.
>
> I meant your rcu_read_lock in page_idle should cover test_bit op.

Yes, definitely. Thanks for catching it.

> One more thing, you should use rcu_dereference.

I will check which one is the best since I saw some use rcu_assign_pointer.

>
> As well, please cover memory onlining case I mentioned in another
> thread as well as memory offlining.

I will look into it too.

Thanks,
Yang

>
> Anyway, to me, every caller of page_ext should prepare lookup_page_ext
> can return NULL anytime and they should use rcu_read_[un]lock, which
> is not good. :(
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
