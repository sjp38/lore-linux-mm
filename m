Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF476B006E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 08:21:04 -0400 (EDT)
Received: by oihb142 with SMTP id b142so30778693oih.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:21:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id cx9si4411525oec.13.2015.06.10.05.21.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 05:21:02 -0700 (PDT)
Subject: Re: [RFC] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150609170310.GA8990@dhcp22.suse.cz>
In-Reply-To: <20150609170310.GA8990@dhcp22.suse.cz>
Message-Id: <201506102120.FEC87595.OQSJLOVtMFOHFF@I-love.SAKURA.ne.jp>
Date: Wed, 10 Jun 2015 21:20:58 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, linux-mm@kvack.org
Cc: rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> Hi,
> during the last iteration of the timeout based oom killer discussion
> (http://marc.info/?l=linux-mm&m=143351457601723) I've proposed to
> introduce panic_on_oom_timeout as an extension to panic_on_oom rather
> than oom timeout which would allow OOM killer to select another oom
> victim and do that until the OOM is resolved or the system panics due to
> potential oom victims depletion.

I welcome the timeout, but I have several questions about implementation.

> 
> My main rationale for going panic_on_oom_timeout way is that this
> approach will lead to much more predictable behavior because the system
> will get to a usable state after given amount of time + reboot time.
> On the other hand, if the other approach was chosen then there is no
> guarantee that another victim would be in any better situation than the
> original one. In fact there might be many tasks blocked on a single lock
> (e.g. i_mutex) and the oom killer doesn't have any way to find out which
> task to kill in order to make the progress. The result would be
> N*timeout time period when the system is basically unusable and the N is
> unknown to the admin.

My version ( http://marc.info/?l=linux-mm&m=143239200805478 ) implemented
two timeouts. /proc/sys/vm/memdie_task_skip_secs is for choosing next OOM
victim and /proc/sys/vm/memdie_task_panic_secs is for triggering panic.
Therefore, the result is no longer N*timeout time period.

> 
> I think that it is more appropriate to shut such a system down when such
> a corner case is hit rather than struggle for basically unbounded amount
> of time.

Ditto. Not unbounded amount of time.

> 
> Thoughts? An RFC implementing this is below. It is quite trivial and
> I've tried to test it a bit. I will add the missing pieces if this looks
> like a way to go.
> 
> There are obviously places in the oom killer and the page allocator path
> which could be improved and this patch doesn't try to put them aside. It
> is just providing a reasonable the very last resort when things go
> really wrong.
> ---
> From 35b7cff442326c609cdbb78757ef46e6d0ca0c61 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Tue, 9 Jun 2015 16:15:42 +0200
> Subject: [RFC] oom: implement panic_on_oom_timeout
> 
> OOM killer is a desparate last resort reclaim attempt to free some
> memory. It is based on heuristics which will never be 100% and may
> result in an unusable or a locked up system.
> 
> panic_on_oom sysctl knob allows to set the OOM policy to panic the
> system instead of trying to resolve the OOM condition. This might be
> useful for several reasons - e.g. reduce the downtime to a predictable
> amount of time, allow to get a crash dump of the system and debug the
> issue post-mortem.
> 
> panic_on_oom is, however, a big hammer in many situations when the
> OOM condition could be resolved in a reasonable time. So it would be
> good to have some middle ground and allow the OOM killer to do its job
> but have a failover when things go wrong and it is not able to make any
> further progress for a considerable amount of time.
> 
> This patch implements panic_on_oom_timeout sysctl which is active
> only when panic_on_oom!=0 and it configures a maximum timeout for
> the OOM killer to resolve the OOM situation. If the system is still
> under OOM after the timeout expires it will panic the system as per
> panic_on_oom configuration. A reasonably chosen timeout can protect from
> both temporal OOM conditions and allows to have a predictable time frame
> for the OOM condition.

Since your version uses the oom_ctx as a global lock (it acts as a lock
because it is assigned when atomic_read(&oom_victims) == 0) without
holding a refcount, you cannot safely handle OOM race like

  (1) p1 in memcg1 calls out_of_memory().
  (2) memcg1 is copied to oom_ctx.memcg and 5 seconds of timeout starts.
  (3) mark_oom_victim(p1) is called.
  (4) p1 takes 3 seconds for some reason.
  (5) p2 in memcg2 calls out_of_memory().
  (6) mark_oom_victim(p2) is called.
  (7) p1 calls unmark_oom_victim().
  (8) all threads in memcg1 exits and memcg1 is released.
  (9) p2 takes 2 seconds for some reason.
  (10) 5 seconds of timeout expires despite individual delay was less than
       5 seconds!?
  (11) panic_on_oom tries to dereference oom_ctx.memcg which is already
       released memcg1, resulting in oops. But panic() will not be called
       if panic_on_oops == 0 because workqueue callback is a sleepable
       context!?

Since my version uses per a "struct task_struct" variable (memdie_start),
5 seconds of timeout is checked for individual memory cgroup. It can avoid
unnecessary panic() calls if nobody needs to call out_of_memory() again
(probably because somebody volunteered memory) when the OOM victim cannot
be terminated for some reason. If we want distinction between "the entire
system is under OOM" and "some memory cgroup is under OOM" because the
former is urgent but the latter is less urgent, it can be modified to
allow different timeout period for system-wide OOM and cgroup OOM.
Finally, it can give a hint for "in what sequence threads got stuck" and
"which thread did take 5 seconds" when analyzing vmcore.

> 
> The feature is implemented as a delayed work which is scheduled when
> the OOM condition is declared for the first time (oom_victims is still
> zero) in out_of_memory and it is canceled in exit_oom_victim after
> the oom_victims count drops down to zero. For this time period OOM
> killer cannot kill new tasks and it only allows exiting or killed
> tasks to access memory reserves (and increase oom_victims counter via
> mark_oom_victim) in order to make a progress so it is reasonable to
> consider the elevated oom_victims count as an ongoing OOM condition

By the way, what guarantees that the panic_on_oom_work is executed under
OOM condition? The moom_work used by SysRq-f sometimes cannot be executed
because some work which is processed before the moom_work is processed is
stalled for unbounded amount of time due to looping inside the memory
allocator. Therefore, my version used DEFINE_TIMER() than
DECLARE_DELAYED_WORK() in order to make sure that the callback shall be
called as soon as timeout expires.

> 
> The log will then contain something like:
> [  904.144494] run_test.sh invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
> [  904.145854] run_test.sh cpuset=/ mems_allowed=0
> [  904.146651] CPU: 0 PID: 5244 Comm: run_test.sh Not tainted 4.0.0-oomtimeout2-00001-g3b4737913602 #575
> [...]
> [  905.147523] panic_on_oom timeout 1s has expired
> [  905.150049] kworker/0:1 invoked oom-killer: gfp_mask=0x280da, order=0, oom_score_adj=0
> [  905.154572] kworker/0:1 cpuset=/ mems_allowed=0
> [...]
> [  905.503378] Kernel panic - not syncing: Out of memory: system-wide panic_on_oom is enabled
> 
> TODO: Documentation update
> TODO: check all potential paths which might skip mark_oom_victim
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
