Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C37E86B0071
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 08:37:02 -0400 (EDT)
Received: by wicnd19 with SMTP id nd19so81763534wic.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 05:37:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s9si8878257wia.28.2015.06.17.05.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 05:37:01 -0700 (PDT)
Date: Wed, 17 Jun 2015 14:36:56 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] panic_on_oom_timeout
Message-ID: <20150617123656.GE25056@dhcp22.suse.cz>
References: <20150610155646.GE4501@dhcp22.suse.cz>
 <201506130022.FJF05762.LSQMOFtVFFOJOH@I-love.SAKURA.ne.jp>
 <20150615124515.GC29447@dhcp22.suse.cz>
 <201506162214.IGG12982.QOFHMOFLOJFtSV@I-love.SAKURA.ne.jp>
 <20150616134650.GC24296@dhcp22.suse.cz>
 <201506172116.HGF17106.JFSOFOLFtMOHVQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506172116.HGF17106.JFSOFOLFtMOHVQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 17-06-15 21:16:37, Tetsuo Handa wrote:
> Michal Hocko wrote a few minutes ago:
> > Subject: [RFC -v2] panic_on_oom_timeout
> 
> Oops, we raced...
> 
> Michal Hocko wrote:
> > On Tue 16-06-15 22:14:28, Tetsuo Handa wrote:
[...]
> > > Since memcg OOM is less critical than system OOM because administrator still
> > > has chance to perform steps to resolve the OOM state, we could give longer
> > > timeout (e.g. 600 seconds) for memcg OOM while giving shorter timeout (e.g.
> > > 10 seconds) for system OOM. But if (a) is impossible, trying to configure
> > > different timeout for non-system OOM stall makes no sense.
> > 
> > I still do not see any point for a separate timeouts.
> > 
> I think that administrator cannot configure adequate timeout if we don't allow
> separate timeouts.

Why? What prevents a user space policy if the system is still usable?

> > Again panic_on_oom=2 sounds very dubious to me as already mentioned. The
> > life would be so much easier if we simply start by supporting
> > panic_on_oom=1 for now. It would be a simple timer (as we cannot use
> > DELAYED_WORK) which would just panic the machine after a timeout. We
> 
> My patch recommends administrators to stop setting panic_on_oom to non-zero
> value and to start setting a separate timeouts, one is for system OOM (short
> timeout) and the other is for non-system OOM (long timeout).
> 
> How does my patch involve panic_on_oom ?

You are panicing the system on OOM condition. It feels natural to bind a
timeout based policy to this knob.

> My patch does not care about dubious panic_on_oom=2.

Yes, it replaces it by additional timeouts which seems an overkill to
me.
 
> > > > Besides that oom_unkillable_task doesn't sound like a good match to
> > > > evaluate this logic. I would expect it to be in oom_scan_process_thread.
> > > 
> > > Well, select_bad_process() which calls oom_scan_process_thread() would
> > > break out from the loop when encountering the first TIF_MEMDIE task.
> > > We need to change
> > > 
> > > 	case OOM_SCAN_ABORT:
> > > 		rcu_read_unlock();
> > > 		return (struct task_struct *)(-1UL);
> > > 
> > > to defer returning of (-1UL) when a TIF_MEMDIE thread was found, in order to
> > > make sure that all TIF_MEMDIE threads are examined for timeout. With that
> > > change made,
> > > 
> > > 	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> > > 		/*** this location ***/
> > > 		if (!force_kill)
> > > 			return OOM_SCAN_ABORT;
> > > 	}
> > > 
> > > in oom_scan_process_thread() will be an appropriate place for evaluating
> > > this logic.
> > 
> > You can also keep select_bad_process untouched and simply check the
> > remaining TIF_MEMDIE tasks in oom_scan_process_thread (if the timeout is > 0
> > of course so the most configurations will be unaffected).
> 
> The most configurations will be unaffected because there is usually no
> TIF_MEMDIE thread. But if something went wrong and there were 100 TIF_MEMDIE
> threads out of 10000 threads, traversing the tasklist from
> oom_scan_process_thread() whenever finding a TIF_MEMDIE thread sounds
> wasteful to me. If we keep traversing from select_bad_process(), the nuber
> of threads to check remains 10000.

Yes, but the code would be uglier and duplicated for memcg and global case.
Also this is an extremely slow path so optimization to skip scanning
some tasks is not worth making the code more obscure.

[...]
> @@ -1583,11 +1584,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  			case OOM_SCAN_CONTINUE:
>  				continue;
>  			case OOM_SCAN_ABORT:
> -				css_task_iter_end(&it);
> -				mem_cgroup_iter_break(memcg, iter);
> -				if (chosen)
> -					put_task_struct(chosen);
> -				goto unlock;
> +				memdie_pending = true;
> +				continue;
>  			case OOM_SCAN_OK:
>  				break;
>  			};

OOM_SCAN_ABORT can be returned even for !TIF_MEMDIE task so you might
force a victim selection when there is an exiting task and we could
delay actual killing.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
