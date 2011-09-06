Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id DF3706B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 05:14:10 -0400 (EDT)
Date: Tue, 6 Sep 2011 11:14:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of
 del_timer
Message-ID: <20110906091401.GA23747@quack.suse.cz>
References: <CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
 <20110902112133.GD12182@quack.suse.cz>
 <CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
 <CAFPAmTTJQddd-vHjCpvyfsHhursRXBwNzF4zoVHL3=ggztE8Qg@mail.gmail.com>
 <20110902151450.GF12182@quack.suse.cz>
 <CAFPAmTQxBK32zutyiX9DJLS2F+z6jxsV71xOwa0sivxSY5MD1Q@mail.gmail.com>
 <20110905103925.GC5466@quack.suse.cz>
 <CAFPAmTR5f_GW_oha07Bf0_LNXhigZri_w2N_XTEqM+X+-Ae-Rw@mail.gmail.com>
 <20110905160534.GB17354@quack.suse.cz>
 <CAFPAmTRdHaQFhbGCQAUhDEPXfaz95KnaX_pZ6xgK98BXL4nn1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAFPAmTRdHaQFhbGCQAUhDEPXfaz95KnaX_pZ6xgK98BXL4nn1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 06-09-11 09:41:42, kautuk.c @samsung.com wrote:
> > On Mon 05-09-11 20:06:04, kautuk.c @samsung.com wrote:
> >> >  OK, I don't care much whether we have there del_timer() or
> >> > del_timer_sync(). Let me just say that the race you are afraid of is
> >> > probably not going to happen in practice so I'm not sure it's valid to be
> >> > afraid of CPU cycles being burned needlessly. The timer is armed when an
> >> > dirty inode is first attached to default bdi's dirty list. Then the default
> >> > bdi flusher thread would have to be woken up so that following happens:
> >> >        CPU1                            CPU2
> >> >  timer fires -> wakeup_timer_fn()
> >> >                                        bdi_forker_thread()
> >> >                                          del_timer(&me->wakeup_timer);
> >> >                                          wb_do_writeback(me, 0);
> >> >                                          ...
> >> >                                          set_current_state(TASK_INTERRUPTIBLE);
> >> >  wake_up_process(default_backing_dev_info.wb.task);
> >> >
> >> >  Especially wb_do_writeback() is going to take a long time so just that
> >> > single thing makes the race unlikely. Given del_timer_sync() is slightly
> >> > more costly than del_timer() even for unarmed timer, it is questionable
> >> > whether (chance race happens * CPU spent in extra loop) > (extra CPU spent
> >> > in del_timer_sync() * frequency that code is executed in
> >> > bdi_forker_thread())...
> >> >
> >>
> >> Ok, so this means that we can compare the following 2 paths of code:
> >> i)   One extra iteration of the bdi_forker_thread loop, versus
> >> ii)  The amount of time it takes for the del_timer_sync to wait till the
> >> timer_fn on the other CPU finishes executing + schedule resulting in a
> >> guaranteed sleep.
> >  No, ii) is going to be as rare. But instead you should compare i) against:
> > iii) The amount of time it takes del_timer_sync() to check whether the
> > timer_fn is running on a different CPU (which is work del_timer() doesn't
> > do).
> 
> The amount of time it takes del_timer_sync to check the timer_fn should be
> negligible.
> In fact, try_to_del_timer_sync differs from del_timer_sync in only
> that it performs
> an additional check:
> if (base->running_timer == timer)
>     goto out;
  Yes, but the probability the race happens is also negligible. So you are
comparing two negligible things... 

> >  We are going to spend time in iii) each and every time
> > if (wb_has_dirty_io(me) || !list_empty(&me->bdi->work_list))
> >  evaluates to true.
> 
> The amount of time spent on this every time will not matter much, as the
> task will still be preemptible. However, if you notice that in most of
> the bdi_forker_thread loop, we disable preemption due to taking a
> spinlock so an additional loop there might be more costly.
  So either you speak about CPU cost in amount of cycles spent - and there
I still don't buy that it's clear del_timer_sync() is better than
del_timer() - or you speak about latency which is a different thing. From
latency POV that additional loop might be worse. But still I don't think
it's clear enough to change it without any measurement...

> >  Now frequency of i) and iii) happening is hard to evaluate so it's not
> > clear what's going to be better. Certainly I don't think such evaluation is
> > worth my time...
> >
> 
> Ok. Anyways, thanks for explaining all this to me.
> I really appreciate your time. :)
  You are welcome. You made me refresh my memory about some parts of kernel
which is also valuable so thanks goes also to you :)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
