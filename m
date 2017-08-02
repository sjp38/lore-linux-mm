Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EC488280310
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 02:10:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z53so4757139wrz.10
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 23:10:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n186si2595685wmn.214.2017.08.01.23.10.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 23:10:25 -0700 (PDT)
Date: Wed, 2 Aug 2017 08:10:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170802061022.GA25318@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-2-mhocko@kernel.org>
 <201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
 <20170801165242.GA15518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801165242.GA15518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 01-08-17 18:52:42, Michal Hocko wrote:
> On Wed 02-08-17 00:30:33, Tetsuo Handa wrote:
[...]
> > > -	if (gfp_pfmemalloc_allowed(gfp_mask))
> > > -		alloc_flags = ALLOC_NO_WATERMARKS;
> > > +	/*
> > > +	 * Distinguish requests which really need access to whole memory
> > > +	 * reserves from oom victims which can live with their own reserve
> > > +	 */
> > > +	reserves = gfp_pfmemalloc_allowed(gfp_mask);
> > > +	if (reserves) {
> > > +		if (tsk_is_oom_victim(current))
> > > +			alloc_flags = ALLOC_OOM;
> > 
> > If reserves == true due to reasons other than tsk_is_oom_victim(current) == true
> > (e.g. __GFP_MEMALLOC), why dare to reduce it?
> 
> Well the comment above tries to explain. I assume that the oom victim is
> special here. a) it is on the way to die and b) we know that something
> will be freeing memory on the background so I assume this is acceptable.

I was thinking about this some more. It is not that hard to achive the
original semantic. The code is slightly uglier but acceptable I guess
What do you think about the following?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3510e06b3bf3..7ae0f6d45614 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3627,21 +3627,31 @@ static bool oom_reserves_allowed(struct task_struct *tsk)
 	return true;
 }
 
-bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
+/*
+ * Distinguish requests which really need access to full memory
+ * reserves from oom victims which can live with a portion of it
+ */
+static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
 {
 	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
-		return false;
-
+		return 0;
 	if (gfp_mask & __GFP_MEMALLOC)
-		return true;
+		return ALLOC_NO_WATERMARKS;
 	if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
-		return true;
-	if (!in_interrupt() &&
-			((current->flags & PF_MEMALLOC) ||
-			 oom_reserves_allowed(current)))
-		return true;
+		return ALLOC_NO_WATERMARKS;
+	if (!in_interrupt()) {
+		if (current->flags & PF_MEMALLOC)
+			return ALLOC_NO_WATERMARKS;
+		else if (oom_reserves_allowed(current))
+			return ALLOC_OOM;
+	}
 
-	return false;
+	return 0;
+}
+
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
+{
+	return __gfp_pfmemalloc_flags(gfp_mask) > 0;
 }
 
 /*
@@ -3794,7 +3804,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
-	bool reserves;
+	int reserves;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3900,17 +3910,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	/*
-	 * Distinguish requests which really need access to whole memory
-	 * reserves from oom victims which can live with their own reserve
-	 */
-	reserves = gfp_pfmemalloc_allowed(gfp_mask);
-	if (reserves) {
-		if (tsk_is_oom_victim(current))
-			alloc_flags = ALLOC_OOM;
-		else
-			alloc_flags = ALLOC_NO_WATERMARKS;
-	}
+	reserves = __gfp_pfmemalloc_flags(gfp_mask);
+	if (reserves)
+		alloc_flags = reserves;
 
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
