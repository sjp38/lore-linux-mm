Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C3BE86B060C
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 17:25:01 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id v127so24656113itd.3
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 14:25:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 133si8217435itb.135.2017.08.03.14.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 14:24:59 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v5 10/15] x86/kasan: explicitly zero kasan shadow memory
Date: Thu,  3 Aug 2017 17:23:48 -0400
Message-Id: <1501795433-982645-11-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501795433-982645-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

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
 arch/x86/mm/kasan_init_64.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 02c9d7553409..7d06cf0b0b6e 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -84,6 +84,28 @@ static struct notifier_block kasan_die_notifier = {
 };
 #endif
 
+/*
+ * Memory that was allocated by vmemmap_populate is not zeroed, so we must
+ * zero it here explicitly.
+ */
+static void
+zero_vemmap_populated_memory(void)
+{
+	u64 i, start, end;
+
+	for (i = 0; i < E820_MAX_ENTRIES && pfn_mapped[i].end; i++) {
+		void *kaddr_start = pfn_to_kaddr(pfn_mapped[i].start);
+		void *kaddr_end = pfn_to_kaddr(pfn_mapped[i].end);
+
+		start = (u64)kasan_mem_to_shadow(kaddr_start);
+		end = (u64)kasan_mem_to_shadow(kaddr_end);
+		memset((void *)start, 0, end - start);
+	}
+	start = (u64)kasan_mem_to_shadow(_stext);
+	end = (u64)kasan_mem_to_shadow(_end);
+	memset((void *)start, 0, end - start);
+}
+
 void __init kasan_early_init(void)
 {
 	int i;
@@ -156,6 +178,13 @@ void __init kasan_init(void)
 		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO);
 		set_pte(&kasan_zero_pte[i], pte);
 	}
+
+	/*
+	 * vmemmap_populate does not zero the memory, so we need to zero it
+	 * explicitly
+	 */
+	zero_vemmap_populated_memory();
+
 	/* Flush TLBs again to be sure that write protection applied. */
 	__flush_tlb_all();
 
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
