Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id ECFE96B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 06:30:08 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n6HAU3p9007940
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 11:30:04 +0100
Received: from pxi28 (pxi28.prod.google.com [10.243.27.28])
	by spaceape23.eur.corp.google.com with ESMTP id n6HATxl4006994
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 03:30:00 -0700
Received: by pxi28 with SMTP id 28so354412pxi.30
        for <linux-mm@kvack.org>; Fri, 17 Jul 2009 03:29:59 -0700 (PDT)
Date: Fri, 17 Jul 2009 03:29:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] page-allocator: Ensure that processes that have been
 OOM killed exit the page allocator (resend)
In-Reply-To: <20090717092157.GA9835@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0907170326400.18608@chino.kir.corp.google.com>
References: <20090715104944.GC9267@csn.ul.ie> <alpine.DEB.2.00.0907151326350.22582@chino.kir.corp.google.com> <20090716110328.GB22499@csn.ul.ie> <alpine.DEB.2.00.0907161202500.27201@chino.kir.corp.google.com> <20090717092157.GA9835@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009, Mel Gorman wrote:

> Ok, lets go with this patch then. Thanks
> 

Ok, thanks, I'll add that as your acked-by and I'll write a formal patch 
description for it.


mm: avoid endless looping for oom killed tasks

If a task is oom killed and still cannot find memory when trying with no 
watermarks, it's better to fail the allocation attempt than to loop 
endlessly.  Direct reclaim has already failed and the oom killer will be a 
no-op since current has yet to die, so there is no other alternative for 
allocations that are not __GFP_NOFAIL.

Acked-by: Mel Gorman <mel@csn.ul.ie>
Signed-off-by: David Rientjes <rientjes@google.com>
---
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
