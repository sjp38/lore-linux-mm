From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/5] hugetlb: Fix up filesystem quota accounting
Date: Tue, 30 Oct 2007 13:45:54 -0700
Message-Id: <20071030204554.16585.80588.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>, Adam Litke <agl@us.ibm.com>
List-ID: <linux-mm.kvack.org>


Changelog:
24 Oct 2007 - Initial Post
30 Oct 2007 - V2
 Changes in response to review
 * Split alloc_huge_page() into private/shared components
 * Store mapping pointer in page->private
 * Consolidated {get|put} quota calls to {alloc|free}_huge_page

Hugetlbfs implements a quota system which can limit the amount of memory that
can be used by the filesystem.  Before allocating a new huge page for a file,
the quota is checked and debited.  The quota is then credited when truncating
the file.  I found a few bugs in the code for both MAP_PRIVATE and MAP_SHARED
mappings.  Before detailing the problems and my proposed solutions, we should
agree on a definition of quotas that properly addresses both private and shared
pages.  Since the purpose of quotas is to limit total memory consumption on a
per-filesystem basis, I argue that all pages allocated by the fs (private and
shared) should be charged against quota.

Private Mappings
================
The current code will debit quota for private pages sometimes, but will never
credit it.  At a minimum, this causes a leak in the quota accounting which
renders the accounting essentially useless as it is.  Shared pages have a one
to one mapping with a hugetlbfs file and are easy to account by debiting on
allocation and crediting on truncate.  Private pages are anonymous in nature
and have a many to one relationship with their hugetlbfs files (due to copy on
write).  Because private pages are not indexed by the mapping's radix tree,
thier quota cannot be credited at file truncation time.  Crediting must be done
when the page is unmapped and freed.

Shared Pages
============
I discovered an issue concerning the interaction between the MAP_SHARED
reservation system and quotas.  Since quota is not checked until page
instantiation, an over-quota mmap/reservation will initially succeed.  When
instantiating the first over-quota page, the program will receive SIGBUS.  This
is inconsistent since the reservation is supposed to be a guarantee.  The
solution is to debit the full amount of quota at reservation time and credit
the unused portion when the reservation is released.

This patch series brings quotas back in line by making the following
modifications:
 * Private pages
   - Debit quota in alloc_huge_page()
   - Credit quota in free_huge_page()
 * Shared pages
   - Debit quota for entire reservation at mmap time
   - Credit quota for instantiated pages in free_huge_page()
   - Credit quota for unused reservation at munmap time

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
