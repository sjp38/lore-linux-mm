Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 33F9D6B0038
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 10:28:06 -0400 (EDT)
Received: by wiga1 with SMTP id a1so50427330wig.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 07:28:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ev4si18303165wjc.204.2015.06.10.07.28.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 07:28:04 -0700 (PDT)
Date: Wed, 10 Jun 2015 16:28:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] panic_on_oom_timeout
Message-ID: <20150610142801.GD4501@dhcp22.suse.cz>
References: <20150609170310.GA8990@dhcp22.suse.cz>
 <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed 10-06-15 21:20:58, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > This patch implements panic_on_oom_timeout sysctl which is active
> > only when panic_on_oom!=0 and it configures a maximum timeout for
> > the OOM killer to resolve the OOM situation. If the system is still
> > under OOM after the timeout expires it will panic the system as per
> > panic_on_oom configuration. A reasonably chosen timeout can protect from
> > both temporal OOM conditions and allows to have a predictable time frame
> > for the OOM condition.
> 
> Since your version uses the oom_ctx as a global lock (it acts as a lock
> because it is assigned when atomic_read(&oom_victims) == 0) without
> holding a refcount, you cannot safely handle OOM race like
> 
>   (1) p1 in memcg1 calls out_of_memory().
>   (2) memcg1 is copied to oom_ctx.memcg and 5 seconds of timeout starts.
>   (3) mark_oom_victim(p1) is called.
>   (4) p1 takes 3 seconds for some reason.
>   (5) p2 in memcg2 calls out_of_memory().
>   (6) mark_oom_victim(p2) is called.
>   (7) p1 calls unmark_oom_victim().
>   (8) all threads in memcg1 exits and memcg1 is released.
>   (9) p2 takes 2 seconds for some reason.
>   (10) 5 seconds of timeout expires despite individual delay was less than
>        5 seconds!?

Yes this is certainly possible and a similar thing would happen with
mempolicy/cpusets. I haven't considered panic_on_oom=2 much for this RFC
to be honest (I am sorry I should have mentioned that in the changelog
explicitly). The semantic of such a timeout is not clear to me.  OOM
domains might intersect and it is not clear which domain will benefit
from killing the particular task. Say Node1 and Node2 are in the OOM
nodemask while a task had memory only from Node2 so Node1 stays OOM.
Should we keep ticking the timer for Node1? Sure we can optimistically
cancel that timer and hope some other allocation would trigger OOM on
Node1 again but wouldn't that break the semantic of the knob.

Memcg case would be easier to handle because we have the memcg context
which can hold the timer and memcg_oom_recover would be a natural place
to stop the delayed panic for the affected hierarchy.

Btw. panic_on_oom=2 is kind of weird and I am not sure it was well
thought through when introduced. 2b744c01a54f ("mm: fix handling of
panic_on_oom when cpusets are in use") is far from being specific about
usecases. It is hardly a failover feature because the system as whole is
not OOM and administrator still has chance to perform steps to resolve
the potential lockup or trashing from the global context (e.g. by
relaxing restrictions or even rebooting cleanly).

That being said, I recognize this is a problem and it makes the timeout
implementation more complicated. The question is do we actually care or
should we start simple and ignore the timeout for panic_on_oom=2 and
implement it after somebody shows up with a reasonable usecase for this
conf+timeout?

>   (11) panic_on_oom tries to dereference oom_ctx.memcg which is already
>        released memcg1, resulting in oops.

Yes this is obviously buggy. Thanks for pointing this out.

>	 But panic() will not be called
>        if panic_on_oops == 0 because workqueue callback is a sleepable
>        context!?
>
> Since my version uses per a "struct task_struct" variable (memdie_start),
> 5 seconds of timeout is checked for individual memory cgroup. It can avoid
> unnecessary panic() calls if nobody needs to call out_of_memory() again
> (probably because somebody volunteered memory) when the OOM victim cannot
> be terminated for some reason. If we want distinction between "the entire
> system is under OOM" and "some memory cgroup is under OOM" because the
> former is urgent but the latter is less urgent, it can be modified to
> allow different timeout period for system-wide OOM and cgroup OOM.
> Finally, it can give a hint for "in what sequence threads got stuck" and
> "which thread did take 5 seconds" when analyzing vmcore.

I will have a look how you have implemented that but separate timeouts
sound like a major over engineering. Also note that global vs. memcg OOM
is not sufficient because there are other oom domains as mentioned above.
 
> > The feature is implemented as a delayed work which is scheduled when
> > the OOM condition is declared for the first time (oom_victims is still
> > zero) in out_of_memory and it is canceled in exit_oom_victim after
> > the oom_victims count drops down to zero. For this time period OOM
> > killer cannot kill new tasks and it only allows exiting or killed
> > tasks to access memory reserves (and increase oom_victims counter via
> > mark_oom_victim) in order to make a progress so it is reasonable to
> > consider the elevated oom_victims count as an ongoing OOM condition
> 
> By the way, what guarantees that the panic_on_oom_work is executed under
> OOM condition?

Tejun would be much better to explain this but my understanding of the
delayed workqueue code is that it doesn't depend on memory allocations.

> The moom_work used by SysRq-f sometimes cannot be executed
> because some work which is processed before the moom_work is processed is
> stalled for unbounded amount of time due to looping inside the memory
> allocator.

Wouldn't wq code pick up another worker thread to execute the work.
There is also a rescuer thread as the last resort AFAIR.

> Therefore, my version used DEFINE_TIMER() than
> DECLARE_DELAYED_WORK() in order to make sure that the callback shall be
> called as soon as timeout expires.

I do not care that much whether it is timer or delayed work which would
be used.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
