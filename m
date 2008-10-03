From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Report the size of pages backing VMAs in /proc V3
Date: Fri,  3 Oct 2008 17:46:53 +0100
Message-Id: <1223052415-18956-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, kosaki.motohiro@jp.fujitsu.com, dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The following two patches add support for printing the size of pages used
by the kernel to back VMAs in maps and smaps. This can be used by a user
to verify that a hugepage-aware application is using the expected page sizes.
In one case the pagesize used by the MMU differs from the size used by the
kernel. This is on PPC64 using 64K as a base page size running on a processor
that does not support 64K in the MMU. In this case, the kernel uses 64K pages
but the MMU is still using 4K.

The first patch prints the size of page used by the kernel when allocating
pages for a VMA in /proc/pid/smaps and should not be considered too
contentious as it is highly unlikely to break any parsers.  The second patch
reports the size of page used by hugetlbfs regions in /proc/pid/maps. There is
a possibility that the final patch will break parsers but they are arguably
already broken. More details are in the patches themselves.

Thanks to KOSAKI Motohiro for rebasing the patches onto mmotm, reviewing
and testing.

Changelog since V2
  o Drop printing of MMUPageSize (mel)
  o Rebase onto mmotm (KOSAKI Motohiro)

Changelog since V1
  o Fix build failure on !CONFIG_HUGETLB_PAGE
  o Uninline helper functions
  o Distinguish between base pagesize and MMU pagesize

 fs/proc/task_mmu.c      |   27 ++++++++++++++++++---------
 include/linux/hugetlb.h |    3 +++
 mm/hugetlb.c            |   17 +++++++++++++++++
 3 files changed, 38 insertions(+), 9 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
