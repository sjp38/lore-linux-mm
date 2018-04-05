Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5E16B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 04:05:14 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 91-v6so5118672plf.6
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 01:05:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e29-v6sor2953214plj.13.2018.04.05.01.05.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 01:05:13 -0700 (PDT)
From: Jia He <hejianet@gmail.com>
Subject: [PATCH v7 1/5] mm: page_alloc: remain memblock_next_valid_pfn() on arm and arm64
Date: Thu,  5 Apr 2018 01:04:34 -0700
Message-Id: <1522915478-5044-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <hejianet@gmail.com>, Jia He <jia.he@hxt-semitech.com>

Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
where possible") optimized the loop in memmap_init_zone(). But it causes
possible panic bug. So Daniel Vacek reverted it later.

But as suggested by Daniel Vacek, it is fine to using memblock to skip
gaps and finding next valid frame with CONFIG_HAVE_ARCH_PFN_VALID.

On arm and arm64, memblock is used by default. But generic version of
pfn_valid() is based on mem sections and memblock_next_valid_pfn() does
not always return the next valid one but skips more resulting in some
valid frames to be skipped (as if they were invalid). And that's why
kernel was eventually crashing on some !arm machines.

And as verified by Eugeniu Rosca, arm can benifit from commit
b92df1de5d28. So remain the memblock_next_valid_pfn on arm/arm64 and
move the related codes to one file include/linux/arm96_common.h

Suggested-by: Daniel Vacek <neelx@redhat.com>
Signed-off-by: Jia He <jia.he@hxt-semitech.com>
---
 arch/arm/mm/init.c           |  1 +
 arch/arm64/mm/init.c         |  1 +
 include/linux/arm96_common.h | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/mmzone.h       | 11 +++++++++++
 mm/page_alloc.c              |  2 +-
 5 files changed, 51 insertions(+), 1 deletion(-)
 create mode 100644 include/linux/arm96_common.h

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index a1f11a7..296cc52 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -25,6 +25,7 @@
 #include <linux/dma-contiguous.h>
 #include <linux/sizes.h>
 #include <linux/stop_machine.h>
+#include <linux/arm96_common.h>
 
 #include <asm/cp15.h>
 #include <asm/mach-types.h>
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 00e7b90..6efab80 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -40,6 +40,7 @@
 #include <linux/mm.h>
 #include <linux/kexec.h>
 #include <linux/crash_dump.h>
+#include <linux/arm96_common.h>
 
 #include <asm/boot.h>
 #include <asm/fixmap.h>
diff --git a/include/linux/arm96_common.h b/include/linux/arm96_common.h
new file mode 100644
index 0000000..a6f68ea
--- /dev/null
+++ b/include/linux/arm96_common.h
@@ -0,0 +1,37 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Common definitions of arm and arm64
+ * Copyright (C) 2018 HXT-semitech Corp.
+ */
+#ifndef __ARM96_COMMON_H
+#define __ARM96_COMMON_H
+#ifdef CONFIG_HAVE_ARCH_PFN_VALID
+/* HAVE_MEMBLOCK is always enabled on arm and arm64 */
+ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
+{
+	struct memblock_type *type = &memblock.memory;
+	unsigned int right = type->cnt;
+	unsigned int mid, left = 0;
+	phys_addr_t addr = PFN_PHYS(++pfn);
+
+	do {
+		mid = (right + left) / 2;
+
+		if (addr < type->regions[mid].base)
+			right = mid;
+		else if (addr >= (type->regions[mid].base +
+				  type->regions[mid].size))
+			left = mid + 1;
+		else {
+			/* addr is within the region, so pfn is valid */
+			return pfn;
+		}
+	} while (left < right);
+
+	if (right == type->cnt)
+		return -1UL;
+	else
+		return PHYS_PFN(type->regions[right].base);
+}
+EXPORT_SYMBOL(memblock_next_valid_pfn);
+#endif /*CONFIG_HAVE_ARCH_PFN_VALID*/
+#endif /*__ARM96_COMMON_H*/
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d797716..eb56071 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1245,6 +1245,8 @@ static inline int pfn_valid(unsigned long pfn)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+
+#define next_valid_pfn(pfn)	(pfn++)
 #endif
 
 static inline int pfn_present(unsigned long pfn)
@@ -1270,6 +1272,10 @@ static inline int pfn_present(unsigned long pfn)
 #endif
 
 #define early_pfn_valid(pfn)	pfn_valid(pfn)
+#ifdef CONFIG_HAVE_ARCH_PFN_VALID
+extern ulong memblock_next_valid_pfn(ulong pfn);
+#define next_valid_pfn(pfn)	memblock_next_valid_pfn(pfn)
+#endif
 void sparse_init(void);
 #else
 #define sparse_init()	do {} while (0)
@@ -1291,6 +1297,11 @@ struct mminit_pfnnid_cache {
 #define early_pfn_valid(pfn)	(1)
 #endif
 
+/* fallback to default defitions*/
+#ifndef next_valid_pfn
+#define next_valid_pfn(pfn)	(pfn++)
+#endif
+
 void memory_present(int nid, unsigned long start, unsigned long end);
 unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c19f5ac..9d05f29 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5475,7 +5475,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 	if (altmap && start_pfn == altmap->base_pfn)
 		start_pfn += altmap->reserve;
 
-	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+	for (pfn = start_pfn; pfn < end_pfn; next_valid_pfn(pfn)) {
 		/*
 		 * There can be holes in boot-time mem_map[]s handed to this
 		 * function.  They do not exist on hotplugged memory.
-- 
2.7.4
