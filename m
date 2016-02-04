Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 90D03440434
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:39:09 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so4862381wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:39:09 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id cz10si17715213wjb.133.2016.02.04.05.39.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 05:39:08 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id r129so12251287wmr.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 05:39:08 -0800 (PST)
Date: Thu, 4 Feb 2016 14:39:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160204133905.GB14425@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
 <20160204125700.GA14425@dhcp22.suse.cz>
 <201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602042210.BCG18704.HOMFFJOStQFOLV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 04-02-16 22:10:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > I am not sure we can fix these pathological loads where we hit the
> > higher order depletion and there is a chance that one of the thousands
> > tasks terminates in an unpredictable way which happens to race with the
> > OOM killer.
> 
> When I hit this problem on Dec 24th, I didn't run thousands of tasks.
> I think there were less than one hundred tasks in the system and only
> a few tasks were running. Not a pathological load at all.

But as the OOM report clearly stated there were no > order-1 pages
available in that particular case. And that happened after the direct
reclaim and compaction were already invoked.

As I've mentioned in the referenced email, we can try to do multiple
retries e.g. do not give up on the higher order requests until we hit
the maximum number of retries but I consider it quite ugly to be honest.
I think that a proper communication with compaction is a more
appropriate way to go long term. E.g. I find it interesting that
try_to_compact_pages doesn't even care about PAGE_ALLOC_COSTLY_ORDER
and treat is as any other high order request.

Something like the following:
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 269a04f20927..1ae5b7da821b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3106,6 +3106,18 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		}
 	}
 
+	/*
+	 * OK, so the watermak check has failed. Make sure we do all the
+	 * retries for !costly high order requests and hope that multiple
+	 * runs of compaction will generate some high order ones for us.
+	 *
+	 * XXX: ideally we should teach the compaction to try _really_ hard
+	 * if we are in the retry path - something like priority 0 for the
+	 * reclaim
+	 */
+	if (order <= PAGE_ALLOC_COSTLY_ORDER)
+		return true;
+
 	return false;
 }
 
@@ -3281,11 +3293,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto noretry;
 
 	/*
-	 * Costly allocations might have made a progress but this doesn't mean
-	 * their order will become available due to high fragmentation so do
-	 * not reset the no progress counter for them
+	 * High order allocations might have made a progress but this doesn't
+	 * mean their order will become available due to high fragmentation so
+	 * do not reset the no progress counter for them
 	 */
-	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
+	if (did_some_progress && !order)
 		no_progress_loops = 0;
 	else
 		no_progress_loops++;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
