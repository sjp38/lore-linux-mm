Date: Wed, 13 Aug 2008 17:40:43 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: pthread_create() slow for many threads; also time to revisit
	64b context switch optimization?
Message-ID: <20080813154043.GA11886@elte.hu>
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48A2FC17.9070302@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

* Ulrich Drepper <drepper@redhat.com> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Ingo Molnar wrote:
> > i find it pretty unacceptable these days that we limit any aspect of 
> > pure 64-bit apps in any way to 4GB (or any other 32-bit-ish limit). 
> 
> Sure, but if we can pin-point the sub-archs for which it is the 
> problem then a flag to optionally request it is even easier to handle.  
> You'd simply ignore the flag for anything but the P4 architecture.

i suspect you are talking about option #2 i described. It is the option 
which will take the most time to trickle down to people.

> I personally have no problem removing the whole thing because I have 
> no such machine running anymore.  But there are people out there who 
> have.

hm, i think the set of people running on such boxes _and_ then upgrading 
to a new glibc and expecting everything to be just as fast to the 
microsecond as before should be miniscule. Those P4 derived 64-bit boxes 
were astonishingly painful in 64-bit mode - most of that hw is running 
32-bit i suspect, because 64-bit on it was really a joke.

Btw., can you see any problems with option #1: simply removing MAP_32BIT 
from 64-bit stack allocations in glibc unconditionally? It's the fastest 
to execute and also the most obvious solution. +1 usecs overhead in the 
64-bit context-switch path on those old slow boxes wont matter much. 

10 _millisecs_ to start a single thread on top-of-the-line hw is quite 
unaccepable. (and there's little sane we can do in the kernel about 
allocation overhead when we have an imperfectly filled 4GB box for all 
allocations)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
