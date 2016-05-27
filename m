Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 547BA6B0005
	for <linux-mm@kvack.org>; Fri, 27 May 2016 14:16:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so166525286pad.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 11:16:44 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id xi11si29833050pac.134.2016.05.27.11.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 11:16:43 -0700 (PDT)
Received: by mail-pa0-x233.google.com with SMTP id fy7so25706002pac.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 11:16:43 -0700 (PDT)
Subject: Re: [PATCH] mm: check the return value of lookup_page_ext for all
 call sites
References: <1464023768-31025-1-git-send-email-yang.shi@linaro.org>
 <20160524025811.GA29094@bbox> <20160526003719.GB9661@bbox>
 <8ae0197c-47b7-e5d2-20c3-eb9d01e6b65c@linaro.org>
 <20160527051432.GF2322@bbox> <20160527060839.GC13661@js1304-P5Q-DELUXE>
 <20160527081108.GG2322@bbox>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <aa33f1e4-5a91-aaaf-70f1-557148b29b38@linaro.org>
Date: Fri, 27 May 2016 11:16:41 -0700
MIME-Version: 1.0
In-Reply-To: <20160527081108.GG2322@bbox>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, Tang Chen <tangchen@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 5/27/2016 1:11 AM, Minchan Kim wrote:
> On Fri, May 27, 2016 at 03:08:39PM +0900, Joonsoo Kim wrote:
>> On Fri, May 27, 2016 at 02:14:32PM +0900, Minchan Kim wrote:
>>> On Thu, May 26, 2016 at 04:15:28PM -0700, Shi, Yang wrote:
>>>> On 5/25/2016 5:37 PM, Minchan Kim wrote:
>>>>> On Tue, May 24, 2016 at 11:58:11AM +0900, Minchan Kim wrote:
>>>>>> On Mon, May 23, 2016 at 10:16:08AM -0700, Yang Shi wrote:
>>>>>>> Per the discussion with Joonsoo Kim [1], we need check the return value of
>>>>>>> lookup_page_ext() for all call sites since it might return NULL in some cases,
>>>>>>> although it is unlikely, i.e. memory hotplug.
>>>>>>>
>>>>>>> Tested with ltp with "page_owner=0".
>>>>>>>
>>>>>>> [1] http://lkml.kernel.org/r/20160519002809.GA10245@js1304-P5Q-DELUXE
>>>>>>>
>>>>>>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>>>>>>
>>>>>> I didn't read code code in detail to see how page_ext memory space
>>>>>> allocated in boot code and memory hotplug but to me, it's not good
>>>>>> to check NULL whenever we calls lookup_page_ext.
>>>>>>
>>>>>> More dangerous thing is now page_ext is used by optionable feature(ie, not
>>>>>> critical for system stability) but if we want to use page_ext as
>>>>>> another important tool for the system in future,
>>>>>> it could be a serious problem.
>>
>> Hello, Minchan.
>
> Hi Joonsoo,
>
>>
>> I wonder how pages that isn't managed by kernel yet will cause serious
>> problem. Until onlining, these pages are out of our scope. Any
>> information about them would be useless until it is actually
>> activated. I guess that returning NULL for those pages will not hurt
>> any functionality. Do you have any possible scenario that this causes the
>> serious problem?
>
> I don't have any specific usecase now. That's why I said "in future".
> And I don't want to argue whether there is possible scenario or not
> to make the feature useful but if you want, I should write novel.
> One of example, pop up my mind, xen, hv and even memory_hotplug itself
> might want to use page_ext for their functionality extension to hook
> guest pages.
>
> My opinion is that page_ext is extension of struct page so it would
> be better to allow any operation on struct page without any limitation
> if we can do it. Whether it's useful or useless depend on random
> usecase and we don't need to limit that way from the beginning.
>
> However, current design allows deferred page_ext population so any user
> of page_ext should keep it in mind and should either make fallback plan
> or don't use page_ext for those cases. If we decide go this way through
> discussion, at least, we should make such limitation more clear to
> somewhere in this chance, maybe around page_ext_operation->need comment.
>
> My comment's point is that we should consider that way at least. It's
> worth to discuss pros and cons, what's the best and what makes that way
> hesitate if we can't.
>
>>
>> And, allocation such memory space doesn't come from free. If someone
>> just add the memory device and don't online it, these memory will be
>
> Here goes several questions.
> Cced hotplug guys
>
> 1.
> If someone just add the memory device without onlining, kernel code
> can return pfn_valid == true on the offlined page?
>
> 2.
> If so, it means memmap on offline memory is already populated somewhere.
> Where is the memmap allocated? part of offlined memory space or other memory?
>
> 3. Could we allocate page_ext in part of offline memory space so that
> it doesn't consume online memory.
>
>> wasted. I don't know if there is such a usecase but it's possible
>> scenario.
>
>>
>>>>>>
>>>>>> Can we put some hooks of page_ext into memory-hotplug so guarantee
>>>>>> that page_ext memory space is allocated with memmap space at the
>>>>>> same time? IOW, once every PFN wakers find a page is valid, page_ext
>>>>>> is valid, too so lookup_page_ext never returns NULL on valid page
>>>>>> by design.
>>>>>>
>>>>>> I hope we consider this direction, too.
>>>>>
>>>>> Yang, Could you think about this?
>>>>
>>>> Thanks a lot for the suggestion. Sorry for the late reply, I was
>>>> busy on preparing patches. I do agree this is a direction we should
>>>> look into, but I haven't got time to think about it deeper. I hope
>>>> Joonsoo could chime in too since he is the original author for page
>>>> extension.
>>>>
>>>>>
>>>>> Even, your patch was broken, I think.
>>>>> It doesn't work with !CONFIG_DEBUG_VM && !CONFIG_PAGE_POISONING because
>>>>> lookup_page_ext doesn't return NULL in that case.
>>>>
>>>> Actually, I think the #ifdef should be removed if lookup_page_ext()
>>>> is possible to return NULL. It sounds not make sense returning NULL
>>>> only when DEBUG_VM is enabled. It should return NULL no matter what
>>>> debug config is selected. If Joonsoo agrees with me I'm going to
>>>> come up with a patch to fix it.
>>
>> Agreed but let's wait for Minchan's response.
>
> If we goes this way, how to guarantee this race?

Thanks for pointing out this. It sounds reasonable. However, this should 
be only possible to happen on 32 bit since just 32 bit version 
page_is_idle() calls lookup_page_ext(), it doesn't do it on 64 bit.

And, such race condition should exist regardless of whether DEBUG_VM is 
enabled or not, right?

rcu might be good enough to protect it.

A quick fix may look like:

diff --git a/include/linux/page_idle.h b/include/linux/page_idle.h
index 8f5d4ad..bf0cd6a 100644
--- a/include/linux/page_idle.h
+++ b/include/linux/page_idle.h
@@ -77,8 +77,12 @@ static inline bool test_and_clear_page_young(struct 
page *page)
  static inline bool page_is_idle(struct page *page)
  {
         struct page_ext *page_ext;
+
+       rcu_read_lock();
         page_ext = lookup_page_ext(page);
+       rcu_read_unlock();
+
	if (unlikely(!page_ext))
                 return false;

diff --git a/mm/page_ext.c b/mm/page_ext.c
index 56b160f..94927c9 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -183,7 +183,6 @@ struct page_ext *lookup_page_ext(struct page *page)
  {
         unsigned long pfn = page_to_pfn(page);
         struct mem_section *section = __pfn_to_section(pfn);
-#if defined(CONFIG_DEBUG_VM) || defined(CONFIG_PAGE_POISONING)
         /*
          * The sanity checks the page allocator does upon freeing a
          * page can reach here before the page_ext arrays are
@@ -195,7 +194,7 @@ struct page_ext *lookup_page_ext(struct page *page)
          */
         if (!section->page_ext)
                 return NULL;
-#endif
+
         return section->page_ext + pfn;
  }

@@ -279,7 +278,8 @@ static void __free_page_ext(unsigned long pfn)
                 return;
         base = ms->page_ext + pfn;
         free_page_ext(base);
-       ms->page_ext = NULL;
+       rcu_assign_pointer(ms->page_ext, NULL);
+       synchronize_rcu();
  }

  static int __meminit online_page_ext(unsigned long start_pfn,

Thanks,
Yang

>
>                                 kpageflags_read
>                                 stable_page_flags
>                                 page_is_idle
>                                   lookup_page_ext
>                                   section = __pfn_to_section(pfn)
> offline_pages
> memory_notify(MEM_OFFLINE)
>   offline_page_ext
>   ms->page_ext = NULL
>                                   section->page_ext + pfn
>
>>
>> Thanks.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
