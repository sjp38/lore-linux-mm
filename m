From: Jeremy Hall <jhall@maoz.com>
Message-Id: <200304150344.h3F3iVrs017946@sith.maoz.com>
Subject: Re: interrupt context
In-Reply-To: <1050361041.3664.121.camel@localhost> from Robert Love at "Apr 14,
 2003 06:57:21 pm"
Date: Mon, 14 Apr 2003 23:44:30 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Jeremy Hall <jhall@maoz.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In the new year, Robert Love wrote:
> On Mon, 2003-04-14 at 17:48, Jeremy Hall wrote:
> 
> > > Note two processors can never run the _same_ handler for the same line. 
> > > A given line (say IRQ 8) is masked out on all processors while its
> > > handler.
> >
> > ok, but in this case, the same handler appears on two different lines, 
> > once for one RME card, once for the other.  It is theoretically possible 
> > that one line could be handled by once CPU and the other by the other CPU.
> 
> Yep.  You must obtain a spin lock and disable local interrupts if there
> is any shared data here (and I am sure there is).
> 
My quandery is where to put the lock so that both cards will use it.  I 
need a layer that is visible to both and don't fully understand the alsa 
architecture enough to know where to put it.
> > I'm still digging at this, so don't know yet how to answer this point.  
> > I'm thinking somehow we need to schedule the snd_pcm_period_elapsed, or 
> > force it to run in interrupt context.
> > 
> > I thought I had done the latter by moving the snd_rme9652_write to the 
> > bottom of the function so that it wouldn't clear the interrupt condition 
> > until after it processed the data.
> > 
> > but I guess I hadn't because it didn't make a difference.  This is why I 
> > raise the question about whether other interrupts can be called.
> 
> Well, as I have said, they can still run on OTHER processors, as long as
> its a different interrupt line (same handler is irrelevant).
> 
yes, I understand, but I had put nosmp and acpi=off in the boot line.  
There should have only been one processor, indeed I verified /proc/cpuinfo 
only showed one, although the kernel was compiled for SMP.

> So you can have these two handlers you speak of run at the same time.  I
> think you are trying to prevent that, no?
> 
I am trying to prevent one card from stopping while the other is reading.  
They can both read or write or whatever at the same time, but if state 
needs to be changed, everything needs to come to a stop so the state can 
change.

> Well, you cannot... but you can protect the shared data or hardware with
> a lock.  Grab a spin_lock in the handler prior to doing what you wish to
> protect.  This will prevent that chunk of code from running
> simultaneously.
> 
yes I understand what you are saying.

> Linus has a nice discussion on spin locks in Documentation/spinlocks.txt
> 
yes sorry for the silly dialog.  I'll post a backtrace so maybe it will be 
more clear.

_J

> 	Robert Love
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
