Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BEF50600227
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 12:48:37 -0400 (EDT)
Received: by bwz9 with SMTP id 9so939462bwz.14
        for <linux-mm@kvack.org>; Mon, 28 Jun 2010 09:48:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100625212101.622422748@quilx.com>
References: <20100625212026.810557229@quilx.com>
	<20100625212101.622422748@quilx.com>
Date: Mon, 28 Jun 2010 19:48:34 +0300
Message-ID: <AANLkTinmvRtH24uflD9e7MknaW6tgMSnN75vVgaj0IM6@mail.gmail.com>
Subject: Re: [S+Q 01/16] [PATCH] ipc/sem.c: Bugfix for semop() not reporting
	successful operation
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Manfred Spraul <manfred@colorfullife.com>, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jun 26, 2010 at 12:20 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> [Necessary to make 2.6.35-rc3 not deadlock. Not sure if this is the "righ=
t"(tm)
> fix]

Is this related to the SLUB patches? Regardless, lets add Andrew and
linux-kernel on CC.

> The last change to improve the scalability moved the actual wake-up out o=
f
> the section that is protected by spin_lock(sma->sem_perm.lock).
>
> This means that IN_WAKEUP can be in queue.status even when the spinlock i=
s
> acquired by the current task. Thus the same loop that is performed when
> queue.status is read without the spinlock acquired must be performed when
> the spinlock is acquired.
>
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>
> ---
> =A0ipc/sem.c | =A0 36 ++++++++++++++++++++++++++++++------
> =A01 files changed, 30 insertions(+), 6 deletions(-)
>
> diff --git a/ipc/sem.c b/ipc/sem.c
> index 506c849..523665f 100644
> --- a/ipc/sem.c
> +++ b/ipc/sem.c
> @@ -1256,6 +1256,32 @@ out:
> =A0 =A0 =A0 =A0return un;
> =A0}
>
> +
> +/** get_queue_result - Retrieve the result code from sem_queue
> + * @q: Pointer to queue structure
> + *
> + * The function retrieve the return code from the pending queue. If
> + * IN_WAKEUP is found in q->status, then we must loop until the value
> + * is replaced with the final value: This may happen if a task is
> + * woken up by an unrelated event (e.g. signal) and in parallel the task
> + * is woken up by another task because it got the requested semaphores.
> + *
> + * The function can be called with or without holding the semaphore spin=
lock.
> + */
> +static int get_queue_result(struct sem_queue *q)
> +{
> + =A0 =A0 =A0 int error;
> +
> + =A0 =A0 =A0 error =3D q->status;
> + =A0 =A0 =A0 while(unlikely(error =3D=3D IN_WAKEUP)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_relax();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D q->status;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return error;
> +}
> +
> +
> =A0SYSCALL_DEFINE4(semtimedop, int, semid, struct sembuf __user *, tsops,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned, nsops, const struct timespec __u=
ser *, timeout)
> =A0{
> @@ -1409,11 +1435,7 @@ SYSCALL_DEFINE4(semtimedop, int, semid, struct sem=
buf __user *, tsops,
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule();
>
> - =A0 =A0 =A0 error =3D queue.status;
> - =A0 =A0 =A0 while(unlikely(error =3D=3D IN_WAKEUP)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu_relax();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D queue.status;
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 error =3D get_queue_result(&queue);
>
> =A0 =A0 =A0 =A0if (error !=3D -EINTR) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* fast path: update_queue already obtaine=
d all requested
> @@ -1427,10 +1449,12 @@ SYSCALL_DEFINE4(semtimedop, int, semid, struct se=
mbuf __user *, tsops,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 error =3D get_queue_result(&queue);
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If queue.status !=3D -EINTR we are woken up by another =
process
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 error =3D queue.status;
> +
> =A0 =A0 =A0 =A0if (error !=3D -EINTR) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unlock_free;
> =A0 =A0 =A0 =A0}
> --
> 1.7.0.1
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
