Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id BB6C16B00BE
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 21:55:32 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so12209022qgd.13
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:55:32 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id d14si20642868qaw.24.2014.06.02.18.55.31
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 18:55:32 -0700 (PDT)
Date: Mon, 2 Jun 2014 21:55:29 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: mm,console: circular dependency between console_sem and zone
 lock
Message-ID: <20140602215529.0c13f91b@gandalf.local.home>
In-Reply-To: <538B33D5.8070002@oracle.com>
References: <536AE5DC.6070307@oracle.com>
	<20140512162811.GD3685@quack.suse.cz>
	<538B33D5.8070002@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Sun, 01 Jun 2014 10:08:21 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

> On 05/12/2014 12:28 PM, Jan Kara wrote:
> > On Wed 07-05-14 22:03:08, Sasha Levin wrote:
> >> > Hi all,
> >> > 
> >> > While fuzzing with trinity inside a KVM tools guest running the latest -next
> >> > kernel I've stumbled on the following spew:
> >   Thanks for report. So the problem seems to be maginally valid but I'm not
> > 100% sure whom to blame :). So printk() code calls up() which calls
> > try_to_wake_up() under console_sem.lock spinlock. That function can take
> > rq->lock which is all expected.
> > 
> > The next part of the chain is that during CPU initialization we call
> > __sched_fork() with rq->lock which calls into hrtimer_init() which can
> > allocate memory which creates a dependency rq->lock => zone.lock.rlock.
> > 
> > And memory management code calls printk() which zone.lock.rlock held which
> > closes the loop. Now I suspect the second link in the chain can happen only
> > while CPU is booting and might even happen only if some debug options are
> > enabled. But I don't really know scheduler code well enough. Steven?
> 
> I've cc'ed Peter and Ingo who may be able to answer that, as it still happens
> on -next.
> 

Hmm, it failed on a try lock, but on the spinlock within the trylock. I
wonder if we should add this.

Peter?

-- Steve

diff --git a/kernel/locking/semaphore.c b/kernel/locking/semaphore.c
index 6815171..6579f84 100644
--- a/kernel/locking/semaphore.c
+++ b/kernel/locking/semaphore.c
@@ -132,7 +132,9 @@ int down_trylock(struct semaphore *sem)
 	unsigned long flags;
 	int count;
 
-	raw_spin_lock_irqsave(&sem->lock, flags);
+	if (!raw_spin_trylock_irqsave(&sem->lock, flags))
+		return 1;
+
 	count = sem->count - 1;
 	if (likely(count >= 0))
 		sem->count = count;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
