Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6816C6B0036
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 02:16:14 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so8602077pdb.13
        for <linux-mm@kvack.org>; Sun, 20 Jul 2014 23:16:14 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id xp3si13150921pbb.125.2014.07.20.23.16.12
        for <linux-mm@kvack.org>;
        Sun, 20 Jul 2014 23:16:13 -0700 (PDT)
Message-ID: <53CCB02A.7070301@lge.com>
Date: Mon, 21 Jul 2014 15:16:10 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
References: <53C8C290.90503@lge.com> <20140721025047.GA7707@bbox>
In-Reply-To: <20140721025047.GA7707@bbox>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?J+q5gOykgOyImCc=?= <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, =?UTF-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, 'Chanho Min' <chanho.min@lge.com>, linux-fsdevel@vger.kernel.org



2014-07-21 i??i ? 11:50, Minchan Kim i?' e,?:
> Hi Gioh,
>
> On Fri, Jul 18, 2014 at 03:45:36PM +0900, Gioh Kim wrote:
>>
>> Hi,
>>
>> For page migration of CMA, buffer-heads of lru should be dropped.
>> Please refer to https://lkml.org/lkml/2014/7/4/101 for the history.
>
> Just nit:
> Please write *problem* in description instead of URL link.
>
>>
>> I have two solution to drop bhs.
>> One is invalidating entire lru.
>
> You mean? All of percpu bh_lrus so if the system has N cpu,
> it invalidates N * 8?

Yes, every bh_lru of all cpus.

>
>> Another is searching the lru and dropping only one bh that Laura proposed
>> at https://lkml.org/lkml/2012/8/31/313.
>>
>> I'm not sure which has better performance.
>
> For whom? system or requestor of CMA?

For system performance.

>
>> So I did performance test on my cortex-a7 platform with Lmbench
>> that has "File & VM system latencies" test.
>> I am attaching the results.
>> The first line is of invalidating entire lru and the second is dropping selected bh.
>
> You mean you did Lmbench with background CMA allocation?
> Could you describe in detail?

I'm sorry not to mention the background.
I did the test without CMA allocation because I wanted to check how it affects system performance.

The first test, invalidating entire lru, is adding invalidate_bh_lrus() at alloc_contig_range().
This is not affecting system performance because alloc_contig_range() is not called
for usual file-system management.
The resulf of the first test is the *default system performance.*

The second test, dropping all bh in lru, is adding drop_buffers().
Every call of drop_buffers drops all bhs in lru of every cpu.
It can affect system performance. *But* it does not affect system performance,
because it drops only bh of migrated pages.


>
>>
>> File & VM system latencies in microseconds - smaller is better
>> -------------------------------------------------------------------------------
>> Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
>>                          Create Delete Create Delete Latency Fault  Fault  selct
>> --------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
>> 10.178.33 Linux 3.10.19   25.1   19.6   32.6   19.7  5098.0 0.666 3.45880 6.506
>> 10.178.33 Linux 3.10.19   24.9   19.5   32.3   19.4  5059.0 0.563 3.46380 6.521
>>
>>
>> I tried several times but the result tells that they are the same under 1% gap
>> except Protection Fault.
>> But the latency of Protection Fault is very small and I think it has little effect.
>>
>> Therefore we can choose anything but I choose invalidating entire lru.
>
> Not sure we can conclude like that.
>
> A few weeks ago, I saw a patch which increases bh_lrus's size.
> https://lkml.org/lkml/2014/7/4/107
> IOW, some of workloads really affects by percpu bh_lrus so it would be
> better to be careful to drain, I think.
>
> You want to argue CMA allocation is rare so the cost is marginable.
> It might but some of usecase might call it frequently with small request
> (ie, 8K, 16K).
>
> Anyway, why cannot CMA have the cost without affecting other subsystem?
> I mean it's okay for CMA to consume more time to shoot out the bh
> instead of simple all bh_lru invalidation because big order allocation is
> kinds of slow thing in the VM and everybody already know that and even
> sometime get failed so it's okay to add more code that extremly slow path.

There are 2 reasons to invalidate entire bh_lru.

1. I think CMA allocation is very rare so that invalidaing bh_lru affects the system little.
How do you think about it? My platform does not call CMA allocation often.
Is the CMA allocation or Memory-Hotplug called often?

2. Adding code in drop_buffers() can affect the system more that adding code in alloc_contig_range()
because the drop_buffers does not have a way to distinguish migrate type.
Even-though the lmbech results that it has almost the same performance.
But I am afraid that it can be changed.
As you said if bh_lru size can be changed it affects more than now.
SO I do not want to touch non-CMA related code.


>
>> The try_to_free_buffers() which is calling drop_buffers() is called by many filesystem code.
>> So I think inserting codes in drop_buffers() can affect the system.
>> And also we cannot distinguish migration type in drop_buffers().
>>
>> In alloc_contig_range() we can distinguish migration type and invalidate lru if it needs.
>> I think alloc_contig_range() is proper to deal with bh like following patch.
>>
>> Laura, can I have you name on Acked-by line?
>> Please let me represent my thanks.
>>
>> Thanks for any feedback.
>>
>> ------------------------------- 8< ----------------------------------
>>
>> >From 33c894b1bab9bc26486716f0c62c452d3a04d35d Mon Sep 17 00:00:00 2001
>> From: Gioh Kim <gioh.kim@lge.com>
>> Date: Fri, 18 Jul 2014 13:40:01 +0900
>> Subject: [PATCH] CMA/HOTPLUG: clear buffer-head lru before page migration
>>
>> The bh must be free to migrate a page at which bh is mapped.
>> The reference count of bh is increased when it is installed
>> into lru so that the bh of lru must be freed before migrating the page.
>>
>> This frees every bh of lru. We could free only bh of migrating page.
>> But searching lru costs more than invalidating entire lru.
>>
>> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
>> Acked-by: Laura Abbott <lauraa@codeaurora.org>
>> ---
>>   mm/page_alloc.c |    3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index b99643d4..3b474e0 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6369,6 +6369,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
>>          if (ret)
>>                  return ret;
>>
>> +       if (migratetype == MIGRATE_CMA || migratetype == MIGRATE_MOVABLE)
>> +               invalidate_bh_lrus();
>> +
>
> Q1. It's a only CMA problem? Memory-Hotplug is not a problem? Or other places?
>
> I mean it would be better to handle in generic way.

Only CMA and Memory-Hotplug needs it.
And I think invalidate_bh_lrus() is general.

>
> Q2. Why do you call it right before calling __alloc_contig_migrate_range?
>
> Some of pages will go bh_lrus by __alloc_contig_migrate_ranges.
> In that case, it is useless without caller's retry logic.
> Even you do it from caller's retrial logic, it's not a good idea because
> you makes new binding alloc_contig_range and uppder layer.
>
> So, IMHO, it would be better to handle it in migrate_pages.
> Maybe we could define new API try_to_drop_buffers which calls
> try_to_free_buffers and then only if the function fails due to
> percpu lru count, we could drain only the bh in percpu lru list instead of
> all bh draining. And places in migration path should use it rather than
> try_to_relese_page.
>
> But the problem from this approach invents new API which should be
> maintained so not sure Andrew think it's worth.
> Maybe we should see the code and diffstat.

I also consider to making new function, drop_bh_of_migrate_page in migrate_page(), just before unmap_and_move().
The migrate_page() has an argument reason that distinguish migrate-type, MR_CMA or MR_MEMORY_HOTPLUG or others.

But I DO NOT WATN TO touch non-CMA related code.
Current CMA and Memory-Hotplug code is not mature so that I am not sure it is ok to touch non-CMA related code for CMA/MemoryHotplug.


My point is:
1. CMA/Memory-hotplug is rare and invalidating bh-lru is also rare.
2. Only change CMA/Memory-hotplig related code.

>
> Overenginnering?
>
>>          ret = __alloc_contig_migrate_range(&cc, start, end);
>>          if (ret)
>>                  goto done;
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
