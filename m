From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/2] Fixes for gigantic compounds pages V3
Date: Thu, 23 Oct 2008 15:19:17 +0100
Message-Id: <1224771559-19363-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <cl@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

[This update includes the cleanups akpm applied, and moves us to a common
form throughout where gigantic page forms of prep/copy/clear are only
used where the original page size is gigantic.  These should trigger
the minimum overall cost for non-gigantic cases.  It also brings the two
patches into one series for easier tracking.]

During stress testing of the gigantic pages in 2.6.27 threw up some more
places where the hugepage support assumes the mem_map is contigious.
The buddy allocator does not guarentee that the memory map is contigious,
and in some memory models it is not; notably with SPARSMEM without
VMEMMAP enabled.

These have been round a couple of times, and I think most of the objections
and comments are included.  The one outstanding was why we needed to fix
it at all as people could use VMEMMAP.  What is comes down to is that
there are legitimate combinations of features, such as memory hot remove,
which require SPARSMEM without VMEMMAP.  With that combination enabled
then any use of gigantic pages will skip off the end of the mem_map
segments and read random memory, with all the associated risks.

This patch set introduces some new iterators for the mem_map which know how
to follow across discontiguities.  It then uses those to provide gigantic
versions of copy_huge_page, clear_huge_page, and prep_compound_page.
This patch set effectivly backs out the changes to prep_compound_page
removing any potential performance issues.

Please consider these patches for -mm.  It is likely arguable these are
also stable candidates for 2.6.27 once they have had some run time.

Thanks to Jon Tollefson for his help testing previous versions of these
patches.

-apw

Andy Whitcroft (2):
  hugetlbfs: handle pages higher order than MAX_ORDER
  hugetlb: pull gigantic page initialisation out of the default path

 mm/hugetlb.c    |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
 mm/internal.h   |   29 +++++++++++++++++++++++++++++
 mm/page_alloc.c |   28 +++++++++++++++++++++-------
 3 files changed, 97 insertions(+), 9 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
