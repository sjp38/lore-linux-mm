Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D26706B0363
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:11:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so221287660pgc.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:11:29 -0800 (PST)
Received: from mail-pf0-x231.google.com (mail-pf0-x231.google.com. [2607:f8b0:400e:c00::231])
        by mx.google.com with ESMTPS id g80si4933501pfg.11.2016.11.17.14.11.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 14:11:28 -0800 (PST)
Received: by mail-pf0-x231.google.com with SMTP id d2so50977519pfd.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:11:28 -0800 (PST)
Date: Thu, 17 Nov 2016 14:11:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, zone: track number of pages in free area by
 migratetype
In-Reply-To: <49ed7412-eab7-4d8d-c6df-fdf76d98da4d@suse.cz>
Message-ID: <alpine.DEB.2.10.1611171405210.99747@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com> <49ed7412-eab7-4d8d-c6df-fdf76d98da4d@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 17 Nov 2016, Vlastimil Babka wrote:

> > The total number of free pages is still tracked, however, to not make
> > zone_watermark_ok() more expensive.  Reading /proc/pagetypeinfo, however,
> > is faster.
> 
> Yeah I've already seen a case with /proc/pagetypeinfo causing soft
> lockups due to high number of iterations...
> 

Thanks for taking a look at the patchset!

Wow, I haven't seen /proc/pagetypeinfo soft lockups yet, I thought this 
was a relatively minor point :)  But it looks like we need some 
improvement in this behavior independent of memory compaction anyway.

> > This patch introduces no functional change and increases the amount of
> > per-zone metadata at worst by 48 bytes per memory zone (when CONFIG_CMA
> > and CONFIG_MEMORY_ISOLATION are enabled).
> 
> Isn't it 48 bytes per zone and order?
> 

Yes, sorry, I'll fix that in v2.  I think less than half a kilobyte for 
each memory zone is satisfactory for extra tracking, compaction 
improvements, and optimized /proc/pagetypeinfo, though.

> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> I'd be for this if there are no performance regressions. It affects hot
> paths and increases cache footprint. I think at least some allocator
> intensive microbenchmark should be used.
> 

I can easily implement a test to stress movable page allocations from 
fallback MIGRATE_UNMOVABLE pageblocks and freeing back to the same 
pageblocks.  I assume we're not interested in memory offline benchmarks.

What do you think about the logic presented in patch 2/2?  Are you 
comfortable with a hard-coded ratio such as 1/64th of free memory or would 
you prefer to look at the zone's watermark with the number of free pages 
from MIGRATE_MOVABLE pageblocks rather than NR_FREE_PAGES?  I was split 
between the two options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
