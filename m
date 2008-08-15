Date: Fri, 15 Aug 2008 14:43:50 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080815124350.GA26594@elte.hu>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <87fxp8zlx3.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fxp8zlx3.fsf@basil.nowhere.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ulrich Drepper <drepper@redhat.com>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Andi Kleen <andi@firstfloor.org> wrote:

> Ingo Molnar <mingo@elte.hu> writes:
> >
> > i find it pretty unacceptable these days that we limit any aspect of 
> > pure 64-bit apps in any way to 4GB (or any other 32-bit-ish limit). 
> 
> It's not limited to 2GB, there's a fallback to >4GB of course. Ok 
> admittedly the fallback is slow, but it's there.

Of course - what you are missing is that _10 milliseconds_ thread 
creation overhead is completely unacceptable overhead: it is so bad as 
if we didnt even support it.

> I would prefer to not slow down the P4s. There are **lots** of them in 
> field. And they ran 64bit still quite well. [...]

Nonsense, i had such a P4 based 64-bit box and it was painful. Everyone 
with half a brain used them as 32-bit machines. Nor is the 
context-switch overhead in any way significant. Plus, as Arjan mentioned 
it, only the earliest P4 64-bit CPUs had this problem.

> [...] Also back then I benchmarked on early K8 and it also made a 
> difference there (but I admit I forgot the numbers)

that's a lot of handwaving with no actual numbers. The numbers in this 
discussion show that the context-switch overhead is small and that the 
overhead on perfectly good systems that hit this limit is obscurely 
high.

I'd love to zap MAP_32BIT this very minute from the kernel, but you 
originally shaped the whole thing in such a stupid way that makes its 
elimination impossible now due to ABI constraints. It would have cost 
you _nothing_ to have added MAP_64BIT_STACK back then, but the quick & 
sloppy solution was to reuse MAP_32BIT for 64-bit tasks. And you are 
stupid about it even now. Bleh.

The correct solution is to eliminate this flag from glibc right now, and 
maybe add the MAP_64BIT_STACK flag as well, as i posted it - if anyone 
with such old boxes still cares (i doubt anyone does). That flag then 
will take its usual slow route. Ulrich?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
