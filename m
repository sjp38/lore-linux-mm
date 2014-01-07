Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 600716B0039
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:16:52 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so273722ead.38
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:16:51 -0800 (PST)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id y48si9813035eew.247.2014.01.07.07.16.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 07:16:50 -0800 (PST)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 15:16:49 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 646EB17D8066
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 15:16:55 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s07FGYxi328056
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 15:16:34 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s07FGj9U019517
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 08:16:46 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH 0/2] Small fixes to memblock and nobootmem
Date: Tue,  7 Jan 2014 16:16:12 +0100
Message-Id: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, tangchen@cn.fujitsu.com, tj@kernel.org, toshi.kani@hp.com, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

While working on the conversion of the s390 port to use memblock and
nobootmem instead of bootmem I discovered two small bugs:

alloc_memory_core_early() in mm/nobootmem.c called memblock_reserve()
without forwarding the return value of memblock_reserve().

free_low_memory_core() (used by free_all_bootmem) in mm/nobootmem.c
already took care of releasing the memblock.reserved array in case
it has been allocated using memblock itself. This behaviour was
missing for memblock.memory.
Cases where memblock.memory grows bigger than the initial 128 entries
have been seen. So this should be supported as well.

Philipp Hachtmann (2):
  mm, nobootmem: Add return value check in __alloc_memory_core_early()
  mm: free memblock.memory in free_all_bootmem

 include/linux/memblock.h |  1 +
 mm/memblock.c            | 12 ++++++++++++
 mm/nobootmem.c           | 11 +++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
