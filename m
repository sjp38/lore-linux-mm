Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFC56B0269
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 13:57:20 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z136-v6so23112104itc.5
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 10:57:20 -0700 (PDT)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id t140-v6si8143869itf.139.2018.10.15.10.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 10:57:19 -0700 (PDT)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Mon, 15 Oct 2018 11:56:59 -0600
Message-Id: <20181015175702.9036-4-logang@deltatee.com>
In-Reply-To: <20181015175702.9036-1-logang@deltatee.com>
References: <20181015175702.9036-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v2 3/6] ARM: mm: make use of new memblocks_present() helper
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Logan Gunthorpe <logang@deltatee.com>, Russell King <linux@armlinux.org.uk>, Kees Cook <keescook@chromium.org>, Philip Derrin <philip@cog.systems>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Nicolas Pitre <nicolas.pitre@linaro.org>

Cleanup the arm_memory_present() function seeing it's very
similar to other arches.

The new memblocks_present() helper checks for node ids which the
arm version did not. However, this is equivalent seeing
HAVE_MEMBLOCK_NODE_MAP should be false in this arch and therefore
memblock_get_region_node() should return 0.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Kees Cook <keescook@chromium.org>
Cc: Philip Derrin <philip@cog.systems>
Cc: "Steven Rostedt (VMware)" <rostedt@goodmis.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>
---
 arch/arm/mm/init.c | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 0cc8e04295a4..e2710dd7446f 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -201,21 +201,6 @@ int pfn_valid(unsigned long pfn)
 EXPORT_SYMBOL(pfn_valid);
 #endif
 
-#ifndef CONFIG_SPARSEMEM
-static void __init arm_memory_present(void)
-{
-}
-#else
-static void __init arm_memory_present(void)
-{
-	struct memblock_region *reg;
-
-	for_each_memblock(memory, reg)
-		memory_present(0, memblock_region_memory_base_pfn(reg),
-			       memblock_region_memory_end_pfn(reg));
-}
-#endif
-
 static bool arm_memblock_steal_permitted = true;
 
 phys_addr_t __init arm_memblock_steal(phys_addr_t size, phys_addr_t align)
@@ -317,7 +302,7 @@ void __init bootmem_init(void)
 	 * Sparsemem tries to allocate bootmem in memory_present(),
 	 * so must be done after the fixed reservations
 	 */
-	arm_memory_present();
+	memblocks_present();
 
 	/*
 	 * sparse_init() needs the bootmem allocator up and running.
-- 
2.19.0
