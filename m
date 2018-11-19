Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 863066B18C3
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 00:19:33 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x197so9419772ywx.15
        for <linux-mm@kvack.org>; Sun, 18 Nov 2018 21:19:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t11-v6sor14892529ybc.175.2018.11.18.21.19.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Nov 2018 21:19:32 -0800 (PST)
MIME-Version: 1.0
References: <1542583623-101514-1-git-send-email-jiangbiao@linux.alibaba.com>
In-Reply-To: <1542583623-101514-1-git-send-email-jiangbiao@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sun, 18 Nov 2018 21:19:20 -0800
Message-ID: <CALvZod5nd4nx5KzhyzCFio9dkEPaAMdQOoFQn=RQJ4Nbhsz23A@mail.gmail.com>
Subject: Re: [PATCH] mm/memcontrol: improve memory.stat reporting
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiangbiao@linux.alibaba.com
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, yang.shi@linux.alibaba.com, xlpang@linux.alibaba.com

On Sun, Nov 18, 2018 at 3:27 PM Jiang Biao <jiangbiao@linux.alibaba.com> wrote:
>
> commit a983b5ebee57 ("mm:memcontrol: fix excessive complexity in
> memory.stat reporting") introduce 8%+ performance regression for
> page_fault3 of will-it-scale benchmark:
>
> Before commit a983b5ebee57,
> #./runtest.py page_fault3
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,729990,95.68,725437,95.66,725437 (Single process)
> ...
> 24,11476599,0.18,2185947,32.67,17410488 (24 processes for 24 cores)
>
> After commit,
> #./runtest.py page_fault3
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,697310,95.61,703615,95.66,703615 (-4.48%)
> ...
> 24,10485783,0.20,2047735,35.99,16886760 (-8.63%)
>
> Get will-it-scale benchmark and test page_fault3,
>  # git clone https://github.com/antonblanchard/will-it-scale.git
>  # cd will-it-scale/
>  # ./runtest.py page_fault3
>
> There are to factors that affect the proformance,
> 1, CHARGE_BATCH is too small that causes bad contention when charge
> global stats/events.
> 2, Disabling interrupt in count_memcg_events/mod_memcg_stat.
>
> This patch increase the CHARGE_BATCH to 256 to ease the contention,
> And narrow the scope of disabling interrupt(only if x > CHARGE_BATCH)
> when charging global stats/events, taking percpu counter's
> implementation as reference.
>
> This patch could fix the performance regression,
> #./runtest.py page_fault3
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,729975,95.64,730302,95.68,730302
> 24,11441125,0.07,2100586,31.08,17527248
>
> Signed-off-by: Jiang Biao <jiangbiao@linux.alibaba.com>
> ---
>  include/linux/memcontrol.h | 28 +++++++++++++---------------
>  1 file changed, 13 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index db3e6bb..7546774 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -595,7 +595,7 @@ static inline void set_task_memcg_oom_skip(struct task_struct *p)
>   * size of first charge trial. "32" comes from vmscan.c's magic value.
>   * TODO: maybe necessary to use big numbers in big irons.
>   */
> -#define CHARGE_BATCH   32U
> +#define CHARGE_BATCH   256U
>

I am already not really happy with '32U' as it has introduced
potentially 100s of MiB discrepancy in the stats on large machines. On
a 100 cpu and 64 KiB page machine, the error in the stats can be up to
(32 * 65565 * 100) bytes.

I was thinking of piggybacking stat_refresh on syncing the per-cpu
memcg stats but still couldn't figure out the right way to do that
(i.e. not traversing memcg tree on each cpu in parallel).

Also can you please rebase your patch over the latest mm or linus tree?

>  static inline void __count_memcg_events(struct mem_cgroup *memcg,
>                                 enum mem_cgroup_events_index idx,
> @@ -608,22 +608,21 @@ static inline void __count_memcg_events(struct mem_cgroup *memcg,
>
>         x = count + __this_cpu_read(memcg->stat->events[idx]);
>         if (unlikely(x > CHARGE_BATCH)) {
> +               unsigned long flags;
> +               local_irq_save(flags);

Does this fine grained interrupt disable really help? Also don't you
need to reevaluate x after disabling interrupt?

>                 atomic_long_add(x, &memcg->events[idx]);
> -               x = 0;
> +               __this_cpu_sub(memcg->stat->events[idx], x - count);

Why 'x - count'?

> +               local_irq_restore(flags);
> +       } else {
> +               this_cpu_add(memcg->stat->events[idx], count);
>         }
> -
> -       __this_cpu_write(memcg->stat->events[idx], x);
>  }
>
>  static inline void count_memcg_events(struct mem_cgroup *memcg,
>                                 enum mem_cgroup_events_index idx,
>                                 unsigned long count)
>  {
> -       unsigned long flags;
> -
> -       local_irq_save(flags);
>         __count_memcg_events(memcg, idx, count);
> -       local_irq_restore(flags);
>  }
>
>  static inline void
> @@ -698,25 +697,24 @@ static inline void __mod_memcg_stat(struct mem_cgroup *memcg,
>
>         if (mem_cgroup_disabled())
>                 return;
> -
>         if (memcg) {
>                 x = val + __this_cpu_read(memcg->stat->count[idx]);
>                 if (unlikely(abs(x) > CHARGE_BATCH)) {
> +                       unsigned long flags;
> +                       local_irq_save(flags);
>                         atomic_long_add(x, &memcg->stats[idx]);
> -                       x = 0;
> +                       __this_cpu_sub(memcg->stat->count[idx], x - val);
> +                       local_irq_restore(flags);
> +               } else {
> +                       this_cpu_add(memcg->stat->count[idx], val);
>                 }
> -               __this_cpu_write(memcg->stat->count[idx], x);
>         }
>  }
>
>  static inline void mod_memcg_stat(struct mem_cgroup *memcg,
>                         enum mem_cgroup_stat_index idx, int val)
>  {
> -       unsigned long flags;
> -
> -       local_irq_save(flags);
>         __mod_memcg_stat(memcg, idx, val);
> -       local_irq_restore(flags);
>  }
>

thanks,
Shakeel
