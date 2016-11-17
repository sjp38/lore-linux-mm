Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 741906B0329
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:04:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so54619171wmf.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 09:04:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mp16si3620279wjb.279.2016.11.17.09.04.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Nov 2016 09:04:22 -0800 (PST)
Subject: Re: [patch 1/2] mm, zone: track number of pages in free area by
 migratetype
References: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <49ed7412-eab7-4d8d-c6df-fdf76d98da4d@suse.cz>
Date: Thu, 17 Nov 2016 18:04:08 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/17/2016 02:32 AM, David Rientjes wrote:
> Each zone's free_area tracks the number of free pages for all free lists.
> This does not allow the number of free pages for a specific migratetype
> to be determined without iterating its free list.
> 
> An upcoming change will use this information to preclude doing async
> memory compaction when the number of MIGRATE_UNMOVABLE pageblocks is
> below a certain threshold.
> 
> The total number of free pages is still tracked, however, to not make
> zone_watermark_ok() more expensive.  Reading /proc/pagetypeinfo, however,
> is faster.

Yeah I've already seen a case with /proc/pagetypeinfo causing soft
lockups due to high number of iterations...

> This patch introduces no functional change and increases the amount of
> per-zone metadata at worst by 48 bytes per memory zone (when CONFIG_CMA
> and CONFIG_MEMORY_ISOLATION are enabled).

Isn't it 48 bytes per zone and order?

> Signed-off-by: David Rientjes <rientjes@google.com>

I'd be for this if there are no performance regressions. It affects hot
paths and increases cache footprint. I think at least some allocator
intensive microbenchmark should be used.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
