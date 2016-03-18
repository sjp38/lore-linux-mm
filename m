Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 123266B007E
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 22:23:35 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id x3so145833131pfb.1
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 19:23:35 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id xu8si9125pac.230.2016.03.17.19.23.31
        for <linux-mm@kvack.org>;
        Thu, 17 Mar 2016 19:23:34 -0700 (PDT)
Subject: Re: Suspicious error for CMA stress test
References: <56DD38E7.3050107@huawei.com> <56DDCB86.4030709@redhat.com>
 <56DE30CB.7020207@huawei.com> <56DF7B28.9060108@huawei.com>
 <CAAmzW4NDJwgq_P33Ru_X0MKXGQEnY5dr_SY1GFutPAqEUAc_rg@mail.gmail.com>
 <56E2FB5C.1040602@suse.cz> <20160314064925.GA27587@js1304-P5Q-DELUXE>
 <56E662E8.700@suse.cz> <20160314071803.GA28094@js1304-P5Q-DELUXE>
 <56E92AFC.9050208@huawei.com> <20160317065426.GA10315@js1304-P5Q-DELUXE>
 <56EA77BC.2090702@huawei.com>
 <CAAmzW4PVc+v9NVyqrHZqh6qWaJD8hrwNUVSb6G=vZ3eA76J3yQ@mail.gmail.com>
From: Hanjun Guo <guohanjun@huawei.com>
Message-ID: <56EB6206.4070802@huawei.com>
Date: Fri, 18 Mar 2016 10:03:50 +0800
MIME-Version: 1.0
In-Reply-To: <CAAmzW4PVc+v9NVyqrHZqh6qWaJD8hrwNUVSb6G=vZ3eA76J3yQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>, Laura Abbott <labbott@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Laura Abbott <lauraa@codeaurora.org>, qiuxishi <qiuxishi@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Arnd Bergmann <arnd@arndb.de>, dingtinahong <dingtianhong@huawei.com>, chenjie6@huawei.com, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/3/17 23:31, Joonsoo Kim wrote:
[...]
>>> I may find that there is a bug which was introduced by me some time
>>> ago. Could you test following change in __free_one_page() on top of
>>> Vlastimil's patch?
>>>
>>> -page_idx = pfn & ((1 << max_order) - 1);
>>> +page_idx = pfn & ((1 << MAX_ORDER) - 1);
>> I tested Vlastimil's patch + your change with stress for more than half hour, the bug
>> I reported is gone :)
> Good to hear!
>
>> I have some questions, Joonsoo, you provided a patch as following:
>>
>> diff --git a/mm/cma.c b/mm/cma.c
>> index 3a7a67b..952a8a3 100644
>> --- a/mm/cma.c
>> +++ b/mm/cma.c
>> @@ -448,7 +448,10 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
>>
>>         VM_BUG_ON(pfn + count > cma->base_pfn + cma->count);
>>
>> + mutex_lock(&cma_mutex);
>>         free_contig_range(pfn, count);
>> + mutex_unlock(&cma_mutex);
>> +
>>         cma_clear_bitmap(cma, pfn, count);
>>         trace_cma_release(pfn, pages, count);
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 7f32950..68ed5ae 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1559,7 +1559,8 @@ void free_hot_cold_page(struct page *page, bool cold)
>>          * excessively into the page allocator
>>          */
>>         if (migratetype >= MIGRATE_PCPTYPES) {
>> -           if (unlikely(is_migrate_isolate(migratetype))) {
>> +         if (is_migrate_cma(migratetype) ||
>> +             unlikely(is_migrate_isolate(migratetype))) {
>>                         free_one_page(zone, page, pfn, 0, migratetype);
>>                         goto out;
>>                 }
>>
>> This patch also works to fix the bug, why not just use this one? is there
>> any side effects for this patch? maybe there is performance issue as the
>> mutex lock is used, any other issues?
> The changes in free_hot_cold_page() would cause unacceptable performance
> problem in a big machine, because, with above change,  it takes zone->lock
> whenever freeing one page on CMA region.

Thanks for the clarify :)

Hanjun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
