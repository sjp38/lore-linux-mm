Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id C8E786B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 08:51:48 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id z11so3470092lbi.35
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 05:51:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id zy4si7344297lbb.133.2014.09.08.05.51.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 05:51:41 -0700 (PDT)
Date: Mon, 8 Sep 2014 13:51:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm: page_alloc: fix zone allocation fairness on UP
Message-ID: <20140908125135.GM17501@suse.de>
References: <1410179751-28115-1-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1410179751-28115-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 08, 2014 at 08:35:51AM -0400, Johannes Weiner wrote:
> The zone allocation batches can easily underflow due to higher-order
> allocations or spills to remote nodes.  On SMP that's fine, because
> underflows are expected from concurrency and dealt with by returning
> 0.  But on UP, zone_page_state will just return a wrapped unsigned
> long, which will get past the <= 0 check and then consider the zone
> eligible until its watermarks are hit.
> 
> 3a025760fc15 ("mm: page_alloc: spill to remote nodes before waking
> kswapd") already made the counter-resetting use atomic_long_read() to
> accomodate underflows from remote spills, but it didn't go all the way
> with it.  Make it clear that these batches are expected to go negative
> regardless of concurrency, and use atomic_long_read() everywhere.
> 
> Fixes: 81c0a2bb515f ("mm: page_alloc: fair zone allocator policy")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: "3.12+" <stable@kernel.org>

This is better than changing the behaviour of zone_page_state().

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
