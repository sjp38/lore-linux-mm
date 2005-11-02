Date: Wed, 2 Nov 2005 09:49:46 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Message-ID: <20051102084946.GA3930@elte.hu>
References: <4366C559.5090504@yahoo.com.au> <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au> <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu> <1130854224.14475.60.camel@localhost> <20051101142959.GA9272@elte.hu> <1130856555.14475.77.camel@localhost> <20051101150142.GA10636@elte.hu> <1130858580.14475.98.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130858580.14475.98.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, Arjan van de Ven <arjanv@infradead.org>
List-ID: <linux-mm.kvack.org>

* Dave Hansen <haveblue@us.ibm.com> wrote:

> On Tue, 2005-11-01 at 16:01 +0100, Ingo Molnar wrote:
> > so it's all about expectations: _could_ you reasonably remove a piece of 
> > RAM? Customer will say: "I have stopped all nonessential services, and 
> > free RAM is at 90%, still I cannot remove that piece of faulty RAM, fix 
> > the kernel!".
> 
> That's an excellent example.  Until we have some kind of kernel 
> remapping, breaking the 1:1 kernel virtual mapping, these pages will 
> always exist.  The easiest example of this kind of memory is kernel 
> text.

another example is open files, dentries, inodes, kernel stacks and 
various other kernel objects, which can become embedded in a generic 
kernel memory zone anywhere, and can become referenced to from other 
objects.

The C language we use for the kernel has no notion to automatically 
track these links between objects, which makes general purpose memory 
unmapping very hard: each and every pointer would have to be tracked 
explicitly.

Such an 'explicit pointer tracking' approach is not only error-prone 
[the C language offers us no way to _avoid_ direct dereferencing], it's 
also clearly a maintainance nightmare. Code like:

	obj->ptr = obj2;

would have to become something like:

	obj_set(obj_deref(obj, ptr), obj2);

this is only a theoretical thing, it is very clear that such an approach 
is unreadable, unmaintainable and unworkable.

fixing 1:1 mapping assumptions is a cakewalk in comparison ...

the only sane solution to make generic kernel RAM hot-removable, from a 
conceptual angle, is to use a language for the kernel that supports 
pointer-rewriting, garbage-collection and hence VM-shrinking. I.e. to 
rewrite the kernel in Java, C# or whatever other type-safe language that 
can track pointers. [But possibly not even current Java implementations 
can do this right now, because they currently use faulting methods for 
GC and do not track every pointer, which method is not suitable for 
hot-remove.]

[ C++ might work too, but that needs extensive other changes and a 
  kernel-pointer type that all other pointer types have to inherited 
  from. No quick & easy void * pointers allowed. Such a restriction is
  possibly unenforcable and thus the solution is unmaintainable. ]

just to state the obvious: while using another programming language for 
the Linux kernel might make sense in the future, the likelhood for that 
to happen anytime soon seems quite low =B-)

so i strongly believe that it's plain impossible to do memory hot-unplug 
of generic kernel RAM in a reliable and guaranteed way.

there are other 'hot-' features though that might be doable though: 
memory hot-add and memory hot-replace:

- hot-add is relatively easy (still nontrivial) and with discontigmem we 
  have it supported in essence.

- hot-replace becomes possible with the breaking of 1:1 kernel mapping,
  because the totality of kernel RAM does not shrink, so it has no
  impact on the virtual side of kernel memory, it's "just" a replacement
  act on the physical side. It's still not trivial though: if the new
  memory area has a different physical offset (which is likely under
  most hw designs), all physical pointers needs tracking and fixups.
  I.e. DMA has to be tracked (iommu-alike approach) or silenced, and
  pagetables may need fixups. Also, if the swapped module involves the
  kernel image itself then "interesting" per-arch things have to be
  done. But in any case, this is a much more limited change than what
  hot-remove of generic kernel RAM necessiates. Hot-replace is what
  fault tolerant systems would need.

reliable hot-remove of generic kernel RAM is plain impossible even in a 
fully virtualized solution. It's impossible even with maximum hardware 
help. We simply dont have the means to fix up live kernel pointers still 
linked into the removed region, under the C programming model.

the hurdles towards a reliable solution are so incredibly high, that
other solutions _have_ to be considered: restrict the type of RAM that
can be removed, and put it into a separate zone. That solves things
easily: no kernel pointers will be allowed in those zones. It becomes
similar to highmem: various kernel caches can opt-in to be included in
that type of RAM, and the complexity (and maintainance impact) of the
approach can thus be nicely scaled.

> > > There is also no precedent in existing UNIXes for a 100% solution.
> > 
> > does this have any relevance to the point, other than to prove that it's 
> > a hard problem that we should not pretend to be able to solve, without 
> > seeing a clear path towards a solution?
> 
> Agreed.  It is a hard problem.  One that some other UNIXes have not
> fully solved.
> 
> Here are the steps that I think we need to take.  Do you see any holes
> in their coverage?  Anything that seems infeasible?
> 
> 1. Fragmentation avoidance
>    * by itself, increases likelyhood of having an area of memory
>      which might be easily removed
>    * very small (if any) performance overhead
>    * other potential in-kernel users
>    * creates infrastructure to enforce the "hotplugablity" of any
>      particular are of memory.
> 2. Driver APIs
>    * Require that drivers specifically request for areas which must
>      retain constant physical addresses
>    * Driver must relinquish control of such areas upon request
>    * Can be worked around by hypervisors
> 3. Break 1:1 Kernel Virtual/Physial Mapping 
>    * In any large area of physical memory we wish to remove, there will
>      likely be very, very few straggler pages, which can not easily be
>      freed.
>    * Kernel will transparently move the contents of these physical pages
>      to new pages, keeping constant virtual addresses.
>    * Negative TLB overhead, as in-kernel large page mappings are broken
>      down into smaller pages.
>    * __{p,v}a() become more expensive, likely a table lookup
> 
> I've already done (3) on a limited basis, in the early days of memory 
> hotplug.  Not the remapping, just breaking the 1:1 assumptions.  It 
> wasn't too horribly painful.

i dont see the most fundamental problem listed: live kernel pointers 
pointing into a generic kernel RAM zone. Removing the 1:1 mapping and 
making the kernel VM space fully virtual will not solve that problem!

lets face it: removal of generic kernel RAM is a hard, and essentially 
unsolvable problem under the current Linux kernel model. It's not just 
the VM itself and 1:1 mappings (which is a nontrivial problem but which 
we can and probably should solve), it boils down to the fundamental 
choice of using C as the language of the kernel!

really, once you accept that, the path out of this mess becomes 'easy': 
we _have to_ compromise on the feature side! And the moment we give up 
the notion of 'generic kernel RAM' and focus on the hot-removability of 
a limited-functionality zone, the complexity of the solution becomes 
three orders of magnitude smaller. No fragmentation avoidance necessary.  
No 'have to handle dozens of very hard problems to become 99% 
functional' issues. Once you make that zone an opt-in thing, it becomes 
much better from a development dynamics point of view as well.

i believe that it's also easier from an emotional point of view: our 
choice to use the C language forces us to abandon the idea of 
hot-removable generic kernel RAM. This is not some borderline decision 
where different people have different judgement - this is a hard, 
almost-mathematical fact that is forced upon us by the laws of physics 
(and/or whatever deity you might believe in). The same laws that make 
faster than O(N)*O(log(N)) sorting impossible. No amount of hacking will 
get us past that wall.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
