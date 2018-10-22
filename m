Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2C976B0008
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 08:03:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e49-v6so20657761edd.20
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 05:03:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c24-v6si70502edn.441.2018.10.22.05.03.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 05:03:12 -0700 (PDT)
Date: Mon, 22 Oct 2018 14:03:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181022120308.GB18839@dhcp22.suse.cz>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
 <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f9a8079f-55b0-301e-9b3d-a5250bd7d277@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 22-10-18 20:45:17, Tetsuo Handa wrote:
> On 2018/10/22 16:13, Michal Hocko wrote:
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
> 
> This is not wrong but is strange. We can use mutex_lock_killable(&oom_lock)
> so that any killed threads no longer wait for oom_lock.

tsk_is_oom_victim is stronger because it doesn't depend on
fatal_signal_pending which might be cleared throughout the exit process.

> Also, closing this race for only memcg OOM path is strange. Global OOM path
> (which are CLONE_VM without CLONE_THREAD) is still suffering this race
> (though frequency is lower than memcg OOM due to use of mutex_trylock()). Either
> checking before calling out_of_memory() or checking task_will_free_mem(current)
> inside out_of_memory() will close this race for both paths.

The global case is much more complicated because we know that memcg
might bypass the charge so we do not have to care about the potential
endless loop like in page allocator path. Moreover I am not even sure
the race is all that interesting in the global case. I have never heard
about a pre-mature panic due to no killable task. The racing oom task
would have to be the last eligible process in the system and that is
quite unlikely. We can think about a more involved solution for that if
we ever hear about this to be a real problem.

So a simple memcg specific fix sounds like a reasonable way forward.
-- 
Michal Hocko
SUSE Labs
