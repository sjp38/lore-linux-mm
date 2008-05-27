From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 0/3] MAP_NORESERVE for hugetlb mappings V3
Message-ID: <exportbomb.1211929624@pinky>
Date: Wed, 28 May 2008 00:09:07 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

This stack is a rebase of the V2 stack onto 2.6.26-rc2-mm1 with
Mel's "Guarantee faults for processes that call mmap(MAP_PRIVATE) on
hugetlbfs v4" applied.  This stack allows map users to opt-out of the
new stricter over-commit handling should those semantics be unsuitable,
using the standard MAP_NORESERVE mmap flag.

This stack should be seen as complementary to Mel's stack, which it is
dependant on.

Please consider for -mm.

-apw
===
With Mel's hugetlb private reservation support patches applied, strict
overcommit semantics are applied to both shared and private huge
page mappings.  This can be a problem if an application relied on
unlimited overcommit semantics for private mappings.  An example of this
would be an application which maps a huge area with the intention of
using it very sparsely.  These application would benefit from being able
to opt-out of the strict overcommit.  It should be noted that prior to
hugetlb supporting demand faulting all mappings were fully populated and
so applications of this type should be rare.

This patch stack implements the MAP_NORESERVE mmap() flag for huge page
mappings.  This flag has the same meaning as for small page mappings,
suppressing reservations for that mapping.

The stack is made up of three patches:

record-MAP_NORESERVE-status-on-vmas-and-fix-small-page-mprotect-reservations --
  currently when we mprotect a private MAP_NORESERVE mapping read-write
  we have no choice but to create a reservation for it.  Fix that by
  introducing a VM_NORESERVE vma flag and checking it before allocating
  reserve.

hugetlb-move-reservation-region-support-earlier -- simply moves the
  reservation region support so it can be used earlier.

hugetlb-allow-huge-page-mappings-to-be-created-without-reservations --
  use the new VM_NORESERVE flag to control the application of hugetlb
  reservations to new mappings.

This has been functionally tested with a hugetlb reservation test suite.

All against 2.6.26-rc2-mm1 with Mel's private reservation patches:

	Subject: Guarantee faults for processes that call mmap(MAP_PRIVATE)
	  on hugetlbfs v4

Thanks to Mel Gorman for reviewing a number of early versions of these
patches.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
