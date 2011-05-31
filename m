Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D01006B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 03:50:52 -0400 (EDT)
Date: Tue, 31 May 2011 03:50:45 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1685840459.318633.1306828245496.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4DE49314.3070105@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com



----- Original Message -----
> >> - If you run the same program as root, non root process and
> >> privilege
> >> explicit
> >> dropping processes (e.g. irqbalance) will be killed at first.
> > Hmm, at least there were some programs were root processes but were
> > killed
> > first.
> > [ pid] ppid uid total_vm rss swap score_adj name
> > [ 5720] 5353 0 24421 257 0 0 sshd
> > [ 5353] 1 0 15998 189 0 0 sshd
> > [ 5451] 1 0 19648 235 0 0 master
> > [ 1626] 1 0 2287 129 0 0 dhclient
> 
> Hi
> 
> I can't reproduce this too. Are you sure these processes have a full
> root privilege?
> I've made new debugging patch. After applying following patch, do
> these processes show
> cap=1?
No, all of them had cap=0. Wondering why something like sshd not been
made cap=1 to avoid early oom kill.
> 
> 
> 
> index f0e34d4..fe788df 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -429,7 +429,7 @@ static void dump_tasks(const struct mem_cgroup
> *mem, const nodemask_t *no
> struct task_struct *p;
> struct task_struct *task;
> 
> - pr_info("[ pid] ppid uid total_vm rss swap score_adj name\n");
> + pr_info("[ pid] ppid uid cap total_vm rss swap score_adj name\n");
> for_each_process(p) {
> if (oom_unkillable_task(p, mem, nodemask))
> continue;
> @@ -444,9 +444,9 @@ static void dump_tasks(const struct mem_cgroup
> *mem, const nodemask_t *no
> continue;
> }
> 
> - pr_info("[%6d] %6d %5d %8lu %8lu %8lu %9d %s\n",
> + pr_info("[%6d] %6d %5d %3d %8lu %8lu %8lu %9d %s\n",
> task_tgid_nr(task), task_tgid_nr(task->real_parent),
> - task_uid(task),
> + task_uid(task), has_capability_noaudit(task, CAP_SYS_ADMIN),
> task->mm->total_vm,
> get_mm_rss(task->mm) + task->mm->nr_ptes,
> get_mm_counter(task->mm, MM_SWAPENTS),
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
