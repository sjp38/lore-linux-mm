From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304142148.h3ELm7HB016432@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <1050355133.3664.73.camel@localhost> from Robert Love at "Apr 14,
 2003 05:18:54 pm"
Date: Mon, 14 Apr 2003 17:48:07 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the new year, Robert Love wrote:
> On Mon, 2003-04-14 at 17:09, Jeremy Hall wrote:
> 
> > with 2.5.67-mm2, it is SA_INTERRUPT|SA_SHIRQ and looks like it can call 
> > multiple interrupts at once.  I am not sure what SA_SHIRQ does, but this 
> > does not address the case where one CPU holds an interrupt for one card 
> > and the other CPU holds the interrupt for the other card.
> 
> SA_SHIRQ means "this interrupt line can be shared" -- thus each handler
> on the line needs to be able to differentiate when it is called whether
> or not its device actually caused the interrupt.
> 
oh, ok.

> Note two processors can never run the _same_ handler for the same line. 
> A given line (say IRQ 8) is masked out on all processors while its
> handler.
> 
ok, but in this case, the same handler appears on two different lines, 
once for one RME card, once for the other.  It is theoretically possible 
that one line could be handled by once CPU and the other by the other CPU.

> Further, if SA_INTERRUPT is specified then all other interrupts are
> disabled, too, on the local processor.
> 
It would appear this may not be true, or my understanding of the code is 
not sound (more likely) it would also appear rme9652_read might not be 
able to differuntiate between being called for an RME card or another 
card.

rme9652_read says

return readl(rme9652->iobase+reg);

oh yeah and it says if it can't read, it just returns.  I guess it can 
tell the difference.

> If you need to protect some data, grab a spin lock in your handler.
> 
I'm still digging at this, so don't know yet how to answer this point.  
I'm thinking somehow we need to schedule the snd_pcm_period_elapsed, or 
force it to run in interrupt context.

I thought I had done the latter by moving the snd_rme9652_write to the 
bottom of the function so that it wouldn't clear the interrupt condition 
until after it processed the data.

but I guess I hadn't because it didn't make a difference.  This is why I 
raise the question about whether other interrupts can be called.

_J

> > I moved the line 
> > 
> > rme9652_write(rme9652, RME9652_irq_clear, 0);
> > 
> > to after the snd_pcm_period_elapsed calls in the hopes that they would be 
> > run in interrupt context, but it did not make a difference.  The backtrace 
> > looks a little different, but it's still the same crash.
> 
> I am afraid I don't understand nearly enough of the context of the
> problem to know what to suggest next.
> 
> Keep hacking :)
> 
> 	Robert Love
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
