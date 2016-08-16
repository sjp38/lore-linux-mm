Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 665726B025E
	for <linux-mm@kvack.org>; Tue, 16 Aug 2016 06:12:11 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 65so174937934uay.1
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 03:12:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fc10si24638648wjc.189.2016.08.16.03.12.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Aug 2016 03:12:10 -0700 (PDT)
Subject: Re: [PATCH 1/3] mm: fix set pageblock migratetype in deferred struct
 page init
References: <57A325CA.9050707@huawei.com> <57A3260F.4050709@huawei.com>
 <20160816084132.GA17417@dhcp22.suse.cz> <57B2D556.5030201@huawei.com>
 <20160816092345.GB17417@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <e9b1213e-6d77-372f-d335-3b98a40378e8@suse.cz>
Date: Tue, 16 Aug 2016 12:12:07 +0200
MIME-Version: 1.0
In-Reply-To: <20160816092345.GB17417@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 08/16/2016 11:23 AM, Michal Hocko wrote:
> On Tue 16-08-16 16:56:54, Xishi Qiu wrote:
>> On 2016/8/16 16:41, Michal Hocko wrote:
>>
>>> On Thu 04-08-16 19:25:03, Xishi Qiu wrote:
>>>> MAX_ORDER_NR_PAGES is usually 4M, and a pageblock is usually 2M, so we only
>>>> set one pageblock's migratetype in deferred_free_range() if pfn is aligned
>>>> to MAX_ORDER_NR_PAGES.
>>>
>>> Do I read the changelog correctly and the bug causes leaking unmovable
>>> allocations into movable zones?
>>
>> Hi Michal,
>>
>> This bug will cause uninitialized migratetype, you can see from
>> "cat /proc/pagetypeinfo", almost half blocks are Unmovable.
>
> Please add that information to the changelog. Leaking unmovable
> allocations to the movable zones defeats the whole purpose of the
> movable zone so I guess we really want to mark this for stable.

Note that it's not as severe. Pageblock migratetype is just heuristic 
against fragmentation. It should not allow unmovable allocations from 
movable zones (although I can't find what really does govern it).

> AFAICS it should also note:
> Fixes: ac5d2539b238 ("mm: meminit: reduce number of times pageblocks are set during struct page init")
> and stable 4.2+



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
