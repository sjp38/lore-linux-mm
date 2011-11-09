Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E65756B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 13:34:55 -0500 (EST)
Received: by qadc11 with SMTP id c11so2315647qad.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 10:34:53 -0800 (PST)
Date: Wed, 9 Nov 2011 10:34:47 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109183447.GG1260@google.com>
References: <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
 <20111109155342.GA1260@google.com>
 <20111109165201.GI5075@redhat.com>
 <20111109165925.GC1260@google.com>
 <20111109170248.GD1260@google.com>
 <20111109172942.GJ5075@redhat.com>
 <20111109180900.GF1260@google.com>
 <20111109181925.GN5075@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109181925.GN5075@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello, Andrea.

On Wed, Nov 09, 2011 at 07:19:25PM +0100, Andrea Arcangeli wrote:
> On Wed, Nov 09, 2011 at 10:09:00AM -0800, Tejun Heo wrote:
> > I'm confused.  You're doing add_wait_queue() before
> > schedule_timeout_interruptible().  prepare_to_wait() is essentially
> > add_wait_queue() + set_current_state().  What am I missing?  ie. why
> > not do the following?
> 
> Ah the reason of the waitqueue is the sysfs store, to get out of there
> if somebody decreases the wait time from 1min to 10sec or
> similar. It's not really needed for other things, in theory it could
> be a separate waitqueue just for sysfs but probably not worth it.

Oh I see.

> I have no "event" to wait other than the wakeup itself, this in the
> end is the only reason it isn't already using
> wait_event_freezable_timeout. Of course I can pass "false" as the
> event.

I think, for this specific case, wait_event_freezable_timeout() w/
false is the simplest thing to do.

> > Hmmm... I don't know.  I really hope all freezable tasks stick to
> > higher level interface.  It's way too easy to get things wrong and eat
> > either freezing or actual wakeup condition.
> 
> Well you've just to tell me if I have to pass "false" and if
> add_wait_queue+schedule_timeout_interruptible is obsoleted. If it's
> not obsoleted the patch I posted should already be ok. It also will be
> useful if others need to wait for a long time (> the freezer max wait)
> without a waitqueue which I don't think is necessarily impossible. It
> wasn't the case here just because I need to promptly react to the
> sysfs writes (or setting the wait time to 1 day would then require 1
> day before sysfs new value becomes meaningful, well unless somebody
> doess killall khugepaged.. :)

I agree that there can be use cases where freezable interruptible
sleep is useful.  Thanks to the the inherently racy nature of
schedule_interruptible_timeout() w.r.t. non-persistent interruptible
wakeups (ie. everything other than signal), race conditions introduced
by try_to_freeze() should be okay

The biggest problem I have with schedule_timeout_freezable() is that
it doesn't advertise that it's racy - ie. it doesn't have sleep
condition in the function name.  Its wait counterpart
wait_event_freezable() isn't racy thanks to the explicit wait
condition and doesn't have such problem.

Maybe my concern is just paraonia and people wouldn't assume it's
schedule_timeout() with magic freezer support.  Or we can name it
schedule_timeout_interruptible_freezable() (urgh........).  I don't
know.  My instinct tells me to strongly recommend use of
wait_event_freezable_timeout() and run away.  :)

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
