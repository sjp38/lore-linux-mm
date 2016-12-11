Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3939F6B025E
	for <linux-mm@kvack.org>; Sun, 11 Dec 2016 08:54:15 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id l192so133806881oih.2
        for <linux-mm@kvack.org>; Sun, 11 Dec 2016 05:54:15 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y129si20041417oig.271.2016.12.11.05.54.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Dec 2016 05:54:14 -0800 (PST)
Subject: Re: [PATCH 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL automatically
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612061938.DDD73970.QFHOFJStFOLVOM@I-love.SAKURA.ne.jp>
	<20161206192242.GA10273@dhcp22.suse.cz>
	<201612082153.BHC81241.VtMFFHOLJOOFSQ@I-love.SAKURA.ne.jp>
	<20161208134718.GC26530@dhcp22.suse.cz>
	<201612112023.HBB57332.QOFFtJLOOMFSVH@I-love.SAKURA.ne.jp>
In-Reply-To: <201612112023.HBB57332.QOFFtJLOOMFSVH@I-love.SAKURA.ne.jp>
Message-Id: <201612112253.GGH60933.tOMHJQOFSOFFVL@I-love.SAKURA.ne.jp>
Date: Sun, 11 Dec 2016 22:53:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 08-12-16 21:53:44, Tetsuo Handa wrote:
> > > If we could agree
> > > with calling __alloc_pages_nowmark() before out_of_memory() if __GFP_NOFAIL
> > > is given, we can avoid locking up while minimizing possibility of invoking
> > > the OOM killer...
> >
> > I do not understand. We do __alloc_pages_nowmark even when oom is called
> > for GFP_NOFAIL.
> 
> Where is that? I can find __alloc_pages_nowmark() after out_of_memory()
> if __GFP_NOFAIL is given, but I can't find __alloc_pages_nowmark() before
> out_of_memory() if __GFP_NOFAIL is given.
> 
> What I mean is below patch folded into
> "[PATCH 1/2] mm: consolidate GFP_NOFAIL checks in the allocator slowpath".
> 
Oops, I wrongly implemented "__alloc_pages_nowmark() before out_of_memory() if
__GFP_NOFAIL is given." case. Updated version is shown below.

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3116,23 +3116,27 @@ void warn_alloc(gfp_t gfp_mask, const char *fmt, ...)
 		/* The OOM killer may not free memory on a specific node */
 		if (gfp_mask & __GFP_THISNODE)
 			goto out;
+	} else {
+		/*
+		 * Help non-failing allocations by giving them access to memory
+		 * reserves
+		 */
+		page = get_page_from_freelist(gfp_mask, order,
+					      ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
+		/*
+		 * fallback to ignore cpuset restriction if our nodes
+		 * are depleted
+		 */
+		if (!page)
+			page = get_page_from_freelist(gfp_mask, order,
+						      ALLOC_NO_WATERMARKS, ac);
+		if (page)
+			goto out;
 	}
+
 	/* Exhausted what can be done so it's blamo time */
-	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
+	if (out_of_memory(&oc))
 		*did_some_progress = 1;
-
-		if (gfp_mask & __GFP_NOFAIL) {
-			page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS|ALLOC_CPUSET, ac);
-			/*
-			 * fallback to ignore cpuset restriction if our nodes
-			 * are depleted
-			 */
-			if (!page)
-				page = get_page_from_freelist(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
-		}
-	}
 out:
 	mutex_unlock(&oom_lock);
 	return page;
@@ -3738,6 +3742,11 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		 */
 		WARN_ON_ONCE(order > PAGE_ALLOC_COSTLY_ORDER);
 
+		/* Try memory reserves and then start killing things. */
+		page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+		if (page)
+			goto got_pg;
+
 		cond_resched();
 		goto retry;
 	}

I'm calling __alloc_pages_may_oom() from nopage: because we reach without
calling __alloc_pages_may_oom(), for PATCH 1/2 is not for stop enforcing
the OOM killer for __GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
