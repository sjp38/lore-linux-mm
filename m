Date: Fri, 13 Apr 2007 16:03:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] generic rwsems
Message-ID: <20070413140313.GG966@wotan.suse.de>
References: <20070413124303.GD966@wotan.suse.de> <20070413100416.GC31487@wotan.suse.de> <25821.1176466182@redhat.com> <30644.1176471112@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <30644.1176471112@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 13, 2007 at 02:31:52PM +0100, David Howells wrote:
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > The other way happens to be better for everyone else, which is why I
> > think your suggestion to instead move everyone to the spinlock version
> > was weird.
> 
> No, you misunderstand me.  My preferred solution is to leave it up to the arch
> and not to make it generic, though I'm not averse to providing some prepackaged
> solutions for an arch to pick from if it wants to.

Just doesn't seem to be much payoff. I know you didn't think there is
anything wrong with 2 different impleemtnations and hundreds of lines
of arch specific assembly, but there is really little gain. Sure you
might be able to optimise a few cycles off the i386 asm, but damn I
just blitzed that sort of improvement on x86-64... and I still doubt
it will be very noticable because rwsems don't get called like
spinlocks.


> > Finally: as I said, even for those 2 architectures, this may not be so
> > bad because it is using a different spinlock for the fastpath as it is
> > for the slowpath. So your uncontested, cache cold case will get a little
> > slower, but the contested case could improve a lot (eg. I saw an order of
> > magnitude improvement).
> 
> Agreed.  I can see why the spinlock implementation is bad on SMP.  By all means
> change those cases, and reduce the spinlock implementation to an interrupt
> disablement only version that may only be used on UP only.

So you missed my point about this above. If your UP atomic ops are
slower than interrupt disabling, then implement the damn things using
interrupt disabling instead of whatever it is you are using that is
slower! ;)

> > 32-bit machines might indeed overflow, but if it hasn't been a problem
> > for i386 or (even 64-bit) powerpc yet, is it a real worry? 
> 
> It has happened, I believe.  People have tried having >32766 threads on a
> 32-bit box.  Mad it may be, but...

Anyway, I doubt all the 32-bit archs using atomics would convert to the
slower spinlocks, so maybe this just has to be a known issue.


> > This is what spinlocks and mutexes do, and they're much more common than
> > rwsems. I'm just trying to make it consistent, and you can muck around
> > with it all you want after that. It is actually very easy to inline
> > things now, unlike before my patch.
> 
> My original stuff was very easy to inline until Ingo got hold of it.

I agree that all the locking has turned pretty messy, but that isn't
my fault.


> > > Think about it.  This algorithm is only optimal where XADD is available.  If
> > > you don't have XADD, but you do have LL/SC or CMPXCHG, you can do better.
> > 
> > You keep saying this too, and I have thought about it but I couldn't think
> > of a much better way. I'm not saying you're wrong, but why don't you just
> > tell me what that better way is?
> 
> Look at how the counter works in the spinlock case.  With the addition of an
> extra flag in the counter to indicate there's stuff waiting on the queue, you
> can manipulate the counter if it appears safe to do so, otherwise you have to
> fall back to the slow path and take a spin lock.

[snip]

Ah, thanks. Yeah actually I remember you describing this at LCA, so I
apologise for saying you didn't ;)

Really, that isn't going to do much for performance (nothing as dramatic
as the x86-64 spinlock->atomic conversion). However it will reduce the
lock size by 8 bytes on 64-bit and fix the overflow on 32-bit...

So why don't we implement this as the generic version? UP archs won't
care because atomic_cmpxchg is generally just an interrupt disable,
similarly for sparc and parisc. Most others except x86 do atomic_add_return
with llsc or cas anyway, and even if the cmpxchg is a tiny bit slower for
x86, at least it should be much faster than the spinlock version for
x86-64, and will solve the overflow for i386. 
 
What do you say?

> > > similarly if you are using a UP-compiled kernel.
> > 
> > Then your UP-compiled kernel's atomic ops are suboptimal, not the rwsem
> > implementation.
> 
> That's usually a function of the CPU designer.

I mean your atomic_xxx functions are suboptimal for that design of CPU.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
