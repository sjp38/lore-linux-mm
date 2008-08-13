Date: Wed, 13 Aug 2008 12:44:45 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080813104445.GA24632@elte.hu>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pardo <pardo@google.com>
Cc: akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Ulrich Drepper <drepper@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

* Pardo <pardo@google.com> wrote:

>  As example, in one case creating new threads goes from about 35,000 
> cycles up to about 25,000,000 cycles -- which is under 100 threads per 
> second. [...]

> Various things would address the slow pthread_create().  Choices 
> include:
>  - Be more platform-aware about when to use MAP_32BIT.
>  - Abandon use of MAP_32BIT entirely, with worse performance on some machines.
>  - Change the mmap() algorithm to be faster on allocation failure
> (avoid a linear search of vmas).

Sigh, unfortunately MAP_32BIT use in 64-bit apps for stacks was 
apparently created without foresight about what would happen in the MM 
when thread stacks exhaust 4GB.

The problem is that MAP_32BIT is used both as a performance hack for 
64-bit apps and as an ABI compat mechanism for 32-bit apps. So we cannot 
just start disregarding MAP_32BIT in the kernel - we'd break 32-bit 
compat apps and/or compat 32-bit libraries.

There are various other options to solve the (severe!) performance 
breakdown:

1- glibc could start not using MAP_32BIT for 64-bit thread stacks (the 
   boxes where context-switching is slow probably do not matter all that 
   much anymore - they were very slow at everything 64-bit anyway)

     Pros: easiest solution.
     Cons: slows down the affected machines and needs a new glibc.

2- We could introduce a new MAP_64BIT_STACK flag which we could
   propagate it into MAP_32BIT on those old CPUs. It would be 
   disregarded on modern CPUs and thread stacks would be 64-bit.

     Pros: cleanest solution.
     Cons: needs both new glibc and new kernel to take advantage of.

3- We could detect the first-4G-is-full condition and cache it. Problem
   is, there will likely be small holes in it so it's rather hard to do 
   it in a sane way. Also, every munmap() of a thread stack will 
   invalidate this - triggering a slow linear search every now and then.

     Pros: only needs a new kernel to take advantage of.
     Cons: is the most complex and messiest solution with no clear 
           benefit to other workloads. Also, does not 100% solve the 
           performance problem and prolongues the 4GB stack threads 
           hack.

i'd go for 1) or 2).

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
