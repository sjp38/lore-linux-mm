Subject: Re: interrupt context
From: Robert Love <rml@tech9.net>
In-Reply-To: <200304142148.h3ELm7HB016432@sith.maoz.com>
References: <200304142148.h3ELm7HB016432@sith.maoz.com>
Content-Type: text/plain
Message-Id: <1050361041.3664.121.camel@localhost>
Mime-Version: 1.0
Date: 14 Apr 2003 18:57:21 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-04-14 at 17:48, Jeremy Hall wrote:

> > Note two processors can never run the _same_ handler for the same line. 
> > A given line (say IRQ 8) is masked out on all processors while its
> > handler.
>
> ok, but in this case, the same handler appears on two different lines, 
> once for one RME card, once for the other.  It is theoretically possible 
> that one line could be handled by once CPU and the other by the other CPU.

Yep.  You must obtain a spin lock and disable local interrupts if there
is any shared data here (and I am sure there is).

> > Further, if SA_INTERRUPT is specified then all other interrupts are
> > disabled, too, on the local processor.
> > 
> It would appear this may not be true, or my understanding of the code is 
> not sound (more likely) it would also appear rme9652_read might not be 
> able to differuntiate between being called for an RME card or another 
> card.

It is true :)

See irq.c for your architecture.  On x86, we have handle_IRQ_event():

	if (!(action->flags & SA_INTERRUPT))
		local_irq_enable();

It is called with interrupts disabled.  Unless SA_INTERRUPT is set,
though, they are enabled here.  Note this is the _local_ processor only.

> I'm still digging at this, so don't know yet how to answer this point.  
> I'm thinking somehow we need to schedule the snd_pcm_period_elapsed, or 
> force it to run in interrupt context.
> 
> I thought I had done the latter by moving the snd_rme9652_write to the 
> bottom of the function so that it wouldn't clear the interrupt condition 
> until after it processed the data.
> 
> but I guess I hadn't because it didn't make a difference.  This is why I 
> raise the question about whether other interrupts can be called.

Well, as I have said, they can still run on OTHER processors, as long as
its a different interrupt line (same handler is irrelevant).

So you can have these two handlers you speak of run at the same time.  I
think you are trying to prevent that, no?

Well, you cannot... but you can protect the shared data or hardware with
a lock.  Grab a spin_lock in the handler prior to doing what you wish to
protect.  This will prevent that chunk of code from running
simultaneously.

Linus has a nice discussion on spin locks in Documentation/spinlocks.txt

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
