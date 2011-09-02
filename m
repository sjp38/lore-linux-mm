Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 404A86B017B
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 08:11:25 -0400 (EDT)
Received: by vwm42 with SMTP id 42so3018421vwm.14
        for <linux-mm@kvack.org>; Fri, 02 Sep 2011 05:11:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1314963064-22109-1-git-send-email-jack@suse.cz>
References: <1314963064-22109-1-git-send-email-jack@suse.cz>
Date: Fri, 2 Sep 2011 17:41:22 +0530
Message-ID: <CAFPAmTTQeHAd9o9y_SfRbQefovo6ukASHodopMtFLCZ4zL07RQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Make logic in bdi_forker_thread() straight
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <jaxboe@fusionio.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>

Sorry to butt in before Jens' review but i have one small comment:

On Fri, Sep 2, 2011 at 5:01 PM, Jan Kara <jack@suse.cz> wrote:
> The logic in bdi_forker_thread() is unnecessarily convoluted by setting t=
ask
> state there and back or calling schedule_timeout() in TASK_RUNNING state.=
 Also
> clearing of BDI_pending bit is placed at the and of global loop and cases=
 of a
> switch which mustn't reach it must call 'continue' instead of 'break' whi=
ch is
> non-intuitive and thus asking for trouble. So make the logic more obvious=
.
>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Wu Fengguang <fengguang.wu@intel.com>
> CC: consul.kautuk@gmail.com
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
> =A0mm/backing-dev.c | =A0 37 ++++++++++++++++++++-----------------
> =A01 files changed, 20 insertions(+), 17 deletions(-)
>
> =A0This should be the right cleanup. Jens?
>
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index d6edf8d..bdf7d6b 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -359,6 +359,17 @@ static unsigned long bdi_longest_inactive(void)
> =A0 =A0 =A0 =A0return max(5UL * 60 * HZ, interval);
> =A0}
>
> +/*
> + * Clear pending bit and wakeup anybody waiting for flusher thread start=
up
> + * or teardown.
> + */
> +static void bdi_clear_pending(struct backing_dev_info *bdi)
> +{
> + =A0 =A0 =A0 clear_bit(BDI_pending, &bdi->state);
> + =A0 =A0 =A0 smp_mb__after_clear_bit();
> + =A0 =A0 =A0 wake_up_bit(&bdi->state, BDI_pending);
> +}
> +
> =A0static int bdi_forker_thread(void *ptr)
> =A0{
> =A0 =A0 =A0 =A0struct bdi_writeback *me =3D ptr;
> @@ -390,8 +401,6 @@ static int bdi_forker_thread(void *ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_bh(&bdi_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_current_state(TASK_INTERRUPTIBLE);
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(bdi, &bdi_list, bdi_li=
st) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool have_dirty_io;
>
> @@ -441,13 +450,8 @@ static int bdi_forker_thread(void *ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_bh(&bdi_lock);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Keep working if default bdi still has th=
ings to do */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!list_empty(&me->bdi->work_list))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TASK_RU=
NNING);
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (action) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case FORK_THREAD:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TASK_RU=
NNING);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task =3D kthread_create(bd=
i_writeback_thread, &bdi->wb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0"flush-%s", dev_name(bdi->dev));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(task)) {
> @@ -469,14 +473,21 @@ static int bdi_forker_thread(void *ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unloc=
k_bh(&bdi->wb_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wake_up_pr=
ocess(task);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_clear_pending(bdi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case KILL_THREAD:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TASK_RU=
NNING);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kthread_stop(task);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_clear_pending(bdi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case NO_ACTION:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Keep working if default =
bdi still has things to do */

Can we acquire and release the spinlocks as below:
                            spin_lock_bh(&me->bdi->wb_lock) ;

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!list_empty(&me->bdi->w=
ork_list)) {

                            spin_unlock_bh(&me->bdi->wb_lock) ;

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_free=
ze();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_current_state(TASK_INTE=
RRUPTIBLE);

                            spin_unlock_bh(&me->bdi->wb_lock) ;

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!wb_has_dirty_io(me) |=
| !dirty_writeback_interval)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * There a=
re no dirty data. The only thing we
> @@ -489,16 +500,8 @@ static int bdi_forker_thread(void *ptr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedule_t=
imeout(msecs_to_jiffies(dirty_writeback_interval * 10));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0try_to_freeze();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Back to the main loop */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Clear pending bit and wakeup anybody w=
aiting to tear us down.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(BDI_pending, &bdi->state);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_mb__after_clear_bit();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_bit(&bdi->state, BDI_pending);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0return 0;
> --
> 1.7.1
>
>

That should take care of the problem I initially mentioned due to the
wakeup_timer_fn executing
in parallel on another CPU as the task state will now be protected by
the wb_lock spinlock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
