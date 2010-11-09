Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2E36B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:29:12 -0500 (EST)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA9KLSR9009126
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:21:30 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA9KT4qS1835208
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:29:04 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA9KT36j023875
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 15:29:04 -0500
Date: Tue, 9 Nov 2010 12:29:00 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage -
	kernel/pid.c:419 invoked rcu_dereference_check() without protection!
Message-ID: <20101109202900.GV4032@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com>
 <20101107182028.GZ15561@linux.vnet.ibm.com>
 <20101108151509.GA3702@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101108151509.GA3702@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 08, 2010 at 04:15:09PM +0100, Oleg Nesterov wrote:
> On 11/07, Paul E. McKenney wrote:
> >
> > On Tue, Oct 12, 2010 at 12:08:46AM -0700, Greg Thelen wrote:
> > >
> > > ioprio_set() contains a comment warning against of usage of
> > > rcu_read_lock() to avoid this warning:
> > > 	/*
> > > 	 * We want IOPRIO_WHO_PGRP/IOPRIO_WHO_USER to be "atomic",
> > > 	 * so we can't use rcu_read_lock(). See re-copy of ->ioprio
> > > 	 * in copy_process().
> > > 	 */
> > >
> > > So I'm not sure what the best fix is.
> 
> (please note that "we can't use rcu_read_lock()" actually meant
>  rcu_read_lock() is not _enough_)
> 
> > I must defer to Oleg, who wrote the comment.  But please see below.
> 
> I added this comment to explain some oddities in copy_process().
> Nobody confirmed my understanding was correct ;)
> 
> In any case, this comment doesn't look right today. This code was
> changed by fd0928df98b9578be8a786ac0cb78a47a5e17a20
> "ioprio: move io priority from task_struct to io_context" after that,
> tasklist can't help to make sys_ioprio_set(IOPRIO_WHO_PGRP) atomic.
> 
> I think tasklist_lock can be removed now.
> 
> And, as Paul pointed out, we need rcu_read_lock() anyway, it was
> already added by Sergey.

Thank you, Oleg!  Greg, would you be willing to update your patch
to remove the comment?  (Perhaps tasklist_lock as well...)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
