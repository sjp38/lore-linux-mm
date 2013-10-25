Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 05EF76B00DB
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 11:46:45 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so5359685pad.21
        for <linux-mm@kvack.org>; Fri, 25 Oct 2013 08:46:45 -0700 (PDT)
Received: from psmtp.com ([74.125.245.185])
        by mx.google.com with SMTP id mj9si5464119pab.16.2013.10.25.08.46.43
        for <linux-mm@kvack.org>;
        Fri, 25 Oct 2013 08:46:45 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Fri, 25 Oct 2013 21:16:40 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id DAEEC394005A
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 21:16:16 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9PFnVZe29294674
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 21:19:32 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r9PFkZTP019639
	for <linux-mm@kvack.org>; Fri, 25 Oct 2013 21:16:35 +0530
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: [PATCH v2 0/2] vmpslice support for zero-copy gifting of pages
Date: Fri, 25 Oct 2013 10:46:22 -0500
Message-Id: <1382715984-10558-1-git-send-email-rcj@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, Robert Jennings <rcj@linux.vnet.ibm.com>, Matt Helsley <matt.helsley@gmail.com>, Anthony Liguori <anthony@codemonkey.ws>, Michael Roth <mdroth@linux.vnet.ibm.com>, Lei Li <lilei@linux.vnet.ibm.com>, Leonardo Garcia <lagarcia@linux.vnet.ibm.com>, Simon Jin <simonjin@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>

From: Robert C Jennings <rcj@linux.vnet.ibm.com>

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
http://lists.gnu.org/archive/html/qemu-devel/2013-10/msg02787.html

Changes from V1:
 - Cleanup zap coalescing in splice_to_pipe for readability
 - Field added to struct partial_page in v1 was unnecessary, using
   private field instead.
 - Read-side code in pipe_to_user pulled out into a new function
 - Improved documentation of read-side flipping code
 - Fixed locking issue in read-size flipping code found by sparse
 - Updated vmsplice comments for vmsplice_to_user(),
   vmsplice_to_pipe, and vmsplice syscall
_______________________________________________________

  vmsplice: unmap gifted pages for recipient
  vmsplice: Add limited zero copy to vmsplice

 fs/splice.c | 159 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 150 insertions(+), 9 deletions(-)

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
