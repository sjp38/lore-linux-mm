Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9OCEYJD007484
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 08:14:34 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9ODNagr071942
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 07:23:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9ODNaqM029902
	for <linux-mm@kvack.org>; Wed, 24 Oct 2007 07:23:36 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/3] hugetlb: Fix up filesystem quota accounting
Date: Wed, 24 Oct 2007 06:23:35 -0700
Message-Id: <20071024132335.13013.76227.stgit@kernel>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ken Chen <kenchen@google.com>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>


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
 - Debit quota when allocating a COW page
 - Credit MAP_PRIVATE pages at unmap time
     (shared pages continue to be credited during truncation)
 - Debit entire amount of quota at shared mmap reservation time

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
