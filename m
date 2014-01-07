Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id C1E0F6B003B
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 10:17:04 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so136788eek.26
        for <linux-mm@kvack.org>; Tue, 07 Jan 2014 07:17:04 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id b44si1641379eez.14.2014.01.07.07.17.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Jan 2014 07:17:04 -0800 (PST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Tue, 7 Jan 2014 15:17:03 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id EAEF4219005E
	for <linux-mm@kvack.org>; Tue,  7 Jan 2014 15:16:59 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s07FGm341376700
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 15:16:48 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s07FH0Hj020168
	for <linux-mm@kvack.org>; Tue, 7 Jan 2014 08:17:00 -0700
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm, nobootmem: Add return value check in __alloc_memory_core_early()
Date: Tue,  7 Jan 2014 16:16:13 +0100
Message-Id: <1389107774-54978-2-git-send-email-phacht@linux.vnet.ibm.com>
In-Reply-To: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389107774-54978-1-git-send-email-phacht@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, jiang.liu@huawei.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, tangchen@cn.fujitsu.com, tj@kernel.org, toshi.kani@hp.com, Philipp Hachtmann <phacht@linux.vnet.ibm.com>

When memblock_reserve() fails because memblock.reserved.regions cannot
be resized, the caller (e.g. alloc_bootmem()) is not informed of the
failed allocation. Therefore alloc_bootmem() silently returns the same
pointer again and again.
This patch adds a check for the return value of memblock_reserve() in
__alloc_memory_core().

Signed-off-by: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
---
 mm/nobootmem.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 2c254d3..3a7e14d 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -45,7 +45,9 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 	if (!addr)
 		return NULL;
 
-	memblock_reserve(addr, size);
+	if (memblock_reserve(addr, size))
+		return NULL;
+
 	ptr = phys_to_virt(addr);
 	memset(ptr, 0, size);
 	/*
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
