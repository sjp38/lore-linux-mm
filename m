Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 178C56B036B
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:35:06 -0400 (EDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 25 Jun 2012 10:34:57 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 94B06C902C4
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:44 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5PGEjeq154464
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 12:14:45 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5PGEje2002404
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 13:14:45 -0300
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 0/3] zsmalloc: remove x86 dependency
Date: Mon, 25 Jun 2012 11:14:35 -0500
Message-Id: <1340640878-27536-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patchset continues/adapts Minchan Kim's work
to remove the x86 dependency from zsmalloc.

However, instead of whitelisting archs with support for
local_tlb_flush_kernel_range() in the zsmalloc Kconfig,
this patchset allows zsmalloc to work with all archs
through the addition of a generic/portable page
mapping methods (i.e. memcpy) when the required tlb
flushing functionality is not supported by the arch.

The arch advertises support for local_tlb_flush_kernel_range()
by defining __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE

The third patch in the set adds local_tlb_flush_kernel_range()
support to x86.  In my single-threaded tests using zcache,
using the pte/tlb mapping method was 40% faster than the generic
method. So while the third patch is optional, it is highly
recommended.

Alex Shi is working on a large x86 patchset that includes
functionality similar to the third patch, however, it seems
that this patchset is getting very little attention and
includes much more than is needed for zsmalloc's purposes.

https://lkml.org/lkml/2012/6/12/116

Future work:
 - Add __HAVE_LOCAL_FLUSH_TLB_KERNEL_RANGE definition to
   archs that already have local_tlb_flush_kernel_range()
 - Add mapping mode flags (RO, WO, RW) to zs_map_object()
   to avoid unnecessary copies in the generic case

Based on Greg's staging-next.

Seth Jennings (3):
  zram/zcache: swtich Kconfig dependency from X86 to ZSMALLOC
  zsmalloc: add generic path and remove x86 dependency
  x86: add local_tlb_flush_kernel_range()

 arch/x86/include/asm/tlbflush.h          |   21 +++++
 drivers/staging/zcache/Kconfig           |    5 +-
 drivers/staging/zram/Kconfig             |    5 +-
 drivers/staging/zsmalloc/Kconfig         |    4 -
 drivers/staging/zsmalloc/zsmalloc-main.c |  136 ++++++++++++++++++++++++------
 drivers/staging/zsmalloc/zsmalloc_int.h  |    5 +-
 6 files changed, 138 insertions(+), 38 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
