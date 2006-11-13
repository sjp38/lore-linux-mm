Date: Mon, 13 Nov 2006 16:57:11 +1100
From: 'David Gibson' <david@gibson.dropbear.id.au>
Subject: Re: [hugepage] Fix unmap_and_free_vma backout path
Message-ID: <20061113055711.GF27042@localhost.localdomain>
References: <20061113051318.GD27042@localhost.localdomain> <Pine.LNX.4.64.0611122127080.2233@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0611122127080.2233@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Nov 12, 2006 at 09:29:48PM -0800, Christoph Lameter wrote:
> On Mon, 13 Nov 2006, 'David Gibson' wrote:
> 
> > This may not be all we want.  Even with this patch, performing such a
> > failing map on to of an existing mapping will clobber (unmap) that
> > pre-existing mapping.  This is in contrast to the analogous situation
> > with normal page mappings - mapping on top with a misaligned offset
> > will fail early enough not to clobber the pre-existing mapping.
> 
> Then it is best to check the huge page alignment at the 
> same place as regular alignment.

Probably, yes, although it's yet another "if (hugepage)
specialcase()".  But I still think we want the above patch as well.
It will make sure we correctly back out from any other possible
failure cases in hugetlbfs_file_mmap() - ones I haven't thought of, or
which get added later.

As far as I can tell, there is in general no guarantee that a failing
MAP_FIXED() mmap() *won't* clobber what was there before.  I believe
there are (admittedly rare) possible late failure cases in pure
normalpage paths which will result in a failed mmap() after clobbering
the prior mapping.  Any failure from the filesystem or device's
f_ops->mmap callback will do this, for example.

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
