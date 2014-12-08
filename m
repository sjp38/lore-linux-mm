Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 28EB96B0038
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 06:16:22 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id ex7so4363013wid.9
        for <linux-mm@kvack.org>; Mon, 08 Dec 2014 03:16:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e9si9264445wiv.77.2014.12.08.03.16.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Dec 2014 03:16:21 -0800 (PST)
Date: Mon, 8 Dec 2014 11:16:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 2/3] mm: more aggressive page stealing for UNMOVABLE
 allocations
Message-ID: <20141208111617.GO6043@suse.de>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-3-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1417713178-10256-3-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Thu, Dec 04, 2014 at 06:12:57PM +0100, Vlastimil Babka wrote:
> When allocation falls back to stealing free pages of another migratetype,
> it can decide to steal extra pages, or even the whole pageblock in order to
> reduce fragmentation, which could happen if further allocation fallbacks
> pick a different pageblock. In try_to_steal_freepages(), one of the situations
> where extra pages are stolen happens when we are trying to allocate a
> MIGRATE_RECLAIMABLE page.
> 
> However, MIGRATE_UNMOVABLE allocations are not treated the same way, although
> spreading such allocation over multiple fallback pageblocks is arguably even
> worse than it is for RECLAIMABLE allocations. To minimize fragmentation, we
> should minimize the number of such fallbacks, and thus steal as much as is
> possible from each fallback pageblock.
> 
> This patch thus adds a check for MIGRATE_UNMOVABLE to the decision to steal
> extra free pages. When evaluating with stress-highalloc from mmtests, this has
> reduced the number of MIGRATE_UNMOVABLE fallbacks to roughly 1/6. The number
> of these fallbacks stealing from MIGRATE_MOVABLE block is reduced to 1/3.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

Note that this is a slightly tricky tradeoff. UNMOVABLE allocations will now
be stealing more of a pageblock during fallback events. This will reduce the
probability that unmovable fallbacks will happen in the future. However,
it also increases the probability that a movable allocation will fallback
in the future. This is particularly true for kernel-build stress workloads
as the liklihood is that unmovable allocations are stealing from movable
pageblocks.  The reason this happens is that the movable free lists are
smaller after an unmovable fallback event so a movable fallback event
happens sooner than it would have otherwise.

Movable fallback events are less severe than unmovable fallback events as
they can be moved or freed later so the patch heads the right direction. The
side-effect is simply interesting to note.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
