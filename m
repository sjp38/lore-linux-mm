Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 59A816B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:55:25 -0400 (EDT)
Message-ID: <4FE27F15.8050102@kernel.org>
Date: Thu, 21 Jun 2012 10:55:33 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Accounting problem of MIGRATE_ISOLATED freed page
References: <4FE169B1.7020600@kernel.org> <4FE16E80.9000306@gmail.com> <4FE18187.3050103@kernel.org> <4FE23069.5030702@gmail.com> <4FE26470.90401@kernel.org> <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com>
In-Reply-To: <CAHGf_=pjoiHQ9vxXXe-GtbkYRzhxdDhu3pf6pwDsCe5pBQE8Nw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/21/2012 10:39 AM, KOSAKI Motohiro wrote:

>>> number of isolate page block is almost always 0. then if we have such counter,
>>> we almost always can avoid zone->lock. Just idea.
>>
>> Yeb. I thought about it but unfortunately we can't have a counter for MIGRATE_ISOLATE.
>> Because we have to tweak in page free path for pages which are going to free later after we
>> mark pageblock type to MIGRATE_ISOLATE.
> 
> I mean,
> 
> if (nr_isolate_pageblock != 0)
>    free_pages -= nr_isolated_free_pages(); // your counting logic
> 
> return __zone_watermark_ok(z, alloc_order, mark,
>                               classzone_idx, alloc_flags, free_pages);
> 
> 
> I don't think this logic affect your race. zone_watermark_ok() is already
> racy. then new little race is no big matter.


It seems my explanation wasn't enough. :(
I already understand your intention but we can't make nr_isolate_pageblock.
Because we should count two type of free pages.

1. Already freed page so they are already in buddy list.
   Of course, we can count it with return value of move_freepages_block(zone, page, MIGRATE_ISOLATE) easily.

2. Will be FREEed page by do_migrate_range.
   It's a _PROBLEM_. For it, we should tweak free path. No?

If All of pages are PageLRU when hot-plug happens(ie, 2), nr_isolate_pagblock is zero and 
zone_watermk_ok_safe can't do his role.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
