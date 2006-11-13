Date: Tue, 14 Nov 2006 10:53:36 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [hugepage] Fix unmap_and_free_vma backout path
Message-ID: <20061113235336.GB13060@localhost.localdomain>
References: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com> <Pine.LNX.4.64.0611131650140.8280@blonde.wat.veritas.com> <1163450069.17046.24.camel@localhost.localdomain> <Pine.LNX.4.64.0611132039001.23846@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611132039001.23846@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Adam Litke <agl@us.ibm.com>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 13, 2006 at 08:41:49PM +0000, Hugh Dickins wrote:
> On Mon, 13 Nov 2006, Adam Litke wrote:
> 
> > Looks good to me, notwithstanding the nano-nit below.
> > 
> > On Mon, 2006-11-13 at 17:00 +0000, Hugh Dickins wrote:
> > > +	/*
> > > +	 * vma alignment has already been checked by prepare_hugepage_range.
> > > +	 * If you add any error returns here, do so after setting VM_HUGETLB,
> > > +	 * so is_vm_huge_tlb_page tests below unmap_region go the right way
> > > +	 * when do_mmap_pgoff unwinds (may be important on powerpc and ia64).
> > > +	 */
> > 
> > Sorry.  This is hardly worth it, but the function referred to by this
> > comment is actually is_vm_hugetlb_page() :-/
> 
> Indeed, thanks!
> 
> [PATCH] hugetlb: prepare_hugepage_range check offset too
> 
> prepare_hugepage_range should check file offset alignment when it checks
> virtual address and length, to stop MAP_FIXED with a bad huge offset from
> unmapping before it fails further down.  PowerPC should apply the same
> prepare_hugepage_range alignment checks as ia64 and all the others do.
> 
> Then none of the alignment checks in hugetlbfs_file_mmap are required
> (nor is the check for too small a mapping); but even so, move up setting
> of VM_HUGETLB and add a comment to warn of what David Gibson discovered -
> if hugetlbfs_file_mmap fails before setting it, do_mmap_pgoff's unmap_region
> when unwinding from error will go the non-huge way, which may cause bad
> behaviour on architectures (powerpc and ia64) which segregate their huge
> mappings into a separate region of the address space.

Looks pretty good.  There's still a certain amount of wierdness on
powerpc: we can back out after (irreversibly) switching chunks of the
address space over to use for hugepages.  I'll try to fix that up
later, but in any case it's certainly more comprehensive than my
original patch.

Acked-by: David Gibson <david@gibson.dropbear.id.au>

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
