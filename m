Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AE25F6B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 11:05:25 -0500 (EST)
Received: by pwj9 with SMTP id 9so173315pwj.14
        for <linux-mm@kvack.org>; Mon, 01 Mar 2010 08:02:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003010213480.26824@chino.kir.corp.google.com>
Date: Tue, 2 Mar 2010 01:02:15 +0900
Message-ID: <28c262361003010802o7de2a32ci913b3833074af9eb@mail.gmail.com>
Subject: Re: [patch] mm: adjust kswapd nice level for high priority page
	allocators
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 1, 2010 at 7:14 PM, David Rientjes <rientjes@google.com> wrote:
> From: Con Kolivas <kernel@kolivas.org>
>
> When kswapd is awoken due to reclaim by a running task, set the priority
> of kswapd to that of the task allocating pages thus making memory reclaim
> cpu activity affected by nice level.
>
> [rientjes@google.com: refactor for current]
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Con Kolivas <kernel@kolivas.org>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 33 ++++++++++++++++++++++++++++++++-
> =C2=A01 files changed, 32 insertions(+), 1 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1658,6 +1658,33 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =C2=A0}
>
> =C2=A0/*
> + * Helper functions to adjust nice level of kswapd, based on the priorit=
y of
> + * the task allocating pages. If it is already higher priority we do not
> + * demote its nice level since it is still working on behalf of a higher
> + * priority task. With kernel threads we leave it at nice 0.
> + *
> + * We don't ever run kswapd real time, so if a real time task calls kswa=
pd we
> + * set it to highest SCHED_NORMAL priority.
> + */
> +static int effective_sc_prio(struct task_struct *p)
> +{
> + =C2=A0 =C2=A0 =C2=A0 if (likely(p->mm)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (rt_task(p))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return -20;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return task_nice(p);
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 return 0;
> +}
> +
> +static void set_kswapd_nice(struct task_struct *kswapd, int active)
> +{
> + =C2=A0 =C2=A0 =C2=A0 long nice =3D effective_sc_prio(current);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (task_nice(kswapd) > nice || !active)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 set_user_nice(kswapd, =
nice);
> +}
> +
> +/*
> =C2=A0* This is the direct reclaim path, for page-allocating processes. =
=C2=A0We only
> =C2=A0* try to reclaim pages from zones which will satisfy the caller's a=
llocation
> =C2=A0* request.
> @@ -2257,6 +2284,7 @@ static int kswapd(void *p)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 set_user_nice(tsk, 0);

Why do you reset nice value which set by set_kswapd_nice?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
