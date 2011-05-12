Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E0C1C6B0025
	for <linux-mm@kvack.org>; Wed, 11 May 2011 20:13:55 -0400 (EDT)
Received: by qyk30 with SMTP id 30so764816qyk.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 17:13:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1105111331480.9346@chino.kir.corp.google.com>
References: <1889981320.330808.1305081044822.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	<alpine.DEB.2.00.1105111331480.9346@chino.kir.corp.google.com>
Date: Thu, 12 May 2011 09:13:54 +0900
Message-ID: <BANLkTi=fNtPZQk5Mp7rbZJFpA1tzBh+VcA@mail.gmail.com>
Subject: Re: OOM Killer don't works at all if the system have >gigabytes
 memory (was Re: [PATCH] mm: check zone->all_unreclaimable in all_unreclaimable())
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: CAI Qian <caiqian@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Thu, May 12, 2011 at 5:34 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Tue, 10 May 2011, CAI Qian wrote:
>
>> Sure, I saw there were some discussion going on between you and David
>> about your patches. Does it make more sense for me to test those after
>> you have settled down technical arguments?
>>
>
> Something like the following (untested) patch should fix the issue by
> simply increasing the range of a task's badness from 0-1000 to 0-10000.
>
> There are other things to fix like the tasklist dump output and
> documentation, but this shows how easy it is to increase the resolution o=
f
> the scoring. =C2=A0(This patch also includes a change to only give root

It does make sense.
I think raising resolution should be a easy way to fix the problem.

> processes a 1% bonus for every 30% of memory they use as proposed
> earlier.)

I didn't follow earlier your suggestion.
But it's not formal patch so I expect if you send formal patch to
merge, you would write down the rationale.

>
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -160,7 +160,7 @@ unsigned int oom_badness(struct task_struct *p, struc=
t mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (p->flags & PF_OOM_ORIGIN) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(p);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1000;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 10000;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -177,32 +177,32 @@ unsigned int oom_badness(struct task_struct *p, str=
uct mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0points =3D get_mm_rss(p->mm) + p->mm->nr_ptes;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0points +=3D get_mm_counter(p->mm, MM_SWAPENTS)=
;
>
> - =C2=A0 =C2=A0 =C2=A0 points *=3D 1000;
> + =C2=A0 =C2=A0 =C2=A0 points *=3D 10000;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0points /=3D totalpages;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0task_unlock(p);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* Root processes get 3% bonus, just like the=
 __vm_enough_memory()
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* implementation used by LSMs.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Root processes get 1% bonus per 30% memory=
 used for a total of 3%
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* possible just like LSMs.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points -=3D 30;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 points -=3D 100 * (poi=
nts / 3000);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * /proc/pid/oom_score_adj ranges from -1000 t=
o +1000 such that it may
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * either completely disable oom killing or al=
ways prefer a certain
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * task.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 points +=3D p->signal->oom_score_adj;
> + =C2=A0 =C2=A0 =C2=A0 points +=3D p->signal->oom_score_adj * 10;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Never return 0 for an eligible task that ma=
y be killed since it's
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* possible that no single user task uses mor=
e than 0.1% of memory and
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* possible that no single user task uses mor=
e than 0.01% of memory and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * no single admin tasks uses more than 3.0%.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (points <=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
> - =C2=A0 =C2=A0 =C2=A0 return (points < 1000) ? points : 1000;
> + =C2=A0 =C2=A0 =C2=A0 return (points < 10000) ? points : 10000;
> =C2=A0}
>
> =C2=A0/*
> @@ -314,7 +314,7 @@ static struct task_struct *select_bad_process(unsigne=
d int *ppoints,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (p =3D=3D current) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0chosen =3D p;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *ppoints =3D 1000;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *ppoints =3D 10000;

Scattering constant value isn't good.
You are proving it now.
I think you did it since this is not a formal patch.
I expect you will define new value (ex, OOM_INTERNAL_MAX_SCORE or whatever)


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
