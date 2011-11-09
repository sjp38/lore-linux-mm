Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F03D26B0069
	for <linux-mm@kvack.org>; Wed,  9 Nov 2011 13:09:07 -0500 (EST)
Received: by gyg10 with SMTP id 10so2599965gyg.14
        for <linux-mm@kvack.org>; Wed, 09 Nov 2011 10:09:06 -0800 (PST)
Date: Wed, 9 Nov 2011 10:09:00 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] thp: reduce khugepaged freezing latency
Message-ID: <20111109180900.GF1260@google.com>
References: <4EB8E969.6010502@suse.cz>
 <1320766151-2619-1-git-send-email-aarcange@redhat.com>
 <1320766151-2619-2-git-send-email-aarcange@redhat.com>
 <4EB98A83.3040101@linux.vnet.ibm.com>
 <4EBA75F2.4080800@linux.vnet.ibm.com>
 <20111109155342.GA1260@google.com>
 <20111109165201.GI5075@redhat.com>
 <20111109165925.GC1260@google.com>
 <20111109170248.GD1260@google.com>
 <20111109172942.GJ5075@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111109172942.GJ5075@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, "Rafael J. Wysocki" <rjw@suse.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hello, Anrea.

On Wed, Nov 09, 2011 at 06:29:42PM +0100, Andrea Arcangeli wrote:
> My point is if what happens is:
> 
>    freezer CPU		   khugepaged
>    ------
>    assert freezing
>    wake_up(interruptible)
> 			   __set_current_state(interruptible)
> 			   schedule()
> 
> are we still hanging then?

Yeap, you're right.  I was thinking INTERRUPTILBE was being set before
try_to_freeze().

> And I think it's silly to use wait_event_freezable_timeout if I
> don't have any waitqueue to wait on.

I'm confused.  You're doing add_wait_queue() before
schedule_timeout_interruptible().  prepare_to_wait() is essentially
add_wait_queue() + set_current_state().  What am I missing?  ie. why
not do the following?

	prepare_to_wait(INTERRUPTIBLE);
	try_to_freeze();
	schedule_timeout();
	try_to_freeze();
	finish_wait();

or even simpler,

	wait_event_freezable_timeout(wq, false, timeout);

In terms of overhead, there is no appreciable difference from

	add_wait_queue();
	schedule_timeout_interruptible();
	remove_wait_queue()

Or is the logic there scheduled to change?

> +signed long __sched schedule_timeout_freezable(signed long timeout)
> +{
> +	do
> +		set_current_state(TASK_INTERRUPTIBLE);
> +	while (try_to_freeze());
> +	return schedule_timeout(timeout);
> +}
> +EXPORT_SYMBOL(schedule_timeout_freezable);

Hmmm... I don't know.  I really hope all freezable tasks stick to
higher level interface.  It's way too easy to get things wrong and eat
either freezing or actual wakeup condition.

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
