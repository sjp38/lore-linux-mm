Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54F986B026E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 07:05:15 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x79so47058496lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:05:15 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y8si17038656wjx.44.2016.10.13.04.05.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 04:05:13 -0700 (PDT)
Subject: Re: [RFC PATCH 5/5] mm/page_alloc: support fixed migratetype
 pageblock
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-6-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f3d23e61-8418-515c-f5bf-31e742e2f64e@suse.cz>
Date: Thu, 13 Oct 2016 13:05:11 +0200
MIME-Version: 1.0
In-Reply-To: <1476346102-26928-6-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> We have migratetype facility to minimise fragmentation. It dynamically
> changes migratetype of pageblock based on some criterias but it never
> be perfect. Some migratetype pages are often placed in the other
> migratetype pageblock. We call this pageblock as mixed pageblock.
>
> There are two types of mixed pageblock. Movable page on unmovable
> pageblock and unmovable page on movable pageblock. (I simply ignore
> reclaimble migratetype/pageblock for easy explanation.) Earlier case is
> not a big problem because movable page is reclaimable or migratable. We can
> reclaim/migrate it when necessary so it usually doesn't contribute
> fragmentation. Actual problem is caused by later case. We don't have
> any way to reclaim/migrate this page and it prevents to make high order
> freepage.
>
> This later case happens when there is too less unmovable freepage. When
> unmovable freepage runs out, fallback allocation happens and unmovable
> allocation would be served by movable pageblock.
>
> To solve/prevent this problem, we need to have enough unmovable freepage
> to satisfy all unmovable allocation request by unmovable pageblock.
> If we set enough unmovable pageblock at boot and fix it's migratetype
> until power off, we would have more unmovable freepage during runtime and
> mitigate above problem.
>
> This patch provides a way to set minimum number of unmovable pageblock
> at boot time. In my test, with proper setup, I can't see any mixed
> pageblock where unmovable allocation stay on movable pageblock.

So if I get this correctly, the fixed-as-unmovable bit doesn't actually 
prevent fallbacks to such pageblocks? Then I'm surprised that's enough 
to make any difference. Also Johannes's problem is that there are too 
many unmovable pageblocks, so I'm a bit skeptical that simply 
preallocating some will help his workload. But we'll see...

In any case I wouldn't pursue a solution that requires user 
configuration, until as a last resort. Hopefully we can make the 
heuristics good enough so that's not necessary. Sorry for my mostly 
negative feedback to your series, I'm glad you pursuit this as well, and 
hope we'll eventually find a good solution :)

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
