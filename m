Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9586B0253
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:42:58 -0400 (EDT)
Received: by oifu63 with SMTP id u63so12836620oif.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:42:58 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id zf8si9620393obc.81.2015.10.22.14.42.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 22 Oct 2015 14:42:57 -0700 (PDT)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151022151528.GG30579@mtj.duckdns.org>
	<20151022153559.GF26854@dhcp22.suse.cz>
	<20151022153703.GA3899@mtj.duckdns.org>
	<20151022154922.GG26854@dhcp22.suse.cz>
	<20151022184226.GA19289@mtj.duckdns.org>
In-Reply-To: <20151022184226.GA19289@mtj.duckdns.org>
Message-Id: <201510230642.HDF57807.QJtSOVFFOMLHOF@I-love.SAKURA.ne.jp>
Date: Fri, 23 Oct 2015 06:42:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: htejun@gmail.com, mhocko@kernel.org
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Tejun Heo wrote:
> On Thu, Oct 22, 2015 at 05:49:22PM +0200, Michal Hocko wrote:
> > I am confused. What makes rescuer to not run? Nothing seems to be
> > hogging CPUs, we are just out of workers which are loopin in the
> > allocator but that is preemptible context.
> 
> It's concurrency management.  Workqueue thinks that the pool is making
> positive forward progress and doesn't schedule anything else for
> execution while that work item is burning cpu cycles.

Then, isn't below change easier to backport which will also alleviate
needlessly burning CPU cycles?

--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3385,6 +3385,7 @@ retry:
 	((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
+		schedule_timeout_uninterruptible(1);
 		goto retry;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
