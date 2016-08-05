Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id A05AB6B0253
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:53:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id 33so155735938lfw.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:53:29 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id t124si3336811wmg.26.2016.08.05.01.41.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 01:41:17 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 3456398DAA
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 08:41:17 +0000 (UTC)
Date: Fri, 5 Aug 2016 09:41:15 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 03/34] mm, vmscan: move LRU lists to node
Message-ID: <20160805084115.GO2799@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-4-git-send-email-mgorman@techsingularity.net>
 <CAAG0J9_k3edxDzqpEjt2BqqZXMW4PVj7BNUBAk6TWtw3Zh_oMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAAG0J9_k3edxDzqpEjt2BqqZXMW4PVj7BNUBAk6TWtw3Zh_oMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, metag <linux-metag@vger.kernel.org>

On Thu, Aug 04, 2016 at 09:59:17PM +0100, James Hogan wrote:
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> This breaks boot on metag architecture:
> Oops: err 0007 (Data access general read/write fault) addr 00233008 [#1]
> 
> It appears to be in node_page_state_snapshot() (via
> pgdat_reclaimable()), and have come via mm_init. Here's the relevant
> bit of the backtrace:
> 
>     node_page_state_snapshot@0x4009c884(enum node_stat_item item =
> ???, struct pglist_data * pgdat = ???) + 0x48
>     pgdat_reclaimable(struct pglist_data * pgdat = 0x402517a0)
>     show_free_areas(unsigned int filter = 0) + 0x2cc
>     show_mem(unsigned int filter = 0) + 0x18
>     mm_init@0x4025c3d4()
>     start_kernel() + 0x204
> 
> __per_cpu_offset[0] == 0x233000 (close to bad addr),
> pgdat->per_cpu_nodestats = NULL. and setup_per_cpu_pageset()
> definitely hasn't been called yet (mm_init is called before
> setup_per_cpu_pageset()).
> 
> Any ideas what the correct solution is (and why presumably others
> haven't seen the same issue on other architectures?).
> 

metag calls show_mem in mem_init() before the pagesets are initialised.
What's surprising is that it worked for the zone stats as it appears
that calling zone_reclaimable() from that context should also have
broken. Did anything change recently that would have avoided the
zone->pageset dereference in zone_reclaimable() before?

The easiest option would be to not call show_mem from arch code until
after the pagesets are setup.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
