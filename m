Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0E2E76B01DD
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 05:59:30 -0400 (EDT)
Received: by iwn1 with SMTP id 1so5328046iwn.14
        for <linux-mm@kvack.org>; Tue, 15 Jun 2010 02:59:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100615152450.f82c1f8c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100615152450.f82c1f8c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 15 Jun 2010 18:59:25 +0900
Message-ID: <AANLkTinEEYWULLICKqBr4yX7GL01E4cq0jQSfuN8J6Jq@mail.gmail.com>
Subject: Re: [PATCH] use find_lock_task_mm in memory cgroups oom
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Tue, Jun 15, 2010 at 3:24 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> based on =C2=A0oom-introduce-find_lock_task_mm-to-fix-mm-false-positives.=
patch
> tested on mm-of-the-moment snapshot 2010-06-11-16-40.
>
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> When the OOM killer scans task, it check a task is under memcg or
> not when it's called via memcg's context.
>
> But, as Oleg pointed out, a thread group leader may have NULL ->mm
> and task_in_mem_cgroup() may do wrong decision. We have to use
> find_lock_task_mm() in memcg as generic OOM-Killer does.
>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I have a trivial comment below.

> ---
> =C2=A0include/linux/oom.h | =C2=A0 =C2=A02 ++
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 | =C2=A0 10 +++++++---
> =C2=A0mm/oom_kill.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A08 ++++++--
> =C2=A03 files changed, 15 insertions(+), 5 deletions(-)
>
> Index: mmotm-2.6.35-0611/include/linux/oom.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.35-0611.orig/include/linux/oom.h
> +++ mmotm-2.6.35-0611/include/linux/oom.h
> @@ -45,6 +45,8 @@ static inline void oom_killer_enable(voi
> =C2=A0 =C2=A0 =C2=A0 =C2=A0oom_killer_disabled =3D false;
> =C2=A0}
>
> +extern struct task_struct *find_lock_task_mm(struct task_struct *p);
> +
> =C2=A0/* sysctls */
> =C2=A0extern int sysctl_oom_dump_tasks;
> =C2=A0extern int sysctl_oom_kill_allocating_task;
> Index: mmotm-2.6.35-0611/mm/memcontrol.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.35-0611.orig/mm/memcontrol.c
> +++ mmotm-2.6.35-0611/mm/memcontrol.c
> @@ -47,6 +47,7 @@
> =C2=A0#include <linux/mm_inline.h>
> =C2=A0#include <linux/page_cgroup.h>
> =C2=A0#include <linux/cpu.h>
> +#include <linux/oom.h>
> =C2=A0#include "internal.h"
>
> =C2=A0#include <asm/uaccess.h>
> @@ -838,10 +839,13 @@ int task_in_mem_cgroup(struct task_struc
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *curr =3D NULL;
> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *p;
>
> - =C2=A0 =C2=A0 =C2=A0 task_lock(task);
> - =C2=A0 =C2=A0 =C2=A0 curr =3D try_get_mem_cgroup_from_mm(task->mm);
> - =C2=A0 =C2=A0 =C2=A0 task_unlock(task);
> + =C2=A0 =C2=A0 =C2=A0 p =3D find_lock_task_mm(task);
> + =C2=A0 =C2=A0 =C2=A0 if (!p)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 curr =3D try_get_mem_cgroup_from_mm(p->mm);
> + =C2=A0 =C2=A0 =C2=A0 task_unlock(p);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!curr)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> Index: mmotm-2.6.35-0611/mm/oom_kill.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.35-0611.orig/mm/oom_kill.c
> +++ mmotm-2.6.35-0611/mm/oom_kill.c
> @@ -81,13 +81,17 @@ static bool has_intersects_mems_allowed(
> =C2=A0}
> =C2=A0#endif /* CONFIG_NUMA */
>
> -/*
> +/**
> + * find_lock_task_mm - Checking a process which a task belongs to has va=
lid mm
> + * and return a locked task which has a valid pointer to mm.
> + *

This comment should have been another patch.
BTW, below comment uses "subthread" word.
Personally it's easy to understand function's goal to me. :)

How about following as?
Checking a process which has any subthread with vaild mm
....


> + * @p: the task of a process to be checked.
> =C2=A0* The process p may have detached its own ->mm while exiting or thr=
ough
> =C2=A0* use_mm(), but one or more of its subthreads may still have a vali=
d
> =C2=A0* pointer. =C2=A0Return p, or any of its subthreads with a valid ->=
mm, with
> =C2=A0* task_lock() held.
> =C2=A0*/
> -static struct task_struct *find_lock_task_mm(struct task_struct *p)
> +struct task_struct *find_lock_task_mm(struct task_struct *p)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct task_struct *t =3D p;
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
