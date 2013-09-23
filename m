Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8BB6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 04:21:49 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so2003062pab.32
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 01:21:48 -0700 (PDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MTK003Z2KJI3CX0@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 23 Sep 2013 17:21:45 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v3 0/3] mm/zswap bugfix: memory leaks and other problems
Date: Mon, 23 Sep 2013 16:19:36 +0800
Message-id: <000001ceb835$f0899910$d19ccb30$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, minchan@kernel.org, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

This patch series fix a few bugs in mm/zswap based on Linux-3.11.

v2 --> v3
	- keep GFP_KERNEL flag

v1 --> v2
	- free memory in zswap_frontswap_invalidate_area(in patch 1)
	- fix whitespace corruption (line wrapping)
	
Corresponding mail thread: https://lkml.org/lkml/2013/8/18/59

These issues fixed/optimized are:

 1. memory leaks when re-swapon
 
 2. memory leaks when invalidate and reclaim occur concurrently
 
 3. avoid unnecessary page scanning


Issues discussed in that mail thread NOT fixed as it happens rarely or
not a big problem or controversial:

 1. a "theoretical race condition" when reclaim page
When a handle alloced from zbud, zbud considers this handle is used
validly by upper(zswap) and can be a candidate for reclaim. But zswap has
to initialize it such as setting swapentry and adding it to rbtree.
so there is a race condition, such as:
 thread 0: obtain handle x from zbud_alloc
 thread 1: zbud_reclaim_page is called
 thread 1: callback zswap_writeback_entry to reclaim handle x
 thread 1: get swpentry from handle x (it is random value now)
 thread 1: bad thing may happen
 thread 0: initialize handle x with swapentry

2. frontswap_map bitmap not cleared after zswap reclaim
Frontswap uses frontswap_map bitmap to track page in "backend" implementation,
when zswap reclaim a page, the corresponding bitmap record is not cleared.

3. the potential that zswap store and reclaim functions called recursively


 mm/zswap.c |   28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
