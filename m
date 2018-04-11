Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E60896B0006
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 09:56:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i128so908028pfg.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 06:56:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 69-v6si1171144pla.390.2018.04.11.06.56.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 06:56:45 -0700 (PDT)
Subject: Re: [PATCH] Revert mm/vmstat.c: fix vmstat_update() preemption BUG
References: <20180411095757.28585-1-bigeasy@linutronix.de>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ef663b6d-9e9f-65c6-25ec-ffa88347c58d@suse.cz>
Date: Wed, 11 Apr 2018 15:56:43 +0200
MIME-Version: 1.0
In-Reply-To: <20180411095757.28585-1-bigeasy@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de, "Steven J . Hill" <steven.hill@cavium.com>, Tejun Heo <htejun@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>

On 04/11/2018 11:57 AM, Sebastian Andrzej Siewior wrote:
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

Oh my, and I have just been assured by Tejun that his cannot happen :)
And yet, in the original report [1] I see:

CPU: 0 PID: 269 Comm: kworker/1:1 Not tainted

So is this perhaps related to the cpu hotplug that [1] mentions? e.g. is
the cpu being hotplugged cpu 1, the worker started too early before
stuff can be scheduled on the CPU, so it has to run on different than
designated CPU?

[1] https://marc.info/?l=linux-mm&m=152088260625433&w=2

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
> 
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
