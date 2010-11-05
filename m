Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B482D6B0099
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 17:16:21 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oA5Kt6jM001966
	for <linux-mm@kvack.org>; Fri, 5 Nov 2010 16:55:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oA5LGI4B2322448
	for <linux-mm@kvack.org>; Fri, 5 Nov 2010 17:16:18 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oA5LGHv3005757
	for <linux-mm@kvack.org>; Fri, 5 Nov 2010 19:16:17 -0200
Subject: [v2][PATCH] [v2] Revalidate page->mapping in do_generic_file_read()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 05 Nov 2010 14:16:15 -0700
Message-Id: <20101105211615.2D67A348@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>, arunabal@in.ibm.com, sbest@us.ibm.com, stable <stable@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>


changes from v1:
 * added a comment
 * changed the ->mapping check to NULL-only to make it more
   clear that we're only checking for truncation

--

70 hours into some stress tests of a 2.6.32-based enterprise kernel,
we ran into a NULL dereference in here:

	int block_is_partially_uptodate(struct page *page, read_descriptor_t *desc,
	                                        unsigned long from)
	{
---->		struct inode *inode = page->mapping->host;

It looks like page->mapping was the culprit.  (xmon trace is below).
After closer examination, I realized that do_generic_file_read() does
a find_get_page(), and eventually locks the page before calling
block_is_partially_uptodate().  However, it doesn't revalidate the
page->mapping after the page is locked.  So, there's a small window
between the find_get_page() and ->is_partially_uptodate() where the
page could get truncated and page->mapping cleared.

We _have_ a reference, so it can't get reclaimed, but it certainly
can be truncated.

I think the correct thing is to check page->mapping after the
trylock_page(), and jump out if it got truncated.  This patch has
been running in the test environment for a month or so now, and we
have not seen this bug pop up again.

xmon info:
======================================
1f:mon> e
cpu 0x1f: Vector: 300 (Data Access) at [c0000002ae36f770]
    pc: c0000000001e7a6c: .block_is_partially_uptodate+0xc/0x100
    lr: c000000000142944: .generic_file_aio_read+0x1e4/0x770
    sp: c0000002ae36f9f0
   msr: 8000000000009032
   dar: 0
 dsisr: 40000000
  current = 0xc000000378f99e30
  paca    = 0xc000000000f66300
    pid   = 21946, comm = bash
1f:mon> r
R00 = 0025c0500000006d   R16 = 0000000000000000
R01 = c0000002ae36f9f0   R17 = c000000362cd3af0
R02 = c000000000e8cd80   R18 = ffffffffffffffff
R03 = c0000000031d0f88   R19 = 0000000000000001
R04 = c0000002ae36fa68   R20 = c0000003bb97b8a0
R05 = 0000000000000000   R21 = c0000002ae36fa68
R06 = 0000000000000000   R22 = 0000000000000000
R07 = 0000000000000001   R23 = c0000002ae36fbb0
R08 = 0000000000000002   R24 = 0000000000000000
R09 = 0000000000000000   R25 = c000000362cd3a80
R10 = 0000000000000000   R26 = 0000000000000002
R11 = c0000000001e7b60   R27 = 0000000000000000
R12 = 0000000042000484   R28 = 0000000000000001
R13 = c000000000f66300   R29 = c0000003bb97b9b8
R14 = 0000000000000001   R30 = c000000000e28a08
R15 = 000000000000ffff   R31 = c0000000031d0f88
pc  = c0000000001e7a6c .block_is_partially_uptodate+0xc/0x100
lr  = c000000000142944 .generic_file_aio_read+0x1e4/0x770
msr = 8000000000009032   cr  = 22000488
ctr = c0000000001e7a60   xer = 0000000020000000   trap =  300
dar = 0000000000000000   dsisr = 40000000
1f:mon> t 
[link register   ] c000000000142944 .generic_file_aio_read+0x1e4/0x770
[c0000002ae36f9f0] c000000000142a14 .generic_file_aio_read+0x2b4/0x770
(unreliable)
[c0000002ae36fb40] c0000000001b03e4 .do_sync_read+0xd4/0x160
[c0000002ae36fce0] c0000000001b153c .vfs_read+0xec/0x1f0
[c0000002ae36fd80] c0000000001b1768 .SyS_read+0x58/0xb0
[c0000002ae36fe30] c00000000000852c syscall_exit+0x0/0x40
--- Exception: c00 (System Call) at 00000080a840bc54
SP (fffca15df30) is in userspace
1f:mon> di c0000000001e7a6c
c0000000001e7a6c  e9290000      ld      r9,0(r9)
c0000000001e7a70  418200c0      beq     c0000000001e7b30        #
.block_is_partially_uptodate+0xd0/0x100
c0000000001e7a74  e9440008      ld      r10,8(r4)
c0000000001e7a78  78a80020      clrldi  r8,r5,32
c0000000001e7a7c  3c000001      lis     r0,1
c0000000001e7a80  812900a8      lwz     r9,168(r9)
c0000000001e7a84  39600001      li      r11,1
c0000000001e7a88  7c080050      subf    r0,r8,r0
c0000000001e7a8c  7f805040      cmplw   cr7,r0,r10
c0000000001e7a90  7d6b4830      slw     r11,r11,r9
c0000000001e7a94  796b0020      clrldi  r11,r11,32
c0000000001e7a98  419d00a8      bgt     cr7,c0000000001e7b40    #
.block_is_partially_uptodate+0xe0/0x100
c0000000001e7a9c  7fa55840      cmpld   cr7,r5,r11
c0000000001e7aa0  7d004214      add     r8,r0,r8
c0000000001e7aa4  79080020      clrldi  r8,r8,32
c0000000001e7aa8  419c0078      blt     cr7,c0000000001e7b20    #
.block_is_partially_uptodate+0xc0/0x100
======================================

Cc: arunabal@in.ibm.com
Cc: sbest@us.ibm.com
Cc: stable <stable@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Rik van Riel <riel@redhat.com>
---

 linux-2.6.git-dave/mm/filemap.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN mm/filemap.c~is_partially_uptodate-revalidate-page mm/filemap.c
--- linux-2.6.git/mm/filemap.c~is_partially_uptodate-revalidate-page	2010-11-03 13:49:21.000000000 -0700
+++ linux-2.6.git-dave/mm/filemap.c	2010-11-04 06:59:08.000000000 -0700
@@ -1016,6 +1016,9 @@ find_page:
 				goto page_not_up_to_date;
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
+			/* Did it get truncated before we got the lock? */
+			if (!page->mapping)
+				goto page_not_up_to_date_locked;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 								desc, offset))
 				goto page_not_up_to_date_locked;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
