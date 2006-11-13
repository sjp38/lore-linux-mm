From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [hugepage] Fix unmap_and_free_vma backout path
Date: Mon, 13 Nov 2006 09:38:38 -0800
Message-ID: <000001c7074a$8dd80f70$ff0da8c0@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.64.0611131650140.8280@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Hugh Dickins' <hugh@veritas.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote on Monday, November 13, 2006 9:00 AM
> On Sun, 12 Nov 2006, Chen, Kenneth W wrote:
> > David Gibson wrote on Sunday, November 12, 2006 10:23 PM
> > > > 
> > > > Something like this?  I haven't tested it yet.  But looks plausible
> > > > because we already have if is_file_hugepages() in the generic path.
> > > 
> > > Um.. if you're going to test pgoff here, you should also test the
> > > address.
> > 
> > prepare_hugepage_range() should catch misaligned memory address, right?
> > What more does get_unmapped_area() need to test?
> 
> David made that remark, I see now, because PowerPC alone omits to
> check address and length alignment in its prepare_hugepage_range:
> it should be checking those as ia64 and generic do.

Ah, I see. I only looked at the generic and ia64 version of
prepare_hugepage_range() and wasn't aware that powerpc doesn't check
address alignment in there :-P


> > > Oh, and that point is too late to catch MAP_FIXED mappings.
> > 
> > I don't understand what you mean by that.
> > In do_mmap_pgoff(), very early in the code it tries to get an valid
> > virtual address:
> > 
> >         addr = get_unmapped_area(file, addr, len, pgoff, flags);
> >         if (addr & ~PAGE_MASK)
> >                 return addr;
> > 
> > We don't even have a vma at this point, there is no error to recover.
> > If get_unmapped_area() tests the validity of pgoff and return an error
> > code, the immediate two lines of code will catch that and everything
> > stops there.  I don't see where the unmap gets called here.  Did I
> > miss something?
> 
> I agree with Ken on that.  I agree with just about everything said by
> people so far.  But I think the check looks nicer tucked away with the
> other alignment checks in prepare_hugepage_range: how about this version?


Looks nice with all the extra clean up.


> (Perhaps, in another mood, I've have chosen BUG_ONs instead of just
> deleting all the redundant tests - another deleted in the ppc case.)
> 
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
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  arch/ia64/mm/hugetlbpage.c    |    4 +++-
>  arch/powerpc/mm/hugetlbpage.c |    8 ++++++--
>  fs/hugetlbfs/inode.c          |   21 ++++++++-------------
>  include/linux/hugetlb.h       |   10 +++++++---
>  mm/mmap.c                     |    2 +-
>  5 files changed, 25 insertions(+), 20 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
