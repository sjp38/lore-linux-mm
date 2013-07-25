Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id D0E5C6B0036
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 13:22:14 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 22:44:54 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 279BF1258052
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 22:51:21 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6PHMqrc40566994
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 22:52:52 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6PHLr4m017229
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 03:21:53 +1000
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [RFC PATCH 0/2] vmpslice support for zero-copy gifting of pages
Date: Thu, 25 Jul 2013 12:21:44 -0500
Message-Id: <1374772906-21511-1-git-send-email-rcj@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Robert Jennings <rcj@linux.vnet.ibm.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <aliguori@us.ibm.com>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>

This patch set would add the ability to move anonymous user pages from one
process to another through vmsplice without copying data.  Moving pages
rather than copying is implemented for a narrow case in this RFC to meet
the needs of QEMU's usage (below).

Among the restrictions the source address and destination addresses must
be page aligned, the size argument must be a multiple of page size,
and by the time the reader calls vmsplice, the page must no longer be
mapped in the source.  If a move is not possible the code transparently
falls back to copying data.

This comes from work in QEMU[1] to migrate a VM from one QEMU instance
to another with minimal down-time for the VM.  This would allow for an
update of the QEMU executable under the VM.

New flag usage
This introduces use of the SPLICE_F_MOVE flag for vmsplice, previously
unused.  Proposed usage is as follows:

 Writer gifts pages to pipe, can not access original contents after gift:
    vmsplice(fd, iov, nr_segs, (SPLICE_F_GIFT | SPLICE_F_MOVE);
 Reader asks kernel to move pages from pipe to memory described by iovec:
    vmsplice(fd, iov, nr_segs, SPLICE_F_MOVE);

Moving pages rather than copying is implemented for a narrow case in
this RFC to meet the needs of QEMU's usage.  If a move is not possible
the code transparently falls back to copying data.

For older kernels the SPLICE_F_MOVE would be ignored and a copy would occur.

[1] QEMU localhost live migration: 
      http://lists.gnu.org/archive/html/qemu-devel/2013-06/msg02540.html
      http://lists.gnu.org/archive/html/qemu-devel/2013-06/msg02577.html
_______________________________________________________

 RFC: vmsplice unmap gifted pages for recipient
 RFC: Add limited zero copy to vmsplice

 fs/splice.c            | 88 +++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/splice.h |  1 +
 2 files changed, 88 insertions(+), 1 deletion(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
