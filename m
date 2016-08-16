Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id A7B006B025F
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 06:30:49 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s207so200977951oie.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:30:49 -0700 (PDT)
Received: from dfwrgout.huawei.com (dfwrgout.huawei.com. [206.16.17.72])
        by mx.google.com with ESMTPS id a185si3072532oib.167.2016.08.16.03.30.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 03:30:49 -0700 (PDT)
Message-ID: <57B2E8F8.8080408@huawei.com>
Date: Tue, 16 Aug 2016 18:20:40 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
References: <57A325CA.9050707@huawei.com> <57A3260F.4050709@huawei.com> <20160816084132.GA17417@dhcp22.suse.cz> <57B2D556.5030201@huawei.com> <20160816092345.GB17417@dhcp22.suse.cz> <e9b1213e-6d77-372f-d335-3b98a40378e8@suse.cz>
In-Reply-To: <e9b1213e-6d77-372f-d335-3b98a40378e8@suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2016/8/16 18:12, Vlastimil Babka wrote:

> On 08/16/2016 11:23 AM, Michal Hocko wrote:
>> On Tue 16-08-16 16:56:54, Xishi Qiu wrote:
>>> On 2016/8/16 16:41, Michal Hocko wrote:
>>>
>>>> On Thu 04-08-16 19:25:03, Xishi Qiu wrote:
>>>>> MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
>>>>> set one pageblock's migratetype in deferred_free_range() if pfn is aligned
>>>>> to MAX_ORDER_NR_PAGES.
>>>>
>>>> Do I read the changelog correctly and the bug causes leaking unmovable
>>>> allocations into movable zones?
>>>
>>> Hi Michal,
>>>
>>> This bug will cause uninitialized migratetype, you can see from
>>> "cat /proc/pagetypeinfo", almost half blocks are Unmovable.
>>
>> Please add that information to the changelog. Leaking unmovable
>> allocations to the movable zones defeats the whole purpose of the
>> movable zone so I guess we really want to mark this for stable.
> 
> Note that it's not as severe. Pageblock migratetype is just heuristic against fragmentation. It should not allow unmovable allocations from movable zones (although I can't find what really does govern it).
> 

Yes, leaking unmovable migratetype to movable zone is fine for mem-offline,
we will check every page in offline_pages().
But as I pointed that we missed to free the last block in deferred_init_memmap(),
this will lead to mem-offline fail.

Thanks,
Xishi Qiu

>> AFAICS it should also note:
>> Fixes: ac5d2539b238 ("mm: meminit: reduce number of times pageblocks are set during struct page init")
>> and stable 4.2+
> 
> 
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
