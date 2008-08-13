Subject: Re: pthread_create() slow for many threads; also time to revisit 64b context switch optimization?
From: Andi Kleen <andi@firstfloor.org>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com>
	<af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>
	<20080813104445.GA24632@elte.hu>
	<20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com>
	<20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com>
	<20080813151007.GA8780@elte.hu>
Date: Wed, 13 Aug 2008 22:42:48 +0200
In-Reply-To: <20080813151007.GA8780@elte.hu> (Ingo Molnar's message of "Wed, 13 Aug 2008 17:10:07 +0200")
Message-ID: <87fxp8zlx3.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Ulrich Drepper <drepper@redhat.com>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:
>
> i find it pretty unacceptable these days that we limit any aspect of 
> pure 64-bit apps in any way to 4GB (or any other 32-bit-ish limit). 

It's not limited to 2GB, there's a fallback to >4GB of course. Ok
admittedly the fallback is slow, but it's there.

I would prefer to not slow down the P4s. There are **lots** of them in
field. And they ran 64bit still quite well. Also back then I
benchmarked on early K8 and it also made a difference there (but I
admit I forgot the numbers)

I think it would be better to fix the VM because there are
other use cases of applications who prefer to allocate in a lower area.
For example Java JVMs now widely use a technique called pointer
compression where they dynamically adjust the pointer size based
on how much memory the process uses. For that you have to get
low memory in the 47bit VM too. The VM should deal with that gracefully.

To be honest I always thought the linear search in the VMA list
was a little dumb. I'm sure there are other cases where it hurts
too. Perhaps this would be really an opportunity  to do something about it :)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
