Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7CF6B0032
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 16:22:04 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so7576377pbc.16
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 13:22:04 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Tue, 8 Oct 2013 06:22:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 6C1292CE8052
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 07:21:56 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r97K4spL1245680
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 07:05:01 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r97KLmku013740
	for <linux-mm@kvack.org>; Tue, 8 Oct 2013 07:21:48 +1100
From: Robert C Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH 0/2] vmpslice support for zero-copy gifting of pages
Date: Mon,  7 Oct 2013 15:21:31 -0500
Message-Id: <1381177293-27125-1-git-send-email-rcj@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Robert C Jennings <rcj@linux.vnet.ibm.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

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

  vmsplice: Add limited zero copy to vmsplice
  vmsplice: unmap gifted pages for recipient

 fs/splice.c            | 114 ++++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/splice.h |   1 +
 2 files changed, 114 insertions(+), 1 deletion(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
