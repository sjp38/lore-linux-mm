Date: Sat, 06 Jul 2002 23:13:12 -0700
From: "Martin J. Bligh" <fletch@aracnet.com>
Subject: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <1048271645.1025997192@[10.10.2.3]>
In-Reply-To: <3D27AC81.FC72D08F@zip.com.au>
References: <3D27AC81.FC72D08F@zip.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Martin is being bitten by the global invalidate more than by the lock.

True.

> He increased the size of the kmap pool just to reduce the invalidate
> frequency and saw 40% speedups of some stuff.

I think that might have been when Andrea was using persistent kmap
for highpte (since fixed), so we were really kicking the **** out 
of it. Nonetheless, your point is perfectly correct, it's the 
global invalidate that's really the expensive thing.

Making the kmap pool 4096 instead of 1024 resulted in a tenfold 
reduction in the number of global TLB flushes (there's a static 
set of "fixed" maps which would presumably explain the difference).

As we have larger memory machines, we're under more and more KVA
pressure, more stuff gets shoved into highmem, kmap usage gets
heavier ... and this starts to look even worse.

> Those invalidates don't show up nicely on profiles.

Not the standard profile, no. We can fairly easily count the cost
of the time taken to do the flush, but not the side effects of the
cache-trash. According to my P4 manual, I can see an ITLB miss counter,
but nothing for the data (apart from some more generic things).

> I was discussing this with sct a few days back.  iiuc, the proposal
> was to create a small per-cpu pool (say, 4-8 pages) which is a
> "front-end" to regular old kmap().
> 
> Any time you have one of these pages in use, the process gets
> pinned onto the current CPU. 

Ewww! That's gross ;-) I don't want to think about how that interacts
with cpus_allowed being changed, etc .... but mainly it's just gross ;-)
On the other hand I won't deny it may be the most practical solution ....

The really sad thing about the global TLB flush for persisant kmap 
is that it's probably wholly unnecessary - most likely each entry
is really only dirty on 1 CPU.

At a random guess (ie I haven't actually checked this), I think the
vast majority of the persistent kmaps are doing something like:
"kmap; copy_to/from_user; kunmap", and are just using this mechanism
in case the page they're copying to / from us going to generate a 
page fault & schedule - thus we don't use atomic kmap. The proportions
are merely speculation - if someone wants to throw stones at that (or
better still, empirical measurements), feel free.

I talked this over with Andrea for a while at OLS, and some of the
other things we covered are below (KVA = kernel virtual addr space,
UKVA = user-kernel virtual address space, per process like user
space, but with the protections of kernel space).

1. Just pin the damned page.

Instead of pinning the process, pin the user page you're touching in
memory. To me this is more elegant, though Andrea pointed out we'd
be slowing down the common case when you don't actually page fault
at all.

Then I mentioned something about fixing it up in the pagefault path
instead so that the process would reset it's map when it got restarted,
but Andrea started laughing at that point ;-)

2. Per process kmaps

This kills the global kmap_lock and is fairly easy to implement with
just a per-process lock. Unfortunately it still doesn't really kill
the problem of having to do a global TLB flush if your process has
more than 1 thread. Whilst I can limply claim that it's kind of nice
for most non-threaded processes, and the fallback position is no worse
than we have now, it's not panning out the way I'd hoped.

3. Per task kmaps

The way we've been doing UKVA up to now is to map it at the top of the
user address space, wedging it above the stack, and it's on a per-process
basis. If we moved the area up to the window in the top 128Mb of KVA
instead, it might be easier to make it really per task instead, which'd
be much more useful for kmap.

Then you'd need to allocate 1 virtual frame per task and you'd get 
atomic, persistent, per-task kmap. Which I think isn't as bad as it
sounds, because you can actually reuse the same virtual page for all
tasks ... or at least I think you can ... it's late, and I need to 
twist my brain through that one some more. I think this'd stop you
having a shared kernel top level pagetable for all tasks though, so
it probably causes more problems than it solves.

4. Another kludge.

Supposing we didn't really map the page at all, just left it as an
invalid page table entry, and just shoved an entry into the TLB 
instead (there's a way of doing that somewhere) ... chances are 
very good it'd stay there long enough to do the operation, if it 
fell out, or we got migrated, you'd just get a pagefault and patch
it back up again ... ;-)

> I believe that IBM have 32gig, 8- or 16-CPU ia32 machines just
> coming into production now.  Presumably, they're not the only
> ones.  We're stuck with this mess for another few years.

We do indeed - the latest ones we'll actually be selling can actually
go even larger. I now have a 32 way 32Gb P3 box in the lab from older hardware for experiments, and have enough hardware to make something 
even bigger if I'm feeling particularly suicidal one day ... whilst 
I'd agree that large 32 bit boxes are a temporary transition phase 
(and a pain in the ass) it'll be a while before we have Hammer systems 
large enough for this sort of thing. Or if you have a few million 
dollars, Anton has a very nice PPC64 machine he can sell you ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
