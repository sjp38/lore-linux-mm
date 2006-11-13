Date: Mon, 13 Nov 2006 17:22:46 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [hugepage] Fix unmap_and_free_vma backout path
Message-ID: <20061113062246.GH27042@localhost.localdomain>
References: <20061113055711.GF27042@localhost.localdomain> <000101c706e9$726c1120$a081030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000101c706e9$726c1120$a081030a@amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 12, 2006 at 10:03:31PM -0800, Chen, Kenneth W wrote:
> David Gibson wrote on Sunday, November 12, 2006 9:57 PM
> > On Sun, Nov 12, 2006 at 09:29:48PM -0800, Christoph Lameter wrote:
> > > On Mon, 13 Nov 2006, 'David Gibson' wrote:
> > > 
> > > > This may not be all we want.  Even with this patch, performing such a
> > > > failing map on to of an existing mapping will clobber (unmap) that
> > > > pre-existing mapping.  This is in contrast to the analogous situation
> > > > with normal page mappings - mapping on top with a misaligned offset
> > > > will fail early enough not to clobber the pre-existing mapping.
> > > 
> > > Then it is best to check the huge page alignment at the 
> > > same place as regular alignment.
> > 
> > Probably, yes, although it's yet another "if (hugepage)
> > specialcase()".  But I still think we want the above patch as well.
> > It will make sure we correctly back out from any other possible
> > failure cases in hugetlbfs_file_mmap() - ones I haven't thought of, or
> > which get added later.
> 
> 
> Something like this?  I haven't tested it yet.  But looks plausible
> because we already have if is_file_hugepages() in the generic path.

Um.. if you're going to test pgoff here, you should also test the
address.  Oh, and that point is too late to catch MAP_FIXED mappings.

I was thinking more of testing it in the same place we test the page
alignment for normal mappings.  Except that's in arch code.

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
