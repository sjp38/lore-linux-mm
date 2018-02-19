Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE23F6B002A
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:11:08 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id v21so10100147qka.6
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:11:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 51sor1330935qtt.47.2018.02.19.11.11.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Feb 2018 11:11:08 -0800 (PST)
Subject: Re: [PATCH] mm: Fix for PG_reserved page flag clearing
References: <d77ca418-1614-6ad3-d739-161ca737b7ec@gmail.com>
 <20180219171916.GR21134@dhcp22.suse.cz>
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Message-ID: <cdc33597-191f-1471-ce5e-9efba1bf5fe7@gmail.com>
Date: Mon, 19 Feb 2018 14:11:03 -0500
MIME-Version: 1.0
In-Reply-To: <20180219171916.GR21134@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, pasha.tatashin@oracle.com, linux-mm@kvack.org

Hello Michal, 

Mon, 19 Feb 2018 18:19:16 +0100 Michal Hocko wrote:
> On Mon 19-02-18 12:06:14, Masayoshi Mizuma wrote:
>> From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>>
>> struct page is inizialized as zero in __init_single_page().
>> If the page is offlined page, PG_reserved flag is set in early boot
>> time before __init_single_page(), so we should not clear the flag.
>>
>> The real problem is that we can not online the offlined page
>> through following sysfs operation because offlined page is
>> expected PG_reserved flag is set. 
>> It is not needed the initialization, so remove it simply.
>>
>>   Code:
>>
>>   static int online_pages_range(unsigned long start_pfn, 
>>   ...
>>           if (PageReserved(pfn_to_page(start_pfn))) <= HERE!!
>>                   for (i = 0; i < nr_pages; i++) {
>>                           page = pfn_to_page(start_pfn + i);
>>                           (*online_page_callback)(page);
>>                           onlined_pages++;
>>   sysfs operation:
>>
>>   # echo online > /sys/devices/system/node/node2/memory12288/online
>>   # cat /sys/devices/system/node/node2/memory12288/online 
>>   1
>>   # cat /sys/devices/system/node/node2/meminfo 
>>   Node 2 MemTotal:              0 kB
> 
> Nack. The patch is simply wrong. We do need to zero page for the boot
> pages. I believe the fix you are looking for is 9bb5a391f9a5 ("mm,
> memory_hotplug: fix memmap initialization"). Or do you still see a
> problem with this patch applied?

I have confirmed the problem is fixed by your patch 9bb5a391f9a5.
(I had tested it in 4.15.2, so I did not notice your patch, sorry)

Thank you for the fix!

- Masayoshi

> 
>> Fixes: f7f99100d8d9 ("mm: stop zeroing memory during allocation in vmemmap")
>> Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
>> ---
>>  mm/page_alloc.c | 1 -
>>  1 file changed, 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 76c9688..3260cd2 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1179,7 +1179,6 @@ static void free_one_page(struct zone *zone,
>>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
>>  				unsigned long zone, int nid)
>>  {
>> -	mm_zero_struct_page(page);
>>  	set_page_links(page, zone, nid, pfn);
>>  	init_page_count(page);
>>  	page_mapcount_reset(page);
>> -- 
>> 2.16.1
>>
>> - Masayoshi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
