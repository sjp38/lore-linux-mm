Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 875B86B04A8
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 02:40:23 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p37so7606654wrc.5
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 23:40:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 42si3865069wrt.387.2017.08.29.23.40.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Aug 2017 23:40:22 -0700 (PDT)
Date: Wed, 30 Aug 2017 08:40:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use WQ_HIGHPRI for mm_percpu_wq.
Message-ID: <20170830064019.mfihbeu3mm5ygcrb@dhcp22.suse.cz>
References: <1503921210-4603-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20170828121055.GI17097@dhcp22.suse.cz>
 <20170828170611.GV491396@devbig577.frc2.facebook.com>
 <20170829133325.o2s4xiqnc3ez6qxb@dhcp22.suse.cz>
 <20170829143319.GJ491396@devbig577.frc2.facebook.com>
 <201708300529.HEB00599.VHtOFOLFSJOMFQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201708300529.HEB00599.VHtOFOLFSJOMFQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tj@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, vbabka@suse.cz

On Wed 30-08-17 05:29:26, Tetsuo Handa wrote:
> Tejun Heo wrote:
> > Hello,
> > 
> > On Tue, Aug 29, 2017 at 03:33:25PM +0200, Michal Hocko wrote:
> > > Hmm, we have this in should_reclaim_retry
> > > 			/*
> > > 			 * Memory allocation/reclaim might be called from a WQ
> > > 			 * context and the current implementation of the WQ
> > > 			 * concurrency control doesn't recognize that
> > > 			 * a particular WQ is congested if the worker thread is
> > > 			 * looping without ever sleeping. Therefore we have to
> > > 			 * do a short sleep here rather than calling
> > > 			 * cond_resched().
> > > 			 */
> > > 			if (current->flags & PF_WQ_WORKER)
> > > 				schedule_timeout_uninterruptible(1);
> > > 
> > > And I thought it would be susfficient for kworkers for concurrency WQ
> > > congestion thingy to jump in. Or do we need something more generic. E.g.
> > > make cond_resched special for kworkers?
> > 
> > I actually think we're hitting a bug somewhere.  Tetsuo's trace with
> > the patch applies doesn't add up.
> > 
> > Thanks.
> 
> If we are under memory pressure, __zone_watermark_ok() can return false.
> If __zone_watermark_ok() == false, when is schedule_timeout_*() called explicitly?

If all zones fail with the watermark check then we should hit the oom
path and sleep there. We do not do so for all cases though. Maybe we
should be more consistent there but even if this was a flood of GFP_NOFS
requests from the WQ context then at least some of them should fail on
the oom lock and sleep and help to make at least some progress. Moreover
Tejun suggests that some pools are idle so this might be a completely
different issue. In any case we can make an explicit reschedule point
in should_reclaim_retry. I would be really surprised if it helped but
maybe this is a better code in the end regardless.
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 018468a3b6b1..c93660926f24 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3699,6 +3699,7 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 {
 	struct zone *zone;
 	struct zoneref *z;
+	int ret = false;
 
 	/*
 	 * Costly allocations might have made a progress but this doesn't mean
@@ -3762,25 +3763,27 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 				}
 			}
 
-			/*
-			 * Memory allocation/reclaim might be called from a WQ
-			 * context and the current implementation of the WQ
-			 * concurrency control doesn't recognize that
-			 * a particular WQ is congested if the worker thread is
-			 * looping without ever sleeping. Therefore we have to
-			 * do a short sleep here rather than calling
-			 * cond_resched().
-			 */
-			if (current->flags & PF_WQ_WORKER)
-				schedule_timeout_uninterruptible(1);
-			else
-				cond_resched();
-
-			return true;
+			ret = true;
+			break;
 		}
 	}
 
-	return false;
+	/*
+	 * Memory allocation/reclaim might be called from a WQ
+	 * context and the current implementation of the WQ
+	 * concurrency control doesn't recognize that
+	 * a particular WQ is congested if the worker thread is
+	 * looping without ever sleeping. Therefore we have to
+	 * do a short sleep here rather than calling
+	 * cond_resched().
+	 */
+	if (current->flags & PF_WQ_WORKER)
+		schedule_timeout_uninterruptible(1);
+	else
+		cond_resched();
+
+
+	return ret;
 }
 
 static inline bool
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
