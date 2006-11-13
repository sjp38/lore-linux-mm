Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kADM7Z8h011196
	for <linux-mm@kvack.org>; Mon, 13 Nov 2006 17:07:35 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kADM7ZiF537926
	for <linux-mm@kvack.org>; Mon, 13 Nov 2006 15:07:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kADM7Zj4026603
	for <linux-mm@kvack.org>; Mon, 13 Nov 2006 15:07:35 -0700
Subject: RE: [hugepage] Fix unmap_and_free_vma backout path
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0611132039001.23846@blonde.wat.veritas.com>
References: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com>
	 <Pine.LNX.4.64.0611131650140.8280@blonde.wat.veritas.com>
	 <1163450069.17046.24.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0611132039001.23846@blonde.wat.veritas.com>
Content-Type: text/plain
Date: Mon, 13 Nov 2006 16:07:33 -0600
Message-Id: <1163455654.17046.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, 'David Gibson' <david@gibson.dropbear.id.au>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-11-13 at 20:41 +0000, Hugh Dickins wrote:
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
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
Acked-by: Adam Litke <agl@us.ibm.com>
-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
