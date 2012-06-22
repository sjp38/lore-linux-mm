Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DD6D06B0273
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 18:54:27 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2466328ghr.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 15:54:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 22 Jun 2012 18:54:06 -0400
Message-ID: <CAHGf_=p4SS7qA_eRpBF0PawyUa8DpYncL0LS-=B4tHFaDUKV-w@mail.gmail.com>
Subject: Re: [patch] mm, oom: replace some information in tasklist dump
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Fri, Jun 22, 2012 at 5:45 PM, David Rientjes <rientjes@google.com> wrote=
:
> The number of ptes and swap entries are used in the oom killer's badness
> heuristic, so they should be shown in the tasklist dump.
>
> This patch adds those fields and replaces cpu and oom_adj values that are
> currently emitted. =A0Cpu isn't interesting and oom_adj is deprecated and
> will be removed later this year, the same information is already
> displayed as oom_score_adj which is used internally.
>
> At the same time, make the documentation a little more clear to state
> this information is helpful to determine why the oom killer chose the
> task it did to kill.
>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
> =A0Documentation/sysctl/vm.txt | =A0 =A07 ++++---
> =A0mm/oom_kill.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 11 ++++++-----
> =A02 files changed, 10 insertions(+), 8 deletions(-)
>
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -502,9 +502,10 @@ oom_dump_tasks
>
> =A0Enables a system-wide task dump (excluding kernel threads) to be
> =A0produced when the kernel performs an OOM-killing and includes such
> -information as pid, uid, tgid, vm size, rss, cpu, oom_adj score, and
> -name. =A0This is helpful to determine why the OOM killer was invoked
> -and to identify the rogue task that caused it.
> +information as pid, uid, tgid, vm size, rss, nr_ptes, swapents,
> +oom_score_adj score, and name. =A0This is helpful to determine why the
> +OOM killer was invoked, to identify the rogue task that caused it,
> +and to determine why the OOM killer chose the task it did to kill.
>
> =A0If this is set to zero, this information is suppressed. =A0On very
> =A0large systems with thousands of tasks it may not be feasible to dump
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -371,8 +371,8 @@ static struct task_struct *select_bad_process(unsigne=
d int *ppoints,
> =A0* Dumps the current memory state of all eligible tasks. =A0Tasks not i=
n the same
> =A0* memcg, not in the same cpuset, or bound to a disjoint set of mempoli=
cy nodes
> =A0* are not shown.
> - * State information includes task's pid, uid, tgid, vm size, rss, cpu, =
oom_adj
> - * value, oom_score_adj value, and name.
> + * State information includes task's pid, uid, tgid, vm size, rss, nr_pt=
es,
> + * swapents, oom_score_adj value, and name.
> =A0*
> =A0* Call with tasklist_lock read-locked.
> =A0*/
> @@ -381,7 +381,7 @@ static void dump_tasks(const struct mem_cgroup *memcg=
, const nodemask_t *nodemas
> =A0 =A0 =A0 =A0struct task_struct *p;
> =A0 =A0 =A0 =A0struct task_struct *task;
>
> - =A0 =A0 =A0 pr_info("[ pid ] =A0 uid =A0tgid total_vm =A0 =A0 =A0rss cp=
u oom_adj oom_score_adj name\n");
> + =A0 =A0 =A0 pr_info("[ pid ] =A0 uid =A0tgid total_vm =A0 =A0 =A0rss nr=
_ptes swapents oom_score_adj name\n");
> =A0 =A0 =A0 =A0for_each_process(p) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (oom_unkillable_task(p, memcg, nodemask=
))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -396,10 +396,11 @@ static void dump_tasks(const struct mem_cgroup *mem=
cg, const nodemask_t *nodemas
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("[%5d] %5d %5d %8lu %8lu %3u =A0 =
=A0 %3d =A0 =A0 =A0 =A0 %5d %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu =
=A0 =A0 =A0 =A0 %5d %s\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task->pid, from_kuid(&init=
_user_ns, task_uid(task)),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task->tgid, task->mm->tota=
l_vm, get_mm_rss(task->mm),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_cpu(task), task->signa=
l->oom_adj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task->mm->nr_ptes,

nr_ptes should be folded into rss. it's "resident".
btw, /proc rss info should be fixed too.



> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_mm_counter(task->mm, MM=
_SWAPENTS),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task->signal->oom_score_ad=
j, task->comm);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task_unlock(task);
> =A0 =A0 =A0 =A0}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
