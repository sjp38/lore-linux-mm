Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6017A6B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 13:19:41 -0500 (EST)
Date: Wed, 9 Nov 2011 19:19:25 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109181925.GN5075@redhat.com>
References: <1320766151-2619-1-git-send-email-aarcange@redhat.com>
 <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
 <20111109155342.GA1260@google.com>
 <20111109165201.GI5075@redhat.com>
 <20111109165925.GC1260@google.com>
 <20111109170248.GD1260@google.com>
 <20111109172942.GJ5075@redhat.com>
 <20111109180900.GF1260@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109180900.GF1260@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 09, 2011 at 10:09:00AM -0800, Tejun Heo wrote:
> I'm confused.  You're doing add_wait_queue() before
> schedule_timeout_interruptible().  prepare_to_wait() is essentially
> add_wait_queue() + set_current_state().  What am I missing?  ie. why
> not do the following?

Ah the reason of the waitqueue is the sysfs store, to get out of there
if somebody decreases the wait time from 1min to 10sec or
similar. It's not really needed for other things, in theory it could
be a separate waitqueue just for sysfs but probably not worth it.

> 	prepare_to_wait(INTERRUPTIBLE);
> 	try_to_freeze();
> 	schedule_timeout();
> 	try_to_freeze();
> 	finish_wait();
> 
> or even simpler,
> 
> 	wait_event_freezable_timeout(wq, false, timeout);
> 
> In terms of overhead, there is no appreciable difference from
> 
> 	add_wait_queue();
> 	schedule_timeout_interruptible();
> 	remove_wait_queue()
> 
> Or is the logic there scheduled to change?

I have no "event" to wait other than the wakeup itself, this in the
end is the only reason it isn't already using
wait_event_freezable_timeout. Of course I can pass "false" as the
event.

> Hmmm... I don't know.  I really hope all freezable tasks stick to
> higher level interface.  It's way too easy to get things wrong and eat
> either freezing or actual wakeup condition.

Well you've just to tell me if I have to pass "false" and if
add_wait_queue+schedule_timeout_interruptible is obsoleted. If it's
not obsoleted the patch I posted should already be ok. It also will be
useful if others need to wait for a long time (> the freezer max wait)
without a waitqueue which I don't think is necessarily impossible. It
wasn't the case here just because I need to promptly react to the
sysfs writes (or setting the wait time to 1 day would then require 1
day before sysfs new value becomes meaningful, well unless somebody
doess killall khugepaged.. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
