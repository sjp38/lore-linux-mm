Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5C5226B0068
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 14:19:41 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 27 Jul 2012 12:19:40 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B267B19D8045
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 18:18:55 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6RIIiM2045016
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:18:47 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6RIIhnS009383
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 12:18:44 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 0/4] promote zcache from staging
Date: Fri, 27 Jul 2012 13:18:33 -0500
Message-Id: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

zcache is the remaining piece of code required to support in-kernel
memory compression.  The other two features, cleancache and frontswap,
have been promoted to mainline in 3.0 and 3.5.  This patchset
promotes zcache from the staging tree to mainline.

Based on the level of activity and contributions we're seeing from a
diverse set of people and interests, I think zcache has matured to the
point where it makes sense to promote this out of staging.

Overview
========
zcache is a backend to frontswap and cleancache that accepts pages from
those mechanisms and compresses them, leading to reduced I/O caused by
swap and file re-reads.  This is very valuable in shared storage situations
to reduce load on things like SANs.  Also, in the case of slow backing/swap
devices, zcache can also yield a performance gain.

In-Kernel Memory Compression Overview:

 swap subsystem            page cache
        +                      +
    frontswap              cleancache
        +                      +
zcache frontswap glue  zcache cleancache glue
        +                      +
        +---------+------------+
                  +
            zcache/tmem core
                  +
        +---------+------------+
        +                      +
     zsmalloc                 zbud

Everything below the frontswap/cleancache layer is current inside the
zcache driver expect for zsmalloc which is a shared between zcache and
another memory compression driver, zram.

Since zcache is dependent on zsmalloc, it is also being promoted by this
patchset.

For information on zsmalloc and the rationale behind it's design and use
cases verses already existing allocators in the kernel:

https://lkml.org/lkml/2012/1/9/386

zsmalloc is the allocator used by zcache to store persistent pages that
comes from frontswap, as opposed to zbud which is the (internal) allocator
used for ephemeral pages from cleancache.

zsmalloc uses many fields of the page struct to create it's conceptual
high-order page called a zspage.  Exactly which fields are used and for
what purpose is documented at the top of the zsmalloc .c file.  Because
zsmalloc uses struct page extensively, Andrew advised that the
promotion location be mm/:

https://lkml.org/lkml/2012/1/20/308

Some benchmarking numbers demonstrating the I/O saving that can be had
with zcache:

https://lkml.org/lkml/2012/3/22/383

Dan's presentation at LSF/MM this year on zcache:

http://oss.oracle.com/projects/tmem/dist/documentation/presentations/LSFMM12-zcache-final.pdf

This patchset is based on next-20120727 + 3-part zsmalloc patchset below

https://lkml.org/lkml/2012/7/18/353

The zsmalloc patchset is already acked and will be integrated by Greg after
3.6-rc1 is out.

Seth Jennings (4):
  zsmalloc: collapse internal .h into .c
  zsmalloc: promote to mm/
  drivers: add memory management driver class
  zcache: promote to drivers/mm/

 drivers/Kconfig                                    |    2 +
 drivers/Makefile                                   |    1 +
 drivers/mm/Kconfig                                 |   13 ++
 drivers/mm/Makefile                                |    1 +
 drivers/{staging => mm}/zcache/Makefile            |    0
 drivers/{staging => mm}/zcache/tmem.c              |    0
 drivers/{staging => mm}/zcache/tmem.h              |    0
 drivers/{staging => mm}/zcache/zcache-main.c       |    4 +-
 drivers/staging/Kconfig                            |    4 -
 drivers/staging/Makefile                           |    2 -
 drivers/staging/zcache/Kconfig                     |   11 --
 drivers/staging/zram/zram_drv.h                    |    3 +-
 drivers/staging/zsmalloc/Kconfig                   |   10 --
 drivers/staging/zsmalloc/Makefile                  |    3 -
 drivers/staging/zsmalloc/zsmalloc_int.h            |  149 --------------------
 .../staging/zsmalloc => include/linux}/zsmalloc.h  |    0
 mm/Kconfig                                         |   18 +++
 mm/Makefile                                        |    1 +
 .../zsmalloc/zsmalloc-main.c => mm/zsmalloc.c      |  133 ++++++++++++++++-
 19 files changed, 170 insertions(+), 185 deletions(-)
 create mode 100644 drivers/mm/Kconfig
 create mode 100644 drivers/mm/Makefile
 rename drivers/{staging => mm}/zcache/Makefile (100%)
 rename drivers/{staging => mm}/zcache/tmem.c (100%)
 rename drivers/{staging => mm}/zcache/tmem.h (100%)
 rename drivers/{staging => mm}/zcache/zcache-main.c (99%)
 delete mode 100644 drivers/staging/zcache/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Kconfig
 delete mode 100644 drivers/staging/zsmalloc/Makefile
 delete mode 100644 drivers/staging/zsmalloc/zsmalloc_int.h
 rename {drivers/staging/zsmalloc => include/linux}/zsmalloc.h (100%)
 rename drivers/staging/zsmalloc/zsmalloc-main.c => mm/zsmalloc.c (86%)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
