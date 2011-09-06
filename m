Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0E96F6B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 00:11:44 -0400 (EDT)
Received: by vwm42 with SMTP id 42so5986645vwm.14
        for <linux-mm@kvack.org>; Mon, 05 Sep 2011 21:11:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110905160534.GB17354@quack.suse.cz>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
	<20110901143333.51baf4ae.akpm@linux-foundation.org>
	<CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
	<20110902112133.GD12182@quack.suse.cz>
	<CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
	<CAFPAmTTJQddd-vHjCpvyfsHhursRXBwNzF4zoVHL3=ggztE8Qg@mail.gmail.com>
	<20110902151450.GF12182@quack.suse.cz>
	<CAFPAmTQxBK32zutyiX9DJLS2F+z6jxsV71xOwa0sivxSY5MD1Q@mail.gmail.com>
	<20110905103925.GC5466@quack.suse.cz>
	<CAFPAmTR5f_GW_oha07Bf0_LNXhigZri_w2N_XTEqM+X+-Ae-Rw@mail.gmail.com>
	<20110905160534.GB17354@quack.suse.cz>
Date: Tue, 6 Sep 2011 09:41:42 +0530
Message-ID: <CAFPAmTRdHaQFhbGCQAUhDEPXfaz95KnaX_pZ6xgK98BXL4nn1A@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of del_timer
From: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

On Mon, Sep 5, 2011 at 9:35 PM, Jan Kara <jack@suse.cz> wrote:
> =A0Hi,
>
> On Mon 05-09-11 20:06:04, kautuk.c @samsung.com wrote:
>> > =A0OK, I don't care much whether we have there del_timer() or
>> > del_timer_sync(). Let me just say that the race you are afraid of is
>> > probably not going to happen in practice so I'm not sure it's valid to=
 be
>> > afraid of CPU cycles being burned needlessly. The timer is armed when =
an
>> > dirty inode is first attached to default bdi's dirty list. Then the de=
fault
>> > bdi flusher thread would have to be woken up so that following happens=
:
>> > =A0 =A0 =A0 =A0CPU1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0CPU2
>> > =A0timer fires -> wakeup_timer_fn()
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0bdi_forker_thread()
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0del_timer(&me->wakeup_timer);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0wb_do_writeback(me, 0);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0...
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0set_current_state(TASK_INTERRUPTIBLE);
>> > =A0wake_up_process(default_backing_dev_info.wb.task);
>> >
>> > =A0Especially wb_do_writeback() is going to take a long time so just t=
hat
>> > single thing makes the race unlikely. Given del_timer_sync() is slight=
ly
>> > more costly than del_timer() even for unarmed timer, it is questionabl=
e
>> > whether (chance race happens * CPU spent in extra loop) > (extra CPU s=
pent
>> > in del_timer_sync() * frequency that code is executed in
>> > bdi_forker_thread())...
>> >
>>
>> Ok, so this means that we can compare the following 2 paths of code:
>> i) =A0 One extra iteration of the bdi_forker_thread loop, versus
>> ii) =A0The amount of time it takes for the del_timer_sync to wait till t=
he
>> timer_fn on the other CPU finishes executing + schedule resulting in a
>> guaranteed sleep.
> =A0No, ii) is going to be as rare. But instead you should compare i) agai=
nst:
> iii) The amount of time it takes del_timer_sync() to check whether the
> timer_fn is running on a different CPU (which is work del_timer() doesn't
> do).

The amount of time it takes del_timer_sync to check the timer_fn should be
negligible.
In fact, try_to_del_timer_sync differs from del_timer_sync in only
that it performs
an additional check:
if (base->running_timer =3D=3D timer)
    goto out;

>
> =A0We are going to spend time in iii) each and every time
> if (wb_has_dirty_io(me) || !list_empty(&me->bdi->work_list))
> =A0evaluates to true.

The amount of time spent on this every time will not matter much, as
the task will
still be preemptible. However, if you notice that in most of the
bdi_forker_thread
loop, we disable preemption due to taking a spinlock so an additional loop =
there
might be more costly.

>
> =A0Now frequency of i) and iii) happening is hard to evaluate so it's not
> clear what's going to be better. Certainly I don't think such evaluation =
is
> worth my time...
>

Ok. Anyways, thanks for explaining all this to me.
I really appreciate your time. :)

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
