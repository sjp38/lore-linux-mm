Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 55B476B0326
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 15:25:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y23-v6so1012085eds.12
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 12:25:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z11-v6si1036082edp.248.2018.10.26.12.25.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 12:25:53 -0700 (PDT)
Date: Fri, 26 Oct 2018 21:25:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181026192551.GC18839@dhcp22.suse.cz>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <20181026142531.GA27370@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026142531.GA27370@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 26-10-18 10:25:31, Johannes Weiner wrote:
> On Mon, Oct 22, 2018 at 09:13:23AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Tetsuo has reported [1] that a single process group memcg might easily
> > swamp the log with no-eligible oom victim reports due to race between
> > the memcg charge and oom_reaper
> > 
> > Thread 1		Thread2				oom_reaper
> > try_charge		try_charge
> > 			  mem_cgroup_out_of_memory
> > 			    mutex_lock(oom_lock)
> >   mem_cgroup_out_of_memory
> >     mutex_lock(oom_lock)
> > 			      out_of_memory
> > 			        select_bad_process
> > 				oom_kill_process(current)
> > 				  wake_oom_reaper
> > 							  oom_reap_task
> > 							  MMF_OOM_SKIP->victim
> > 			    mutex_unlock(oom_lock)
> >     out_of_memory
> >       select_bad_process # no task
> > 
> > If Thread1 didn't race it would bail out from try_charge and force the
> > charge. We can achieve the same by checking tsk_is_oom_victim inside
> > the oom_lock and therefore close the race.
> > 
> > [1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/memcontrol.c | 14 +++++++++++++-
> >  1 file changed, 13 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e79cb59552d9..a9dfed29967b 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  		.gfp_mask = gfp_mask,
> >  		.order = order,
> >  	};
> > -	bool ret;
> > +	bool ret = true;
> >  
> >  	mutex_lock(&oom_lock);
> > +
> > +	/*
> > +	 * multi-threaded tasks might race with oom_reaper and gain
> > +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> > +	 * to out_of_memory failure if the task is the last one in
> > +	 * memcg which would be a false possitive failure reported
> > +	 */
> > +	if (tsk_is_oom_victim(current))
> > +		goto unlock;
> > +
> >  	ret = out_of_memory(&oc);
> 
> We already check tsk_is_oom_victim(current) in try_charge() before
> looping on the OOM killer, so at most we'd have a single "no eligible
> tasks" message from such a race before we force the charge - right?

Not really. You can have many threads blocked on the oom_lock and being
reaped while they are waiting. So the check without the lock will always
be racy. This is what Tetsuo's test case actually triggers I believe.

> While that's not perfect, I don't think it warrants complicating this
> code even more. I honestly find it near-impossible to follow the code
> and the possible scenarios at this point.

I do agree that the code is quite far from easy to follow. The set of
events that might happen in a different context is not trivial.

> out_of_memory() bails on task_will_free_mem(current), which
> specifically *excludes* already reaped tasks. Why are we then adding a
> separate check before that to bail on already reaped victims?

696453e66630a has introduced the bail out.

> Do we want to bail if current is a reaped victim or not?
> 
> I don't see how we could skip it safely in general: the current task
> might have been killed and reaped and gotten access to the memory
> reserve and still fail to allocate on its way out. It needs to kill
> the next task if there is one, or warn if there isn't another
> one. Because we're genuinely oom without reclaimable tasks.

Yes, this would be the case for the global case which is a real OOM
situation. Memcg oom is somehow more relaxed because the oom is local.

> There is of course the scenario brought forward in this thread, where
> multiple threads of a process race and the second one enters oom even
> though it doesn't need to anymore. What the global case does to catch
> this is to grab the oom lock and do one last alloc attempt. Should
> memcg lock the oom_lock and try one more time to charge the memcg?

That would be another option. I agree that making it more towards the
global case makes it more attractive. My tsk_is_oom_victim is more
towards "plug this particular case".

So does this look better to you?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e79cb59552d9..4abb66efe806 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		.gfp_mask = gfp_mask,
 		.order = order,
 	};
-	bool ret;
+	bool ret = true;
 
 	mutex_lock(&oom_lock);
+
+	/*
+	 * Make the last moment check while we were waiting for the oom_lock
+	 * just in case the oom_reaper could have freed released some
+	 * memory in the meantime. This mimics the lalst moment allocation
+	 * in __alloc_pages_may_oom
+	 */
+	if (mem_cgroup_margin(mem_over_limit) >= 1 << order)
+		goto unlock;
+
 	ret = out_of_memory(&oc);
+
+unlock:
 	mutex_unlock(&oom_lock);
 	return ret;
 }

> Some simplification in this area would really be great. I'm reluctant
> to ack patches like the above, even if they have some optical benefits
> for the user, because the code is already too tricky for what it does.

I am open to different ideas, unless they are crazy timeout here and
timeout there wrapped with a duct tape.
-- 
Michal Hocko
SUSE Labs
