Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFDF6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 04:32:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so458508882pfb.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 01:32:46 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id h185si38177347pfg.282.2016.07.26.01.32.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 01:32:45 -0700 (PDT)
Message-ID: <57971FDE.20507@huawei.com>
Date: Tue, 26 Jul 2016 16:31:26 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: Re: [PATCH] mm: walk the zone in pageblock_nr_pages steps
References: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com> <7fcafdb1-86fa-9245-674b-db1ae53d1c77@suse.cz>
In-Reply-To: <7fcafdb1-86fa-9245-674b-db1ae53d1c77@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2016/7/26 14:24, Vlastimil Babka wrote:
> On 07/26/2016 05:08 AM, zhongjiang wrote:
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> when walking the zone, we can happens to the holes. we should not
>> align MAX_ORDER_NR_PAGES, so it can skip the normal memory.
>>
>> In addition, pagetypeinfo_showmixedcount_print reflect fragmentization.
>> we hope to get more accurate data. therefore, I decide to fix it.
>
> Can't say I'm happy with another random half-fix. What's the real granularity of holes for CONFIG_HOLES_IN_ZONE systems? I suspect it can be below pageblock_nr_pages. The pfn_valid_within() mechanism seems rather insufficient... it does prevent running unexpectedly into holes in the middle of pageblock/MAX_ORDER block, but together with the large skipping it doesn't guarantee that we cover all non-holes.
>
  I am sorry for that. I did not review the whole code before sending above patch.  In arch of x86, The real granularity of holes is in 256, that is a section. while in arm64, we can see that the hole is identify by located in
  SYSTEM_RAM. I admit that that is not a best way. but at present, it's a better way to amend.
> I think in a robust solution, functions such as these should use something like PAGE_HOLE_GRANULARITY which equals MAX_ORDER_NR_PAGES for !CONFIG_HOLES_IN_ZONE and some arch/config/system specific value for CONFIG_HOLES_IN_ZONE. This would then be used in the ALIGN() part.
> It could be also used together with pfn_valid_within() in the inner loop to skip over holes more quickly (if it's worth).
>
 Maybe reimplement the code about hole punch is a better way.
> Also I just learned there's also CONFIG_ARCH_HAS_HOLES_MEMORYMODEL that affects a function called memmap_valid_within(). But that one has only one caller - pagetypeinfo_showblockcount_print(). Why is it needed there and not in pagetypeinfo_showmixedcount_print() (or anywhere else?)
>
 yes, but in other place, for example, the caller apagetypeinfo_showmixedcount_print you can see the commit.(91c43c7313a995a8908f8f6b911a85d00fdbffd)
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/vmstat.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/vmstat.c b/mm/vmstat.c
>> index cb2a67b..3508f74 100644
>> --- a/mm/vmstat.c
>> +++ b/mm/vmstat.c
>> @@ -1033,7 +1033,7 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
>>       */
>>      for (; pfn < end_pfn; ) {
>>          if (!pfn_valid(pfn)) {
>> -            pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES);
>> +            pfn = ALIGN(pfn + 1, pageblock_nr_pages);
>>              continue;
>>          }
>>
>>
>
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
