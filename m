Date: Wed, 13 Aug 2008 16:25:29 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080813142529.GB21129@elte.hu>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A2EE07.3040003@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Arjan van de Ven wrote:
> >> i'd go for 1) or 2).
> > 
> > I would go for 1) clearly; it's the cleanest thing going forward for
> > sure.
> 
> I want to see numbers first.  If there are problems visible I 
> definitely would want to see 2.  Andi at the time I wrote that code 
> was very adamant that I use the flag.

not sure exactly what numbers you mean, but there are lots of numbers in 
the first mail, attached below. For example:

| As example, in one case creating new threads goes from about 35,000 
| cycles up to about 25,000,000 cycles -- which is under 100 threads per 
| second.  Larger stacks reduce the severity of slowdown but also make

being able to create only 100 threads per second brings us back to 33 
MHz 386 DX Linux performance.

	Ingo

---------------------->

mmap() is slow on MAP_32BIT allocation failure, sometimes causing
NPTL's pthread_create() to run about three orders of magnitude slower.
 As example, in one case creating new threads goes from about 35,000
cycles up to about 25,000,000 cycles -- which is under 100 threads per
second.  Larger stacks reduce the severity of slowdown but also make
slowdown happen after allocating a few thousand threads.  Costs vary
with platform, stack size, etc., but thread allocation rates drop
suddenly on all of a half-dozen platforms I tried.

The cause is NPTL allocates stacks with code of the form (e.g., glibc
2.7 nptl/allocatestack.c):

sto = mmap(0, ..., MAP_PRIVATE|MAP_32BIT, ...);
if (sto == MAP_FAILED)
  sto = mmap(0, ..., MAP_PRIVATE, ...);

That is, try to allocate in the low 4GB, and when low addresses are
exhausted, allocate from any location.  Thus, once low addresses run
out, every stack allocation does a failing mmap() followed by a
successful mmap().  The failing mmap() is slow because it does a
linear search of all low-space vma's.

Low-address stacks are preferred because some machines context switch
much faster when the stack address has only 32 significant bits.  Slow
allocation was discussed in 2003 but without resolution.  See, e.g.,
http://ussg.iu.edu/hypermail/linux/kernel/0305.1/0321.html,
http://ussg.iu.edu/hypermail/linux/kernel/0305.1/0517.html,
http://ussg.iu.edu/hypermail/linux/kernel/0305.1/0538.html, and
http://ussg.iu.edu/hypermail/linux/kernel/0305.1/0520.html. With
increasing use of threads, slow allocation is becoming a problem.

Some old machines were faster switching 32b stacks, but new machines
seem to switch as fast or faster using 64b stacks.  I measured
thread-to-thread context switches on two AMD processors and five Intel
procesors.  Tests used the same code with 32b or 64b stack pointers;
tests covered varying numbers of threads switched and varying methods
of allocating stacks.  Two systems gave indistinguishable performance
with 32b or 64b stacks, four gave 5%-10% better performance using 64b
stacks, and of the systems I tested, only the P4 microarchitecture
x86-64 system gave better performance for 32b stacks, in that case
vastly better.  Most systems had thread-to-thread switch costs around
800-1200 cycles.  The P4 microarchitecture system had 32b context
switch costs around 3,000 cycles and 64b context switches around 4,800
cycles.

It appears the kernel's 64-bit switch path handles all 32-bit cases.
So on machines with a fast 64-bit path, context switch speed would
presumably be improved yet further by eliminating the special 32-bit
path.  It appears this would also collapse the task state's fs and
fsindex fields, and the gs and gsindex fields.  These could further
reduce memory, cache, and branch predictor pressure.

Various things would address the slow pthread_create().  Choices include:
 - Be more platform-aware about when to use MAP_32BIT.
 - Abandon use of MAP_32BIT entirely, with worse performance on some machines.
 - Change the mmap() algorithm to be faster on allocation failure
(avoid a linear search of vmas).

Options to improve context switch times include:

 - Do nothing.
 - Be more platform-aware about when to use different 32b and 64b paths.
 - Get rid of the 32b path, which also appears it would make contexts smaller.

[Not] Attached is a program to measure context switch costs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
