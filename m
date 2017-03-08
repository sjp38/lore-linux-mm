Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE5F831E3
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 08:01:34 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y90so10741836wrb.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 05:01:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 52si4283174wrb.134.2017.03.08.05.01.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Mar 2017 05:01:33 -0800 (PST)
Date: Wed, 8 Mar 2017 14:01:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: move pcp and lru-pcp drainging into single wq
Message-ID: <20170308130132.GJ11028@dhcp22.suse.cz>
References: <20170307131751.24936-1-mhocko@kernel.org>
 <201703072250.FJD86423.FJOHOFLFOMQVSt@I-love.SAKURA.ne.jp>
 <20170307142338.GL28642@dhcp22.suse.cz>
 <201703082050.FHI90692.OFFJMOFVQtOSHL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201703082050.FHI90692.OFFJMOFVQtOSHL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 08-03-17 20:50:45, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Tue 07-03-17 22:50:48, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > From: Michal Hocko <mhocko@suse.com>
> > > > 
> > > > We currently have 2 specific WQ_RECLAIM workqueues in the mm code.
> > > > vmstat_wq for updating pcp stats and lru_add_drain_wq dedicated to drain
> > > > per cpu lru caches. This seems more than necessary because both can run
> > > > on a single WQ. Both do not block on locks requiring a memory allocation
> > > > nor perform any allocations themselves. We will save one rescuer thread
> > > > this way.
> > > > 
> > > > On the other hand drain_all_pages() queues work on the system wq which
> > > > doesn't have rescuer and so this depend on memory allocation (when all
> > > > workers are stuck allocating and new ones cannot be created). This is
> > > > not critical as there should be somebody invoking the OOM killer (e.g.
> > > > the forking worker) and get the situation unstuck and eventually
> > > > performs the draining. Quite annoying though. This worker should be
> > > > using WQ_RECLAIM as well. We can reuse the same one as for lru draining
> > > > and vmstat.
> > > 
> > > Is "there should be somebody invoking the OOM killer" really true?
> > 
> > in most cases there should be... I didn't say there will be...
> 
> It can become critical if there is nobody who can invoke the OOM killer.

I am not aware of any "real life" bug report that would make this
critical and worth backporting to stable trees and what not.

> > > According to http://lkml.kernel.org/r/201703031948.CHJ81278.VOHSFFFOOLJQMt@I-love.SAKURA.ne.jp
> > > 
> > >   kthreadd (PID = 2) is trying to allocate "struct task_struct" requested by
> > >   workqueue managers (PID = 19, 157, 10499) but is blocked on memory allocation.
> > > 
> > > __GFP_FS allocations could get stuck waiting for drain_all_pages() ?
> > > Also, order > 0 allocation request by the forking worker could get stuck
> > > at too_many_isolated() in mm/compaction.c ?
> > 
> > There might be some extreme cases which however do not change the
> > justification of this patch. I didn't see such cases reported anywhere
> > - other than in your stress testing where we do not really know what is
> > going on yet - and so I didn't mention them and nor I have marked the
> > patch for stable.
> 
> As shown in my stress testing, warn_alloc() is not powerful enough when
> something we did not imagine happens.

yes, your stress testing is hitting many corner cases and it is good to
deal with them long term but that doesn't mean normal workloads should
be too stressed about backporting this patch because it is not very
likely they would ever hit a problem here.
 
> > I am wondering what is the point of this feedback actually? Do you
> > see anything wrong in the patch or is this about the wording of the
> > changelog? If it is the later is your concern serious enough to warrant
> > the rewording/reposting?
> 
> I don't see anything wrong in the patch. I just thought

OK
 
>   This is not critical as there should be somebody invoking the OOM killer
>   (e.g. the forking worker) and get the situation unstuck and eventually
>   performs the draining. Quite annoying though.
> 
> part can be dropped because there is no guarantee that something we do not
> imagine won't happen.

I do not consider "something we do not imagine won't happen" as critical
enough. And the changelog tries to be explicit about the expectations
and argues why people do not have to be scared and automatically
backport it because it is urgent.

> After applying this patch, we might be able to replace
> 
>         if (unlikely(!mutex_trylock(&pcpu_drain_mutex))) {
>                 if (!zone)
>                         return;
>                 mutex_lock(&pcpu_drain_mutex);
>         }
> 
> with
> 
>         if (mutex_lock_killable(&pcpu_drain_mutex))
> 		return;
> 
> because forward progress will be guaranteed by this patch and
> we can favor pcpu_drain_mutex owner to use other CPU's time for
> flushing queued works when many other allocating threads are
> almost busy looping.

But we do not really want to make this synchronous, I believe. Not with
a proper justification numbers.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
