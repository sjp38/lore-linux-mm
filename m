Message-ID: <4173D219.3010706@shadowen.org>
Date: Mon, 18 Oct 2004 15:24:25 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: CONFIG_NONLINEAR for small systems
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
Cc: Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Following this email will be a series of patches which provide a
sample implementation of a simplified CONFIG_NONLINEAR memory model. 
The first two cleanup general infrastructure to minimise code 
duplication.  The third introduces an allocator for the numa remap space 
on i386.  The fourth generalises the page flags code to allow the reuse 
of the NODEZONE bits.  The final three are the actual meat of the 
implementation for both i386 and ppc64.

050-bootmem-use-NODE_DATA
060-refactor-setup_memory-i386
080-alloc_remap-i386
100-cleanup-node-zone
150-nonlinear
160-nonlinear-i386
170-nonlinear-ppc64

As has been observed the CONFIG_DISCONTIGMEM implementation
is inefficient space-wise where a system has a sparse intra-node memory
configuration. For example we have systems where node 0 has a
1GB hole within it. Under CONFIG_DISCONTIGMEM this results in the
struct page's for this area being allocated from ZONE_NORMAL and
never used; this is particularly problematic on these 32bit systems
as we are already under severe pressure in this zone.

The generalised CONFIG_NONLINEAR memory model described at OLS
seemed provide more than enough decriptive power to address this
issue but provided far more functionality that was required.
Particularly it breaks the identity V=P+c to allow compression of
the kernel address space, which is not required on these smaller systems.

This patch set is implemented as a proof-of-concept to show
that a simplified CONFIG_NONLINEAR based implementation could provide
sufficient flexibility to solve the problems for these systems.

In the longer term I'd like to see a single CONFIG_NONLINEAR
implementation which allowed these various features to be stacked in
combination as required.

Thoughts?

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
