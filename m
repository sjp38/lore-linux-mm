Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B45D6B0262
	for <linux-mm@kvack.org>; Mon,  9 May 2016 06:15:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id b203so369925041pfb.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 03:15:50 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id b6si36906786pfb.63.2016.05.09.03.15.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 May 2016 03:15:49 -0700 (PDT)
Message-ID: <57306038.1070907@huawei.com>
Date: Mon, 9 May 2016 18:02:32 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix pfn spans two sections in has_unmovable_pages()
References: <57304B9A.40504@huawei.com> <57305AD8.9090202@suse.cz>
In-Reply-To: <57305AD8.9090202@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux
 MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/5/9 17:39, Vlastimil Babka wrote:

> On 05/09/2016 10:34 AM, Xishi Qiu wrote:
>> If the pfn is not aligned to pageblock, the check pfn may access a next
>> pageblcok, and the next pageblock may belong to a next section. Because
>> struct page has not been alloced in the next section, so kernel panic.
>>
>> I find the caller of has_unmovable_pages() has passed a aligned pfn, so it
>> doesn't have this problem. But the earlier kernel version(e.g. v3.10) has.
>> e.g. echo xxx > /sys/devices/system/memory/soft_offline_page could trigger
>> it. The following log is from RHEL v7.1
> 
> I think has_unmovable_pages() is wrong layer where to fix such problem, as I'll explain below.
> 
>> [14111.611492] Stack:
>> [14111.611494] ffffffff8115d952 0000000000000000 01ff880c393ebe40 ffff880c7ffd9000
>> [14111.611500] ffffea0061ffffc0 ffff880c7ffd9068 0000000000000286 0000000000000001
>> [14111.611505] ffff880c393ebe10 ffffffff811c265a 000000000187ffff 0000000000000200
>> [14111.611511] Call Trace:
>> [14111.611516] [<ffffffff8115d952>] ? has_unmovable_pages+0xd2/0x130
>> [14111.611521] [<ffffffff811c265a>] set_migratetype_isolate+0xda/0x170
>> [14111.611526] [<ffffffff811c187a>] soft_offline_page+0x9a/0x590
>> [14111.611530] [<ffffffff812e7cab>] ? _kstrtoull+0x3b/0xa0
>> [14111.611535] [<ffffffff813e158f>] store_soft_offline_page+0xaf/0xf0
>> [14111.611539] [<ffffffff813cae18>] dev_attr_store+0x18/0x30
>> [14111.611544] [<ffffffff8123c046>] sysfs_write_file+0xc6/0x140
>> [14111.611548] [<ffffffff811c5b5d>] vfs_write+0xbd/0x1e0
>> [14111.611551] [<ffffffff811c65a8>] SyS_write+0x58/0xb0
>> [14111.611556] [<ffffffff8160f509>] system_call_fastpath+0x16/0x1b
>> [14111.611559] Code: 66 66 66 90 48 83 e0 fd 0c a0 5d c3 66 2e 0f 1f 84 00 00 00 00 00 48 89 f8 66 66 66 90 48 83 c8 42 0c a0 5d c3 90 66 66 66 66 90 <8b> 07 25 00 c0 00 00 75 02 f3 c3 48 8b 07 f6 c4 80 75 0f 48 81
>> [14111.611594] RIP [<ffffffff81199fc5>] PageHuge+0x5/0x40
>> [14111.611598] RSP <ffff880c393ebd80>
>> [14111.611600] CR2: ffffea0062000000
>> [14111.611604] ---[ end trace 9f780ed1def334c6 ]---
>> [14111.678586] Kernel panic - not syncing: Fatal exception
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> 
> It's not CC'd stable, so how will this patch fix the older kernels? Also you should determine which upstream kernel versions are affected, not a RHEL derivative.
> Also is the current upstream broken or not?
> 

OK, I'll resend it later. The current upstream has not this problem.

>> ---
>>   mm/page_alloc.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 59de90d..9afc1bc 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6842,6 +6842,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>>           return false;
>>
>>       pfn = page_to_pfn(page);
>> +    pfn = pfn & ~(pageblock_nr_pages - 1);
> 
> I think it's wrong that has_unmovable_pages() would silently correct wrong input. See e.g. the call path from start_isolate_page_range -> set_migratetype_isolate -> has_unmovable_pages. In start_isolate_page_range() there are BUG_ON's to check the alignment. That would be more appropriate here as well (but use VM_BUG_ON please).
> 

Yes, this path is correct.

But the older kernel like the following path has the problem.
soft_offline_page
	get_any_page
		__get_any_page
			set_migratetype_isolate
				has_unmovable_pages

> One danger of the self-correction is that the adjusted pfn might be of
> a different zone, so let's not go there. If there's a call stack that passes unaligned page, it has to be fixed higher in the stack IMHO.
>

How about change the pfn when calling set_migratetype_isolate()?
e.g. set_migratetype_isolate((p & ~(pageblock_nr_pages - 1)), true);

Thanks,
Xishi Qiu

>>       for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
>>           unsigned long check = pfn + iter;
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
