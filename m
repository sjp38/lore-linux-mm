Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C9DEF6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 21:17:53 -0400 (EDT)
Date: Tue, 31 May 2011 21:17:48 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <566395823.341360.1306891068362.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4DE4BC64.3040807@jp.fujitsu.com>
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
> (2011/05/31 17:11), KOSAKI Motohiro wrote:
> >>> Then, I believe your distro applying distro specific patch to ssh.
> >>> Which distro are you using now?
> >> It is a Fedora-like distro.
> 
> So, Does this makes sense?
Looks like so, at least now sshd can survive from oom-killed.
> 
> 
> 
> From e47fedaa546499fa3d4196753194db0609cfa2e5 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 31 May 2011 18:28:30 +0900
> Subject: [PATCH] oom: use euid instead of CAP_SYS_ADMIN for protection
> root process
> 
> Recently, many userland daemon prefer to use libcap-ng and drop
> all privilege just after startup. Because of (1) Almost privilege
> are necessary only when special file open, and aren't necessary
> read and write. (2) In general, privilege dropping brings better
> protection from exploit when bugs are found in the daemon.
> 
> But, it makes suboptimal oom-killer behavior. CAI Qian reported
> oom killer killed some important daemon at first on his fedora
> like distro. Because they've lost CAP_SYS_ADMIN.
> 
> Of course, we recommend to drop privileges as far as possible
> instead of keeping them. Thus, oom killer don't have to check
> any capability. It implicitly suggest wrong programming style.
> 
> This patch change root process check way from CAP_SYS_ADMIN to
> just euid==0.
> 
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> mm/oom_kill.c | 8 ++++----
> 1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 59eda6e..4e1e8a5 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -203,7 +203,7 @@ unsigned long oom_badness(struct task_struct *p,
> struct mem_cgroup *mem,
> * Root processes get 3% bonus, just like the __vm_enough_memory()
> * implementation used by LSMs.
> */
> - if (protect_root && has_capability_noaudit(p, CAP_SYS_ADMIN)) {
> + if (protect_root && (task_euid(p) == 0)) {
> if (points >= totalpages / 32)
> points -= totalpages / 32;
> else
> @@ -429,7 +429,7 @@ static void dump_tasks(const struct mem_cgroup
> *mem, const nodemask_t *nodemask)
> struct task_struct *p;
> struct task_struct *task;
> 
> - pr_info("[ pid] ppid uid cap total_vm rss swap score_adj name\n");
> + pr_info("[ pid] ppid uid euid total_vm rss swap score_adj name\n");
> for_each_process(p) {
> if (oom_unkillable_task(p, mem, nodemask))
> continue;
> @@ -444,9 +444,9 @@ static void dump_tasks(const struct mem_cgroup
> *mem, const nodemask_t *nodemask)
> continue;
> }
> 
> - pr_info("[%6d] %6d %5d %3d %8lu %8lu %8lu %9d %s\n",
> + pr_info("[%6d] %6d %5d %5d %8lu %8lu %8lu %9d %s\n",
> task_tgid_nr(task), task_tgid_nr(task->real_parent),
> - task_uid(task), has_capability_noaudit(task, CAP_SYS_ADMIN),
> + task_uid(task), task_euid(task),
> task->mm->total_vm,
> get_mm_rss(task->mm) + task->mm->nr_ptes,
> get_mm_counter(task->mm, MM_SWAPENTS),
> --
> 1.7.3.1
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign
> http://stopthemeter.ca/
> Don't email: href=mailto:"dont@kvack.org"> email@kvack.org 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
