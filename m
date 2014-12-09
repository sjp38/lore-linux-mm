Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD316B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 04:47:23 -0500 (EST)
Received: by mail-wi0-f179.google.com with SMTP id ex7so1063730wid.0
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 01:47:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u12si14062210wiv.10.2014.12.09.01.47.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 01:47:21 -0800 (PST)
Date: Tue, 9 Dec 2014 09:47:18 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 2/3] mm: more aggressive page stealing for UNMOVABLE
 allocations
Message-ID: <20141209094718.GA21903@suse.de>
References: <1417713178-10256-1-git-send-email-vbabka@suse.cz>
 <1417713178-10256-3-git-send-email-vbabka@suse.cz>
 <20141209030939.GD3358@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20141209030939.GD3358@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, Dec 09, 2014 at 12:09:40PM +0900, Minchan Kim wrote:
> On Thu, Dec 04, 2014 at 06:12:57PM +0100, Vlastimil Babka wrote:
> > When allocation falls back to stealing free pages of another migratetype,
> > it can decide to steal extra pages, or even the whole pageblock in order to
> > reduce fragmentation, which could happen if further allocation fallbacks
> > pick a different pageblock. In try_to_steal_freepages(), one of the situations
> > where extra pages are stolen happens when we are trying to allocate a
> > MIGRATE_RECLAIMABLE page.
> > 
> > However, MIGRATE_UNMOVABLE allocations are not treated the same way, although
> > spreading such allocation over multiple fallback pageblocks is arguably even
> > worse than it is for RECLAIMABLE allocations. To minimize fragmentation, we
> > should minimize the number of such fallbacks, and thus steal as much as is
> > possible from each fallback pageblock.
> 
> Fair enough.
> 

Just to be absolutly sure, check that data and see what the number of
MIGRATE_UNMOVABLE blocks looks like over time. Make sure it's not just
continually growing. MIGRATE_RECLAIMABLE and MIGRATE_MOVABLE blocks were
expected to be freed if the system was aggressively reclaimed but the same
is not be true of MIGRATE_UNMOVABLE. Even if all processes are
aggressively reclaimed for example, the page tables are still there.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
