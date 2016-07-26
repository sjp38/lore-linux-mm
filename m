Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 11E5F6B025E
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 05:32:17 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j124so13216533ith.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 02:32:17 -0700 (PDT)
Received: from szxga02-in.huawei.com ([119.145.14.65])
        by mx.google.com with ESMTPS id q72si18691895itc.67.2016.07.26.02.32.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 02:32:16 -0700 (PDT)
Message-ID: <57972DD3.3050909@huawei.com>
Date: Tue, 26 Jul 2016 17:30:59 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: walk the zone in pageblock_nr_pages steps
References: <1469502526-24486-1-git-send-email-zhongjiang@huawei.com> <7fcafdb1-86fa-9245-674b-db1ae53d1c77@suse.cz> <57971FDE.20507@huawei.com> <473964c8-23cd-cee7-b25c-6ef020547b9a@suse.cz>
In-Reply-To: <473964c8-23cd-cee7-b25c-6ef020547b9a@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 2016/7/26 16:53, Vlastimil Babka wrote:
> On 07/26/2016 10:31 AM, zhong jiang wrote:
>> On 2016/7/26 14:24, Vlastimil Babka wrote:
>>> On 07/26/2016 05:08 AM, zhongjiang wrote:
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> when walking the zone, we can happens to the holes. we should
>>>> not align MAX_ORDER_NR_PAGES, so it can skip the normal memory.
>>>>
>>>> In addition, pagetypeinfo_showmixedcount_print reflect
>>>> fragmentization. we hope to get more accurate data. therefore, I
>>>> decide to fix it.
>>>
>>> Can't say I'm happy with another random half-fix. What's the real
>>> granularity of holes for CONFIG_HOLES_IN_ZONE systems? I suspect it
>>> can be below pageblock_nr_pages. The pfn_valid_within() mechanism
>>> seems rather insufficient... it does prevent running unexpectedly
>>> into holes in the middle of pageblock/MAX_ORDER block, but together
>>> with the large skipping it doesn't guarantee that we cover all
>>> non-holes.
>>>
>> I am sorry for that. I did not review the whole code before sending
>> above patch.  In arch of x86, The real granularity of holes is in
>> 256, that is a section.
>
> Huh, x86 doesn't even have CONFIG_HOLES_IN_ZONE? So any pfn valid within MAX_ORDER_NR_PAGES (and within zone boundaries?) should mean the whole range is valid? AFAICS only ia64, mips and s390 has CONFIG_HOLES_IN_ZONE.
>
> Maybe I misunderstand... can you help by demonstrating on which arch and configuration your patch makes a difference?
>
 a x86 arch ,for example, when CONFIG_HOLES_IN_ZONE disable, hole punch is not existence. we scan the zone in the way of pageblock ,compared with the MAX_ORDER_NR_PAGES, it should be more resonable.
 when CONFIG_HOLES_IN_ZONE enable, hole punch is existence. it will prevent the rest 2M to be skipped. you can get from code that we prefer to align with pageblock.
>> while in arm64, we can see that the hole is
>> identify by located in SYSTEM_RAM. I admit that that is not a best
>> way. but at present, it's a better way to amend.
>>> I think in a robust solution, functions such as these should use
>>> something like PAGE_HOLE_GRANULARITY which equals
>>> MAX_ORDER_NR_PAGES for !CONFIG_HOLES_IN_ZONE and some
>>> arch/config/system specific value for CONFIG_HOLES_IN_ZONE. This
>>> would then be used in the ALIGN() part. It could be also used
>>> together with pfn_valid_within() in the inner loop to skip over
>>> holes more quickly (if it's worth).
>>>
>> Maybe reimplement the code about hole punch is a better way.
>>> Also I just learned there's also CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
>>> that affects a function called memmap_valid_within(). But that one
>>> has only one caller - pagetypeinfo_showblockcount_print(). Why is
>>> it needed there and not in pagetypeinfo_showmixedcount_print() (or
>>> anywhere else?)
>>>
>> yes, but in other place, for example, the caller
>> apagetypeinfo_showmixedcount_print you can see the
>> commit.(91c43c7313a995a8908f8f6b911a85d00fdbffd)
>
> Hmm I don't see such commit in linus.git, mmotm or linux-next trees.
>
>>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com> ---
>>>> mm/vmstat.c | 2 +- 1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/mm/vmstat.c b/mm/vmstat.c index cb2a67b..3508f74
>>>> 100644 --- a/mm/vmstat.c +++ b/mm/vmstat.c @@ -1033,7 +1033,7 @@
>>>> static void pagetypeinfo_showmixedcount_print(struct seq_file
>>>> *m, */ for (; pfn < end_pfn; ) { if (!pfn_valid(pfn)) { -
>>>> pfn = ALIGN(pfn + 1, MAX_ORDER_NR_PAGES); +            pfn =
>>>> ALIGN(pfn + 1, pageblock_nr_pages); continue; }
>>>>
>>>>
>>>
>>> -- To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM, see:
>>> http://www.linux-mm.org/ . Don't email: <a
>>> href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>>
>>>
>>
>>
>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
