Date: Fri, 15 Aug 2008 16:54:57 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: pthread_create() slow for many threads; also time to revisit 64b context switch optimization?
Message-ID: <20080815155457.GA5210@shareable.org>
References: <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com> <20080813154043.GA11886@elte.hu> <48A303EE.8070002@redhat.com> <20080813160218.GB18037@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080813160218.GB18037@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Ulrich Drepper <drepper@redhat.com>, Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> As unimplemented flags just get ignored by the kernel, if this flag goes 
> into v2.6.27 as-is and is ignored by the kernel (i.e. we just use a 
> plain old 64-bit [47-bit] allocation), then you could do the glibc 
> change straight away, correct? So then if people complain we can fix it 
> in the kernel purely.
> 
> how about this then?

> +#define MAP_64BIT_STACK 0x20000         /* give out 32bit addresses on old CPUs */

I think the flag makes sense but it's name is confusing - 64BIT for a
flag which means "maybe request 32-bit stack"!  Suggest:

+#define MAP_STACK       0x20000         /* 31bit or 64bit address for stack, */
+                                        /* whichever is faster on this CPU */

Also, is this _only_ useful for thread stacks, or are there other
memory allocations where 31-bitness affects execution speed on old P4s?

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
