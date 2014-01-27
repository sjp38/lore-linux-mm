Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 31C726B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 05:01:24 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so5549699pdj.10
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 02:01:23 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id n8si10772370pax.160.2014.01.27.02.01.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Jan 2014 02:01:21 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N0200DJZ165C470@mailout4.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jan 2014 19:01:17 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 0/8] mm/swap: fix some rare issues in swap subsystem
Date: Mon, 27 Jan 2014 18:00:03 +0800
Message-id: <000501cf1b46$b899edb0$29cdc910$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: quoted-printable
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, shli@kernel.org, 'Bob Liu' <bob.liu@oracle.com>, weijie.yang.kh@gmail.com, 'Seth Jennings' <sjennings@variantweb.net>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, 'Heesub Shin' <heesub.shin@samsung.com>, mguzik@redhat.com

This patch series focus on some tiny and rare issues in swap subsystem.
These issues happen rarely, so it is just for the correctness of the =
code.

It firstly add some comments to try to make swap flag/lock usage in
swapfile.c more clear and readable,
and fix some rare issues in swap subsystem that cause race condition =
among
swapon, swapoff and frontswap_register_ops.
and fix some not race issues.

Please see individual patch for details, any complaint and suggestion
are welcome.

Regards

patch 1/8: add some comments for swap flag/lock usage

patch 2/8: fix race on swap_info reuse between swapoff and swapon
	This patch has been in akpm -mm tree, however I improve it according
	to Heesub Shin and Mateusz Guzik's suggestion. So, that old patch need
	to be dropped.

patch 3/8: prevent concurrent swapon on the same S_ISBLK blockdev

patch 4/8: fix race among frontswap_register_ops, swapoff and swapon

patch 5/8: drop useless and bug frontswap_shrink codes

patch 6/8: remove swap_lock to simplify si_swapinfo()

patch 7/8: check swapfile blocksize greater than PAGE_SIZE

patch 8/8: add missing handle on a dup-store failure

 include/linux/blkdev.h    |    4 +++-
 include/linux/frontswap.h |    2 --
 include/linux/swapfile.h  |    4 +---
 mm/frontswap.c            |  127 =
+++++++------------------------------------------------------------------=
------------------------------------------------------
 mm/page_io.c              |    2 ++
 mm/rmap.c                 |    2 +-
 mm/swapfile.c             |  138 =
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++++++++++++++----------------------------------------
 7 files changed, 112 insertions(+), 167 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
