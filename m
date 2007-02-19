Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1JIVOh8015154
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:24 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1JIVObp282230
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:24 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1JIVOJQ004728
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 13:31:24 -0500
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API
Date: Mon, 19 Feb 2007 10:31:23 -0800
Message-Id: <20070219183123.27318.27319.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

The page tables for hugetlb mappings are handled differently than page tables
for normal pages.  Rather than integrating multiple page size support into the
main VM (which would tremendously complicate the code) some hooks were created.
This allows hugetlb special cases to be handled "out of line" by a separate
interface.

Hugetlbfs was the huge page interface chosen.  At the time, large database
users were the only big users of huge pages and the hugetlbfs design meets
their needs pretty well.  Over time, hugetlbfs has been expanded to enable new
uses of huge page memory with varied results.  As features are added, the
semantics become a permanent part of the Linux API.  This makes maintenance of
hugetlbfs an increasingly difficult task and inhibits the addition of features
and functionality in support of ever-changing hardware.

To remedy the situation, I propose an API (currently called
pagetable_operations).  All of the current hugetlbfs-specific hooks are moved
into an operations struct that is attached to VMAs.  The end result is a more
explicit and IMO a cleaner interface between hugetlbfs and the core VM.  We are
then free to add other hugetlb interfaces (such as a /dev/zero-styled character
device) that can operate either in concert with or independent of hugetlbfs.

There should be no measurable performance impact for normal page users (we're
checking if pagetable_ops != NULL instead of checking for vm_flags &
VM_HUGETLB).  Of course we do increase the VMA size by one pointer.  For huge
pages, there is an added indirection for pt_op() calls.  This patch series does
not change the logic of the the hugetlbfs operations, just moves them into the
pagetable_operations struct.

Comments?  Do you think it's as good of an idea as I do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
