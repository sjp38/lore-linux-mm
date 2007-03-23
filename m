Date: Fri, 23 Mar 2007 14:57:23 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: pagetable_ops: Hugetlb character device example
In-Reply-To: <20070322181537.GA8317@infradead.org>
Message-ID: <Pine.LNX.4.64.0703231456230.4133@skynet.skynet.ie>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
 <1174506228.21684.41.camel@localhost.localdomain> <20070322103817.GA7348@infradead.org>
 <20070322154227.GA14366@skynet.ie> <20070322181537.GA8317@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Ken Chen <kenchen@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Mar 2007, Christoph Hellwig wrote:

> On Thu, Mar 22, 2007 at 03:42:27PM +0000, Mel Gorman wrote:
> > A year ago, I may have agreed with you. However, Linus not only veto'd
> > it but
> > stamped on it repeatadly at VM Summit. He couldn't have made it clearer
> > if
> > he wore a t-shirt a hat and held up a neon sign. The assertion at the
> > time
> > was that variable page support of any sort had to be outside of the core
> > VM
> > because automatic support will get it wrong in some cases and makes the
> > core
> > VM harder to understand (because it's super-clear at the moment). Others
> > attending agreed with the position. That position rules out drivers or
> > filesystems giving hints about superpage sizes in the foreseeable
> > future.
> 
> Actually I think the only way to get it right is to do it in the core
> (or inm the architecture code for the really nasty bits of course), but
> then again this isn't the point I want to make here..
>

Maybe ultimatly it's the right thing to do, more can be done "on the side"
until such time as it's really worth handling the complexity in the core VM.

> > What they did not have any problem with was providing better interfaces
> > to
> > program against as long as they were on the side of the VM like
> > hugetlbfs
> > and not in the core. The character device for private mappings is an
> > example of an interface that is easier to program against than
> > hugetlbfs.
> > It's far easier for an application to mmap a file at a fixed location
> > than
> > trying to discover if hugetlbfs is mounted or not. However, to support
> > that
> > sort of interface, there needs to be a way of telling the VM to call the
> > an
> > alternative pagetable handler - hence Adam's patches.
> 
> .. and this is where we get into problems.  There should be no need to
> use all kinds of pseudo-OO obsfucation to get there.  A VMA flag that
> means 'this is hugetlb backed anonymous memory' is much nicer to archive
> this.

Except in the example he posted, the fault handler for the char device and
the hugetlbfs case are doing slightly different things. The fault handler
for hugetlbfs assumes the existance of a file mapping where as the char
device is inserting the page directly. Having the bit is not enough for the
core is not enough to determine that a slightly different fault handler was
needed.

With the current code, it is almost impossible for a driver with a different
pagetable layout to express different semantics to hugetlbfs with respects
to how their pagetables are setup. Altering hugetlbfs much is very difficult
because any alteration becomes global in nature. The ops would allow a
experimental drivers and interfaces to be developed without breaking
existing users of hugetlbfs and let us figure out things like "Is it worth
supporting 1GiB pages in Opterons" without breaking everything else in the
process.

> Because it makes clear there is exactly one special case here
> and no carte blanche for drivers to do whatever they want.

Drivers can already cause all sorts of mayhem through the existing hooks if
they are perverse enough. It is never encouraged of course but nothing
prevents them.

> I would prefer
> to even get rid of that single special case as mentioned above, but I'm
> definitly set dead against at making this special case totally open for
> random bits of the kernel to mess with.
>

As kernel memory is already backed by huge tlb entries in many cases, random
drivers should have little or no interest in doing anything mad with
pagetable ops. All it gets them is pain and entertaining posts from the
mailing list.

That said, your main objection seems to be opening to door to arbitrary
drivers to change the pagetable ops. I can see your point and Hughs on why
this could lead to some hilarity down the road, particularly if out-of-tree
drivers entering into the mess so how about the following;

Instead of having a vma->pagetable_ops with a structure of pointers,
it would be a simple integer  into a fixed list of pagetable operation
handlers. Something like....

#define PAGETABLE_OP_DEFAULT      0
#define PAGETABLE_OP_HUGETLB_FS   1
#define PAGETABLE_OP_HUGETLB_CHAR 2

struct pagetable_operations_struct[] pagetable_ops_lookup_table = {
 	/* PAGETABLE_OP_DEFAULT assuming we always used the table */
 	{
 		.fault = handle_pte_fault
 		....
 	},

 	/* PAGETABLE_OP_HUGETLB_FS */
 	{
 		.fault    = hugetlb_fault
 		.copy_vma = copy_hugetlb_page_range
 		......
 	},

 	/* PAGETABLE_OP_HUGETLB_CHAR */
 	{
 		.fault = whatever
 	}
};

Drivers would only be able to set an index in the VMA for this table.
The lookup would be about the same cost as what is currently there. However,
random drivers cannot mess with the pagetable ops - they would have to be
known by the core. Experimental drivers would have to update the table but
that shouldn't be an issue. Out-of-tree drivers would have no ability to
mess here at all which is a good thing.

> > Someone with sufficient energy could try implementing variable page
> > support
> > entirely as a device using Adam's interface.
> 
> Hopefully not, doing this in a driver would be utterly braindead and
> certainly not mergeable.
>

Indeed, but exposing superpages only through a magic filesystem with special
semantics doesn't win the nobel prize either. The point is to have the
ability to develop alternatives to try them out without breaking existing
users of hugepages. How else can it be shown that further churn in the
core superpage support would be worth it?

All of that said, while I was writing this mail up Ken Chen posted a patch 
for a char device that sits on top of hugetlbfs that looks promising. That 
can be kicked that around a bit and put the pagetable ops on the 
back-burner until such time as there is a driver of interest that really 
needs to do something different semantically different to hugetlbfs with 
respects to page tables.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
