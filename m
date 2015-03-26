Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD9B6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 16:18:25 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so73186429pdb.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 13:18:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qh9si2791311pab.98.2015.03.26.13.18.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 13:18:24 -0700 (PDT)
Date: Thu, 26 Mar 2015 13:18:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-Id: <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
In-Reply-To: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: hannes@cmpxchg.org, cl@linux.com, linaro-kernel@lists.linaro.org, linux-kernel@vger.kernel.org, vinmenon@codeaurora.org, shashim@codeaurora.org, mhocko@suse.cz, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On Thu, 26 Mar 2015 11:09:01 +0530 Viresh Kumar <viresh.kumar@linaro.org> wrote:

> A delayed work to schedule vmstat_shepherd() is queued at periodic intervals for
> internal working of vmstat core. This work and its timer end up waking an idle
> cpu sometimes, as this always stays on CPU0.
> 
> Because we re-queue the work from its handler, idle_cpu() returns false and so
> the timer (used by delayed work) never migrates to any other CPU.
> 
> This may not be the desired behavior always as waking up an idle CPU to queue
> work on few other CPUs isn't good from power-consumption point of view.
> 
> In order to avoid waking up an idle core, we can replace schedule_delayed_work()
> with a normal work plus a separate timer. The timer handler will then queue the
> work after re-arming the timer. If the CPU was idle before the timer fired,
> idle_cpu() will mostly return true and the next timer shall be migrated to a
> non-idle CPU.
> 
> But the timer core has a limitation, when the timer is re-armed from its
> handler, timer core disables migration of that timer to other cores. Details of
> that limitation are present in kernel/time/timer.c:__mod_timer() routine.
> 
> Another simple yet effective solution can be to keep two timers with same
> handler and keep toggling between them, so that the above limitation doesn't
> hold true anymore.
> 
> This patch replaces schedule_delayed_work() with schedule_work() plus two
> timers. After this, it was seen that the timer and its do get migrated to other
> non-idle CPUs, when the local cpu is idle.

Shouldn't this be viewed as a shortcoming of the core timer code? 

vmstat_shepherd() is merely rescheduling itself with
schedule_delayed_work().  That's a dead bog simple operation and if
it's producing suboptimal behaviour then we shouldn't be fixing it with
elaborate workarounds in the caller?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
