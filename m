Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E1DBC6B018C
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 11:15:04 -0400 (EDT)
Date: Fri, 2 Sep 2011 17:14:50 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of
 del_timer
Message-ID: <20110902151450.GF12182@quack.suse.cz>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
 <20110901143333.51baf4ae.akpm@linux-foundation.org>
 <CAFPAmTQbdhNgFNoP0RyS0E9Gm4djA-W_4JWwpWZ7U=XnTKR+cg@mail.gmail.com>
 <20110902112133.GD12182@quack.suse.cz>
 <CAFPAmTSh-WWJjtuNjZsdEcaK-zSf8CvBmrRGFTmd_HZQNAKUCw@mail.gmail.com>
 <CAFPAmTTJQddd-vHjCpvyfsHhursRXBwNzF4zoVHL3=ggztE8Qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAFPAmTTJQddd-vHjCpvyfsHhursRXBwNzF4zoVHL3=ggztE8Qg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kautuk.c @samsung.com" <consul.kautuk@gmail.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 02-09-11 17:32:35, kautuk.c @samsung.com wrote:
> Hi Jan,
> 
> I looked at that other patch you just sent.
> 
> I think that the task state problem can still happen in that case as the setting
> of the task state is not protected by any lock and the timer callback can be
> executing on another CPU at that time.
> 
> Am I right about this ?
  Yes, the cleanup is not meant to change the scenario you describe - as I
said, there's no point in protecting against it as it's harmless...

								Honza

> On Fri, Sep 2, 2011 at 5:14 PM, kautuk.c @samsung.com
> <consul.kautuk@gmail.com> wrote:
> > Hi,
> >
> > On Fri, Sep 2, 2011 at 4:51 PM, Jan Kara <jack@suse.cz> wrote:
> >>  Hello,
> >>
> >> On Fri 02-09-11 10:47:03, kautuk.c @samsung.com wrote:
> >>> On Fri, Sep 2, 2011 at 3:03 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> >>> > On Thu,  1 Sep 2011 21:27:02 +0530
> >>> > Kautuk Consul <consul.kautuk@gmail.com> wrote:
> >>> >
> >>> >> This is important for SMP scenario, to check whether the timer
> >>> >> callback is executing on another CPU when we are deleting the
> >>> >> timer.
> >>> >>
> >>> >
> >>> > I don't see why?
> >>> >
> >>> >> index d6edf8d..754b35a 100644
> >>> >> --- a/mm/backing-dev.c
> >>> >> +++ b/mm/backing-dev.c
> >>> >> @@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
> >>> >>                * dirty data on the default backing_dev_info
> >>> >>                */
> >>> >>               if (wb_has_dirty_io(me) || !list_empty(&me->bdi->work_list)) {
> >>> >> -                     del_timer(&me->wakeup_timer);
> >>> >> +                     del_timer_sync(&me->wakeup_timer);
> >>> >>                       wb_do_writeback(me, 0);
> >>> >>               }
> >>> >
> >>> > It isn't a use-after-free fix: bdi_unregister() safely shoots down any
> >>> > running timer.
> >>> >
> >>>
> >>> In the situation that we do a del_timer at the same time that the
> >>> wakeup_timer_fn is
> >>> executing on another CPU, there is one tiny possible problem:
> >>> 1)  The wakeup_timer_fn will call wake_up_process on the bdi-default thread.
> >>>       This will set the bdi-default thread's state to TASK_RUNNING.
> >>> 2)  However, the code in bdi_writeback_thread() sets the state of the
> >>> bdi-default process
> >>>     to TASK_INTERRUPTIBLE as it intends to sleep later.
> >>>
> >>> If 2) happens before 1), then the bdi_forker_thread will not sleep
> >>> inside schedule as is the intention of the bdi_forker_thread() code.
> >>  OK, I agree the code in bdi_forker_thread() might use some straightening
> >> up wrt. task state handling but is what you decribe really an issue? Sure
> >> the task won't go to sleep but the whole effect is that it will just loop
> >> once more to find out there's nothing to do and then go to sleep - not a
> >> bug deal... Or am I missing something?
> >
> > Yes, you are right.
> > I was studying the code and I found this inconsistency.
> > Anyways, if there is NO_ACTION it will just loop and go to sleep again.
> > I just posted this because I felt that the code was not achieving the logic
> > that was intended in terms of sleeps and wakeups.
> >
> > I am currently trying to study the other patches you have just sent.
> >
> >>
> >>> This protection is not achieved even by acquiring spinlocks before
> >>> setting the task->state
> >>> as the spinlock used in wakeup_timer_fn is &bdi->wb_lock whereas the code in
> >>> bdi_forker_thread acquires &bdi_lock which is a different spin_lock.
> >>>
> >>> Am I correct in concluding this ?
> >>
> >>                                                                Honza
> >> --
> >> Jan Kara <jack@suse.cz>
> >> SUSE Labs, CR
> >>
> >
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
