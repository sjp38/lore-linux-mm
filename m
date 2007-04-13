From: David Howells <dhowells@redhat.com>
In-Reply-To: <20070413100416.GC31487@wotan.suse.de> 
References: <20070413100416.GC31487@wotan.suse.de> 
Subject: Re: [patch] generic rwsems 
Date: Fri, 13 Apr 2007 13:09:42 +0100
Message-ID: <25821.1176466182@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:

> This patch converts all architectures to a generic rwsem implementation,
> which will compile down to the same code for i386, or powerpc, for
> example,

> and will allow some (eg. x86-64) to move away from spinlock based rwsems.

Which are better on UP kernels because spinlocks degrade to nothing, and then
you're left with a single disable/enable interrupt pair per operation, and no
requirement for atomic ops at all.

What you propose may wind up with several per op because if the CPU does not
support atomic ops directly and cannot emulate them through other atomic ops,
then these have to be emulated by:

	atomic_op() {
		spin_lock_irqsave
		do op
		spin_unlock_irqrestore
	}

> Move to an architecture independent rwsem implementation, using the
> better of the two rwsem implementations

That's not necessarily the case, as I said above.

Furthermore, the spinlock implementation struct is smaller on 64-bit machines,
and is less prone to counter overrun on 32-bit machines.

> Out-of-line the fastpaths, to bring rw-semaphores into line with
> mutexes and spinlocks WRT our icache vs function call policy.

That should depend on whether you optimise for space or for speed.  Function
calls are relatively heavyweight.

Please re-inline and fix Ingo's mess if you must clean up.  Take the i386
version, for instance, I'd made it so that the compiler didn't know it was
taking a function call when it went down the slow path, thus meaning the
compiler didn't have to deal with that.  Furthermore, it only interpolated two
or three instructions into the calling code in the fastpath.  It's a real shame
that gcc inline asm doesn't allow you to use status flags as boolean returns,
otherwise I could reduce that even further.

> Spinlock based rwsems are inferior to atomic based ones one most
> architectures that can do atomic ops without spinlocks:

Note the "most" in your statement...

Think about it.  This algorithm is only optimal where XADD is available.  If
you don't have XADD, but you do have LL/SC or CMPXCHG, you can do better.

If the only atomic op you have is XCHG, then this is a really poor choice;
similarly if you are using a UP-compiled kernel.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
