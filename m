Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2JK55Lm016934
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 16:05:05 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2JK54au067142
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 14:05:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2JK54dX025383
	for <linux-mm@kvack.org>; Mon, 19 Mar 2007 14:05:04 -0600
From: Adam Litke <agl@us.ibm.com>
Subject: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API (V2)
Date: Mon, 19 Mar 2007 13:05:02 -0700
Message-Id: <20070319200502.17168.17175.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Adam Litke <agl@us.ibm.com>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew, given the favorable review of these patches the last time around, would
you consider them for the -mm tree?  Does anyone else have any objections?

The page tables for hugetlb mappings are handled differently than page tables
for normal pages.  Rather than integrating multiple page size support into the
core VM (which would tremendously complicate the code) some hooks were created.
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

I did some pretty basic benchmarking of these patches on ppc64, x86, and x86_64
to get a feel for the fast-path performance impact.  The following tables show
kernbench performance comparisons between a clean 2.6.20 kernel and one with my
patches applied.  These numbers seem well within statistical noise to me.

Changes since V1:
	- Made hugetlbfs_pagetable_ops const (Thanks Arjan)

--

KernBench Comparison (ppc64)
----------------------------
                       2.6.20-clean      2.6.20-pgtable_ops    pct. diff
User   CPU time              708.82                 708.59      0.03
System CPU time               62.50                  62.58     -0.13
Total  CPU time              771.32                 771.17      0.02
Elapsed    time              115.40                 115.35      0.04

KernBench Comparison (x86)
--------------------------
                       2.6.20-clean      2.6.20-pgtable_ops    pct. diff
User   CPU time             1382.62                1381.88      0.05
System CPU time              146.06                 146.86     -0.55
Total  CPU time             1528.68                1528.74     -0.00
Elapsed    time              394.92                 396.70     -0.45

KernBench Comparison (x86_64)
-----------------------------
                       2.6.20-clean      2.6.20-pgtable_ops    pct. diff
User   CPU time              559.39                 557.97      0.25
System CPU time               65.10                  66.17     -1.64
Total  CPU time              624.49                 624.14      0.06
Elapsed    time              158.54                 158.59     -0.03

The lack of a performance impact makes sense to me.  The following is a
simplified instruction comparison for each case:

2.6.20-clean                           2.6.20-pgtable_ops
-------------------                    --------------------
/* Load vm_flags */                    /* Load pagetable_ops pointer */
mov 	0x18(ecx),eax                  mov	0x48(ecx),eax
/* Test for VM_HUGETLB */              /* Test if it's NULL */
test 	$0x400000,eax                  test   eax,eax
/* If set, jump to call stub */        /* If so, jump away to main code */
jne 	c0148f04                       je	c0148ba1
...                                    /* Lookup the operation's function pointer */
/* copy_hugetlb_page_range call */     mov	0x4(eax),ebx
c0148f04:                              /* Test if it's NULL */
mov	0xffffff98(ebp),ecx            test   ebx,ebx
mov	0xffffff9c(ebp),edx            /* If so, jump away to main code */
mov	0xffffffa0(ebp),eax            je	c0148ba1
call	c01536e0                       /* pagetable operation call */
                                       mov	0xffffff9c(ebp),edx
				       mov	0xffffffa0(ebp),eax
				       call	*ebx

For the common case (vma->pagetable_ops == NULL), we do almost the same thing as the current code: load and test.  The third instruction is different in that we jump for the common case instead of jumping in the hugetlb case.  I don't think this is a big deal though.  If it is, would an unlikely() macro fix it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
