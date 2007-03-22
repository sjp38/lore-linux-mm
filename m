Date: Thu, 22 Mar 2007 15:42:27 +0000
Subject: Re: pagetable_ops: Hugetlb character device example
Message-ID: <20070322154227.GA14366@skynet.ie>
References: <20070319200502.17168.17175.stgit@localhost.localdomain> <1174506228.21684.41.camel@localhost.localdomain> <20070322103817.GA7348@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070322103817.GA7348@infradead.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (22/03/07 10:38), Christoph Hellwig didst pronounce:
> On Wed, Mar 21, 2007 at 02:43:48PM -0500, Adam Litke wrote:
> > The main reason I am advocating a set of pagetable_operations is to
> > enable the development of a new hugetlb interface.  During the hugetlb
> > BOFS at OLS last year, we talked about a character device that would
> > behave like /dev/zero.  Many of the people were talking about how they
> > just wanted to create MAP_PRIVATE hugetlb mappings without all the fuss
> > about the hugetlbfs filesystem.  /dev/zero is a familiar interface for
> > getting anonymous memory so bringing that model to huge pages would make
> > programming for anonymous huge pages easier.
> 
> That is a very laudable goal, but an utterly wrong way to get there.
> Despite Linus' veto a while ago what we really want is support for transparent
> super pages.

A year ago, I may have agreed with you. However, Linus not only veto'd it but
stamped on it repeatadly at VM Summit. He couldn't have made it clearer if
he wore a t-shirt a hat and held up a neon sign. The assertion at the time
was that variable page support of any sort had to be outside of the core VM
because automatic support will get it wrong in some cases and makes the core
VM harder to understand (because it's super-clear at the moment). Others
attending agreed with the position. That position rules out drivers or
filesystems giving hints about superpage sizes in the foreseeable future.

What they did not have any problem with was providing better interfaces to
program against as long as they were on the side of the VM like hugetlbfs
and not in the core. The character device for private mappings is an
example of an interface that is easier to program against than hugetlbfs.
It's far easier for an application to mmap a file at a fixed location than
trying to discover if hugetlbfs is mounted or not. However, to support that
sort of interface, there needs to be a way of telling the VM to call the an
alternative pagetable handler - hence Adam's patches.

Someone with sufficient energy could try implementing variable page support
entirely as a device using Adam's interface. If it turned out to be a
good idea, then another push could be made for transparent support later.
As it is, transparent superpage support is a also bit of a bitch for Power
and IA64. Power because in many cases (not all), pages of two different
sizes cannot be in the same virtual address range. IA64 has issues because
with the *current* pagetable implementation, hugepages are limited to fixed
address ranges. These sort of issues alone make transparent support in the
kernel a non-trivial problem.

> Adding random pointer indirections where we had the direct
> hugetlb calls before isn't helpful for that at all. 

They aren't random, they are pretty specific. Also, even when paths like fault
is entered, the cost of an indirect call is insignificant in comparison to
the page allocation, clearing the page and updating page tables.

In Adam's current patches, the indirect call only happens when a driver is
using the pagetable ops. In the tests I looked at, the cost of the branch
could only be detected on an instruction-level profile and even the branch
cost was pretty damn tiny. If it was a case that indirect calls always took
place, it *might* be a bit more noticable but still nothing in comparison
to the cost of the remainder of the operation.

> As a start you might
> want to make a clear destinction between core hugetlb code and the
> filesystem interface to it without all the useless indirections. 

The indirect calls are about supporting interfaces to userspace. In practice,
the hugetlbfs interface, the shared memory interface and the character device
interface would share a large amount of core code.  Admittadly that code
could do with restructuring because it's all mangled together at the moment.

The core hugetlb code as you call it is mainly dealing with page cache and
huge page pool management. The filesystem layer is relatively thin on top of
it. With Adams pagetable abstraction, it would make more sense to restructuring
the huge page code and separate out core-support-for-superpages from hugetlbfs.

> That
> should get you as far as your char dev interface. 

No, it wouldn't. Restructing the current code would allow better sharing
between interfaces but that's it. At the end of the restructuring, we'd still
need a way of saying "this VMA should be using some but not all the hugetlb
code over there even though I'm not hugetlbfs". At that point, we'd be back
at the pagetable ops abstraction.

> But over the long
> term the core VM needs to deal with multiple (and probably not just two)
> page sizes.  Given that the code to deal with different sized pages is
> essentially the same just on different units on most architectures cries
> for a better method to implement this than adding random function indirection
> that point to mostly identical code.
> 

Internally, a semi-sane way of supporting multiple page sizes would be
to have one internal VFS mount per page size and using the hugetlbfs page
cache management code.  Currently, HugetlbFS is basically a wrapper around
an internal VFS mount whose pages happen to be a specific size.

That said, variable page sizes is a different problem to the one Adam is
addressing here. In fact, someone with sufficient energy could implement a
variable page device behind Adam's abstraction just to see if it worked in
practice or not.

Restructering to support something like variable page support and more than
one interface would look something like;

HugetlbFS Interface	Shared Memory Interface		Char Device
	|                         |                          |
	|                         |               |-----------------
	|                         |               |                |
Internal hugetlbfs mount   Internal mount       mount            mount
 size HugePageSize         size HugPageSize   HugePageSize   different size
        |                         |               |                |
	|-----------------------------------------------------------
	                          |
		          Hugeage Reservation tracking
			          |
			  Hugepage pool management
			          |
		           Page allocator
	

But if this nice arrangement existed today, Adams patches would still be
needed to make it usable.

> And your driver is the best example of why we utterly don't want
> a page_table operations interface.  The last thing we want is random
> driver taking over core VM functionality. 

Who said anything about random? If a new driver of any sort shows up and
using pagetable_ops, the developer will certainly be asked what they are
doing that for.

> The right way would be to a
> filesystem/driver to tell (or maybe just give hints) which page size
> to use for this mapping.
> 

If a driver wants to "tell" what pagesize to use, they can override the ops
to call the appropriate hugetlb code. Hints will be damn near impossible to
get right in all cases.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
