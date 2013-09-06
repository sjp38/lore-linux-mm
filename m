Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5000F6B0031
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:16:43 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSO006LAUNM2P90@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Sep 2013 14:16:41 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v2 0/4] mm/zswap bugfix: memory leaks and other problems
Date: Fri, 06 Sep 2013 13:15:08 +0800
Message-id: <000501ceaac0$4568ec70$d03ac550$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch series fix a few bugs in zswap based on Linux-3.11.

v1 --> v2
	- free memory in zswap_frontswap_invalidate_area (in patch 1)
	- fix whitespace corruption (line wrapping)

Corresponding mail thread: https://lkml.org/lkml/2013/8/18/59

These issues fixed/optimized are:

 1. memory leaks when re-swapon
 
 2. memory leaks when invalidate and reclaim occur concurrently
 
 3. avoid unnecessary page scanning
 
 4. use GFP_NOIO instead of GFP_KERNEL to avoid zswap store and reclaim 
functions called recursively

Issues discussed in that mail thread NOT fixed as it happens rarely or
not a big problem:

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

 mm/zswap.c |   34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
