Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 457182803A1
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 04:30:12 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p14so19245935wrg.8
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 01:30:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si8897550wrd.130.2017.08.21.01.30.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Aug 2017 01:30:10 -0700 (PDT)
Date: Mon, 21 Aug 2017 10:30:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 mm-oom-let-oom_reap_task-and-exit_mmap-to-run-concurrently.patch added to
 -mm tree
Message-ID: <20170821083008.GA25956@dhcp22.suse.cz>
References: <59936823.CQNWQErWJ8EAIG3q%akpm@linux-foundation.org>
 <20170816132329.GA32169@dhcp22.suse.cz>
 <20170817171240.GB5066@redhat.com>
 <20170818070444.GA9004@dhcp22.suse.cz>
 <20170818184145.GF5066@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170818184145.GF5066@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, hughd@google.com, kirill@shutemov.name, oleg@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, rientjes@google.com, mm-commits@vger.kernel.org, linux-mm@kvack.org

On Fri 18-08-17 20:41:45, Andrea Arcangeli wrote:
> On Fri, Aug 18, 2017 at 09:04:44AM +0200, Michal Hocko wrote:
> > I dunno. This doesn't make any difference in the generated code for
> > me (with gcc 6.4). If anything we might wan't to putt unlikely inside
> 
> That's fine, this is just in case the code surrounding the check
> changes in the future. It's not like we should remove unlikely/likely
> if the emitted bytecode doesn't change.
> 
> > tsk_is_oom_victim. Or even go further and use a jump label to get any
> 
> I don't think it's necessarily the best to put it inside
> tsk_is_oom_victim, even if currently it would be the same.
> 
> All it matters for likely unlikely is not to risk to ever get it
> wrong. If unsure it's better to leave it alone.
> 
> We can't be sure all future callers of tsk_is_oom_victim will always
> be unlikely to get a true retval. All we can be sure is that this
> specific caller will get a false retval 100% of the time, in all
> workloads where performance can matter.

Cosindering that it is highly unlikely to meet an OOM victim I would
consider unlikely as always applicable. Even if this is something in the
oom proper then it is a) a cold path so a misprediction doesn't matter
and b) even then it is highly unlikely to meet a victim because oom
victims should almost always be a minority.

> > conditional paths out of way.
> 
> Using a jump label won't allocate memory so I tend to believe it would
> be safe to run them here. However before worrying at the exit path, I
> think the first target of optimization would be the MMF_UNSTABLE
> checks, those are in the page fault fast paths and they end up run
> infinitely more frequently than this single branch in exit.

Yes that is true.

[...]
> So what would you think about the simplest approach to the
> MMF_UNSTABLE issue, that is to add a build time CONFIG_OOM_REAPER=y
> option for the OOM reaper so those branches are optimized away at
> build time (and the above one too, and perhaps the MMF_OOM_SKIP
> set_bit too) if it's ok to disable the OOM reaper as well and increase
> the risk an OOM hang? (it's years I didn't hit an OOM hang in my
> desktop even before OOM reaper was introduced). It could be default
> enabled of course.

I really do hate how many config options we have already and adding more
on top doesn't look like an improvement to me. Jump labels sound like
a much better way forward. Or do you see any potential disadvantage?

> I'd be curious to be able to still test what happens to the VM when
> the OOM reaper is off, so if nothing else it would be a debug option,
> because it'd also help to reproduce more easily those

The same could be achieved with a kernel command line option which would
be a smaller patch, easier to maintain in future and also wouldn't
further increase the config space fragmentation.

> filesystem-kernel-thread induced hangs that would still happen if the
> OOM reaper cannot run because some other process is trying to take the
> mmap_sem for writing. A down_read_trylock_unfair would go a long way
> to reduce the likelyhood to run into that. The kernel CI exercising
> multiple configs would then also autonomously CC us on a report if
> those branches are a measurable issue so it'll be easier to tell if
> the migration entry conversion or static key is worth it for
> MMF_UNSTABLE.

While this sounds like an interesting exercise I am not convinced it
justifies the new config option.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
