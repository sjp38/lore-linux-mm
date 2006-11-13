From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [hugepage] Fix unmap_and_free_vma backout path
Date: Sun, 12 Nov 2006 23:35:28 -0800
Message-ID: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061113062246.GH27042@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, 'Hugh Dickins' <hugh@veritas.com>, bill.irwin@oracle.com, 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Sunday, November 12, 2006 10:23 PM
> > > Probably, yes, although it's yet another "if (hugepage)
> > > specialcase()".  But I still think we want the above patch as well.
> > > It will make sure we correctly back out from any other possible
> > > failure cases in hugetlbfs_file_mmap() - ones I haven't thought of, or
> > > which get added later.
> > 
> > 
> > Something like this?  I haven't tested it yet.  But looks plausible
> > because we already have if is_file_hugepages() in the generic path.
> 
> Um.. if you're going to test pgoff here, you should also test the
> address.

prepare_hugepage_range() should catch misaligned memory address, right?
What more does get_unmapped_area() need to test?


> Oh, and that point is too late to catch MAP_FIXED mappings.

I don't understand what you mean by that.
In do_mmap_pgoff(), very early in the code it tries to get an valid
virtual address:

        addr = get_unmapped_area(file, addr, len, pgoff, flags);
        if (addr & ~PAGE_MASK)
                return addr;

We don't even have a vma at this point, there is no error to recover.
If get_unmapped_area() tests the validity of pgoff and return an error
code, the immediate two lines of code will catch that and everything
stops there.  I don't see where the unmap gets called here.  Did I
miss something?


- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
