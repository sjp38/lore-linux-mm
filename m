Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 949F46B2B6E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 14:25:34 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x204-v6so5368071qka.6
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 11:25:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d14-v6sor2705222qvj.63.2018.08.23.11.25.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 11:25:33 -0700 (PDT)
From: Masayoshi Mizuma <msys.mizuma@gmail.com>
Subject: [PATCH 1/2] Revert "x86/e820: put !E820_TYPE_RAM regions into memblock.reserved"
Date: Thu, 23 Aug 2018 14:25:12 -0400
Message-Id: <20180823182513.8801-1-msys.mizuma@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, x86@kernel.org

From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>

commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into
memblock.reserved") breaks movable_node kernel option because it
changed the memory gap range to reserved memblock. So, the node
is marked as Normal zone even if the SRAT has Hot plaggable affinity.

    =====================================================================
    kernel: BIOS-e820: [mem 0x0000180000000000-0x0000180fffffffff] usable
    kernel: BIOS-e820: [mem 0x00001c0000000000-0x00001c0fffffffff] usable
    ...
    kernel: reserved[0x12]#011[0x0000181000000000-0x00001bffffffffff], 0x000003f000000000 bytes flags: 0x0
    ...
    kernel: ACPI: SRAT: Node 2 PXM 6 [mem 0x180000000000-0x1bffffffffff] hotplug
    kernel: ACPI: SRAT: Node 3 PXM 7 [mem 0x1c0000000000-0x1fffffffffff] hotplug
    ...
    kernel: Movable zone start for each node
    kernel:  Node 3: 0x00001c0000000000
    kernel: Early memory node ranges
    ...
    =====================================================================

Naoya's v1 patch [*] fixes the original issue and this movable_node
issue doesn't occur.
Let's revert commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM
regions into memblock.reserved") and apply the v1 patch.

[*] https://lkml.org/lkml/2018/6/13/27

Signed-off-by: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
---
 arch/x86/kernel/e820.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/arch/x86/kernel/e820.c b/arch/x86/kernel/e820.c
index c88c23c658c1..d1f25c831447 100644
--- a/arch/x86/kernel/e820.c
+++ b/arch/x86/kernel/e820.c
@@ -1248,7 +1248,6 @@ void __init e820__memblock_setup(void)
 {
 	int i;
 	u64 end;
-	u64 addr = 0;
 
 	/*
 	 * The bootstrap memblock region count maximum is 128 entries
@@ -1265,21 +1264,13 @@ void __init e820__memblock_setup(void)
 		struct e820_entry *entry = &e820_table->entries[i];
 
 		end = entry->addr + entry->size;
-		if (addr < entry->addr)
-			memblock_reserve(addr, entry->addr - addr);
-		addr = end;
 		if (end != (resource_size_t)end)
 			continue;
 
-		/*
-		 * all !E820_TYPE_RAM ranges (including gap ranges) are put
-		 * into memblock.reserved to make sure that struct pages in
-		 * such regions are not left uninitialized after bootup.
-		 */
 		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
-			memblock_reserve(entry->addr, entry->size);
-		else
-			memblock_add(entry->addr, entry->size);
+			continue;
+
+		memblock_add(entry->addr, entry->size);
 	}
 
 	/* Throw away partial pages: */
-- 
2.18.0
