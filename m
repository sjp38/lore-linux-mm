Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3488D6B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 17:00:03 -0400 (EDT)
Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id n6FKxvxh020953
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 21:59:57 +0100
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by spaceape13.eur.corp.google.com with ESMTP id n6FKxsnP021050
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:59:55 -0700
Received: by pzk38 with SMTP id 38so2414848pzk.10
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:59:54 -0700 (PDT)
Date: Wed, 15 Jul 2009 13:59:50 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
 OOM killed exit the page allocator (resend)
In-Reply-To: <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.0907151358400.25459@chino.kir.corp.google.com>
References: <20090715104944.GC9267@csn.ul.ie> <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, David Rientjes wrote:

> This only works for GFP_ATOMIC since the next iteration of the page 
> allocator will (probably) fail reclaim and simply invoke the oom killer 
> again, which will notice current has TIF_MEMDIE set and choose to do 
> nothing, at which time the allocator simply loops again.
> 

In other words, I'd propose this as an alternative patch.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1789,6 +1789,10 @@ rebalance:
 	if (p->flags & PF_MEMALLOC)
 		goto nopage;
 
+	/* Avoid allocations with no watermarks from looping endlessly */
+	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
+		goto nopage;
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
