Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 94CC8828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 11:49:40 -0500 (EST)
Received: by mail-lf0-f49.google.com with SMTP id d17so12769956lfb.1
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 08:49:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n9si964339lbd.135.2016.01.08.08.49.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 08:49:39 -0800 (PST)
Date: Fri, 8 Jan 2016 17:49:31 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v3 22/22] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160108164931.GT3178@pathway.suse.cz>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-23-git-send-email-pmladek@suse.com>
 <20160107115531.34279a9b@icelake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107115531.34279a9b@icelake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, linux-pm@vger.kernel.org

On Thu 2016-01-07 11:55:31, Jacob Pan wrote:
> On Wed, 18 Nov 2015 14:25:27 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> I have tested this patchset and found no obvious issues in terms of
> functionality, power and performance. Tested CPU online/offline,
> suspend resume, freeze etc.
> Power numbers are comparable too. e.g. on IVB 8C system. Inject idle
> from 5 to 50% and read package power while running CPU bound workload.

Great news. Thanks a lot for testing.

> > IMHO, the most natural way is to split one cycle into two works.
> > First one does some balancing and let the CPU work normal
> > way for some time. The second work checks what the CPU has done
> > in the meantime and put it into C-state to reach the required
> > idle time ratio. The delay between the two works is achieved
> > by the delayed kthread work.
> > 
> > The two works have to share some data that used to be local
> > variables of the single kthread function. This is achieved
> > by the new per-CPU struct kthread_worker_data. It might look
> > as a complication. On the other hand, the long original kthread
> > function was not nice either.
> > 
> > The two works are queuing each other. It makes it a bit tricky to
> > break it when we want to stop the worker. We use the global and
> > per-worker "clamping" variables to make sure that the re-queuing
> > eventually stops. We also cancel the works to make it faster.
> > Note that the canceling is not reliable because the handling
> > of the two variables and queuing is not synchronized via a lock.
> > But it is not a big deal because it is just an optimization.
> > The job is stopped faster than before in most cases.

> I am not convinced this added complexity is necessary, here are my
> concerns by breaking down into two work items.

I am not super happy with the split either. But the current state has
its drawback as well.


> - overhead of queuing,

Good question. Here is a rather typical snippet from function_graph
tracer of the clamp_balancing func:

  31)               |  clamp_balancing_func() {
  31)               |    queue_delayed_kthread_work() {
  31)               |      __queue_delayed_kthread_work() {
  31)               |        add_timer() {
  31)   4.906 us    |        }
  31)   5.959 us    |      }
  31)   9.702 us    |    }
  31) + 10.878 us   |  }

On one hand it spends most of the time (10 of 11 secs) in queueing
the work. On the other hand, half of this time is spent on adding
the timer. schedule_timeout() would need to setup the timer as well.


Here is a snippet from clamp_idle_injection_func()

  31)               |  clamp_idle_injection_func() {
  31)               |    smp_apic_timer_interrupt() {
  31) + 67.523 us   |    }
  31)               |    smp_apic_timer_interrupt() {
  31) + 59.946 us   |    }
  ...
  31)               |    queue_kthread_work() {
  31)   4.314 us    |    }
  31) * 24075.11 us |  }


Of course, it spends most of the time in the idle state. Anyway, the
time spent on queuing is negligible in compare with the time spent
in the several timer interrupt handlers.


> per cpu data as you already mentioned.

On the other hand, the variables need to be stored somewhere.
Also it helps to split the rather long function into more pieces.


> - since we need to have very tight timing control, two items may limit
>   our turnaround time. Wouldn't it take one extra tick for the scheduler
>   to run the balance work then add delay? as opposed to just
>   schedule_timeout()?

Kthread worker processes works until the queue is empty. It calls
try_to_freeze() and __preempt_schedule() between the works.
Where __preempt_schedule() is hidden in the spin_unlock_irq().

try_to_freeze() is in the original code as well.

Is the __preempt_schedule() a problem? It allows to switch the process
when needed. I thought that it was safe because try_to_freeze() might
have slept as well.


> - vulnerable to future changes of queuing work

The question is if it is safe to sleep, freeze, or even migrate
the system between the works. It looks like because of the
try_to_freeze() and schedule_interrupt() calls in the original code.

BTW: I wonder if the original code correctly handle freezing after
the schedule_timeout(). It does not call try_to_freeze()
there and the forced idle states might block freezing.
I think that the small overhead of kthread works is worth
solving such bugs. It makes it easier to maintain these
sleeping states.


Thanks a lot for feedback,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
