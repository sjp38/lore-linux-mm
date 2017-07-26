Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7638B6B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 12:39:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id q198so52577200qke.13
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 09:39:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s13si13489138qks.161.2017.07.26.09.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 09:39:33 -0700 (PDT)
Date: Wed, 26 Jul 2017 18:39:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170726163928.GB29716@redhat.com>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170725152639.GP29716@redhat.com>
 <20170725154514.GN26723@dhcp22.suse.cz>
 <20170725182619.GQ29716@redhat.com>
 <20170726054533.GA960@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170726054533.GA960@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 26, 2017 at 07:45:33AM +0200, Michal Hocko wrote:
> Yes, exit_aio is the only blocking call I know of currently. But I would
> like this to be as robust as possible and so I do not want to rely on
> the current implementation. This can change in future and I can
> guarantee that nobody will think about the oom path when adding
> something to the final __mmput path.

I think ksm_exit may block too waiting for allocations, the generic
idea is those calls before exit_mmap can cause a problem yes.

> > exit_mmap would have no issue, if there was enough time in the
> > lifetime CPU to allocate the memory, sure the memory will also be
> > freed in finite amount of time by exit_mmap.
> 
> I am not sure I understand. Say that any call prior to unmap_vmas blocks
> on a lock which is held by another call path which cannot proceed with
> the allocation...

What I meant was, if three was no prior call to exit_mmap->unmap_vmas.

> I really do not want to rely on any timing. This just too fragile. Once
> we have killed a task then we shouldn't pick another victim until it
> passed exit_mmap or the oom_reaper did its job. Otherwise we just risk
> false positives while we have already disrupted the workload.

On smaller systems lack or parallelism in OOM killing surely isn't a
problem.

> This will work more or less the same to what we have currently.
> 
> [victim]		[oom reaper]				[oom killer]
> do_exit			__oom_reap_task_mm
>   mmput
>     __mmput
> 			  mmget_not_zero
> 			    test_and_set_bit(MMF_OOM_SKIP)
> 			    					oom_evaluate_task
> 								   # select next victim 
> 			  # reap the mm
>       unmap_vmas
>
> so we can select a next victim while the current one is still not
> completely torn down.

How does oom_evaluate_task possibly run at the same time of
test_and_set_bit in __oom_reap_task_mm considering both are running
under the oom_lock? It's hard to see how what you describe above could
materialize as second and third column cannot run in parallel because
of the oom_lock.

I don't think there was any issue, but then you pointed out the
locking on signal->oom_mm that is protected by the task_lock vs
current->mm NULL check, so I can replace in my patch the
test_and_set_bit with set_bit on one side and the oom_mm task_lock
protected locking on the other side. This way I can put back a set_bit
in the __mmput fast path (instead of test_and_set_bit) and it's even
more efficient. With such a change, I'll also stop depending on the
oom_lock to prevent second and third column to run in parallel.

I still didn't remove the oom_lock outright that seems orthogonal
change unrelated to this issue but now you could remove it as far as
the above is concerned.

> I hope 3f70dc38cec2 ("mm: make sure that kthreads will not refault oom
> reaped memory") will clarify this code. If not please start a new thread
> so that we do not conflate different things together.

I'll look into that, thanks.
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
