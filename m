Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 08AEE6B0255
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 10:44:30 -0500 (EST)
Received: by wmdw130 with SMTP id w130so117974462wmd.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:44:29 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id k129si25885732wma.26.2015.11.11.07.44.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 07:44:27 -0800 (PST)
Received: by wmdw130 with SMTP id w130so117973032wmd.0
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 07:44:27 -0800 (PST)
Date: Wed, 11 Nov 2015 16:44:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151111154424.GC1432@dhcp22.suse.cz>
References: <20151022143349.GD30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220939310.23718@east.gentwo.org>
 <20151022151414.GF30579@mtj.duckdns.org>
 <20151023042649.GB18907@mtj.duckdns.org>
 <20151102150137.GB3442@dhcp22.suse.cz>
 <201511052359.JBB24816.FHtFOJOSLOVMQF@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1511051144240.28554@east.gentwo.org>
 <20151106001648.GA18183@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151106001648.GA18183@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <htejun@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu 05-11-15 19:16:48, Tejun Heo wrote:
> Hello,
> 
> On Thu, Nov 05, 2015 at 11:45:42AM -0600, Christoph Lameter wrote:
> > Sorry but we need work queue processing for vmstat counters that is
> 
> I made this analogy before but this is similar to looping with
> preemption off.  If anything on workqueue stays RUNNING w/o making
> forward progress, it's buggy.  I'd venture to say any code which busy
> loops without making forward progress in the time scale noticeable to
> human beings is borderline buggy too. 

Well, the caller asked for a memory but the request cannot succeed. Due
to the memory allocator semantic we cannot fail the request so we have
to loop. If we had an event to wait for we would do so, of course.

Now wrt. to a small sleep. We used to do that and called
congestion_wait(HZ/50) before retry. This has proved to cause stalls
during high memory pressure 0e093d99763e ("writeback: do not sleep on
the congestion queue if there are no congested BDIs or if significant
congestion is not being encountered in the current zone"). I do not
really remember what was CONFIG_HZ in those reports but it is quite
possible it was 250. So there is a risk of (partial) re-introducing of
those stalls with the patch from Tetsuo
(http://lkml.kernel.org/r/201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp)

If we really have to do short sleep, though, then I would suggest
sticking that into wait_iff_congested rather than spread it into more
places and reduce it only to worker threads. This should be much more
safer. Thought?
---
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 8ed2ffd963c5..7340353f8aea 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -957,8 +957,9 @@ EXPORT_SYMBOL(congestion_wait);
  * jiffies for either a BDI to exit congestion of the given @sync queue
  * or a write to complete.
  *
- * In the absence of zone congestion, cond_resched() is called to yield
- * the processor if necessary but otherwise does not sleep.
+ * In the absence of zone congestion, a short sleep or a cond_resched is
+ * performed to yield the processor and to allow other subsystems to make
+ * a forward progress.
  *
  * The return value is 0 if the sleep is for the full timeout. Otherwise,
  * it is the number of jiffies that were still remaining when the function
@@ -978,7 +979,19 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	 */
 	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
 	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
-		cond_resched();
+
+		/*
+		 * Memory allocation/reclaim might be called from a WQ
+		 * context and the current implementation of the WQ
+		 * concurrency control doesn't recognize that a particular
+		 * WQ is congested if the worker thread is looping without
+		 * ever sleeping. Therefore we have to do a short sleep
+		 * here rather than calling cond_resched().
+		 */
+		if (current->flags & PF_WQ_WORKER)
+			schedule_timeout(1);
+		else
+			cond_resched();
 
 		/* In case we scheduled, work out time remaining */
 		ret = timeout - (jiffies - start);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
