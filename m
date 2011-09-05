Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 58DFD6B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 01:49:49 -0400 (EDT)
Received: by vwm42 with SMTP id 42so5001912vwm.14
        for <linux-mm@kvack.org>; Sun, 04 Sep 2011 22:49:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110902151450.GF12182@quack.suse.cz>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
	<20110901143333.51baf4ae.akpm@linux-foundation.org>
	<CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
	<20110902112133.GD12182@quack.suse.cz>
	<CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
	<CAFPAmTTJQddd-vHjCpvyfsHhursRXBwNzF4zoVHL3=ggztE8Qg@mail.gmail.com>
	<20110902151450.GF12182@quack.suse.cz>
Date: Mon, 5 Sep 2011 11:19:46 +0530
Message-ID: <CAFPAmTQxBK32zutyiX9DJLS2F+z6jxsV71xOwa0sivxSY5MD1Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of del_timer
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 2, 2011 at 8:44 PM, Jan Kara <jack@suse.cz> wrote:
> On Fri 02-09-11 17:32:35, kautuk.c @samsung.com wrote:
>> Hi Jan,
>>
>> I looked at that other patch you just sent.
>>
>> I think that the task state problem can still happen in that case as the=
 setting
>> of the task state is not protected by any lock and the timer callback ca=
n be
>> executing on another CPU at that time.
>>
>> Am I right about this ?
> =A0Yes, the cleanup is not meant to change the scenario you describe - as=
 I
> said, there's no point in protecting against it as it's harmless...
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
>

On second thought:
In the case that the timer_fn of the default bdi causes the
bdi_forker_thread to wake up,
why waste CPU time on one more loop when we could know convincingly
that we would want to
sleep ?

Of course, if any of the other BDIs are scheduling work to the default
the default thread
will wake up reliably as you mentioned.
But, in the case that the race between the default BDI's own timer_fn
(me->wakeup_timer)
on one CPU with the code in bdi_forker_thread on another CPU happens,
we will end up in
one more loop which will result in more CPU usage when we could
actually just go to sleep in
the current iteration of the loop if no work is found on its own bdi
list (i.e., me->bdi->work_list).


>> On Fri, Sep 2, 2011 at 5:14 PM, kautuk.c @samsung.com
>> <consul.kautuk@gmail.com> wrote:
>> > Hi,
>> >
>> > On Fri, Sep 2, 2011 at 4:51 PM, Jan Kara <jack@suse.cz> wrote:
>> >> =A0Hello,
>> >>
>> >> On Fri 02-09-11 10:47:03, kautuk.c @samsung.com wrote:
>> >>> On Fri, Sep 2, 2011 at 3:03 AM, Andrew Morton <akpm@linux-foundation=
.org> wrote:
>> >>> > On Thu, =A01 Sep 2011 21:27:02 +0530
>> >>> > Kautuk Consul <consul.kautuk@gmail.com> wrote:
>> >>> >
>> >>> >> This is important for SMP scenario, to check whether the timer
>> >>> >> callback is executing on another CPU when we are deleting the
>> >>> >> timer.
>> >>> >>
>> >>> >
>> >>> > I don't see why?
>> >>> >
>> >>> >> index d6edf8d..754b35a 100644
>> >>> >> --- a/mm/backing-dev.c
>> >>> >> +++ b/mm/backing-dev.c
>> >>> >> @@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
>> >>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* dirty data on the default backin=
g_dev_info
>> >>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wb_has_dirty_io(me) || !list_empt=
y(&me->bdi->work_list)) {
>> >>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&me->wakeup_t=
imer);
>> >>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer_sync(&me->wak=
eup_timer);
>> >>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wb_do_writeback(me, 0=
);
>> >>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >>> >
>> >>> > It isn't a use-after-free fix: bdi_unregister() safely shoots down=
 any
>> >>> > running timer.
>> >>> >
>> >>>
>> >>> In the situation that we do a del_timer at the same time that the
>> >>> wakeup_timer_fn is
>> >>> executing on another CPU, there is one tiny possible problem:
>> >>> 1) =A0The wakeup_timer_fn will call wake_up_process on the bdi-defau=
lt thread.
>> >>> =A0 =A0 =A0 This will set the bdi-default thread's state to TASK_RUN=
NING.
>> >>> 2) =A0However, the code in bdi_writeback_thread() sets the state of =
the
>> >>> bdi-default process
>> >>> =A0 =A0 to TASK_INTERRUPTIBLE as it intends to sleep later.
>> >>>
>> >>> If 2) happens before 1), then the bdi_forker_thread will not sleep
>> >>> inside schedule as is the intention of the bdi_forker_thread() code.
>> >> =A0OK, I agree the code in bdi_forker_thread() might use some straigh=
tening
>> >> up wrt. task state handling but is what you decribe really an issue? =
Sure
>> >> the task won't go to sleep but the whole effect is that it will just =
loop
>> >> once more to find out there's nothing to do and then go to sleep - no=
t a
>> >> bug deal... Or am I missing something?
>> >
>> > Yes, you are right.
>> > I was studying the code and I found this inconsistency.
>> > Anyways, if there is NO_ACTION it will just loop and go to sleep again=
.
>> > I just posted this because I felt that the code was not achieving the =
logic
>> > that was intended in terms of sleeps and wakeups.
>> >
>> > I am currently trying to study the other patches you have just sent.
>> >
>> >>
>> >>> This protection is not achieved even by acquiring spinlocks before
>> >>> setting the task->state
>> >>> as the spinlock used in wakeup_timer_fn is &bdi->wb_lock whereas the=
 code in
>> >>> bdi_forker_thread acquires &bdi_lock which is a different spin_lock.
>> >>>
>> >>> Am I correct in concluding this ?
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
>> >> --
>> >> Jan Kara <jack@suse.cz>
>> >> SUSE Labs, CR
>> >>
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
