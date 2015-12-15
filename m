Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 95EFC6B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:56:31 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id xm8so18596382igb.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 08:56:31 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id pg2si5928107igb.58.2015.12.15.08.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 08:56:30 -0800 (PST)
Date: Tue, 15 Dec 2015 17:56:50 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [BISECTED] rcu_sched self-detected stall since 3.17
Message-ID: <20151215165650.GA13604@redhat.com>
References: <564F3DCA.1080907@arm.com> <20151201130404.GL3816@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151201130404.GL3816@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vladimir Murzin <vladimir.murzin@arm.com>, linux-kernel@vger.kernel.org, neilb@suse.de, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Sorry again for the huge delay.

And all I can say is that I am all confused.

On 12/01, Peter Zijlstra wrote:
>
> On Fri, Nov 20, 2015 at 03:35:38PM +0000, Vladimir Murzin wrote:
> > commit 743162013d40ca612b4cb53d3a200dff2d9ab26e
> > Author: NeilBrown <neilb@suse.de>
> > Date:   Mon Jul 7 15:16:04 2014 +1000

That patch still looks correct to me.

> > and if I apply following diff I don't see stalls anymore.
> >
> > diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> > index a104879..2d68cdb 100644
> > --- a/kernel/sched/wait.c
> > +++ b/kernel/sched/wait.c
> > @@ -514,9 +514,10 @@ EXPORT_SYMBOL(bit_wait);
> >
> >  __sched int bit_wait_io(void *word)
> >  {
> > +       io_schedule();
> > +
> >         if (signal_pending_state(current->state, current))
> >                 return 1;
> > -       io_schedule();
> >         return 0;
> >  }
> >  EXPORT_SYMBOL(bit_wait_io);

I can't understand why this change helps. But note that it actually removes
the signal_pending_state() check from bit_wait_io(), current->state is always
TASK_RUNNING after return from schedule(), signal_pending_state() will always
return zero.

This means that after this change wait_on_page_bit_killable() will spin in a
busy-wait loop if the caller is killed.

> The reason this is broken is that schedule() will no-op when there is a
> pending signal, while raising a signal will also issue a wakeup.

But why this is wrong? We should notice signal_pending_state() on the next
iteration.

> Thus the right thing to do is check for the signal state after,

I think this check should work on both sides. The only difference is that
you obviously can't use current->state after schedule().

I still can't understand the problem.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
