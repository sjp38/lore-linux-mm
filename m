Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B508F6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 06:20:21 -0500 (EST)
Received: by padfb1 with SMTP id fb1so35343062pad.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:20:21 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id zo2si8949062pac.218.2015.02.24.03.20.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Feb 2015 03:20:20 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141230112158.GA15546@dhcp22.suse.cz>
	<201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
	<20150216154201.GA27295@phnom.home.cmpxchg.org>
	<201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502231347510.21127@chino.kir.corp.google.com>
Message-Id: <201502242020.IDI64912.tOOQSVJFOFLHMF@I-love.SAKURA.ne.jp>
Date: Tue, 24 Feb 2015 20:20:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: hannes@cmpxchg.org, mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, fernando_b1@lab.ntt.co.jp

David Rientjes wrote:
> Perhaps we should consider an alternative: allow threads, such as TaskA, 
> that are deferring for a long amount of time to simply allocate with 
> ALLOC_NO_WATERMARKS itself in that scenario in the hope that the 
> allocation succeeding will eventually allow it to drop the mutex.  Two 
> problems: (1) there's no guarantee that the simple allocation is all TaskA 
> needs before it will drop the lock and (2) another thread could 
> immediately grab the same mutex and allocate, in which the same series of 
> events repeats.

We can see that effectively GFP_NOFAIL allocations with a lock held
(e.g. filesystem transaction) exist, can't we?

----------------------------------------
TaskA               TaskB               TaskC               TaskD               TaskE
                    call mutex_lock()
                                        call mutex_lock()
                                                            call mutex_lock()
                                                                                call mutex_lock()
call mutex_lock()
                    do GFP_NOFAIL allocation
                    oom kill TaskA
                    waiting for TaskA to die
                    will do something with allocated memory
                    will call mutex_unlock()
                                        will do GFP_NOFAIL allocation
                                        will wait for TaskA to die
                                        will do something with allocated memory
                                        will call mutex_unlock()
                                                            will do GFP_NOFAIL allocation
                                                            will wait for TaskA to die
                                                            will do something with allocated memory
                                                            will call mutex_unlock()
                                                                                will do GFP_NOFAIL allocation
                                                                                will wait for TaskA to die
                                                                                will do something with allocated memory
                                                                                will call mutex_unlock()
will do GFP_NOFAIL allocation
----------------------------------------

Allowing ALLOC_NO_WATERMARKS to TaskB helps nothing. We don't want to
allow ALLOC_NO_WATERMARKS to TaskC, TaskD, TaskE and TaskA when they
do the same sequence TaskB did, or we will deplete memory reserves.

> In a timeout based solution, this would be detected and another thread 
> would be chosen for oom kill.  There's currently no way for the oom killer 
> to select a process that isn't waiting for that same mutex, however.  If 
> it does, then the process has been killed needlessly since it cannot make 
> forward progress itself without grabbing the mutex.

Right. The OOM killer cannot understand that there is such lock dependency.

And do you think there will be a way available for the OOM killer to select
a process that isn't waiting for that same mutex in the neare future?
(Remembering mutex's address currently waiting for using "struct task_struct"
would do, but will not be accepted due to performance penalty. Simplified form
would be to check "struct task_struct"->state , but will not be perfect.)

> Certainly, it would be better to eventually kill something else in the 
> hope that it does not need the mutex and will free some memory which would 
> allow the thread that had originally been deferring forever, TaskA, in the 
> oom killer waiting for the original victim, TaskB, to exit.  If that's the 
> solution, then TaskA had been killed unnecessarily itself.

Complaining about unnecessarily killed processes is preventing us from
making forward progress.

The memory reserves are something like a balloon. To guarantee forward
progress, the balloon must not become empty. All memory managing techniques
except the OOM killer are trying to control "deflator of the balloon" via
various throttling heuristics. On the other hand, the OOM killer is the only
memory managing technique which is trying to control "inflator of the balloon"
via several throttling heuristics. The OOM killer is invoked when all memory
managing techniques except the OOM killer failed to make forward progress.

Therefore, the OOM killer is responsible for making forward progress for
"deflator of the balloon" and is granted the prerogative to send SIGKILL to
any process.

Given the fact that the OOM killer cannot understand lock dependency and
there are effectively GFP_NOFAIL allocations, it is inevitable that the
OOM killer fails to choose one correct process that will make forward
progress.

Currently the OOM killer is invoked as one shot mode. This mode helps us
to reduce the possibility of depleting the memory reserves and killing
processes unnecessarily. But this mode is bothering people with "silently
stalling forever" problem when the bullet from the OOM killer missed the
target. This mode is also bothering people with "complete system crash"
problem when the bullet from SysRq-f missed the target, for they have to
use SysRq-i or SysRq-c or SysRq-b which is far more unnecessary kill of
processes in order to solve the OOM condition.

My proposal is to allow the OOM killer be invoked as consecutive shots
mode. Although consecutive shots mode may increase possibility of killing
processes unnecessarily, trying to kill an unkillable process in one shot
mode is after all unnecessary kill of processes. The root cause is the same
(i.e. the OOM killer cannot understand the dependency). My patch can stop
bothering people with "silently stalling forever" / "complete system crash"
problems by retrying the oom kill attempt than wait forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
