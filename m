Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE826B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:50:01 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i18so3893434wrb.21
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:50:01 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 45si8969400wrb.329.2017.03.29.08.49.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 08:49:59 -0700 (PDT)
Subject: Re: [PATCH v3 4/8] mm, page_alloc: count movable pages when stealing
 from pageblock
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-5-vbabka@suse.cz>
 <20170316015323.GB14063@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0da9d0e1-59f3-79f2-2bc4-6c381f103813@suse.cz>
Date: Wed, 29 Mar 2017 17:49:57 +0200
MIME-Version: 1.0
In-Reply-To: <20170316015323.GB14063@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On 03/16/2017 02:53 AM, Joonsoo Kim wrote:
> On Tue, Mar 07, 2017 at 02:15:41PM +0100, Vlastimil Babka wrote:
>> When stealing pages from pageblock of a different migratetype, we count how
>> many free pages were stolen, and change the pageblock's migratetype if more
>> than half of the pageblock was free. This might be too conservative, as there
>> might be other pages that are not free, but were allocated with the same
>> migratetype as our allocation requested.
> 
> I think that too conservative is good for movable case. In my experiments,
> fragmentation spreads out when unmovable/reclaimable pageblock is
> changed to movable pageblock prematurely ('prematurely' means that
> allocated unmovable pages remains). As you said below, movable allocations
> falling back to other pageblocks don't causes permanent fragmentation.
> Therefore, we don't need to be less conservative for movable
> allocation. So, how about following change to keep the criteria for
> movable allocation conservative even with this counting improvement?
> 
> threshold = (1 << (pageblock_order - 1));
> if (start_type == MIGRATE_MOVABLE)
>         threshold += (1 << (pageblock_order - 2));
> 
> if (free_pages + alike_pages >= threshold)
>         ...

That could help, or also not. Keeping more pageblocks marked as unmovable also
means that more unmovable allocations will spread out to them all, even if they
would fit within less pageblocks. MIGRATE_MIXED was an idea to help in this
case, as truly unmovable pageblocks would be preferred to the mixed ones.

Can't decide about such change without testing :/

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
