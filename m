From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304141932.h3EJWXIW015193@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <1050346609.3664.55.camel@localhost> from Robert Love at "Apr 14,
 2003 02:56:50 pm"
Date: Mon, 14 Apr 2003 15:32:33 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the new year, Robert Love wrote:
> On Mon, 2003-04-14 at 14:51, Jeremy Hall wrote:
> 
> If you need to ensure concurrency is protected in your interrupt
> handler, grab a lock and disable interrupts around the critical region.
> 
I am assuming you mean in some parent context.

on alsa-devel, I wrote:

Consider the following:

Two RME9652's are running together and on different interrupts.

The master, in interrupt context, acquires its runtime->lock and begins
snd_pcm_update_hw_ptr_interrupt()

At the same time, the second card, the slave, is behind, still in play
mode, and wants to XRUN.  To do that, it must stop and restart all the
substreams connected to it.  To do that, it must acquire the runtime lock
of each, but the capture substream of the master is locked in another 
interrupt.

solution:

Is it acceptible if XRUN occurs in a pcm_multi environment to only restart
substreams related to that physical card? or is it necessary to restart
the whole device to maintain sample-sync?

I'm thinking you'd need to restart all devices.  Is this reasonable? as
in, am I reading the code correctly?

_J

The ideal solution would be to put both rme cards on the same interrupt, 
but I haven't been able to figure out how to do that, unless it is as 
simple as setting interrupt_line with setpci, but when the pcm_multi 
device is set up, it should find a way to figure out which interrupt(s) 
are functioning as a single device and mask them together somehow.

and this calling snd_pcm_period_elapsed from the interrupt handler but 
after clearing the interrupt (rme9652.c) i think is ultimately how this 
can occur.  I'm thinking that even IF they were both on the same interrupt 
this could occur because the irq is cleared before snd_pcm_period_elapsed 
runs.

_J

> 	Robert Love
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
