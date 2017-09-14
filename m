Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 394C66B0261
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 18:36:15 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u48so935185qtc.3
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 15:36:15 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s9si6849283qts.212.2017.09.14.15.36.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 15:36:14 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v8 10/11] arm64/kasan: explicitly zero kasan shadow memory
Date: Thu, 14 Sep 2017 18:35:16 -0400
Message-Id: <20170914223517.8242-11-pasha.tatashin@oracle.com>
In-Reply-To: <20170914223517.8242-1-pasha.tatashin@oracle.com>
References: <20170914223517.8242-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org, mgorman@techsingularity.net, Steven.Sistare@oracle.com, daniel.m.jordan@oracle.com, bob.picco@oracle.com

To optimize the performance of struct page initialization,
vmemmap_populate() will no longer zero memory.

We must explicitly zero the memory that is allocated by vmemmap_populate()
for kasan, as this memory does not go through struct page initialization
path.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 arch/arm64/mm/kasan_init.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 81f03959a4ab..e78a9ecbb687 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -135,6 +135,41 @@ static void __init clear_pgds(unsigned long start,
 		set_pgd(pgd_offset_k(start), __pgd(0));
 }
 
+/*
+ * Memory that was allocated by vmemmap_populate is not zeroed, so we must
+ * zero it here explicitly.
+ */
+static void
+zero_vmemmap_populated_memory(void)
+{
+	struct memblock_region *reg;
+	u64 start, end;
+
+	for_each_memblock(memory, reg) {
+		start = __phys_to_virt(reg->base);
+		end = __phys_to_virt(reg->base + reg->size);
+
+		if (start >= end)
+			break;
+
+		start = (u64)kasan_mem_to_shadow((void *)start);
+		end = (u64)kasan_mem_to_shadow((void *)end);
+
+		/* Round to the start end of the mapped pages */
+		start = round_down(start, SWAPPER_BLOCK_SIZE);
+		end = round_up(end, SWAPPER_BLOCK_SIZE);
+		memset((void *)start, 0, end - start);
+	}
+
+	start = (u64)kasan_mem_to_shadow(_text);
+	end = (u64)kasan_mem_to_shadow(_end);
+
+	/* Round to the start end of the mapped pages */
+	start = round_down(start, SWAPPER_BLOCK_SIZE);
+	end = round_up(end, SWAPPER_BLOCK_SIZE);
+	memset((void *)start, 0, end - start);
+}
+
 void __init kasan_init(void)
 {
 	u64 kimg_shadow_start, kimg_shadow_end;
@@ -205,8 +240,15 @@ void __init kasan_init(void)
 			pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
 
 	memset(kasan_zero_page, 0, PAGE_SIZE);
+
 	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
+	/*
+	 * vmemmap_populate does not zero the memory, so we need to zero it
+	 * explicitly
+	 */
+	zero_vmemmap_populated_memory();
+
 	/* At this point kasan is fully initialized. Enable error messages */
 	init_task.kasan_depth = 0;
 	pr_info("KernelAddressSanitizer initialized\n");
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
