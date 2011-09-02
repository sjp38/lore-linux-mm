Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4AB2B6B0193
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 12:02:57 -0400 (EDT)
Received: by fxg9 with SMTP id 9so2383376fxg.14
        for <linux-mm@kvack.org>; Fri, 02 Sep 2011 09:02:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110902154249.GG12182@quack.suse.cz>
References: <1314963064-22109-1-git-send-email-jack@suse.cz>
	<CAFPAmTTQeHAd9o9y_SfRbQefovo6ukASHodopMtFLCZ4zL07RQ@mail.gmail.com>
	<CAFPAmTRFMHbZO86sUM+xA=HMCSixjzNt13-bz-KXv-ChRWXpCA@mail.gmail.com>
	<20110902154249.GG12182@quack.suse.cz>
Date: Fri, 2 Sep 2011 21:32:53 +0530
Message-ID: <CAFPAmTS_NrruU0EU0jWQ4ZemrSgJv+PQRv-MbOwMNTfm9CeHTQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Make logic in bdi_forker_thread() straight
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Jens Axboe <jaxboe@fusionio.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, Sep 2, 2011 at 9:12 PM, Jan Kara <jack@suse.cz> wrote:
> On Fri 02-09-11 18:03:19, kautuk.c @samsung.com wrote:
>> Sorry, I was wrong in this email. Please ignore.
>>
>> This problem will still happen as the CPU executing the
>> wakeup_timer_fn can still
>> get the lock and do a wake_up_process which can set the task state to
>> TASK_RUNNING.
> =A0Hmm, but actually the code is more subtle than I originally thought an=
d
> my cleanup patch is just plain wrong. The code really relies on setting
> TASK_INTERRUPTIBLE so early because otherwise we could miss e.g. wakeups
> from wakeup_timer_fn() when flusher thread should be teared down.
>
> =A0Also the above implies that the case you worry about - when we set
> TASK_INTERRUPTIBLE but wakeup_timer_fn() wakes the process is generally
> what we desire. In some cases it can lead to unnecessary wakeups (when th=
e
> loop in bdi_forker_thread() already notices there is some work and perfor=
ms
> it) but in other cases it is necessary so that we don't go to sleep when
> there is some work queued. So in the end I think the code is OK, it is ju=
st
> missing some explanatory comments.

Ok.
In the case the timer happens first, then lost wakeup scenario is avoided
because the code anyways checks the bdi list to set the task state.
In the case the timer happens later, then the worst possible condition
is that the loop
will loop around and some work will be found in the bdi list and this
will then be processed.

Thanks for the help. :)

>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
>
>> On Fri, Sep 2, 2011 at 5:41 PM, kautuk.c @samsung.com
>> <consul.kautuk@gmail.com> wrote:
>> > Sorry to butt in before Jens' review but i have one small comment:
>> >
>> > On Fri, Sep 2, 2011 at 5:01 PM, Jan Kara <jack@suse.cz> wrote:
>> >> The logic in bdi_forker_thread() is unnecessarily convoluted by setti=
ng task
>> >> state there and back or calling schedule_timeout() in TASK_RUNNING st=
ate. Also
>> >> clearing of BDI_pending bit is placed at the and of global loop and c=
ases of a
>> >> switch which mustn't reach it must call 'continue' instead of 'break'=
 which is
>> >> non-intuitive and thus asking for trouble. So make the logic more obv=
ious.
>> >>
>> >> CC: Andrew Morton <akpm@linux-foundation.org>
>> >> CC: Wu Fengguang <fengguang.wu@intel.com>
>> >> CC: consul.kautuk@gmail.com
>> >> Signed-off-by: Jan Kara <jack@suse.cz>
>> >> ---
>> >> =A0mm/backing-dev.c | =A0 37 ++++++++++++++++++++-----------------
>> >> =A01 files changed, 20 insertions(+), 17 deletions(-)
>> >>
>> >> =A0This should be the right cleanup. Jens?
>> >>
>> >> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> >> index d6edf8d..bdf7d6b 100644
>> >> --- a/mm/backing-dev.c
>> >> +++ b/mm/backing-dev.c
>> >> @@ -359,6 +359,17 @@ static unsigned long bdi_longest_inactive(void)
>> >> =A0 =A0 =A0 =A0return max(5UL * 60 * HZ, interval);
>> >> =A0}
>> >>
>> >> +/*
>> >> + * Clear pending bit and wakeup anybody waiting for flusher thread s=
tartup
>> >> + * or teardown.
>> >> + */
>> >> +static void bdi_clear_pending(struct backing_dev_info *bdi)
>> >> +{
>> >> + =A0 =A0 =A0 clear_bit(BDI_pending, &bdi->state);
>> >> + =A0 =A0 =A0 smp_mb__after_clear_bit();
>> >> + =A0 =A0 =A0 wake_up_bit(&bdi->state, BDI_pending);
>> >> +}
>> >> +
>> >> =A0static int bdi_forker_thread(void *ptr)
>> >> =A0{
>> >> =A0 =A0 =A0 =A0struct bdi_writeback *me =3D ptr;
>> >> @@ -390,8 +401,6 @@ static int bdi_forker_thread(void *ptr)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_bh(&bdi_lock);
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_current_state(TASK_INTERRUPTIBLE);
>> >> -
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(bdi, &bdi_list, bd=
i_list) {
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool have_dirty_io;
>> >>
>> >> @@ -441,13 +450,8 @@ static int bdi_forker_thread(void *ptr)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_bh(&bdi_lock);
>> >>
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Keep working if default bdi still ha=
s things to do */
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!list_empty(&me->bdi->work_list))
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TAS=
K_RUNNING);
>> >> -
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (action) {
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case FORK_THREAD:
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TAS=
K_RUNNING);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task =3D kthread_creat=
e(bdi_writeback_thread, &bdi->wb,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0"flush-%s", dev_name(bdi->dev));
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(task)) {
>> >> @@ -469,14 +473,21 @@ static int bdi_forker_thread(void *ptr)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_u=
nlock_bh(&bdi->wb_lock);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wake_u=
p_process(task);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_clear_pending(bdi);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case KILL_THREAD:
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_current_state(TAS=
K_RUNNING);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kthread_stop(task);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bdi_clear_pending(bdi);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case NO_ACTION:
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Keep working if defa=
ult bdi still has things to do */
>> >
>> > Can we acquire and release the spinlocks as below:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_bh(&m=
e->bdi->wb_lock) ;
>> >
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!list_empty(&me->bd=
i->work_list)) {
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_bh(=
&me->bdi->wb_lock) ;
>> >
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 try_to_=
freeze();
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_current_state(TASK_=
INTERRUPTIBLE);
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_bh(=
&me->bdi->wb_lock) ;
>> >
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!wb_has_dirty_io(m=
e) || !dirty_writeback_interval)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * The=
re are no dirty data. The only thing we
>> >> @@ -489,16 +500,8 @@ static int bdi_forker_thread(void *ptr)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0schedu=
le_timeout(msecs_to_jiffies(dirty_writeback_interval * 10));
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0try_to_freeze();
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Back to the main loo=
p */
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> >> -
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Clear pending bit and wakeup anybo=
dy waiting to tear us down.
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(BDI_pending, &bdi->state);
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_mb__after_clear_bit();
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 wake_up_bit(&bdi->state, BDI_pending);
>> >> =A0 =A0 =A0 =A0}
>> >>
>> >> =A0 =A0 =A0 =A0return 0;
>> >> --
>> >> 1.7.1
>> >>
>> >>
>> >
>> > That should take care of the problem I initially mentioned due to the
>> > wakeup_timer_fn executing
>> > in parallel on another CPU as the task state will now be protected by
>> > the wb_lock spinlock.
>> >
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
