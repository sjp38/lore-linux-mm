Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6BF406B0044
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 20:09:04 -0400 (EDT)
Received: by mail-ig0-f179.google.com with SMTP id hn18so1719626igb.0
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 17:09:04 -0700 (PDT)
Received: from mail-ie0-x232.google.com (mail-ie0-x232.google.com [2607:f8b0:4001:c03::232])
        by mx.google.com with ESMTPS id bf2si24200578igb.9.2014.06.04.17.09.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 17:09:02 -0700 (PDT)
Received: by mail-ie0-f178.google.com with SMTP id rl12so238463iec.9
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 17:09:02 -0700 (PDT)
Date: Wed, 4 Jun 2014 17:08:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 6/6] mm, compaction: don't migrate in blocks that
 cannot be fully compacted in async direct compaction
In-Reply-To: <1401898310-14525-6-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-6-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 4 Jun 2014, Vlastimil Babka wrote:

> In direct compaction, we want to allocate the high-order page as soon as
> possible, so migrating from a block of pages that contains also unmigratable
> pages just adds to allocation latency.
> 

The title of the patch in the subject line should probably be reworded 
since it implies we never isolate from blocks that cannot become 
completely free and what you're really doing is skipping cc->order aligned 
pages.

> This patch therefore makes the migration scanner skip to the next cc->order
> aligned block of pages as soon as it cannot isolate a non-free page. Everything
> isolated up to that point is put back.
> 
> In this mode, the nr_isolated limit to COMPACT_CLUSTER_MAX is not observed,
> allowing the scanner to scan the whole block at once, instead of migrating
> COMPACT_CLUSTER_MAX pages and then finding an unmigratable page in the next
> call. This might however have some implications on too_many_isolated.
> 
> Also in this RFC PATCH, the "skipping mode" is tied to async migration mode,
> which is not optimal. What we most probably want is skipping in direct
> compactions, but not from kswapd and hugepaged.
> 
> In very preliminary tests, this has reduced migrate_scanned, isolations and
> migrations by about 10%, while the success rate of stress-highalloc mmtests
> actually improved a bit.
> 

Ok, so this obsoletes my patchseries that did something similar.  I hope 
you can rebase this set on top of linux-next and then propose it formally 
without the RFC tag.

We also need to discuss the scheduling heuristics, the reliance on 
need_resched(), to abort async compaction.  In testing, we actualy 
sometimes see 2-3 pageblocks scanned before terminating and thp has a very 
little chance of being allocated.  At the same time, if we try to fault 
64MB of anon memory in and each of the 32 calls to compaction are 
expensive but don't result in an order-9 page, we see very lengthy fault 
latency.

I think it would be interesting to consider doing async compaction 
deferral up to 1 << COMPACT_MAX_DEFER_SHIFT after a sysctl-configurable 
amount of memory is scanned, at least for thp, and remove the scheduling 
heuristic entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
