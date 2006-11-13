From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [hugepage] Fix unmap_and_free_vma backout path
Date: Sun, 12 Nov 2006 22:03:31 -0800
Message-ID: <000101c706e9$726c1120$a081030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20061113055711.GF27042@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>, Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, bill.irwin@oracle.com, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Sunday, November 12, 2006 9:57 PM
> On Sun, Nov 12, 2006 at 09:29:48PM -0800, Christoph Lameter wrote:
> > On Mon, 13 Nov 2006, 'David Gibson' wrote:
> > 
> > > This may not be all we want.  Even with this patch, performing such a
> > > failing map on to of an existing mapping will clobber (unmap) that
> > > pre-existing mapping.  This is in contrast to the analogous situation
> > > with normal page mappings - mapping on top with a misaligned offset
> > > will fail early enough not to clobber the pre-existing mapping.
> > 
> > Then it is best to check the huge page alignment at the 
> > same place as regular alignment.
> 
> Probably, yes, although it's yet another "if (hugepage)
> specialcase()".  But I still think we want the above patch as well.
> It will make sure we correctly back out from any other possible
> failure cases in hugetlbfs_file_mmap() - ones I haven't thought of, or
> which get added later.


Something like this?  I haven't tested it yet.  But looks plausible
because we already have if is_file_hugepages() in the generic path.




--- ./mm/mmap.c.orig	2006-11-12 22:43:10.000000000 -0800
+++ ./mm/mmap.c	2006-11-12 22:56:23.000000000 -0800
@@ -1375,11 +1375,14 @@ get_unmapped_area(struct file *file, uns
 	if (addr & ~PAGE_MASK)
 		return -EINVAL;
 	if (file && is_file_hugepages(file))  {
+		ret = 0;
 		/*
 		 * Check if the given range is hugepage aligned, and
 		 * can be made suitable for hugepages.
 		 */
-		ret = prepare_hugepage_range(addr, len);
+		if (pgoff & (~HPAGE_MASK >> PAGE_SHIFT) ||
+		    prepare_hugepage_range(addr, len))
+			ret = -EINVAL;
 	} else {
 		/*
 		 * Ensure that a normal request is not falling in a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
