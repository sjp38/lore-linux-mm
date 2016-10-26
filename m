Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 155FD6B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:11:05 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rt15so2961902pab.14
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:11:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id fc3si1908867pab.267.2016.10.26.05.11.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 05:11:04 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9QC8arw061267
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:11:03 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26aqwmp176-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:11:03 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 26 Oct 2016 13:11:00 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 88B2C17D805D
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:13:12 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9QCAviE24641666
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:10:57 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9QCAvBo026004
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:10:57 -0600
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: regression 4.8+ commit 8ea1d2a (mm, frontswap: convert
 frontswap_enabled to static key) cause memory leak on swapon
Date: Wed, 26 Oct 2016 14:10:57 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <633c9485-d150-03ac-d0d3-827ad24c514d@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Vlastimil,

with commit 8ea1d2a1985a7ae096e ("mm, frontswap: convert frontswap_enabled to static key")
kmemleak complains about a memory leak in swapon

unreferenced object 0x3e09ba56000 (size 32112640):
  comm "swapon", pid 7852, jiffies 4294968787 (age 1490.770s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<00000000003a2504>] __vmalloc_node_range+0x194/0x2d8
    [<00000000003a2918>] vzalloc+0x58/0x68
    [<00000000003b0af0>] SyS_swapon+0xd60/0x12f8
    [<0000000000a3dc2e>] system_call+0xd6/0x270
    [<ffffffffffffffff>] 0xffffffffffffffff


Turns out kmemleak is right. We now allocate the frontswap map depending on the kernel config
(and no longer on the enablement)

swapfile.c:
[...]
      if (IS_ENABLED(CONFIG_FRONTSWAP))
                frontswap_map = vzalloc(BITS_TO_LONGS(maxpages) * sizeof(long));

but later on this is passed along
--> enable_swap_info(p, prio, swap_map, cluster_info, frontswap_map);

and ignored if frontswap is disabled
--> frontswap_init(p->type, frontswap_map);
static inline void frontswap_init(unsigned type, unsigned long *map)
{
        if (frontswap_enabled())
                __frontswap_init(type, map);
}

Thing is, that frontswap map is never freed.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
