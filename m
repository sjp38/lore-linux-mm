Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF2C56B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 06:56:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id u65so5169720wrc.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 03:56:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b6si2137116wmh.15.2017.02.08.03.56.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 03:56:12 -0800 (PST)
Date: Wed, 8 Feb 2017 12:56:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: move pcp and lru-pcp drainging into vmstat_wq
Message-ID: <20170208115609.GH5686@dhcp22.suse.cz>
References: <20170207210908.530-1-mhocko@kernel.org>
 <378bf4f0-e16d-a68f-6c91-a05cda47991e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <378bf4f0-e16d-a68f-6c91-a05cda47991e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 08-02-17 11:49:11, Vlastimil Babka wrote:
> On 02/07/2017 10:09 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > We currently have 2 specific WQ_RECLAIM workqueues. One for updating
> > pcp stats vmstat_wq and one dedicated to drain per cpu lru caches. This
> > seems more than necessary because both can run on a single WQ. Both
> > do not block on locks requiring a memory allocation nor perform any
> > allocations themselves. We will save one rescuer thread this way.
> > 
> > On the other hand drain_all_pages queues work on the system wq which
> > doesn't have rescuer and so this depend on memory allocation (when all
> > workers are stuck allocating and new ones cannot be created). This is
> > not critical as there should be somebody invoking the OOM killer (e.g.
> > the forking worker) and get the situation unstuck and eventually
> > performs the draining. Quite annoying though. This worker should be
> > using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> > and vmstat.
> > 
> > Suggested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > 
> > Hi,
> > Tetsuo has noted that drain_all_pages doesn't use WQ_RECLAIM [1]
> > and asked whether we can move the worker to the vmstat_wq which is
> > WQ_RECLAIM. I think the deadlock he has described shouldn't happen but
> > it would be really better to have the rescuer. I also think that we do
> > not really need 2 or more workqueues and also pull lru draining in.
> > 
> > What do you think? Please note I haven't tested it yet.
> 
> Why not, I guess, of course I may be overlooking some subtlety. You could
> have CC'd Tejun and Christoph.

will do on the next submission

> Watch out for the init order though, maybe? Is there no caller of the
> lru/pcp drain before module_init(setup_vmstat) happens?

Hard to tell. I expect that there shouldn't be but I will add
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c0a7c38cd91..73018f07bcc9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2370,6 +2370,13 @@ void drain_all_pages(struct zone *zone)
 	 */
 	static cpumask_t cpus_with_pcps;
 
+	/*
+	 * Make sure nobody triggers this path before vmstat_wq is fully
+	 * initialized.
+	 */
+	if (WARN_ON(!vmstat_wq))
+		return;
+
 	/* Workqueues cannot recurse */
 	if (current->flags & PF_WQ_WORKER)
 		return;
diff --git a/mm/swap.c b/mm/swap.c
index 23f09d6dd212..39c240fc9d48 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -676,6 +676,13 @@ void lru_add_drain_all(void)
 	static struct cpumask has_work;
 	int cpu;
 
+	/*
+	 * Make sure nobody triggers this path before vmstat_wq is fully
+	 * initialized.
+	 */
+	if (WARN_ON(!vmstat_wq))
+		return;
+
 	mutex_lock(&lock);
 	get_online_cpus();
 	cpumask_clear(&has_work);

to be sure.
[...]

> > @@ -1763,9 +1762,11 @@ static int vmstat_cpu_dead(unsigned int cpu)
> > 
> >  static int __init setup_vmstat(void)
> >  {
> > -#ifdef CONFIG_SMP
> > -	int ret;
> > +	int ret = 0;
> > +
> > +	vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
> 
> Did you want to set ret to -ENOMEM if the alloc fails, or something?
> Otherwise I don't see why the changes.

no I just didn't want to get defined but not used warning for
CONFIG_SMP=n

> 
> > 
> > +#ifdef CONFIG_SMP
> >  	ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
> >  					NULL, vmstat_cpu_dead);
> >  	if (ret < 0)
> > @@ -1789,7 +1790,7 @@ static int __init setup_vmstat(void)
> >  	proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
> >  	proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
> >  #endif
> > -	return 0;
> > +	return ret;
> >  }
> >  module_init(setup_vmstat)
> > 
> > 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
