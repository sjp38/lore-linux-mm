Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7501C6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:03:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e131so8519871pfh.7
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:03:31 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r1si6059539plj.260.2017.05.05.10.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 10:03:30 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v3 4/9] mm: do not zero vmemmap_buf
Date: Fri,  5 May 2017 13:03:11 -0400
Message-Id: <1494003796-748672-5-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

alloc_block_buf() can either use external allocator by calling
vmemmap_alloc_block() or when available use pre-allocated vmemmap_buf
to do allocation. In either case, alloc_block_buf() knows when to zero
memory based on the "zero" argument.  This is why it is not needed to
zero vmemmap_buf beforehand. Let clients of alloc_block_buf() to
decide whether that is needed.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
---
 mm/sparse-vmemmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 5d255b0..1e9508b 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -305,7 +305,7 @@ void __init sparse_mem_maps_populate_node(struct page **map_map,
 
 	size = ALIGN(size, PMD_SIZE);
 	vmemmap_buf_start = __earlyonly_bootmem_alloc(nodeid, size
-			* map_count, PMD_SIZE, __pa(MAX_DMA_ADDRESS), true);
+			* map_count, PMD_SIZE, __pa(MAX_DMA_ADDRESS), false);
 
 	if (vmemmap_buf_start) {
 		vmemmap_buf = vmemmap_buf_start;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
