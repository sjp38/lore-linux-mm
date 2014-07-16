Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 980736B0071
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 07:14:34 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so1111881wib.4
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 04:14:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id et2si20052059wib.13.2014.07.16.04.14.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 04:14:33 -0700 (PDT)
Message-ID: <53C65E92.2000606@suse.cz>
Date: Wed, 16 Jul 2014 13:14:26 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <53B6C947.1070603@suse.cz> <20140707044932.GA29236@js1304-P5Q-DELUXE> <53BAAFA5.9070403@suse.cz> <20140714062222.GA11317@js1304-P5Q-DELUXE> <53C3A7A5.9060005@suse.cz> <20140715082828.GM11317@js1304-P5Q-DELUXE> <53C4E813.7020108@suse.cz> <20140716084333.GA20359@js1304-P5Q-DELUXE>
In-Reply-To: <20140716084333.GA20359@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, Lisa Du <cldu@marvell.com>, linux-kernel@vger.kernel.org

On 07/16/2014 10:43 AM, Joonsoo Kim wrote:
>> I think your plan of multiple parallel CMA allocations (and thus
>> multiple parallel isolations) is also possible. The isolate pcplists
>> can be shared by pages coming from multiple parallel isolations. But
>> the flush operation needs a pfn start/end parameters to only flush
>> pages belonging to the given isolation. That might mean a bit of
>> inefficient list traversing, but I don't think it's a problem.
> 
> I think that special pcplist would cause a problem if we should check
> pfn range. If there are too many pages on this pcplist, move pages from
> this pcplist to isolate freelist takes too long time in irq context and
> system could be broken. This operation cannot be easily stopped because
> it is initiated by IPI on other cpu and starter of this IPI expect that
> all pages on other cpus' pcplist are moved properly when returning
> from on_each_cpu().
> 
> And, if there are so many pages, serious lock contention would happen
> in this case.

Hm I see. So what if it wasn't a special pcplist, but a special "free list"
where the pages would be just linked together as on pcplist, regardless of
order, and would not merge until the CPU that drives the memory isolation
process decides it is safe to flush them away. That would remove the need for
IPI's and provide the same guarantees I think.

> Anyway, my idea's key point is using PageIsolated() to distinguish
> isolated page, instead of using PageBuddy(). If page is PageIsolated(),

Is PageIsolated a completely new page flag? Those are a limited resource so I
would expect some resistance to such approach. Or a new special page->_mapcount
value? That could maybe work.

> it isn't handled as freepage although it is in buddy allocator. During free,
> page with MIGRATETYPE_ISOLATE will be marked as PageIsolated() and
> won't be merged and counted for freepage.

OK. Preventing wrong merging is the key point and this should work.

> When we move pages from normal buddy list to isolate buddy
> list, we check PageBuddy() and subtract number of PageBuddy() pages

Do we really need to check PageBuddy()? Could a page get marked as PageIsolate()
but still go to normal list instead of isolate list?

> from number of freepage. And, change page from PageBuddy() to PageIsolated()
> since it is handled as isolated page at this point. In this way, freepage
> count will be correct.
> 
> Unisolation can be done by similar approach.
> 
> I made prototype of this approach and it isn't intrusive to core
> allocator compared to my previous patchset.
> 
> Make sense?

I think so :)

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
