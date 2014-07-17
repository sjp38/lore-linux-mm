Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 58F4D6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 05:28:39 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so7587719wib.14
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 02:28:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ez4si24828658wic.77.2014.07.17.02.28.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 02:28:30 -0700 (PDT)
Message-ID: <53C793F0.6030707@suse.cz>
Date: Thu, 17 Jul 2014 11:14:24 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <53B6C947.1070603@suse.cz> <20140707044932.GA29236@js1304-P5Q-DELUXE> <53BAAFA5.9070403@suse.cz> <20140714062222.GA11317@js1304-P5Q-DELUXE> <53C3A7A5.9060005@suse.cz> <20140715082828.GM11317@js1304-P5Q-DELUXE> <53C4E813.7020108@suse.cz> <20140716084333.GA20359@js1304-P5Q-DELUXE> <53C65E92.2000606@suse.cz> <20140717061205.GA22418@js1304-P5Q-DELUXE>
In-Reply-To: <20140717061205.GA22418@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, Lisa Du <cldu@marvell.com>, linux-kernel@vger.kernel.org

On 07/17/2014 08:12 AM, Joonsoo Kim wrote:
>>
>> Hm I see. So what if it wasn't a special pcplist, but a special "free list"
>> where the pages would be just linked together as on pcplist, regardless of
>> order, and would not merge until the CPU that drives the memory isolation
>> process decides it is safe to flush them away. That would remove the need for
>> IPI's and provide the same guarantees I think.
>
> Looks good. It would work. I think that your solution is better than mine.
> I will implement it and test.

Thanks. But maybe there's still a good use for marking pages specially 
as isolated, and not PageBuddy with freepage_migratetype set to 
MIGRATE_ISOLATE. Why do we buddy-merge them anyway? I don't think CMA or 
memory offlining benefits from that, and it only makes the code more 
complex?
So maybe we could split isolated buddy pages to order-0 marked as 
PageIsolated and have a single per-zone list instead of order-based 
freelists?

>> Do we really need to check PageBuddy()? Could a page get marked as PageIsolate()
>> but still go to normal list instead of isolate list?
>
> Checking PageBuddy() is used for identifying page linked in normal
> list.

Ah right, forgot it walks by pfn scanning, not by traversing the free list.

> Thanks.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
