Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 780036B0289
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 20:55:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 33so2492567lfw.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 17:55:56 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 203si1831333wmh.93.2016.08.29.17.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 17:55:54 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id i138so940997wmf.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 17:55:54 -0700 (PDT)
Date: Tue, 30 Aug 2016 02:55:52 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
Message-ID: <20160830005550.GB32720@lerouge>
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
 <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
 <20160811181132.GD4214@lerouge>
 <alpine.DEB.2.20.1608111349190.1644@east.gentwo.org>
 <c675d2b6-c380-2a3f-6d49-b5e8b48eae1f@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c675d2b6-c380-2a3f-6d49-b5e8b48eae1f@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 15, 2016 at 10:59:55AM -0400, Chris Metcalf wrote:
> On 8/11/2016 2:50 PM, Christoph Lameter wrote:
> >On Thu, 11 Aug 2016, Frederic Weisbecker wrote:
> >
> >>Do we need to quiesce vmstat everytime before entering userspace?
> >>I thought that vmstat only need to be offlined once and for all?
> >Once is sufficient after disabling the tick.
> 
> It's true that task_isolation_enter() is called every time before
> returning to user space while task isolation is enabled.
> 
> But once we enter the kernel again after returning from the initial
> prctl() -- assuming we are in NOSIG mode so doing so is legal in the
> first place -- almost anything can happen, certainly including
> restarting the tick.  Thus, we have to make sure that normal quiescing
> happens again before we return to userspace.

Yes but we need to sort out what needs to be called only once on prctl().

Once vmstat is quiesced, it's not going to need quiescing again even if we
restart the tick.

> 
> For vmstat, you're right that it's somewhat heavyweight to do the
> quiesce, and if we don't need it, it's wasted time on the return path.
> So I will add a guard call to the new vmstat_idle() before invoking
> quiet_vmstat_sync().  This slows down the path where it turns out we
> do need to quieten vmstat, but not by too much.

Why not do this on prctl() only?

> The LRU quiesce is quite light-weight.  We just check pagevec_count()
> on a handful of pagevec's, confirm they are all zero, and return
> without further work.  So for that one, adding a separate
> lru_add_drain_needed() guard test would just be wasted effort.

Ok if this one is justified, like LRU may need update everytime we re-enter
the kernel, then we can keep it (I can't tell, I don't know much about -mm).

> The thing to remember is that this is only relevant if the user has
> explicitly requested the NOSIG behavior from task isolation, which we
> don't really expect to be the default - we are implicitly encouraging
> use of the default semantics of "you can't enter the kernel again
> until you turn off isolation".

That's right. Although NOSIG is the only thing we can afford as long as
we drag around the 1Hz.

> 
> >> +	if (!tick_nohz_tick_stopped())
> >> +		set_tsk_need_resched(current);
> >> Again, that won't help
> 
> It won't be better than spinning in a loop if there aren't any other
> schedulable processes, but it won't be worse either.  If there is
> another schedulable process, we at least will schedule it sooner than
> if we just sat in a busy loop and waited for the scheduler to kick
> us. But there's nothing else we can do anyway if we want to maintain
> the guarantee that the dyn tick is stopped before return to userspace.

I don't think it helps either way. If reschedule is pending, the current
task already has TIF_RESCHED set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
