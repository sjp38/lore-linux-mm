Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF3E6B0010
	for <linux-mm@kvack.org>; Mon,  7 May 2018 03:31:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w14-v6so18709959wrk.22
        for <linux-mm@kvack.org>; Mon, 07 May 2018 00:31:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5-v6si154611edx.293.2018.05.07.00.31.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 May 2018 00:31:07 -0700 (PDT)
Subject: Re: [PATCH REPOST] Revert mm/vmstat.c: fix vmstat_update() preemption
 BUG
References: <20180504104451.20278-1-bigeasy@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <513014a0-a149-5141-a5a0-9b0a4ce9a8d8@suse.cz>
Date: Mon, 7 May 2018 09:31:05 +0200
MIME-Version: 1.0
In-Reply-To: <20180504104451.20278-1-bigeasy@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On 05/04/2018 12:44 PM, Sebastian Andrzej Siewior wrote:
> This patch reverts commit c7f26ccfb2c3 ("mm/vmstat.c: fix
> vmstat_update() preemption BUG").
> Steven saw a "using smp_processor_id() in preemptible" message and
> added a preempt_disable() section around it to keep it quiet. This is
> not the right thing to do it does not fix the real problem.
> 
> vmstat_update() is invoked by a kworker on a specific CPU. This worker
> it bound to this CPU. The name of the worker was "kworker/1:1" so it
> should have been a worker which was bound to CPU1. A worker which can
> run on any CPU would have a `u' before the first digit.
> 
> smp_processor_id() can be used in a preempt-enabled region as long as
> the task is bound to a single CPU which is the case here. If it could
> run on an arbitrary CPU then this is the problem we have an should seek
> to resolve.
> Not only this smp_processor_id() must not be migrated to another CPU but
> also refresh_cpu_vm_stats() which might access wrong per-CPU variables.
> Not to mention that other code relies on the fact that such a worker
> runs on one specific CPU only.
> 
> Therefore I revert that commit and we should look instead what broke the
> affinity mask of the kworker.

Yes. I think there's an important detail that should be perhaps included
explicitly here. The check check_preemption_disabled() does include this
test:

        /*
         * Kernel threads bound to a single CPU can safely use
         * smp_processor_id():
         */
        if (cpumask_equal(&current->cpus_allowed, cpumask_of(this_cpu)))
                goto out;

So indeed, if kworkers work as expected, there's no false positive bug.

The report in commit c7f26ccfb2c3 included:

      BUG: using smp_processor_id() in preemptible [00000000] code:
      kworker/1:1/269
      caller is vmstat_update+0x50/0xa0
      CPU: 0 PID: 269 Comm: kworker/1:1 Not tainted

I.e. kworker/1 running on CPU 0. Because the BUG was reported, we know
that the test above did not prevent it. That means either the kworker's
cpumask was not restricted to CPU 1 (it included also cpu 0), or it was
restricted, but the restriction was ignored, and it still executed on cpu 0.

Note the report also said "Attempting to hotplug CPUs with
CONFIG_VM_EVENT_COUNTERS enabled can...". IIRC Tejun mentioned that
during hotplug (or hotremove, actually?) the guarantees are off, but
vmstat should not schedule work items on such cpus due to its hooks/checks.

In any case I agree that the revert should be done immediately even
before fixing the underlying bug. The preempt_disable/enable doesn't
prevent the bug, it only prevents the debugging code from actually
reporting it! Note that it's debugging code (CONFIG_DEBUG_PREEMPT) that
production kernels most likely don't have enabled, so we are not even
helping them not crash (while allowing possible data corruption).

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> Cc: Steven J. Hill <steven.hill@cavium.com>
> Cc: Tejun Heo <htejun@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>  mm/vmstat.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 33581be705f0..40b2db6db6b1 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1839,11 +1839,9 @@ static void vmstat_update(struct work_struct *w)
>  		 * to occur in the future. Keep on running the
>  		 * update worker thread.
>  		 */
> -		preempt_disable();
>  		queue_delayed_work_on(smp_processor_id(), mm_percpu_wq,
>  				this_cpu_ptr(&vmstat_work),
>  				round_jiffies_relative(sysctl_stat_interval));
> -		preempt_enable();
>  	}
>  }
>  
> 
