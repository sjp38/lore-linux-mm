Date: Sun, 07 Jul 2002 09:00:27 -0700
From: "Martin J. Bligh" <fletch@aracnet.com>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <1083506661.1026032427@[10.10.2.3]>
In-Reply-To: <Pine.LNX.4.44.0207070041260.2262-100000@home.transmeta.com>
References: <Pine.LNX.4.44.0207070041260.2262-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> I think that might have been when Andrea was using persistent kmap
>> for highpte (since fixed), so we were really kicking the **** out
>> of it. Nonetheless, your point is perfectly correct, it's the
>> global invalidate that's really the expensive thing.
> 
> I suspect that there really aren't that many places that care about the
> persistent mappings, and the atomic per-cpu stuff is inherently scalable
> (but due to being harder to cache, slower). So I wonder how much of a
> problem the kmap stuff really is.
> 
> So if the main problem ends up being that some paths (a) really want the
> persistent version _and_ (b) you can make the paths hold them for long
> times (by writing to a blocking pipe/socket or similar) we may just have
> much simpler approaches - like a per-user kmap count.

I don't think they really want something that's persistant over a
long time, I think they want something they can hold over a potential
reschedule - that's why they're not using kmap_atomic.

> Which just guarantees that any user at any time can only hold 100
> concurrent persistent kmap's open. Problem solved.

We're not running out of kmaps in the pool, we're just churning them
(and dirtying them) at an unpleasant rate. Every time we exhaust the
pool, we do a global TLB flush on all CPUs, which sucks for performance.
 
> The _performance_ scalability concerns should be fairly easily solvable
> (as far as I can tell - feel free to correct me) by making the persistent
> array bigger 

Making the array bigger does help, but it consumes some more virtual
address space, which the most critical resource on these machines ... 
at the moment we use up 1024 entries, which is 4Mb, I normally set
things to 4096, which uses 16Mb - certainly that would be a better
default for larger machines. But if I make it much bigger than that,
I start to run out of vmalloc space ;-) Of course we could just add
the size of the kmap pool to _VMALLOC_RESERVE, which would be somewhat
better ...

> and finding things where persistency isn't needed (and
> possibly doesn't even help due to lack of locality), and just 
> making those places use the per-cpu atomic ones.

I'm kind of handwaving at this point because I don't have the stats
to hand. I had Keith gather some stats on this, and see what was 
actually calling kmap - I'll dig those out on Monday when I'm back
in the office, and send them along.

I was kind of hoping to find some elegant killer solution to all this,
but it's been kicked around for a while now, and every solution seems
to have its problems. If it can't be elegantly solved, we can probably
kill the performance issue by just tuning, as you say ...

M.

PS. One interesting thing Keith found was this: on NUMA-Q, I currently
do the IPI send for smp_call_function (amongst other things) as a 
sequenced unicast (send a seperate message to each CPU in turn), 
rather than the normal broadcast because it's harder to do in 
clustered apic mode. Whilst trying to switch this back, he found it ran
faster as the sequenced unicast, not only for NUMA-Q, but also for
standard SMP boxes!!! I'm guessing the timing offset generated helps
cacheline or lock contention ... interesting anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
