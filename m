Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7D686B000C
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:16:39 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id t189-v6so4121786ywg.2
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:16:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l68-v6sor483597ywb.410.2018.08.07.13.16.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 13:16:36 -0700 (PDT)
Date: Tue, 7 Aug 2018 16:19:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg, oom: be careful about races when warning about no
 reclaimable task
Message-ID: <20180807201935.GB4251@cmpxchg.org>
References: <20180807072553.14941-1-mhocko@kernel.org>
 <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <863d73ce-fae9-c117-e361-12c415c787de@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dmitry Vyukov <dvyukov@google.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>

On Tue, Aug 07, 2018 at 07:15:11PM +0900, Tetsuo Handa wrote:
> On 2018/08/07 16:25, Michal Hocko wrote:
> > @@ -1703,7 +1703,8 @@ static enum oom_status mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int
> >  		return OOM_ASYNC;
> >  	}
> >  
> > -	if (mem_cgroup_out_of_memory(memcg, mask, order))
> > +	if (mem_cgroup_out_of_memory(memcg, mask, order) ||
> > +			tsk_is_oom_victim(current))
> >  		return OOM_SUCCESS;
> >  
> >  	WARN(1,"Memory cgroup charge failed because of no reclaimable memory! "
> > 
> 
> I don't think this patch is appropriate. This patch only avoids hitting WARN(1).
> This patch does not address the root cause:
> 
> The task_will_free_mem(current) test in out_of_memory() is returning false
> because test_bit(MMF_OOM_SKIP, &mm->flags) test in task_will_free_mem() is
> returning false because MMF_OOM_SKIP was already set by the OOM reaper. The OOM
> killer does not need to start selecting next OOM victim until "current thread
> completes __mmput()" or "it fails to complete __mmput() within reasonable
> period".

I don't see why it matters whether the OOM victim exits or not, unless
you count the memory consumed by struct task_struct.

> According to https://syzkaller.appspot.com/text?tag=CrashLog&x=15a1c770400000 ,
> PID=23767 selected PID=23766 as an OOM victim and the OOM reaper set MMF_OOM_SKIP
> before PID=23766 unnecessarily selects PID=23767 as next OOM victim.
> At uptime = 366.550949, out_of_memory() should have returned true without selecting
> next OOM victim because tsk_is_oom_victim(current) == true.

The code works just fine. We have to kill tasks until we a) free
enough memory or b) run out of tasks or c) kill current. When one of
these outcomes is reached, we allow the charge and return.

The only problem here is a warning in the wrong place.
