Subject: Re: interrupt context
From: Robert Love <rml@tech9.net>
In-Reply-To: <200304142109.h3EL90YY016047@sith.maoz.com>
References: <200304142109.h3EL90YY016047@sith.maoz.com>
Content-Type: text/plain
Message-Id: <1050355133.3664.73.camel@localhost>
Mime-Version: 1.0
Date: 14 Apr 2003 17:18:54 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2003-04-14 at 17:09, Jeremy Hall wrote:

> with 2.5.67-mm2, it is SA_INTERRUPT|SA_SHIRQ and looks like it can call 
> multiple interrupts at once.  I am not sure what SA_SHIRQ does, but this 
> does not address the case where one CPU holds an interrupt for one card 
> and the other CPU holds the interrupt for the other card.

SA_SHIRQ means "this interrupt line can be shared" -- thus each handler
on the line needs to be able to differentiate when it is called whether
or not its device actually caused the interrupt.

Note two processors can never run the _same_ handler for the same line. 
A given line (say IRQ 8) is masked out on all processors while its
handler.

Further, if SA_INTERRUPT is specified then all other interrupts are
disabled, too, on the local processor.

If you need to protect some data, grab a spin lock in your handler.

> I moved the line 
> 
> rme9652_write(rme9652, RME9652_irq_clear, 0);
> 
> to after the snd_pcm_period_elapsed calls in the hopes that they would be 
> run in interrupt context, but it did not make a difference.  The backtrace 
> looks a little different, but it's still the same crash.

I am afraid I don't understand nearly enough of the context of the
problem to know what to suggest next.

Keep hacking :)

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
