Date: Fri, 15 Aug 2008 15:33:22 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit 64b context switch optimization?
Message-ID: <20080815133322.GH19125@one.firstfloor.org>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <87fxp8zlx3.fsf@basil.nowhere.org> <20080815124350.GA26594@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080815124350.GA26594@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andi Kleen <andi@firstfloor.org>, Ulrich Drepper <drepper@redhat.com>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 15, 2008 at 02:43:50PM +0200, Ingo Molnar wrote:
> i had such a P4 based 64-bit box and it was painful.

I used them as 64bit machines and they weren't painful at all.

> I'd love to zap MAP_32BIT this very minute from the kernel, but you 
> originally shaped the whole thing in such a stupid way that makes its 
> elimination impossible now due to ABI constraints. It would have cost 

MAP_32BIT was not actually added for this originally. It 
was originally added for the X server's old dynamic loader, which
needed 2GB memory.

It's main failing, which I freely admit, was to not call it MAP_31BIT.

> you _nothing_ to have added MAP_64BIT_STACK back then, but the quick & 

Not sure what the semantics of that would be. For me it would
seem ugly to hardcode specific semantics in the kernel for this
("mechanism not policy")

But for most possible semantics I can think of the data structure would still 
need to be fixed I think.

> The correct solution is to eliminate this flag from glibc right now, and 

IMHO the correct solution is to fix the data structure to not have such
a bad complexity in this corner case. We typically do this for all
other data structures as we discover such cases. No reason the VMAs
should be any different. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
