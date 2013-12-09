Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id AA5D76B011C
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:56:40 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3212771yha.21
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:56:40 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id k1si11319352yhm.93.2013.12.09.13.56.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 13:56:39 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id v1so3238200yhn.18
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:56:39 -0800 (PST)
Date: Mon, 9 Dec 2013 13:56:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, page_alloc: make __GFP_NOFAIL really not fail
Message-ID: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

__GFP_NOFAIL specifies that the page allocator cannot fail to return
memory.  Allocators that call it may not even check for NULL upon
returning.

It turns out GFP_NOWAIT | __GFP_NOFAIL or GFP_ATOMIC | __GFP_NOFAIL can
actually return NULL.  More interestingly, processes that are doing
direct reclaim and have PF_MEMALLOC set may also return NULL for any
__GFP_NOFAIL allocation.

This patch fixes it so that the page allocator never actually returns
NULL as expected for __GFP_NOFAIL.  It turns out that no code actually
does anything as crazy as GFP_ATOMIC | __GFP_NOFAIL currently, so this
is more for correctness than a bug fix for that issue.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2535,17 +2535,19 @@ rebalance:
 		}
 	}
 
-	/* Atomic allocations - we can't balance anything */
-	if (!wait)
-		goto nopage;
-
-	/* Avoid recursion of direct reclaim */
-	if (current->flags & PF_MEMALLOC)
-		goto nopage;
-
-	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
-		goto nopage;
+	if (likely(!(gfp_mask & __GFP_NOFAIL))) {
+		/* Atomic allocations - we can't balance anything */
+		if (!wait)
+			goto nopage;
+
+		/* Avoid recursion of direct reclaim */
+		if (current->flags & PF_MEMALLOC)
+			goto nopage;
+
+		/* Avoid allocations with no watermarks from looping forever */
+		if (test_thread_flag(TIF_MEMDIE))
+			goto nopage;
+	}
 
 	/*
 	 * Try direct compaction. The first pass is asynchronous. Subsequent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
