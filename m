Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DBAC76B0178
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 07:47:23 -0400 (EDT)
Received: by vxj3 with SMTP id 3so2802351vxj.14
        for <linux-mm@kvack.org>; Fri, 02 Sep 2011 04:44:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110902112133.GD12182@quack.suse.cz>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
	<20110901143333.51baf4ae.akpm@linux-foundation.org>
	<CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
	<20110902112133.GD12182@quack.suse.cz>
Date: Fri, 2 Sep 2011 17:14:05 +0530
Message-ID: <CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of del_timer
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Fri, Sep 2, 2011 at 4:51 PM, Jan Kara <jack@suse.cz> wrote:
> =A0Hello,
>
> On Fri 02-09-11 10:47:03, kautuk.c @samsung.com wrote:
>> On Fri, Sep 2, 2011 at 3:03 AM, Andrew Morton <akpm@linux-foundation.org=
> wrote:
>> > On Thu, =A01 Sep 2011 21:27:02 +0530
>> > Kautuk Consul <consul.kautuk@gmail.com> wrote:
>> >
>> >> This is important for SMP scenario, to check whether the timer
>> >> callback is executing on another CPU when we are deleting the
>> >> timer.
>> >>
>> >
>> > I don't see why?
>> >
>> >> index d6edf8d..754b35a 100644
>> >> --- a/mm/backing-dev.c
>> >> +++ b/mm/backing-dev.c
>> >> @@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* dirty data on the default backing_de=
v_info
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wb_has_dirty_io(me) || !list_empty(&m=
e->bdi->work_list)) {
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&me->wakeup_timer=
);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer_sync(&me->wakeup_=
timer);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wb_do_writeback(me, 0);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >
>> > It isn't a use-after-free fix: bdi_unregister() safely shoots down any
>> > running timer.
>> >
>>
>> In the situation that we do a del_timer at the same time that the
>> wakeup_timer_fn is
>> executing on another CPU, there is one tiny possible problem:
>> 1) =A0The wakeup_timer_fn will call wake_up_process on the bdi-default t=
hread.
>> =A0 =A0 =A0 This will set the bdi-default thread's state to TASK_RUNNING=
.
>> 2) =A0However, the code in bdi_writeback_thread() sets the state of the
>> bdi-default process
>> =A0 =A0 to TASK_INTERRUPTIBLE as it intends to sleep later.
>>
>> If 2) happens before 1), then the bdi_forker_thread will not sleep
>> inside schedule as is the intention of the bdi_forker_thread() code.
> =A0OK, I agree the code in bdi_forker_thread() might use some straighteni=
ng
> up wrt. task state handling but is what you decribe really an issue? Sure
> the task won't go to sleep but the whole effect is that it will just loop
> once more to find out there's nothing to do and then go to sleep - not a
> bug deal... Or am I missing something?

Yes, you are right.
I was studying the code and I found this inconsistency.
Anyways, if there is NO_ACTION it will just loop and go to sleep again.
I just posted this because I felt that the code was not achieving the logic
that was intended in terms of sleeps and wakeups.

I am currently trying to study the other patches you have just sent.

>
>> This protection is not achieved even by acquiring spinlocks before
>> setting the task->state
>> as the spinlock used in wakeup_timer_fn is &bdi->wb_lock whereas the cod=
e in
>> bdi_forker_thread acquires &bdi_lock which is a different spin_lock.
>>
>> Am I correct in concluding this ?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
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
