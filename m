Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 7EB656B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 06:13:28 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MRZ00I1EB2C7VQ0@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Aug 2013 19:13:26 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH 0/4] zswap bugfix: memory leaks and other problem
Date: Fri, 23 Aug 2013 18:12:33 +0800
Message-id: <000101ce9fe9$6849dab0$38dd9010$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: quoted-printable
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, bob.liu@oracle.com, sjenning@linux.vnet.ibm.com
Cc: weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch series fix a few bugs in zswap based on Linux-3.11-rc6.

Corresponding mail thread see: lkml.org/lkml/2013/8/18/59 .

These issues fixed are:
1. memory leaks when re-swapon
2. potential problem which store and reclaim functions is called =
recursively=20
3. memory leaks when invalidate and reclaim occur simultaneously=20
4. unnecessary page scanning

Issues discussed in that mail thread NOT fixed as it happens rarely or =
not a big problem:
1. a "theoretical race condition" when reclaim page=20
when a handle alloced from zbud, zbud considers this handle is used =
validly by upper(zswap) and can be a candidate for reclaim.
But zswap has to initialize it such as setting swapentry and adding it =
to rbtree. so there is a race condition, such as:
thread 0: obtain handle x from zbud_alloc=20
thread 1: zbud_reclaim_page is called=20
thread 1: callback zswap_writeback_entry to reclaim handle x=20
thread 1: get swpentry from handle x (it is random value now)=20
thread 1: bad thing may happen=20
thread 0: initialize handle x with swapentry

2. frontswap_map bitmap not cleared after zswap reclaim=20
Frontswap uses frontswap_map bitmap to track page in "backend" =
implementation,=20
when zswap reclaim a page, the corresponding bitmap record is not =
cleared.

mm/zswap.c |   35 ++++++++++++++++++++++++-----------
 1 files changed, 24 insertions(+), 11 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
