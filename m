Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 792396B0038
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 12:00:46 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id p66so11268591wmp.1
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 09:00:46 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v62si13029937wme.73.2015.12.12.09.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 12 Dec 2015 09:00:45 -0800 (PST)
Date: Sat, 12 Dec 2015 12:00:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4] mm,oom: Add memory allocation watchdog kernel thread.
Message-ID: <20151212170032.GB7107@cmpxchg.org>
References: <201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201512130033.ABH90650.FtFOMOFLVOJHQS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com, arekm@maven.pl

On Sun, Dec 13, 2015 at 12:33:04AM +0900, Tetsuo Handa wrote:
> +Currently, when something went wrong inside memory allocation request,
> +the system will stall with either 100% CPU usage (if memory allocating
> +tasks are doing busy loop) or 0% CPU usage (if memory allocating tasks
> +are waiting for file data to be flushed to storage).
> +But /proc/sys/kernel/hung_task_warnings is not helpful because memory
> +allocating tasks unlikely sleep in uninterruptible state for
> +/proc/sys/kernel/hung_task_timeout_secs seconds.

Yes, this is very annoying. Other tasks in the system get dumped out
as they are blocked for too long, but not the allocating task itself
as it's busy looping.

That being said, I'm not entirely sure why we need daemon to do this,
which then requires us to duplicate allocation state to task_struct.
There is no scenario where the allocating task is not moving at all
anymore, right? So can't we dump the allocation state from within the
allocator and leave the rest to the hung task detector?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 05ef7fb..fbfc581 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3004,6 +3004,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	unsigned int nr_tries = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3033,6 +3034,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 retry:
+	if (++nr_retries % 1000 == 0)
+		warn_alloc_failed(gfp_mask, order, "Potential GFP deadlock\n");
+
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
Basing it on nr_retries alone might be too crude and take too long
when each cycle spends time waiting for IO. However, if that is a
problem we can make it time-based instead, like your memalloc_timer,
to catch tasks that spend too much time in a single alloc attempt.

> +		start_memalloc_timer(alloc_mask, order);
>  		page = __alloc_pages_slowpath(alloc_mask, order, &ac);
> +		stop_memalloc_timer(alloc_mask);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
