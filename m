Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 868776B0031
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 21:01:37 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kq14so6347129pab.34
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 18:01:37 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id v1si5434139pdn.271.2014.07.07.18.01.34
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 18:01:36 -0700 (PDT)
Message-ID: <53BB42E3.4060005@lge.com>
Date: Tue, 08 Jul 2014 10:01:23 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] mm/page_alloc: use get_onbuddy_migratetype() to
 get buddy list type
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <1404460675-24456-9-git-send-email-iamjoonsoo.kim@lge.com> <53BAC37D.3060703@suse.cz>
In-Reply-To: <53BAC37D.3060703@suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



2014-07-08 i??i ? 12:57, Vlastimil Babka i?' e,?:
> On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
>> When isolating free page, what we want to know is which list
>> the page is linked. If it is linked in isolate migratetype buddy list,
>> we can skip watermark check and freepage counting. And if it is linked
>> in CMA migratetype buddy list, we need to fixup freepage counting. For
>> this purpose, get_onbuddy_migratetype() is more fit and cheap than
>> get_pageblock_migratetype(). So use it.
>
> Hm but you made get_onbuddy_migratetype() work only with CONFIG_MEMORY_ISOLATION. And __isolate_free_page is (despite the name) not at all limited to CONFIG_MEMORY_ISOLATION.
>

Current __isolate_free_page is called by only split_free_page, and split_free_page by isolate_freepages_block.
split_free_page is called only for isolated pages now but It can be changed someday.
I think get_onbuddy_migratetype should work with any situation.

And I think the name of get_onbuddy_migratetype is confused.
Because of _onbuddy_, it might look like that the pages are buddy pages.
I think the original name _freepage_ is proper one.


>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>   mm/page_alloc.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index e1c4c3e..d9fb8bb 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1597,7 +1597,7 @@ static int __isolate_free_page(struct page *page, unsigned int order)
>>       BUG_ON(!PageBuddy(page));
>>
>>       zone = page_zone(page);
>> -    mt = get_pageblock_migratetype(page);
>> +    mt = get_onbuddy_migratetype(page);
>>
>>       if (!is_migrate_isolate(mt)) {
>>           /* Obey watermarks as if the page was being allocated */
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
