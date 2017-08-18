Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D950C6B0499
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 14:41:51 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m68so24183165qkf.7
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 11:41:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p2si6036322qtd.469.2017.08.18.11.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Aug 2017 11:41:50 -0700 (PDT)
Date: Fri, 18 Aug 2017 20:41:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: +
 mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch added to
 -mm tree
Message-ID: <20170818184145.GF5066@redhat.com>
References: <59936823.CQNWQErWJ8EAIG3q%akpm@linux-foundation.org>
 <20170816132329.GA32169@dhcp22.suse.cz>
 <20170817171240.GB5066@redhat.com>
 <20170818070444.GA9004@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170818070444.GA9004@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hughd@google.com, kirill@shutemov.name, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 18, 2017 at 09:04:44AM +0200, Michal Hocko wrote:
> I dunno. This doesn't make any difference in the generated code for
> me (with gcc 6.4). If anything we might wan't to putt unlikely inside

That's fine, this is just in case the code surrounding the check
changes in the future. It's not like we should remove unlikely/likely
if the emitted bytecode doesn't change.

> tsk_is_oom_victim. Or even go further and use a jump label to get any

I don't think it's necessarily the best to put it inside
tsk_is_oom_victim, even if currently it would be the same.

All it matters for likely unlikely is not to risk to ever get it
wrong. If unsure it's better to leave it alone.

We can't be sure all future callers of tsk_is_oom_victim will always
be unlikely to get a true retval. All we can be sure is that this
specific caller will get a false retval 100% of the time, in all
workloads where performance can matter.

> conditional paths out of way.

Using a jump label won't allocate memory so I tend to believe it would
be safe to run them here. However before worrying at the exit path, I
think the first target of optimization would be the MMF_UNSTABLE
checks, those are in the page fault fast paths and they end up run
infinitely more frequently than this single branch in exit.

I'm guilty of adding a branch to the page fault myself to check for
userfaultfd_missing(vma) (and such one is not even unlikely, as it
depends on the workload if it is), but without userfaultfd there are
things that just aren't possible with the standard
mmap/mprotect/SIGSEGV legacy API. So there's no way around it, unless
we run stop machine on s390 or 2*NR_CPUs IPIs on x86 every time
somebody calls UFFDIO_REGISTER/UNREGISTER which may introduce
unexpected latencies on large SMP systems (furthermore I made sure
CONFIG_USERFAULTFD=n would completely eliminate the branch at build
time, see the "return false" inline).

So what would you think about the simplest approach to the
MMF_UNSTABLE issue, that is to add a build time CONFIG_OOM_REAPER=y
option for the OOM reaper so those branches are optimized away at
build time (and the above one too, and perhaps the MMF_OOM_SKIP
set_bit too) if it's ok to disable the OOM reaper as well and increase
the risk an OOM hang? (it's years I didn't hit an OOM hang in my
desktop even before OOM reaper was introduced). It could be default
enabled of course.

I'd be curious to be able to still test what happens to the VM when
the OOM reaper is off, so if nothing else it would be a debug option,
because it'd also help to reproduce more easily those
filesystem-kernel-thread induced hangs that would still happen if the
OOM reaper cannot run because some other process is trying to take the
mmap_sem for writing. A down_read_trylock_unfair would go a long way
to reduce the likelyhood to run into that. The kernel CI exercising
multiple configs would then also autonomously CC us on a report if
those branches are a measurable issue so it'll be easier to tell if
the migration entry conversion or static key is worth it for
MMF_UNSTABLE.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
