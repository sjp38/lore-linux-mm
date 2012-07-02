Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 035226B0070
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:33 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 17:16:32 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C816D6E806A
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:02 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62LG2Yb54722734
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 17:16:02 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q632kthX031164
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 22:46:55 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 0/4] zsmalloc improvements
Date: Mon,  2 Jul 2012 16:15:48 -0500
Message-Id: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patchset removes the current x86 dependency for zsmalloc
and introduces some performance improvements in the object
mapping paths.

It was meant to be a follow-on to my previous patchest

https://lkml.org/lkml/2012/6/26/540

However, this patchset differed so much in light of new performance
information that I mostly started over.

In the past, I attempted to compare different mapping methods
via the use of zcache and frontswap.  However, the nature of those
two features makes comparing mapping method efficiency difficult
since the mapping is a very small part of the overall code path.

In an effort to get more useful statistics on the mapping speed,
I wrote a microbenchmark module named zsmapbench, designed to
measure mapping speed by calling straight into the zsmalloc
paths.

https://github.com/spartacus06/zsmapbench

This exposed an interesting and unexpected result: in all
cases that I tried, copying the objects that span pages instead
of using the page table to map them, was _always_ faster.  I could
not find a case in which the page table mapping method was faster.

zsmapbench measures the copy-based mapping at ~560 cycles for a
map/unmap operation on spanned object for both KVM guest and bare-metal,
while the page table mapping was ~1500 cycles on a VM and ~760 cycles
bare-metal.  The cycles for the copy method will vary with
allocation size, however, it is still faster even for the largest
allocation that zsmalloc supports.

The result is convenient though, as mempcy is very portable :)

This patchset replaces the x86-only page table mapping code with
copy-based mapping code. It also makes changes to optimize this
new method further.

There are no changes in arch/x86 required.

Patchset is based on greg's staging-next.

Seth Jennings (4):
  zsmalloc: remove x86 dependency
  zsmalloc: add single-page object fastpath in unmap
  zsmalloc: add details to zs_map_object boiler plate
  zsmalloc: add mapping modes

 drivers/staging/zcache/zcache-main.c     |    6 +-
 drivers/staging/zram/zram_drv.c          |    7 +-
 drivers/staging/zsmalloc/Kconfig         |    4 -
 drivers/staging/zsmalloc/zsmalloc-main.c |  124 ++++++++++++++++++++++--------
 drivers/staging/zsmalloc/zsmalloc.h      |   14 +++-
 drivers/staging/zsmalloc/zsmalloc_int.h  |    6 +-
 6 files changed, 114 insertions(+), 47 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
