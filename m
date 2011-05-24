Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B3BB86B0022
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:32:08 -0400 (EDT)
Date: Tue, 24 May 2011 04:32:03 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1459757587.187076.1306225923651.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <alpine.DEB.2.00.1105231547060.17840@chino.kir.corp.google.com>
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



----- Original Message -----
> On Mon, 23 May 2011, David Rientjes wrote:
> 
> > I already suggested an alternative patch to CAI Qian to greatly
> > increase
> > the granularity of the oom score from a range of 0-1000 to 0-10000
> > to
> > differentiate between tasks within 0.01% of available memory (16MB
> > on CAI
> > Qian's 16GB system). I'll propose this officially in a separate
> > email.
> >
> 
> This is an alternative patch as earlier proposed with suggested
> improvements from Minchan. CAI, would it be possible to test this out
> on
> your usecase?
Sure, will test KOSAKI Motohiro's v2 patches plus this one.
> I'm indifferent to the actual scale of OOM_SCORE_MAX_FACTOR; it could
> be
> 10 as proposed in this patch or even increased higher for higher
> resolution.
> 
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -38,6 +38,9 @@ int sysctl_oom_kill_allocating_task;
> int sysctl_oom_dump_tasks = 1;
> static DEFINE_SPINLOCK(zone_scan_lock);
> 
> +#define OOM_SCORE_MAX_FACTOR 10
> +#define OOM_SCORE_MAX (OOM_SCORE_ADJ_MAX * OOM_SCORE_MAX_FACTOR)
> +
> #ifdef CONFIG_NUMA
> /**
> * has_intersects_mems_allowed() - check task eligiblity for kill
> @@ -160,7 +163,7 @@ unsigned int oom_badness(struct task_struct *p,
> struct mem_cgroup *mem,
> */
> if (p->flags & PF_OOM_ORIGIN) {
> task_unlock(p);
> - return 1000;
> + return OOM_SCORE_MAX;
> }
> 
> /*
> @@ -177,32 +180,38 @@ unsigned int oom_badness(struct task_struct *p,
> struct mem_cgroup *mem,
> points = get_mm_rss(p->mm) + p->mm->nr_ptes;
> points += get_mm_counter(p->mm, MM_SWAPENTS);
> 
> - points *= 1000;
> + points *= OOM_SCORE_MAX;
> points /= totalpages;
> task_unlock(p);
> 
> /*
> - * Root processes get 3% bonus, just like the __vm_enough_memory()
> - * implementation used by LSMs.
> + * Root processes get a bonus of 1% per 10% of memory used.
> */
> - if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> - points -= 30;
> + if (has_capability_noaudit(p, CAP_SYS_ADMIN)) {
> + int bonus;
> + int granularity;
> +
> + bonus = OOM_SCORE_MAX / 100; /* bonus is 1% */
> + granularity = OOM_SCORE_MAX / 10; /* granularity is 10% */
> +
> + points -= bonus * (points / granularity);
> + }
> 
> /*
> * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
> * either completely disable oom killing or always prefer a certain
> * task.
> */
> - points += p->signal->oom_score_adj;
> + points += p->signal->oom_score_adj * OOM_SCORE_MAX_FACTOR;
> 
> /*
> * Never return 0 for an eligible task that may be killed since it's
> - * possible that no single user task uses more than 0.1% of memory
> and
> + * possible that no single user task uses more than 0.01% of memory
> and
> * no single admin tasks uses more than 3.0%.
> */
> if (points <= 0)
> return 1;
> - return (points < 1000) ? points : 1000;
> + return (points < OOM_SCORE_MAX) ? points : OOM_SCORE_MAX;
> }
> 
> /*
> @@ -314,7 +323,7 @@ static struct task_struct
> *select_bad_process(unsigned int *ppoints,
> */
> if (p == current) {
> chosen = p;
> - *ppoints = 1000;
> + *ppoints = OOM_SCORE_MAX;
> } else {
> /*
> * If this task is not being ptraced on exit,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
