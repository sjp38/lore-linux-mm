Date: Fri, 13 Apr 2007 14:43:03 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] generic rwsems
Message-ID: <20070413124303.GD966@wotan.suse.de>
References: <20070413100416.GC31487@wotan.suse.de> <25821.1176466182@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25821.1176466182@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

David, you keep saying the same things and don't listen to me.

On Fri, Apr 13, 2007 at 01:09:42PM +0100, David Howells wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > This patch converts all architectures to a generic rwsem implementation,
> > which will compile down to the same code for i386, or powerpc, for
> > example,
> 
> > and will allow some (eg. x86-64) to move away from spinlock based rwsems.
> 
> Which are better on UP kernels because spinlocks degrade to nothing, and then
> you're left with a single disable/enable interrupt pair per operation, and no
> requirement for atomic ops at all.

On UP, if an IRQ disable/enable pair operation is _faster_ than the atomic
op, then the architecture can and should impelemnt atomic ops on UP by
doing exactly that.


> What you propose may wind up with several per op because if the CPU does not
> support atomic ops directly and cannot emulate them through other atomic ops,
> then these have to be emulated by:
> 
> 	atomic_op() {
> 		spin_lock_irqsave
> 		do op
> 		spin_unlock_irqrestore
> 	}

Yes, this is the case on our 2 premiere SMP powerhouse architectures,
sparc32 and parsic.

The other way happens to be better for everyone else, which is why I
think your suggestion to instead move everyone to the spinlock version
was weird.

Finally: as I said, even for those 2 architectures, this may not be so
bad because it is using a different spinlock for the fastpath as it is
for the slowpath. So your uncontested, cache cold case will get a little
slower, but the contested case could improve a lot (eg. I saw an order of
magnitude improvement).


> > Move to an architecture independent rwsem implementation, using the
> > better of the two rwsem implementations
> 
> That's not necessarily the case, as I said above.
> 
> Furthermore, the spinlock implementation struct is smaller on 64-bit machines,
> and is less prone to counter overrun on 32-bit machines.

I think 64-bit machines will be happy to take the extra word it if they
have double the single threaded performance, quadruple the parallel read
performance, and 10 times the contested read performance.

32-bit machines might indeed overflow, but if it hasn't been a problem
for i386 or (even 64-bit) powerpc yet, is it a real worry? 


> > Out-of-line the fastpaths, to bring rw-semaphores into line with
> > mutexes and spinlocks WRT our icache vs function call policy.
> 
> That should depend on whether you optimise for space or for speed.  Function
> calls are relatively heavyweight.

This is what spinlocks and mutexes do, and they're much more common than
rwsems. I'm just trying to make it consistent, and you can muck around
with it all you want after that. It is actually very easy to inline
things now, unlike before my patch.


> Please re-inline and fix Ingo's mess if you must clean up.  Take the i386
> version, for instance, I'd made it so that the compiler didn't know it was
> taking a function call when it went down the slow path, thus meaning the
> compiler didn't have to deal with that.  Furthermore, it only interpolated two
> or three instructions into the calling code in the fastpath.  It's a real shame
> that gcc inline asm doesn't allow you to use status flags as boolean returns,
> otherwise I could reduce that even further.

I cleaned it.


> > Spinlock based rwsems are inferior to atomic based ones one most
> > architectures that can do atomic ops without spinlocks:
> 
> Note the "most" in your statement...
> 
> Think about it.  This algorithm is only optimal where XADD is available.  If
> you don't have XADD, but you do have LL/SC or CMPXCHG, you can do better.

You keep saying this too, and I have thought about it but I couldn't think
of a much better way. I'm not saying you're wrong, but why don't you just
tell me what that better way is?


> If the only atomic op you have is XCHG, then this is a really poor choice;

What is better? spinlocks? I think that considering only 2 dead archs
really care at this stage, and I have good reason to believe that the
contested case will be impreoved, then why don't you come up with some
numbers to prove me wrong?


> similarly if you are using a UP-compiled kernel.

Then your UP-compiled kernel's atomic ops are suboptimal, not the rwsem
implementation.

Anyway, thanks for taking the time again. If you would please address each
of my points, then we might finally be able to stop having this discussion
every 6 months ;)

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
