Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8610E6B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 12:16:48 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id l4-v6so12567199iog.13
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 09:16:48 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id f6si1666271itk.72.2018.10.05.09.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 05 Oct 2018 09:16:47 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Fri,  5 Oct 2018 10:16:40 -0600
Message-Id: <20181005161642.2462-4-logang@deltatee.com>
In-Reply-To: <20181005161642.2462-1-logang@deltatee.com>
References: <20181005161642.2462-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH 3/5] arm64: mm: make use of new memblocks_present() helper
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>

Cleanup the arm64_memory_present() function seeing it's very
similar to other arches.

memblocks_present() is a direct replacement of arm64_memory_present()

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
---
 arch/arm64/mm/init.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 787e27964ab9..63fa9653f281 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -296,24 +296,6 @@ int pfn_valid(unsigned long pfn)
 EXPORT_SYMBOL(pfn_valid);
 #endif
 
-#ifndef CONFIG_SPARSEMEM
-static void __init arm64_memory_present(void)
-{
-}
-#else
-static void __init arm64_memory_present(void)
-{
-	struct memblock_region *reg;
-
-	for_each_memblock(memory, reg) {
-		int nid = memblock_get_region_node(reg);
-
-		memory_present(nid, memblock_region_memory_base_pfn(reg),
-				memblock_region_memory_end_pfn(reg));
-	}
-}
-#endif
-
 static phys_addr_t memory_limit = PHYS_ADDR_MAX;
 
 /*
@@ -506,7 +488,7 @@ void __init bootmem_init(void)
 	 * Sparsemem tries to allocate bootmem in memory_present(), so must be
 	 * done after the fixed reservations.
 	 */
-	arm64_memory_present();
+	memblocks_present();
 
 	sparse_init();
 	zone_sizes_init(min, max);
-- 
2.19.0
