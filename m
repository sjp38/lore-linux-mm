Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 291B56B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 00:31:59 -0400 (EDT)
Received: by qyk30 with SMTP id 30so3811203qyk.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 21:31:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD6207E.1070300@jp.fujitsu.com>
References: <4DD61F80.1020505@jp.fujitsu.com>
	<4DD6207E.1070300@jp.fujitsu.com>
Date: Mon, 23 May 2011 13:31:57 +0900
Message-ID: <BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

2011/5/20 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> CAI Qian reported oom-killer killed all system daemons in his
> system at first if he ran fork bomb as root. The problem is,
> current logic give them bonus of 3% of system ram. Example,
> he has 16GB machine, then root processes have ~500MB oom
> immune. It bring us crazy bad result. _all_ processes have
> oom-score=3D1 and then, oom killer ignore process memory usage
> and kill random process. This regression is caused by commit
> a63d83f427 (oom: badness heuristic rewrite).
>
> This patch changes select_bad_process() slightly. If oom points =3D=3D 1,
> it's a sign that the system have only root privileged processes or
> similar. Thus, select_bad_process() calculate oom badness without
> root bonus and select eligible process.
>
> Also, this patch move finding sacrifice child logic into
> select_bad_process(). It's necessary to implement adequate
> no root bonus recalculation. and it makes good side effect,
> current logic doesn't behave as the doc.
>
> Documentation/sysctl/vm.txt says
>
> =C2=A0 =C2=A0oom_kill_allocating_task
>
> =C2=A0 =C2=A0If this is set to non-zero, the OOM killer simply kills the =
task that
> =C2=A0 =C2=A0triggered the out-of-memory condition. =C2=A0This avoids the=
 expensive
> =C2=A0 =C2=A0tasklist scan.
>
> IOW, oom_kill_allocating_task shouldn't search sacrifice child.
> This patch also fixes this issue.
>
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =C2=A0fs/proc/base.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0include/linux/oom.h | =C2=A0 =C2=A03 +-
> =C2=A0mm/oom_kill.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 89 ++++++++++++++++++++=
++++++++----------------------
> =C2=A03 files changed, 53 insertions(+), 41 deletions(-)
>
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index d6b0424..b608b69 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -482,7 +482,7 @@ static int proc_oom_score(struct task_struct *task, c=
har *buffer)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_lock(&tasklist_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (pid_alive(task)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points =3D oom_badness=
(task, NULL, NULL, totalpages);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points =3D oom_badness=
(task, NULL, NULL, totalpages, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ratio =3D points *=
 1000 / totalpages;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_unlock(&tasklist_lock);
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 0f5b588..3dd3669 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -42,7 +42,8 @@ enum oom_constraint {
>
> =C2=A0/* The badness from the OOM killer */
> =C2=A0extern unsigned long oom_badness(struct task_struct *p, struct mem_=
cgroup *mem,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 const nodemask_t *nodemask, unsigned long totalpages);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 const nodemask_t *nodemask, unsigned long totalpages,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 int protect_root);
> =C2=A0extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gf=
p_flags);
> =C2=A0extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp=
_flags);
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8bbc3df..7d280d4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -133,7 +133,8 @@ static bool oom_unkillable_task(struct task_struct *p=
,
> =C2=A0* task consuming the most memory to avoid subsequent oom failures.
> =C2=A0*/
> =C2=A0unsigned long oom_badness(struct task_struct *p, struct mem_cgroup =
*mem,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 c=
onst nodemask_t *nodemask, unsigned long totalpages)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0const nodemask_t *nodemask, unsigned long totalpages,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0int protect_root)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long points;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long score_adj =3D 0;
> @@ -186,7 +187,7 @@ unsigned long oom_badness(struct task_struct *p, stru=
ct mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * XXX: Too large bonus, example, if the syste=
m have tera-bytes memory..
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (has_capability_noaudit(p, CAP_SYS_ADMIN)) {
> + =C2=A0 =C2=A0 =C2=A0 if (protect_root && has_capability_noaudit(p, CAP_=
SYS_ADMIN)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (points >=3D to=
talpages / 32)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0points -=3D totalpages / 32;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> @@ -298,8 +299,11 @@ static struct task_struct *select_bad_process(unsign=
ed long *ppoints,
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *g, *p;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *chosen =3D NULL;
> - =C2=A0 =C2=A0 =C2=A0 *ppoints =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 int protect_root =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long chosen_points =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *child;
>
> + retry:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0do_each_thread_reverse(g, p) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long poin=
ts;
>
> @@ -332,7 +336,7 @@ static struct task_struct *select_bad_process(unsigne=
d long *ppoints,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (p =3D=3D current) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0chosen =3D p;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *ppoints =3D ULONG_MAX;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 chosen_points =3D ULONG_MAX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0} else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * If this task is not being ptraced =
on exit,
> @@ -345,13 +349,49 @@ static struct task_struct *select_bad_process(unsig=
ned long *ppoints,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points =3D oom_badness=
(p, mem, nodemask, totalpages);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (points > *ppoints)=
 {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points =3D oom_badness=
(p, mem, nodemask, totalpages, protect_root);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (points > chosen_po=
ints) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0chosen =3D p;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 *ppoints =3D points;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 chosen_points =3D points;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0} while_each_thread(g, p);
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* chosen_point=3D=3D1 may be a sign that roo=
t privilege bonus is too large
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* and we choose wrong task. Let's recalculat=
e oom score without the
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* dubious bonus.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (protect_root && (chosen_points =3D=3D 1)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 protect_root =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto retry;
> + =C2=A0 =C2=A0 =C2=A0 }

The idea is good to me.
But once we meet it, should we give up protecting root privileged processes=
?
How about decaying bonus point?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
