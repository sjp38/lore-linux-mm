Date: Sun, 7 Jul 2002 11:28:03 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
In-Reply-To: <1083506661.1026032427@[10.10.2.3]>
Message-ID: <Pine.LNX.4.44.0207071119130.3271-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <fletch@aracnet.com>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sun, 7 Jul 2002, Martin J. Bligh wrote:
> >
> > So if the main problem ends up being that some paths (a) really want the
> > persistent version _and_ (b) you can make the paths hold them for long
> > times (by writing to a blocking pipe/socket or similar) we may just have
> > much simpler approaches - like a per-user kmap count.
>
> I don't think they really want something that's persistant over a
> long time, I think they want something they can hold over a potential
> reschedule - that's why they're not using kmap_atomic.

Some things could be _loong_, ie the "sendfile()" case to a socket.

Worse, it can be intentionally made arbitrarily long by just setting up a
socket that has no readers, which is why it is potentially a DoS thing.

This is why I suggested the per-user kmap semaphore: not because it will
ever trigger in normal load (where "normal load" means even _extremely_
high load by people who don't actively try to break the system), but
because it will be a resource counter for a potential attack and limit the
attacker down to the point where it isn't a problem.

> > Which just guarantees that any user at any time can only hold 100
> > concurrent persistent kmap's open. Problem solved.
>
> We're not running out of kmaps in the pool, we're just churning them
> (and dirtying them) at an unpleasant rate. Every time we exhaust the
> pool, we do a global TLB flush on all CPUs, which sucks for performance.

That's the "normal load" case, fixable by just making the kmap pool
larger. That's ot what the semaphore is there for.

> > The _performance_ scalability concerns should be fairly easily solvable
> > (as far as I can tell - feel free to correct me) by making the persistent
> > array bigger
>
> Making the array bigger does help, but it consumes some more virtual
> address space, which the most critical resource on these machines ...
> at the moment we use up 1024 entries, which is 4Mb, I normally set
> things to 4096, which uses 16Mb - certainly that would be a better
> default for larger machines. But if I make it much bigger than that,
> I start to run out of vmalloc space ;-) Of course we could just add
> the size of the kmap pool to _VMALLOC_RESERVE, which would be somewhat
> better ...

I don't see 16MB of virtual space as being a real problem on a 64GB
machine.

> PS. One interesting thing Keith found was this: on NUMA-Q, I currently
> do the IPI send for smp_call_function (amongst other things) as a
> sequenced unicast (send a seperate message to each CPU in turn),
> rather than the normal broadcast because it's harder to do in
> clustered apic mode. Whilst trying to switch this back, he found it ran
> faster as the sequenced unicast, not only for NUMA-Q, but also for
> standard SMP boxes!!! I'm guessing the timing offset generated helps
> cacheline or lock contention ... interesting anyway.

Hmm.. Right now we have the same IDT and GDT on all CPU's, so _if_ the CPU
is stupid enough to do a locked cycle to update the "A" bit on the
segments (even if it is already set), you would see horrible cacheline
bouncing for any interrupt.

I don't know if that is the case. I'd _assume_ that the microcode was
clever enough to not do this, but who knows. It should be fairly easily
testable (just "SMOP") by duplicating the IDT/GDT across CPU's.

I don't think the cross-calls should have any locks in them, although
there does seem to be some silly things like "flush_cpumask" that should
probably just be in the "cpu_tlbstate[cpu] array instead (no cacheline
bouncing, and since we touch that array anyway, it should be better for
the cache in other ways too).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
