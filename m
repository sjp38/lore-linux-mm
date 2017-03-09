Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 731DF2808E6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 09:44:51 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v66so21660353wrc.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 06:44:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h66si4657295wmi.3.2017.03.09.06.44.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 06:44:49 -0800 (PST)
Date: Thu, 9 Mar 2017 15:44:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: move pcp and lru-pcp drainging into single wq
Message-ID: <20170309144448.GJ11592@dhcp22.suse.cz>
References: <20170307131751.24936-1-mhocko@kernel.org>
 <20170309142602.nhuawsps3mdxqxjv@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309142602.nhuawsps3mdxqxjv@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 09-03-17 14:26:02, Mel Gorman wrote:
> On Tue, Mar 07, 2017 at 02:17:51PM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
> > vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
> > per cpu lru caches. This seems more than necessary because both can run
> > on a single WQ. Both do not block on locks requiring a memory allocation
> > nor perform any allocations themselves. We will save one rescuer thread
> > this way.
> > 
> > On the other hand drain_all_pages() queues work on the system wq which
> > doesn't have rescuer and so this depend on memory allocation (when all
> > workers are stuck allocating and new ones cannot be created). This is
> > not critical as there should be somebody invoking the OOM killer (e.g.
> > the forking worker) and get the situation unstuck and eventually
> > performs the draining. Quite annoying though. This worker should be
> > using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> > and vmstat.
> > 
> > Changes since v1
> > - rename vmstat_wq to mm_percpu_wq - per Mel
> > - make sure we are not trying to enqueue anything while the WQ hasn't
> >   been intialized yet. This shouldn't happen because the initialization
> >   is done from an init code but some init section might be triggering
> >   those paths indirectly so just warn and skip the draining in that case
> >   per Vlastimil
> > - do not propagate error from setup_vmstat to keep the previous behavior
> >   per Mel
> > 
> > Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks!

> > +struct workqueue_struct *mm_percpu_wq;
> > +
> >  static int __init setup_vmstat(void)
> >  {
> > -#ifdef CONFIG_SMP
> > -	int ret;
> > +	int ret __maybe_unused;
> >  
> > +	mm_percpu_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
> > +
> > +#ifdef CONFIG_SMP
> >  	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
> >  					NULL, vmstat_cpu_dead);
> >  	if (ret < 0)
> 
> Should the workqueue also have been renamed to mm_percpu_wq?

Of course. Andrew, could you fold the following in
---
diff --git a/mm/vmstat.c b/mm/vmstat.c
index ff9c49c47f32..4bbc775f9d08 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1766,7 +1766,7 @@ static int __init setup_vmstat(void)
 {
 	int ret __maybe_unused;
 
-	mm_percpu_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
+	mm_percpu_wq = alloc_workqueue("mm_percpu_wq", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
 
 #ifdef CONFIG_SMP
 	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
