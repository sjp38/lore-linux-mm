Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BFB06B0022
	for <linux-mm@kvack.org>; Mon, 23 May 2011 00:02:33 -0400 (EDT)
Received: by qyk2 with SMTP id 2so765949qyk.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 21:02:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD6204D.5020109@jp.fujitsu.com>
References: <4DD61F80.1020505@jp.fujitsu.com>
	<4DD6204D.5020109@jp.fujitsu.com>
Date: Mon, 23 May 2011 13:02:31 +0900
Message-ID: <BANLkTinpX59NnwsJVQZNTgt_6X3DVK9WLg@mail.gmail.com>
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram internally
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

2011/5/20 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> CAI Qian reported his kernel did hang-up if he ran fork intensive
> workload and then invoke oom-killer.
>
> The problem is, current oom calculation uses 0-1000 normalized value
> (The unit is a permillage of system-ram). Its low precision make
> a lot of same oom score. IOW, in his case, all processes have smaller
> oom score than 1 and internal calculation round it to 1.
>
> Thus oom-killer kill ineligible process. This regression is caused by
> commit a63d83f427 (oom: badness heuristic rewrite).
>
> The solution is, the internal calculation just use number of pages
> instead of permillage of system-ram. And convert it to permillage
> value at displaying time.
>
> This patch doesn't change any ABI (included =C2=A0/proc/<pid>/oom_score_a=
dj)
> even though current logic has a lot of my dislike thing.
>
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
> =C2=A0fs/proc/base.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 13 ++++++----
> =C2=A0include/linux/oom.h | =C2=A0 =C2=A07 +----
> =C2=A0mm/oom_kill.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 60 ++++++++++++++++++++=
+++++++++++++-----------------
> =C2=A03 files changed, 49 insertions(+), 31 deletions(-)
>
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index dfa5327..d6b0424 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -476,14 +476,17 @@ static const struct file_operations proc_lstats_ope=
rations =3D {
>
> =C2=A0static int proc_oom_score(struct task_struct *task, char *buffer)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 unsigned long points =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long points;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long ratio =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long totalpages =3D totalram_pages + tota=
l_swap_pages + 1;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_lock(&tasklist_lock);
> - =C2=A0 =C2=A0 =C2=A0 if (pid_alive(task))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points =3D oom_badness=
(task, NULL, NULL,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 totalram_pag=
es + total_swap_pages);
> + =C2=A0 =C2=A0 =C2=A0 if (pid_alive(task)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points =3D oom_badness=
(task, NULL, NULL, totalpages);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ratio =3D points * 100=
0 / totalpages;
> + =C2=A0 =C2=A0 =C2=A0 }
> =C2=A0 =C2=A0 =C2=A0 =C2=A0read_unlock(&tasklist_lock);
> - =C2=A0 =C2=A0 =C2=A0 return sprintf(buffer, "%lu\n", points);
> + =C2=A0 =C2=A0 =C2=A0 return sprintf(buffer, "%lu\n", ratio);
> =C2=A0}
>
> =C2=A0struct limit_names {
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 5e3aa83..0f5b588 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -40,7 +40,8 @@ enum oom_constraint {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0CONSTRAINT_MEMCG,
> =C2=A0};
>
> -extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup=
 *mem,
> +/* The badness from the OOM killer */
> +extern unsigned long oom_badness(struct task_struct *p, struct mem_cgrou=
p *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0const nodemask_t *nodemask, unsigned long totalpages);
> =C2=A0extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gf=
p_flags);
> =C2=A0extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp=
_flags);
> @@ -62,10 +63,6 @@ static inline void oom_killer_enable(void)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0oom_killer_disabled =3D false;
> =C2=A0}
>
> -/* The badness from the OOM killer */
> -extern unsigned long badness(struct task_struct *p, struct mem_cgroup *m=
em,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 c=
onst nodemask_t *nodemask, unsigned long uptime);
> -
> =C2=A0extern struct task_struct *find_lock_task_mm(struct task_struct *p)=
;
>
> =C2=A0/* sysctls */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index e6a6c6f..8bbc3df 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -132,10 +132,12 @@ static bool oom_unkillable_task(struct task_struct =
*p,
> =C2=A0* predictable as possible. =C2=A0The goal is to return the highest =
value for the
> =C2=A0* task consuming the most memory to avoid subsequent oom failures.
> =C2=A0*/
> -unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> +unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0const nodemask_t *nodemask, unsigned long totalpages)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 int points;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long points;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long score_adj =3D 0;
> +
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (oom_unkillable_task(p, mem, nodemask))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> @@ -160,7 +162,7 @@ unsigned int oom_badness(struct task_struct *p, struc=
t mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (p->flags & PF_OOM_ORIGIN) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(p);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1000;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ULONG_MAX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -176,33 +178,49 @@ unsigned int oom_badness(struct task_struct *p, str=
uct mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0points =3D get_mm_rss(p->mm) + p->mm->nr_ptes;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0points +=3D get_mm_counter(p->mm, MM_SWAPENTS)=
;
> -
> - =C2=A0 =C2=A0 =C2=A0 points *=3D 1000;
> - =C2=A0 =C2=A0 =C2=A0 points /=3D totalpages;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(p);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Root processes get 3% bonus, just like the =
__vm_enough_memory()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * implementation used by LSMs.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* XXX: Too large bonus, example, if the syst=
em have tera-bytes memory..
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */

Nitpick. I have no opposition about adding this comment.
But strictly speaking, the comment isn't related to this patch.
No biggie and it's up to you.  :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
