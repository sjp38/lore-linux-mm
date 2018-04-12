Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6759C6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 20:47:56 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id h32-v6so2410955pld.15
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 17:47:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o61-v6sor999693pld.117.2018.04.11.17.47.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Apr 2018 17:47:55 -0700 (PDT)
Date: Thu, 12 Apr 2018 09:47:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm, slab: reschedule cache_reap() on the same CPU
Message-ID: <20180412004747.GA253442@rodete-desktop-imager.corp.google.com>
References: <20180410081531.18053-1-vbabka@suse.cz>
 <20180411070007.32225-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180411070007.32225-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, John Stultz <john.stultz@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Stephen Boyd <sboyd@kernel.org>

On Wed, Apr 11, 2018 at 09:00:07AM +0200, Vlastimil Babka wrote:
> cache_reap() is initially scheduled in start_cpu_timer() via
> schedule_delayed_work_on(). But then the next iterations are scheduled via
> schedule_delayed_work(), i.e. using WORK_CPU_UNBOUND.
> 
> Thus since commit ef557180447f ("workqueue: schedule WORK_CPU_UNBOUND work on
> wq_unbound_cpumask CPUs") there is no guarantee the future iterations will run
> on the originally intended cpu, although it's still preferred. I was able to
> demonstrate this with /sys/module/workqueue/parameters/debug_force_rr_cpu.
> IIUC, it may also happen due to migrating timers in nohz context. As a result,
> some cpu's would be calling cache_reap() more frequently and others never.
> 
> This patch uses schedule_delayed_work_on() with the current cpu when scheduling
> the next iteration.

Could you write down part about "so what's the user effect on some condition?".
It would really help to pick up the patch.

> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Fixes: ef557180447f ("workqueue: schedule WORK_CPU_UNBOUND work on wq_unbound_cpumask CPUs")
> CC: <stable@vger.kernel.org>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Lai Jiangshan <jiangshanlai@gmail.com>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Stephen Boyd <sboyd@kernel.org>
> ---
>  mm/slab.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 9095c3945425..a76006aae857 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4074,7 +4074,8 @@ static void cache_reap(struct work_struct *w)
>  	next_reap_node();
>  out:
>  	/* Set up the next iteration */
> -	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
> +	schedule_delayed_work_on(smp_processor_id(), work,
> +				round_jiffies_relative(REAPTIMEOUT_AC));
>  }
>  
>  void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
> -- 
> 2.16.3
> 
