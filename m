Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B10FD6B0038
	for <linux-mm@kvack.org>; Sat,  3 Sep 2016 11:31:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 1so32892221wmz.2
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 08:31:08 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id x6si9606055wmg.52.2016.09.03.08.31.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Sep 2016 08:31:07 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id i138so6773845wmf.3
        for <linux-mm@kvack.org>; Sat, 03 Sep 2016 08:31:07 -0700 (PDT)
Date: Sat, 3 Sep 2016 17:31:01 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH v14 04/14] task_isolation: add initial support
Message-ID: <20160903153059.GA9589@lerouge>
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
 <1470774596-17341-5-git-send-email-cmetcalf@mellanox.com>
 <20160811181132.GD4214@lerouge>
 <alpine.DEB.2.20.1608111349190.1644@east.gentwo.org>
 <c675d2b6-c380-2a3f-6d49-b5e8b48eae1f@mellanox.com>
 <20160830005550.GB32720@lerouge>
 <69cbe2bd-3d39-b3ae-2ebc-6399125fc782@mellanox.com>
 <20160830171003.GA14200@lerouge>
 <aea6b90e-4b43-302a-636f-36516f30f5d6@mellanox.com>
 <107bd666-dbcf-7fa5-ff9c-f79358899712@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <107bd666-dbcf-7fa5-ff9c-f79358899712@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@mellanox.com>
Cc: Christoph Lameter <cl@linux.com>, Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2016 at 02:17:27PM -0400, Chris Metcalf wrote:
> On 8/30/2016 1:36 PM, Chris Metcalf wrote:
> >>>See the other thread with Peter Z for the longer discussion of this.
> >>>At this point I'm leaning towards replacing the set_tsk_need_resched() with
> >>>
> >>>     set_current_state(TASK_INTERRUPTIBLE);
> >>>     schedule();
> >>>     __set_current_state(TASK_RUNNING);
> >>I don't see how that helps. What will wake the thread up except a signal?
> >
> >The answer is that the scheduler will keep bringing us back to this
> >point (either after running another runnable task if there is one,
> >or else just returning to this point immediately without doing a
> >context switch), and we will then go around the "prepare exit to
> >userspace" loop and perhaps discover that enough time has gone
> >by that the last dyntick interrupt has triggered and the kernel has
> >quiesced the dynticks.  At that point we stop calling schedule()
> >over and over and can return normally to userspace.
> 
> Oops, you're right that if I set TASK_INTERRUPTIBLE, then if I call
> schedule(), I never get control back.  So I don't want to do that.
> 
> I suppose I could do a schedule_timeout() here instead and try
> to figure out how long to wait for the next dyntick.  But since we
> don't expect anything else running on the core anyway, it seems
> like we are probably working too hard at this point.  I don't think
> it's worth it just to go into the idle task and (possibly) save some
> power for a few microseconds.
> 
> The more I think about this, the more I think I am micro-optimizing
> by trying to poke the scheduler prior to some external thing setting
> need_resched, so I think the thing to do here is in fact, nothing.

Exactly, I fear there is nothing you can do about that.

> I won't worry about rescheduling but will just continue going around
> the prepare-exit-to-userspace loop until the last dyn tick fires.

You mean waiting in prepare-exit-to-userspace until the last tick fires?
I'm not sure it's a good idea either, this could take ages, it could as
well never happen.

I'd rather say that if we are in signal mode, fire such, otherwise just
return to userspace. If there is a tick, it means that the environment is
not suitable for isolation anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
