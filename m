Date: Mon, 8 Jul 2002 09:11:13 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020708071113.GB1350@dualathlon.random>
References: <1083506661.1026032427@[10.10.2.3]> <Pine.LNX.4.44.0207071119130.3271-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0207071119130.3271-100000@home.transmeta.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <fletch@aracnet.com>, Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 07, 2002 at 11:28:03AM -0700, Linus Torvalds wrote:
> Hmm.. Right now we have the same IDT and GDT on all CPU's, so _if_ the CPU
> is stupid enough to do a locked cycle to update the "A" bit on the
> segments (even if it is already set), you would see horrible cacheline
> bouncing for any interrupt.
> 
> I don't know if that is the case. I'd _assume_ that the microcode was
> clever enough to not do this, but who knows. It should be fairly easily
> testable (just "SMOP") by duplicating the IDT/GDT across CPU's.

if that would be the problem, it would be not specific to IPI though, I
would be surprised if the cpu would be that stupid to lock in such an
always read-only place, it would showup in any smp regardless of the
smp_call_function. OTOH I don't know why the hardware would even try to
lock implicitly there.

> I don't think the cross-calls should have any locks in them, although
> there does seem to be some silly things like "flush_cpumask" that should
> probably just be in the "cpu_tlbstate[cpu] array instead (no cacheline
> bouncing, and since we touch that array anyway, it should be better for
> the cache in other ways too).

agreed, I overlooked it, flush_cpumask is also a good candidate to be
made per-cpu. The others as said are the ->started/finished in the
call_data array (that's generic for all smp_call_function).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
