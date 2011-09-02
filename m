Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id ECE0B6B017A
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 08:02:38 -0400 (EDT)
Received: by vxj3 with SMTP id 3so2818898vxj.14
        for <linux-mm@kvack.org>; Fri, 02 Sep 2011 05:02:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
	<20110901143333.51baf4ae.akpm@linux-foundation.org>
	<CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
	<20110902112133.GD12182@quack.suse.cz>
	<CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
Date: Fri, 2 Sep 2011 17:32:35 +0530
Message-ID: <CAFPAmTTJQddd-vHjCpvyfsHhursRXBwNzF4zoVHL3=ggztE8Qg@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of del_timer
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jan,

I looked at that other patch you just sent.

I think that the task state problem can still happen in that case as the se=
tting
of the task state is not protected by any lock and the timer callback can b=
e
executing on another CPU at that time.

Am I right about this ?


On Fri, Sep 2, 2011 at 5:14 PM, kautuk.c @samsung.com
<consul.kautuk@gmail.com> wrote:
> Hi,
>
> On Fri, Sep 2, 2011 at 4:51 PM, Jan Kara <jack@suse.cz> wrote:
>> =A0Hello,
>>
>> On Fri 02-09-11 10:47:03, kautuk.c @samsung.com wrote:
>>> On Fri, Sep 2, 2011 at 3:03 AM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
>>> > On Thu, =A01 Sep 2011 21:27:02 +0530
>>> > Kautuk Consul <consul.kautuk@gmail.com> wrote:
>>> >
>>> >> This is important for SMP scenario, to check whether the timer
>>> >> callback is executing on another CPU when we are deleting the
>>> >> timer.
>>> >>
>>> >
>>> > I don't see why?
>>> >
>>> >> index d6edf8d..754b35a 100644
>>> >> --- a/mm/backing-dev.c
>>> >> +++ b/mm/backing-dev.c
>>> >> @@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* dirty data on the default backing_d=
ev_info
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wb_has_dirty_io(me) || !list_empty(&=
me->bdi->work_list)) {
>>> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&me->wakeup_time=
r);
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer_sync(&me->wakeup=
_timer);
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wb_do_writeback(me, 0);
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> >
>>> > It isn't a use-after-free fix: bdi_unregister() safely shoots down an=
y
>>> > running timer.
>>> >
>>>
>>> In the situation that we do a del_timer at the same time that the
>>> wakeup_timer_fn is
>>> executing on another CPU, there is one tiny possible problem:
>>> 1) =A0The wakeup_timer_fn will call wake_up_process on the bdi-default =
thread.
>>> =A0 =A0 =A0 This will set the bdi-default thread's state to TASK_RUNNIN=
G.
>>> 2) =A0However, the code in bdi_writeback_thread() sets the state of the
>>> bdi-default process
>>> =A0 =A0 to TASK_INTERRUPTIBLE as it intends to sleep later.
>>>
>>> If 2) happens before 1), then the bdi_forker_thread will not sleep
>>> inside schedule as is the intention of the bdi_forker_thread() code.
>> =A0OK, I agree the code in bdi_forker_thread() might use some straighten=
ing
>> up wrt. task state handling but is what you decribe really an issue? Sur=
e
>> the task won't go to sleep but the whole effect is that it will just loo=
p
>> once more to find out there's nothing to do and then go to sleep - not a
>> bug deal... Or am I missing something?
>
> Yes, you are right.
> I was studying the code and I found this inconsistency.
> Anyways, if there is NO_ACTION it will just loop and go to sleep again.
> I just posted this because I felt that the code was not achieving the log=
ic
> that was intended in terms of sleeps and wakeups.
>
> I am currently trying to study the other patches you have just sent.
>
>>
>>> This protection is not achieved even by acquiring spinlocks before
>>> setting the task->state
>>> as the spinlock used in wakeup_timer_fn is &bdi->wb_lock whereas the co=
de in
>>> bdi_forker_thread acquires &bdi_lock which is a different spin_lock.
>>>
>>> Am I correct in concluding this ?
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
>> --
>> Jan Kara <jack@suse.cz>
>> SUSE Labs, CR
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
