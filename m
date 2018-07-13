Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73C726B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 18:13:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id x14-v6so28872438ioa.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 15:13:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s63-v6sor2297525its.52.2018.07.13.15.13.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 15:13:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180712172942.10094-11-hannes@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org> <20180712172942.10094-11-hannes@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 13 Jul 2018 15:13:07 -0700
Message-ID: <CAJuCfpHGhSs6upZj0ARng-rE1Nbtcr_XHynZhN7EgGdC16tpPg@mail.gmail.com>
Subject: Re: [RFC PATCH 10/10] psi: aggregate ongoing stall events when
 somebody reads pressure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 10:29 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Right now, psi reports pressure and stall times of already concluded
> stall events. For most use cases this is current enough, but certain
> highly latency-sensitive applications, like the Android OOM killer,

to be more precise, it's Android LMKD (low memory killer daemon) not
to be confused with kernel OOM killer.

> might want to know about and react to stall states before they have
> even concluded (e.g. a prolonged reclaim cycle).
>
> This patches the procfs/cgroupfs interface such that when the pressure
> metrics are read, the current per-cpu states, if any, are taken into
> account as well.
>
> Any ongoing states are concluded, their time snapshotted, and then
> restarted. This requires holding the rq lock to avoid corruption. It
> could use some form of rq lock ratelimiting or avoidance.
>
> Requested-by: Suren Baghdasaryan <surenb@google.com>
> Not-yet-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---

IMHO this description is a little difficult to understand. In essence,
PSI information is being updated periodically every 2secs and without
this patch the data can be stale at the time when we read it (because
it was last updated up to 2secs ago). To avoid this we update the PSI
"total" values when data is being read.

>  kernel/sched/psi.c | 56 +++++++++++++++++++++++++++++++++++++---------
>  1 file changed, 46 insertions(+), 10 deletions(-)
>
> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> index 53e0b7b83e2e..5a6c6057f775 100644
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -190,7 +190,7 @@ static void calc_avgs(unsigned long avg[3], u64 time, int missed_periods)
>         }
>  }
>
> -static bool psi_update_stats(struct psi_group *group)
> +static bool psi_update_stats(struct psi_group *group, bool ondemand)
>  {
>         u64 some[NR_PSI_RESOURCES] = { 0, };
>         u64 full[NR_PSI_RESOURCES] = { 0, };
> @@ -200,8 +200,6 @@ static bool psi_update_stats(struct psi_group *group)
>         int cpu;
>         int r;
>
> -       mutex_lock(&group->stat_lock);
> -
>         /*
>          * Collect the per-cpu time buckets and average them into a
>          * single time sample that is normalized to wallclock time.
> @@ -218,10 +216,36 @@ static bool psi_update_stats(struct psi_group *group)
>         for_each_online_cpu(cpu) {
>                 struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
>                 unsigned long nonidle;
> +               struct rq_flags rf;
> +               struct rq *rq;
> +               u64 now;
>
> -               if (!groupc->nonidle_time)
> +               if (!groupc->nonidle_time && !groupc->nonidle)
>                         continue;
>
> +               /*
> +                * We come here for two things: 1) periodic per-cpu
> +                * bucket flushing and averaging and 2) when the user
> +                * wants to read a pressure file. For flushing and
> +                * averaging, which is relatively infrequent, we can
> +                * be lazy and tolerate some raciness with concurrent
> +                * updates to the per-cpu counters. However, if a user
> +                * polls the pressure state, we want to give them the
> +                * most uptodate information we have, including any
> +                * currently active state which hasn't been timed yet,
> +                * because in case of an iowait or a reclaim run, that
> +                * can be significant.
> +                */
> +               if (ondemand) {
> +                       rq = cpu_rq(cpu);
> +                       rq_lock_irq(rq, &rf);
> +
> +                       now = cpu_clock(cpu);
> +
> +                       groupc->nonidle_time += now - groupc->nonidle_start;
> +                       groupc->nonidle_start = now;
> +               }
> +
>                 nonidle = nsecs_to_jiffies(groupc->nonidle_time);
>                 groupc->nonidle_time = 0;
>                 nonidle_total += nonidle;
> @@ -229,13 +253,27 @@ static bool psi_update_stats(struct psi_group *group)
>                 for (r = 0; r < NR_PSI_RESOURCES; r++) {
>                         struct psi_resource *res = &groupc->res[r];
>
> +                       if (ondemand && res->state != PSI_NONE) {
> +                               bool is_full = res->state == PSI_FULL;
> +
> +                               res->times[is_full] += now - res->state_start;
> +                               res->state_start = now;
> +                       }
> +
>                         some[r] += (res->times[0] + res->times[1]) * nonidle;
>                         full[r] += res->times[1] * nonidle;
>
> -                       /* It's racy, but we can tolerate some error */
>                         res->times[0] = 0;
>                         res->times[1] = 0;
>                 }
> +
> +               if (ondemand)
> +                       rq_unlock_irq(rq, &rf);
> +       }
> +
> +       for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +               do_div(some[r], max(nonidle_total, 1UL));
> +               do_div(full[r], max(nonidle_total, 1UL));
>         }
>
>         /*
> @@ -249,12 +287,10 @@ static bool psi_update_stats(struct psi_group *group)
>          * activity, thus no data, and clock ticks are sporadic. The
>          * below handles both.
>          */
> +       mutex_lock(&group->stat_lock);
>
>         /* total= */
>         for (r = 0; r < NR_PSI_RESOURCES; r++) {
> -               do_div(some[r], max(nonidle_total, 1UL));
> -               do_div(full[r], max(nonidle_total, 1UL));
> -
>                 group->some[r] += some[r];
>                 group->full[r] += full[r];
>         }
> @@ -301,7 +337,7 @@ static void psi_clock(struct work_struct *work)
>          * go - see calc_avgs() and missed_periods.
>          */
>
> -       nonidle = psi_update_stats(group);
> +       nonidle = psi_update_stats(group, false);
>
>         if (nonidle) {
>                 unsigned long delay = 0;
> @@ -570,7 +606,7 @@ int psi_show(struct seq_file *m, struct psi_group *group, enum psi_res res)
>         if (psi_disabled)
>                 return -EOPNOTSUPP;
>
> -       psi_update_stats(group);
> +       psi_update_stats(group, true);
>
>         for (w = 0; w < 3; w++) {
>                 avg[0][w] = group->avg_some[res][w];
> --
> 2.18.0
>
