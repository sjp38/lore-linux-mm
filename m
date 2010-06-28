Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7077D6B01B2
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 20:03:36 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5T03WP3001705
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Jun 2010 09:03:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEAEF45DE4D
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 09:03:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B75345DE6F
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 09:03:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AFE9E38001
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 09:03:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C70951DB803A
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 09:03:30 +0900 (JST)
Date: Tue, 29 Jun 2010 08:58:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [S+Q 01/16] [PATCH] ipc/sem.c: Bugfix for semop() not reporting
 successful operation
Message-Id: <20100629085859.2acd95e5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C28D1A5.9040700@colorfullife.com>
References: <20100625212026.810557229@quilx.com>
	<20100625212101.622422748@quilx.com>
	<20100628111731.18f1f858.kamezawa.hiroyu@jp.fujitsu.com>
	<4C28D1A5.9040700@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010 18:45:25 +0200
Manfred Spraul <manfred@colorfullife.com> wrote:

> On 06/28/2010 04:17 AM, KAMEZAWA Hiroyuki wrote:
> > On Fri, 25 Jun 2010 16:20:27 -0500
> > Christoph Lameter<cl@linux-foundation.org>  wrote:
> >
> >    
> >> [Necessary to make 2.6.35-rc3 not deadlock. Not sure if this is the "right"(tm)
> >> fix]
> >>
> >> The last change to improve the scalability moved the actual wake-up out of
> >> the section that is protected by spin_lock(sma->sem_perm.lock).
> >>
> >> This means that IN_WAKEUP can be in queue.status even when the spinlock is
> >> acquired by the current task. Thus the same loop that is performed when
> >> queue.status is read without the spinlock acquired must be performed when
> >> the spinlock is acquired.
> >>
> >> Signed-off-by: Manfred Spraul<manfred@colorfullife.com>
> >> Signed-off-by: Christoph Lameter<cl@linux-foundation.org>
> >>      
> >
> > Hmm, I'm sorry if I don't understand the code...
> >
> >    
> >> ---
> >>   ipc/sem.c |   36 ++++++++++++++++++++++++++++++------
> >>   1 files changed, 30 insertions(+), 6 deletions(-)
> >>
> >> diff --git a/ipc/sem.c b/ipc/sem.c
> >> index 506c849..523665f 100644
> >> --- a/ipc/sem.c
> >> +++ b/ipc/sem.c
> >> @@ -1256,6 +1256,32 @@ out:
> >>   	return un;
> >>   }
> >>
> >> +
> >> +/** get_queue_result - Retrieve the result code from sem_queue
> >> + * @q: Pointer to queue structure
> >> + *
> >> + * The function retrieve the return code from the pending queue. If
> >> + * IN_WAKEUP is found in q->status, then we must loop until the value
> >> + * is replaced with the final value: This may happen if a task is
> >> + * woken up by an unrelated event (e.g. signal) and in parallel the task
> >> + * is woken up by another task because it got the requested semaphores.
> >> + *
> >> + * The function can be called with or without holding the semaphore spinlock.
> >> + */
> >> +static int get_queue_result(struct sem_queue *q)
> >> +{
> >> +	int error;
> >> +
> >> +	error = q->status;
> >> +	while(unlikely(error == IN_WAKEUP)) {
> >> +		cpu_relax();
> >> +		error = q->status;
> >> +	}
> >> +
> >> +	return error;
> >> +}
> >>      
> > no memory barrier is required ?
> >
> >    
> No.
> q->status is the only field that is read in the exit path of 
> sys_semtimedop():
> After that, q->status is used as the return value of sys_semtimedop(), 
> without accessing any other field.
> Thus no memory barrier is required: there is just no other read/write 
> operation against which the read of q->status must be serialized.
> 
> There is a smp_wmb() wake_up_sem_queue_do(), to ensure that all writes 
> that are done by the cpu that does the wake-up are completed before 
> q->status is set to the final value.
> 

Thanks. BTW, cpu_relax() always includes asm("":::"memory") for avoiding
optimization ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
