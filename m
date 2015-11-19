Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id A22CF6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 07:43:52 -0500 (EST)
Received: by wmww144 with SMTP id w144so114819838wmw.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:43:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 76si11891758wms.44.2015.11.19.04.43.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 04:43:51 -0800 (PST)
Date: Thu, 19 Nov 2015 13:43:49 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v3 01/22] timer: Allow to check when the timer callback
 has not finished yet
Message-ID: <20151119124349.GP4431@pathway.suse.cz>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-2-git-send-email-pmladek@suse.com>
 <alpine.DEB.2.11.1511182331010.3761@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1511182331010.3761@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 2015-11-18 23:32:28, Thomas Gleixner wrote:
> On Wed, 18 Nov 2015, Petr Mladek wrote:
> > timer_pending() checks whether the list of callbacks is empty.
> > Each callback is removed from the list before it is called,
> > see call_timer_fn() in __run_timers().
> > 
> > Sometimes we need to make sure that the callback has finished.
> > For example, if we want to free some resources that are accessed
> > by the callback.
> > 
> > For this purpose, this patch adds timer_active(). It checks both
> > the list of callbacks and the running_timer. It takes the base_lock
> > to see a consistent state.
> > 
> > I plan to use it to implement delayed works in kthread worker.
> > But I guess that it will have wider use. In fact, I wonder if
> > timer_pending() is misused in some situations.
> 
> Well. That's nice and good. But how will that new function solve
> anything? After you drop the lock the state is not longer valid.

If we prevent anyone from setting up the timer and timer_pending()
returns false, we are sure that the timer will stay as is.

For example, I use it in the function try_to_cancel_kthread_work().
Any manipulation with the timer is protected by worker->lock.
If the timer is not pending but still active, I have to drop
the lock and busy wait for the timer callback. See
http://thread.gmane.org/gmane.linux.kernel.mm/141493/focus=141501


Also I wonder if the following usage in
drivers/infiniband/hw/nes/nes_cm.c is safe:

static int mini_cm_dealloc_core(struct nes_cm_core *cm_core)
{
	nes_debug(NES_DBG_CM, "De-Alloc CM Core (%p)\n", cm_core);

	if (!cm_core)
		return -EINVAL;

	barrier();

	if (timer_pending(&cm_core->tcp_timer))
		del_timer(&cm_core->tcp_timer);

	destroy_workqueue(cm_core->event_wq);
	destroy_workqueue(cm_core->disconn_wq);

We destroy the workqueue but the timer callback might still
be in progress and queue new work.


There are many more locations where I see the pattern:

      if (timer_pending())
		del_timer();
      clean_up_stuff();

IMHO, we should use:

      if (timer_active())
		del_timer_sync();
      /* really safe to free stuff */
      clean_up_stuff();

or just

   del_timer_sync();
   clean_up_stuff();


I wonder if timer_pending() is used in more racy scenarios. Or maybe,
I just miss something that makes it all safe.

Thanks,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
