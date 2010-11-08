Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1014E6B004A
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 10:21:17 -0500 (EST)
Date: Mon, 8 Nov 2010 16:15:09 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage -
	kernel/pid.c:419 invoked rcu_dereference_check() without protection!
Message-ID: <20101108151509.GA3702@redhat.com>
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com> <20101107182028.GZ15561@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101107182028.GZ15561@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/07, Paul E. McKenney wrote:
>
> On Tue, Oct 12, 2010 at 12:08:46AM -0700, Greg Thelen wrote:
> >
> > ioprio_set() contains a comment warning against of usage of
> > rcu_read_lock() to avoid this warning:
> > 	/*
> > 	 * We want IOPRIO_WHO_PGRP/IOPRIO_WHO_USER to be "atomic",
> > 	 * so we can't use rcu_read_lock(). See re-copy of ->ioprio
> > 	 * in copy_process().
> > 	 */
> >
> > So I'm not sure what the best fix is.

(please note that "we can't use rcu_read_lock()" actually meant
 rcu_read_lock() is not _enough_)

> I must defer to Oleg, who wrote the comment.  But please see below.

I added this comment to explain some oddities in copy_process().
Nobody confirmed my understanding was correct ;)

In any case, this comment doesn't look right today. This code was
changed by fd0928df98b9578be8a786ac0cb78a47a5e17a20
"ioprio: move io priority from task_struct to io_context" after that,
tasklist can't help to make sys_ioprio_set(IOPRIO_WHO_PGRP) atomic.

I think tasklist_lock can be removed now.

And, as Paul pointed out, we need rcu_read_lock() anyway, it was
already added by Sergey.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
