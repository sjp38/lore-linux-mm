Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB947680FC1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:00:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t18so9131719wmt.7
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 09:00:01 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 125si4154744wmf.48.2017.02.14.09.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 09:00:00 -0800 (PST)
Date: Tue, 14 Feb 2017 11:59:52 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 03/10] mm, page_alloc: split smallest stolen page in
 fallback
Message-ID: <20170214165952.GD2450@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-4-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-4-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:36PM +0100, Vlastimil Babka wrote:
> The __rmqueue_fallback() function is called when there's no free page of
> requested migratetype, and we need to steal from a different one. There are
> various heuristics to make this event infrequent and reduce permanent
> fragmentation. The main one is to try stealing from a pageblock that has the
> most free pages, and possibly steal them all at once and convert the whole
> pageblock. Precise searching for such pageblock would be expensive, so instead
> the heuristics walks the free lists from MAX_ORDER down to requested order and
> assumes that the block with highest-order free page is likely to also have the
> most free pages in total.
> 
> Chances are that together with the highest-order page, we steal also pages of
> lower orders from the same block. But then we still split the highest order
> page. This is wasteful and can contribute to fragmentation instead of avoiding
> it.
> 
> This patch thus changes __rmqueue_fallback() to just steal the page(s) and put
> them on the freelist of the requested migratetype, and only report whether it
> was successful. Then we pick (and eventually split) the smallest page with
> __rmqueue_smallest().  This all happens under zone lock, so nobody can steal it
> from us in the process. This should reduce fragmentation due to fallbacks. At
> worst we are only stealing a single highest-order page and waste some cycles by
> moving it between lists and then removing it, but fallback is not exactly hot
> path so that should not be a concern. As a side benefit the patch removes some
> duplicate code by reusing __rmqueue_smallest().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

It took me a second to understand what you're doing here, but this is
clever. Finding a suitable fallback still goes by biggest block to
make future stealing less probable, but when we do steal the entire
block and move_freepages_block() has migrated all the free chunks of
that block over to the new migratetype list, we might as well then try
to allocate from the smallest chunk available in the stolen block.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
