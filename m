Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8EA436B0035
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 17:16:14 -0500 (EST)
Received: by mail-pb0-f49.google.com with SMTP id up15so17274617pbc.22
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:16:14 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ui8si19641797pac.235.2014.02.18.14.15.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Feb 2014 14:15:45 -0800 (PST)
From: Laura Abbott <lauraa@codeaurora.org>
Subject: [PATCHv4 2/2] arm: Get rid of meminfo
Date: Tue, 18 Feb 2014 14:15:33 -0800
Message-Id: <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
In-Reply-To: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org
Cc: Laura Abbott <lauraa@codeaurora.org>, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

memblock is now fully integrated into the kernel and is the prefered
method for tracking memory. Rather than reinvent the wheel with
meminfo, migrate to using memblock directly instead of meminfo as
an intermediate.

Acked-by: Jason Cooper <jason@lakedaemon.net>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Acked-by: Kukjin Kim <kgene.kim@samsung.com>
Tested-by: Marek Szyprowski <m.szyprowski@samsung.com>
Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
---
 arch/arm/include/asm/mach/arch.h         |    4 +-
 arch/arm/include/asm/memblock.h          |    3 +-
 arch/arm/include/asm/setup.h             |   23 ------
 arch/arm/kernel/atags_parse.c            |    5 +-
 arch/arm/kernel/devtree.c                |    5 --
 arch/arm/kernel/setup.c                  |   30 ++------
 arch/arm/mach-clps711x/board-clep7312.c  |    7 +-
 arch/arm/mach-clps711x/board-edb7211.c   |   10 +--
 arch/arm/mach-clps711x/board-p720t.c     |    2 +-
 arch/arm/mach-footbridge/cats-hw.c       |    2 +-
 arch/arm/mach-footbridge/netwinder-hw.c  |    2 +-
 arch/arm/mach-msm/board-halibut.c        |    6 --
 arch/arm/mach-msm/board-mahimahi.c       |   13 +---
 arch/arm/mach-msm/board-msm7x30.c        |    3 +-
 arch/arm/mach-msm/board-sapphire.c       |   13 ++--
 arch/arm/mach-msm/board-trout.c          |    8 +--
 arch/arm/mach-orion5x/common.c           |    3 +-
 arch/arm/mach-orion5x/common.h           |    3 +-
 arch/arm/mach-pxa/cm-x300.c              |    3 +-
 arch/arm/mach-pxa/corgi.c                |   10 +--
 arch/arm/mach-pxa/eseries.c              |    9 +--
 arch/arm/mach-pxa/poodle.c               |    8 +--
 arch/arm/mach-pxa/spitz.c                |    8 +--
 arch/arm/mach-pxa/tosa.c                 |    8 +--
 arch/arm/mach-realview/core.c            |   11 +--
 arch/arm/mach-realview/core.h            |    3 +-
 arch/arm/mach-realview/realview_pb1176.c |    8 +--
 arch/arm/mach-realview/realview_pbx.c    |   17 ++---
 arch/arm/mach-s3c24xx/mach-smdk2413.c    |    8 +--
 arch/arm/mach-s3c24xx/mach-vstms.c       |    8 +--
 arch/arm/mach-sa1100/assabet.c           |    2 +-
 arch/arm/mm/init.c                       |   67 +++++++-----------
 arch/arm/mm/mmu.c                        |  115 +++++++++---------------------
 arch/arm/mm/nommu.c                      |   66 +++++++++--------
 34 files changed, 172 insertions(+), 321 deletions(-)

diff --git a/arch/arm/include/asm/mach/arch.h b/arch/arm/include/asm/mach/arch.h
index 17a3fa2..c43473a 100644
--- a/arch/arm/include/asm/mach/arch.h
+++ b/arch/arm/include/asm/mach/arch.h
@@ -14,7 +14,6 @@
 #include <linux/reboot.h>
 
 struct tag;
-struct meminfo;
 struct pt_regs;
 struct smp_operations;
 #ifdef CONFIG_SMP
@@ -47,8 +46,7 @@ struct machine_desc {
 	enum reboot_mode	reboot_mode;	/* default restart mode	*/
 	struct smp_operations	*smp;		/* SMP operations	*/
 	bool			(*smp_init)(void);
-	void			(*fixup)(struct tag *, char **,
-					 struct meminfo *);
+	void			(*fixup)(struct tag *, char **);
 	void			(*init_meminfo)(void);
 	void			(*reserve)(void);/* reserve mem blocks	*/
 	void			(*map_io)(void);/* IO mapping function	*/
diff --git a/arch/arm/include/asm/memblock.h b/arch/arm/include/asm/memblock.h
index c2f5102..bf47a6c 100644
--- a/arch/arm/include/asm/memblock.h
+++ b/arch/arm/include/asm/memblock.h
@@ -1,10 +1,9 @@
 #ifndef _ASM_ARM_MEMBLOCK_H
 #define _ASM_ARM_MEMBLOCK_H
 
-struct meminfo;
 struct machine_desc;
 
-void arm_memblock_init(struct meminfo *, const struct machine_desc *);
+void arm_memblock_init(const struct machine_desc *);
 phys_addr_t arm_memblock_steal(phys_addr_t size, phys_addr_t align);
 
 #endif
diff --git a/arch/arm/include/asm/setup.h b/arch/arm/include/asm/setup.h
index 8d6a089..0196091 100644
--- a/arch/arm/include/asm/setup.h
+++ b/arch/arm/include/asm/setup.h
@@ -26,29 +26,6 @@ static const struct tagtable __tagtable_##fn __tag = { tag, fn }
  */
 #define NR_BANKS	CONFIG_ARM_NR_BANKS
 
-struct membank {
-	phys_addr_t start;
-	phys_addr_t size;
-	unsigned int highmem;
-};
-
-struct meminfo {
-	int nr_banks;
-	struct membank bank[NR_BANKS];
-};
-
-extern struct meminfo meminfo;
-
-#define for_each_bank(iter,mi)				\
-	for (iter = 0; iter < (mi)->nr_banks; iter++)
-
-#define bank_pfn_start(bank)	__phys_to_pfn((bank)->start)
-#define bank_pfn_end(bank)	__phys_to_pfn((bank)->start + (bank)->size)
-#define bank_pfn_size(bank)	((bank)->size >> PAGE_SHIFT)
-#define bank_phys_start(bank)	(bank)->start
-#define bank_phys_end(bank)	((bank)->start + (bank)->size)
-#define bank_phys_size(bank)	(bank)->size
-
 extern int arm_add_memory(u64 start, u64 size);
 extern void early_print(const char *str, ...);
 extern void dump_machine_table(void);
diff --git a/arch/arm/kernel/atags_parse.c b/arch/arm/kernel/atags_parse.c
index 8c14de8..7807ef5 100644
--- a/arch/arm/kernel/atags_parse.c
+++ b/arch/arm/kernel/atags_parse.c
@@ -22,6 +22,7 @@
 #include <linux/fs.h>
 #include <linux/root_dev.h>
 #include <linux/screen_info.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <asm/system_info.h>
@@ -222,10 +223,10 @@ setup_machine_tags(phys_addr_t __atags_pointer, unsigned int machine_nr)
 	}
 
 	if (mdesc->fixup)
-		mdesc->fixup(tags, &from, &meminfo);
+		mdesc->fixup(tags, &from);
 
 	if (tags->hdr.tag == ATAG_CORE) {
-		if (meminfo.nr_banks != 0)
+		if (memblock_phys_mem_size())
 			squash_mem_tags(tags);
 		save_atags(tags);
 		parse_tags(tags);
diff --git a/arch/arm/kernel/devtree.c b/arch/arm/kernel/devtree.c
index f751714..398cd5f 100644
--- a/arch/arm/kernel/devtree.c
+++ b/arch/arm/kernel/devtree.c
@@ -26,11 +26,6 @@
 #include <asm/mach/arch.h>
 #include <asm/mach-types.h>
 
-void __init early_init_dt_add_memory_arch(u64 base, u64 size)
-{
-	arm_add_memory(base, size);
-}
-
 void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
 {
 	return memblock_virt_alloc(size, align);
diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 1e8b030..7dd83d0 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -625,15 +625,8 @@ void __init dump_machine_table(void)
 
 int __init arm_add_memory(u64 start, u64 size)
 {
-	struct membank *bank = &meminfo.bank[meminfo.nr_banks];
 	u64 aligned_start;
 
-	if (meminfo.nr_banks >= NR_BANKS) {
-		pr_crit("NR_BANKS too low, ignoring memory at 0x%08llx\n",
-			(long long)start);
-		return -EINVAL;
-	}
-
 	/*
 	 * Ensure that start/size are aligned to a page boundary.
 	 * Size is appropriately rounded down, start is rounded up.
@@ -674,17 +667,17 @@ int __init arm_add_memory(u64 start, u64 size)
 		aligned_start = PHYS_OFFSET;
 	}
 
-	bank->start = aligned_start;
-	bank->size = size & ~(phys_addr_t)(PAGE_SIZE - 1);
+	start = aligned_start;
+	size = size & ~(phys_addr_t)(PAGE_SIZE - 1);
 
 	/*
 	 * Check whether this memory region has non-zero size or
 	 * invalid node number.
 	 */
-	if (bank->size == 0)
+	if (size == 0)
 		return -EINVAL;
 
-	meminfo.nr_banks++;
+	memblock_add(start, size);
 	return 0;
 }
 
@@ -692,6 +685,7 @@ int __init arm_add_memory(u64 start, u64 size)
  * Pick out the memory size.  We look for mem=size@start,
  * where start and size are "size[KkMm]"
  */
+
 static int __init early_mem(char *p)
 {
 	static int usermem __initdata = 0;
@@ -706,7 +700,8 @@ static int __init early_mem(char *p)
 	 */
 	if (usermem == 0) {
 		usermem = 1;
-		meminfo.nr_banks = 0;
+		memblock_remove(memblock_start_of_DRAM(),
+			memblock_end_of_DRAM() - memblock_start_of_DRAM());
 	}
 
 	start = PHYS_OFFSET;
@@ -851,13 +846,6 @@ static void __init reserve_crashkernel(void)
 static inline void reserve_crashkernel(void) {}
 #endif /* CONFIG_KEXEC */
 
-static int __init meminfo_cmp(const void *_a, const void *_b)
-{
-	const struct membank *a = _a, *b = _b;
-	long cmp = bank_pfn_start(a) - bank_pfn_start(b);
-	return cmp < 0 ? -1 : cmp > 0 ? 1 : 0;
-}
-
 void __init hyp_mode_check(void)
 {
 #ifdef CONFIG_ARM_VIRT_EXT
@@ -900,12 +888,10 @@ void __init setup_arch(char **cmdline_p)
 
 	parse_early_param();
 
-	sort(&meminfo.bank, meminfo.nr_banks, sizeof(meminfo.bank[0]), meminfo_cmp, NULL);
-
 	early_paging_init(mdesc, lookup_processor_type(read_cpuid_id()));
 	setup_dma_zone(mdesc);
 	sanity_check_meminfo();
-	arm_memblock_init(&meminfo, mdesc);
+	arm_memblock_init(mdesc);
 
 	paging_init(mdesc);
 	request_standard_resources(mdesc);
diff --git a/arch/arm/mach-clps711x/board-clep7312.c b/arch/arm/mach-clps711x/board-clep7312.c
index b476424..4d04b91 100644
--- a/arch/arm/mach-clps711x/board-clep7312.c
+++ b/arch/arm/mach-clps711x/board-clep7312.c
@@ -18,6 +18,7 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <asm/mach-types.h>
@@ -26,11 +27,9 @@
 #include "common.h"
 
 static void __init
-fixup_clep7312(struct tag *tags, char **cmdline, struct meminfo *mi)
+fixup_clep7312(struct tag *tags, char **cmdline)
 {
-	mi->nr_banks=1;
-	mi->bank[0].start = 0xc0000000;
-	mi->bank[0].size = 0x01000000;
+	memblock_add(0xc0000000, 0x01000000);
 }
 
 MACHINE_START(CLEP7212, "Cirrus Logic 7212/7312")
diff --git a/arch/arm/mach-clps711x/board-edb7211.c b/arch/arm/mach-clps711x/board-edb7211.c
index fe6184e..b617aa2 100644
--- a/arch/arm/mach-clps711x/board-edb7211.c
+++ b/arch/arm/mach-clps711x/board-edb7211.c
@@ -16,6 +16,7 @@
 #include <linux/interrupt.h>
 #include <linux/backlight.h>
 #include <linux/platform_device.h>
+#include <linux/memblock.h>
 
 #include <linux/mtd/physmap.h>
 #include <linux/mtd/partitions.h>
@@ -133,7 +134,7 @@ static void __init edb7211_reserve(void)
 }
 
 static void __init
-fixup_edb7211(struct tag *tags, char **cmdline, struct meminfo *mi)
+fixup_edb7211(struct tag *tags, char **cmdline)
 {
 	/*
 	 * Bank start addresses are not present in the information
@@ -143,11 +144,8 @@ fixup_edb7211(struct tag *tags, char **cmdline, struct meminfo *mi)
 	 * Banks sizes _are_ present in the param block, but we're
 	 * not using that information yet.
 	 */
-	mi->bank[0].start = 0xc0000000;
-	mi->bank[0].size = SZ_8M;
-	mi->bank[1].start = 0xc1000000;
-	mi->bank[1].size = SZ_8M;
-	mi->nr_banks = 2;
+	memblock_add(0xc0000000, SZ_8M);
+	memblock_add(0xc1000000, SZ_8M);
 }
 
 static void __init edb7211_init(void)
diff --git a/arch/arm/mach-clps711x/board-p720t.c b/arch/arm/mach-clps711x/board-p720t.c
index dd81b06..c1c6729 100644
--- a/arch/arm/mach-clps711x/board-p720t.c
+++ b/arch/arm/mach-clps711x/board-p720t.c
@@ -295,7 +295,7 @@ static struct generic_bl_info p720t_lcd_backlight_pdata = {
 };
 
 static void __init
-fixup_p720t(struct tag *tag, char **cmdline, struct meminfo *mi)
+fixup_p720t(struct tag *tag, char **cmdline)
 {
 	/*
 	 * Our bootloader doesn't setup any tags (yet).
diff --git a/arch/arm/mach-footbridge/cats-hw.c b/arch/arm/mach-footbridge/cats-hw.c
index 9669cc0..de86ab6 100644
--- a/arch/arm/mach-footbridge/cats-hw.c
+++ b/arch/arm/mach-footbridge/cats-hw.c
@@ -76,7 +76,7 @@ __initcall(cats_hw_init);
  * hard reboots fail on early boards.
  */
 static void __init
-fixup_cats(struct tag *tags, char **cmdline, struct meminfo *mi)
+fixup_cats(struct tag *tags, char **cmdline)
 {
 	screen_info.orig_video_lines  = 25;
 	screen_info.orig_video_points = 16;
diff --git a/arch/arm/mach-footbridge/netwinder-hw.c b/arch/arm/mach-footbridge/netwinder-hw.c
index eb1fa5c..cdee08c 100644
--- a/arch/arm/mach-footbridge/netwinder-hw.c
+++ b/arch/arm/mach-footbridge/netwinder-hw.c
@@ -620,7 +620,7 @@ __initcall(nw_hw_init);
  * the parameter page.
  */
 static void __init
-fixup_netwinder(struct tag *tags, char **cmdline, struct meminfo *mi)
+fixup_netwinder(struct tag *tags, char **cmdline)
 {
 #ifdef CONFIG_ISAPNP
 	extern int isapnp_disable;
diff --git a/arch/arm/mach-msm/board-halibut.c b/arch/arm/mach-msm/board-halibut.c
index a775298..61bfe58 100644
--- a/arch/arm/mach-msm/board-halibut.c
+++ b/arch/arm/mach-msm/board-halibut.c
@@ -83,11 +83,6 @@ static void __init halibut_init(void)
 	platform_add_devices(devices, ARRAY_SIZE(devices));
 }
 
-static void __init halibut_fixup(struct tag *tags, char **cmdline,
-				 struct meminfo *mi)
-{
-}
-
 static void __init halibut_map_io(void)
 {
 	msm_map_common_io();
@@ -100,7 +95,6 @@ static void __init halibut_init_late(void)
 
 MACHINE_START(HALIBUT, "Halibut Board (QCT SURF7200A)")
 	.atag_offset	= 0x100,
-	.fixup		= halibut_fixup,
 	.map_io		= halibut_map_io,
 	.init_early	= halibut_init_early,
 	.init_irq	= halibut_init_irq,
diff --git a/arch/arm/mach-msm/board-mahimahi.c b/arch/arm/mach-msm/board-mahimahi.c
index 7d9981c..873c3ca 100644
--- a/arch/arm/mach-msm/board-mahimahi.c
+++ b/arch/arm/mach-msm/board-mahimahi.c
@@ -22,6 +22,7 @@
 #include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/platform_device.h>
+#include <linux/memblock.h>
 
 #include <asm/mach-types.h>
 #include <asm/mach/arch.h>
@@ -52,16 +53,10 @@ static void __init mahimahi_init(void)
 	platform_add_devices(devices, ARRAY_SIZE(devices));
 }
 
-static void __init mahimahi_fixup(struct tag *tags, char **cmdline,
-				  struct meminfo *mi)
+static void __init mahimahi_fixup(struct tag *tags, char **cmdline)
 {
-	mi->nr_banks = 2;
-	mi->bank[0].start = PHYS_OFFSET;
-	mi->bank[0].node = PHYS_TO_NID(PHYS_OFFSET);
-	mi->bank[0].size = (219*1024*1024);
-	mi->bank[1].start = MSM_HIGHMEM_BASE;
-	mi->bank[1].node = PHYS_TO_NID(MSM_HIGHMEM_BASE);
-	mi->bank[1].size = MSM_HIGHMEM_SIZE;
+	memblock_add(PHYS_OFFSET, 219*SZ_1M);
+	memblock_add(MSM_HIGHMEM_BASE, MSM_HIGHMEM_SIZE);
 }
 
 static void __init mahimahi_map_io(void)
diff --git a/arch/arm/mach-msm/board-msm7x30.c b/arch/arm/mach-msm/board-msm7x30.c
index 46de789..b621b23 100644
--- a/arch/arm/mach-msm/board-msm7x30.c
+++ b/arch/arm/mach-msm/board-msm7x30.c
@@ -40,8 +40,7 @@
 #include "proc_comm.h"
 #include "common.h"
 
-static void __init msm7x30_fixup(struct tag *tag, char **cmdline,
-		struct meminfo *mi)
+static void __init msm7x30_fixup(struct tag *tag, char **cmdline)
 {
 	for (; tag->hdr.size; tag = tag_next(tag))
 		if (tag->hdr.tag == ATAG_MEM && tag->u.mem.start == 0x200000) {
diff --git a/arch/arm/mach-msm/board-sapphire.c b/arch/arm/mach-msm/board-sapphire.c
index 3276051..e509679 100644
--- a/arch/arm/mach-msm/board-sapphire.c
+++ b/arch/arm/mach-msm/board-sapphire.c
@@ -35,6 +35,7 @@
 
 #include <linux/mtd/nand.h>
 #include <linux/mtd/partitions.h>
+#include <linux/memblock.h>
 
 #include "gpio_chip.h"
 #include "board-sapphire.h"
@@ -74,22 +75,18 @@ static struct map_desc sapphire_io_desc[] __initdata = {
 	}
 };
 
-static void __init sapphire_fixup(struct tag *tags, char **cmdline,
-				  struct meminfo *mi)
+static void __init sapphire_fixup(struct tag *tags, char **cmdline)
 {
 	int smi_sz = parse_tag_smi((const struct tag *)tags);
 
-	mi->nr_banks = 1;
-	mi->bank[0].start = PHYS_OFFSET;
-	mi->bank[0].node = PHYS_TO_NID(PHYS_OFFSET);
 	if (smi_sz == 32) {
-		mi->bank[0].size = (84*1024*1024);
+		memblock_add(PHYS_OFFSET, 84*SZ_1M);
 	} else if (smi_sz == 64) {
-		mi->bank[0].size = (101*1024*1024);
+		memblock_add(PHYS_OFFSET, 101*SZ_1M);
 	} else {
+		memblock_add(PHYS_OFFSET, 101*SZ_1M);
 		/* Give a default value when not get smi size */
 		smi_sz = 64;
-		mi->bank[0].size = (101*1024*1024);
 	}
 }
 
diff --git a/arch/arm/mach-msm/board-trout.c b/arch/arm/mach-msm/board-trout.c
index 015d544..58826cf 100644
--- a/arch/arm/mach-msm/board-trout.c
+++ b/arch/arm/mach-msm/board-trout.c
@@ -19,6 +19,7 @@
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/clkdev.h>
+#include <linux/memblock.h>
 
 #include <asm/system_info.h>
 #include <asm/mach-types.h>
@@ -55,12 +56,9 @@ static void __init trout_init_irq(void)
 	msm_init_irq();
 }
 
-static void __init trout_fixup(struct tag *tags, char **cmdline,
-			       struct meminfo *mi)
+static void __init trout_fixup(struct tag *tags, char **cmdline)
 {
-	mi->nr_banks = 1;
-	mi->bank[0].start = PHYS_OFFSET;
-	mi->bank[0].size = (101*1024*1024);
+	memblock_add(PHYS_OFFSET, 101*SZ_1M);
 }
 
 static void __init trout_init(void)
diff --git a/arch/arm/mach-orion5x/common.c b/arch/arm/mach-orion5x/common.c
index 3f1de11..6bbb7b5 100644
--- a/arch/arm/mach-orion5x/common.c
+++ b/arch/arm/mach-orion5x/common.c
@@ -365,8 +365,7 @@ void orion5x_restart(enum reboot_mode mode, const char *cmd)
  * Many orion-based systems have buggy bootloader implementations.
  * This is a common fixup for bogus memory tags.
  */
-void __init tag_fixup_mem32(struct tag *t, char **from,
-			    struct meminfo *meminfo)
+void __init tag_fixup_mem32(struct tag *t, char **from)
 {
 	for (; t->hdr.size; t = tag_next(t))
 		if (t->hdr.tag == ATAG_MEM &&
diff --git a/arch/arm/mach-orion5x/common.h b/arch/arm/mach-orion5x/common.h
index f565f99..175ec4c 100644
--- a/arch/arm/mach-orion5x/common.h
+++ b/arch/arm/mach-orion5x/common.h
@@ -71,9 +71,8 @@ void edmini_v2_init(void);
 static inline void edmini_v2_init(void) {};
 #endif
 
-struct meminfo;
 struct tag;
-extern void __init tag_fixup_mem32(struct tag *, char **, struct meminfo *);
+extern void __init tag_fixup_mem32(struct tag *, char **);
 
 /*****************************************************************************
  * Helpers to access Orion registers
diff --git a/arch/arm/mach-pxa/cm-x300.c b/arch/arm/mach-pxa/cm-x300.c
index 584439bf..4d3588d 100644
--- a/arch/arm/mach-pxa/cm-x300.c
+++ b/arch/arm/mach-pxa/cm-x300.c
@@ -837,8 +837,7 @@ static void __init cm_x300_init(void)
 	cm_x300_init_bl();
 }
 
-static void __init cm_x300_fixup(struct tag *tags, char **cmdline,
-				 struct meminfo *mi)
+static void __init cm_x300_fixup(struct tag *tags, char **cmdline)
 {
 	/* Make sure that mi->bank[0].start = PHYS_ADDR */
 	for (; tags->hdr.size; tags = tag_next(tags))
diff --git a/arch/arm/mach-pxa/corgi.c b/arch/arm/mach-pxa/corgi.c
index f162f1b..a763744 100644
--- a/arch/arm/mach-pxa/corgi.c
+++ b/arch/arm/mach-pxa/corgi.c
@@ -33,6 +33,7 @@
 #include <linux/mtd/sharpsl.h>
 #include <linux/input/matrix_keypad.h>
 #include <linux/module.h>
+#include <linux/memblock.h>
 #include <video/w100fb.h>
 
 #include <asm/setup.h>
@@ -713,16 +714,13 @@ static void __init corgi_init(void)
 	platform_add_devices(devices, ARRAY_SIZE(devices));
 }
 
-static void __init fixup_corgi(struct tag *tags, char **cmdline,
-			       struct meminfo *mi)
+static void __init fixup_corgi(struct tag *tags, char **cmdline)
 {
 	sharpsl_save_param();
-	mi->nr_banks=1;
-	mi->bank[0].start = 0xa0000000;
 	if (machine_is_corgi())
-		mi->bank[0].size = (32*1024*1024);
+		memblock_add(0xa0000000, SZ_32M);
 	else
-		mi->bank[0].size = (64*1024*1024);
+		memblock_add(0xa0000000, SZ_64M);
 }
 
 #ifdef CONFIG_MACH_CORGI
diff --git a/arch/arm/mach-pxa/eseries.c b/arch/arm/mach-pxa/eseries.c
index 8280ebca..cfb8641 100644
--- a/arch/arm/mach-pxa/eseries.c
+++ b/arch/arm/mach-pxa/eseries.c
@@ -21,6 +21,7 @@
 #include <linux/mtd/nand.h>
 #include <linux/mtd/partitions.h>
 #include <linux/usb/gpio_vbus.h>
+#include <linux/memblock.h>
 
 #include <video/w100fb.h>
 
@@ -41,14 +42,12 @@
 #include "clock.h"
 
 /* Only e800 has 128MB RAM */
-void __init eseries_fixup(struct tag *tags, char **cmdline, struct meminfo *mi)
+void __init eseries_fixup(struct tag *tags, char **cmdline)
 {
-	mi->nr_banks=1;
-	mi->bank[0].start = 0xa0000000;
 	if (machine_is_e800())
-		mi->bank[0].size = (128*1024*1024);
+		memblock_add(0xa0000000, SZ_128M);
 	else
-		mi->bank[0].size = (64*1024*1024);
+		memblock_add(0xa0000000, SZ_64M);
 }
 
 struct gpio_vbus_mach_info e7xx_udc_info = {
diff --git a/arch/arm/mach-pxa/poodle.c b/arch/arm/mach-pxa/poodle.c
index aedf053..1319916 100644
--- a/arch/arm/mach-pxa/poodle.c
+++ b/arch/arm/mach-pxa/poodle.c
@@ -29,6 +29,7 @@
 #include <linux/spi/ads7846.h>
 #include <linux/spi/pxa2xx_spi.h>
 #include <linux/mtd/sharpsl.h>
+#include <linux/memblock.h>
 
 #include <mach/hardware.h>
 #include <asm/mach-types.h>
@@ -456,13 +457,10 @@ static void __init poodle_init(void)
 	poodle_init_spi();
 }
 
-static void __init fixup_poodle(struct tag *tags, char **cmdline,
-				struct meminfo *mi)
+static void __init fixup_poodle(struct tag *tags, char **cmdline)
 {
 	sharpsl_save_param();
-	mi->nr_banks=1;
-	mi->bank[0].start = 0xa0000000;
-	mi->bank[0].size = (32*1024*1024);
+	memblock_add(0xa0000000, SZ_32M);
 }
 
 MACHINE_START(POODLE, "SHARP Poodle")
diff --git a/arch/arm/mach-pxa/spitz.c b/arch/arm/mach-pxa/spitz.c
index 0b11c1a..840c3a4 100644
--- a/arch/arm/mach-pxa/spitz.c
+++ b/arch/arm/mach-pxa/spitz.c
@@ -32,6 +32,7 @@
 #include <linux/io.h>
 #include <linux/module.h>
 #include <linux/reboot.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <asm/mach-types.h>
@@ -971,13 +972,10 @@ static void __init spitz_init(void)
 	spitz_i2c_init();
 }
 
-static void __init spitz_fixup(struct tag *tags, char **cmdline,
-			       struct meminfo *mi)
+static void __init spitz_fixup(struct tag *tags, char **cmdline)
 {
 	sharpsl_save_param();
-	mi->nr_banks = 1;
-	mi->bank[0].start = 0xa0000000;
-	mi->bank[0].size = (64*1024*1024);
+	memblock_add(0xa0000000, SZ_64M);
 }
 
 #ifdef CONFIG_MACH_SPITZ
diff --git a/arch/arm/mach-pxa/tosa.c b/arch/arm/mach-pxa/tosa.c
index ef5557b..c158a6e 100644
--- a/arch/arm/mach-pxa/tosa.c
+++ b/arch/arm/mach-pxa/tosa.c
@@ -37,6 +37,7 @@
 #include <linux/i2c/pxa-i2c.h>
 #include <linux/usb/gpio_vbus.h>
 #include <linux/reboot.h>
+#include <linux/memblock.h>
 
 #include <asm/setup.h>
 #include <asm/mach-types.h>
@@ -960,13 +961,10 @@ static void __init tosa_init(void)
 	platform_add_devices(devices, ARRAY_SIZE(devices));
 }
 
-static void __init fixup_tosa(struct tag *tags, char **cmdline,
-			      struct meminfo *mi)
+static void __init fixup_tosa(struct tag *tags, char **cmdline)
 {
 	sharpsl_save_param();
-	mi->nr_banks=1;
-	mi->bank[0].start = 0xa0000000;
-	mi->bank[0].size = (64*1024*1024);
+	memblock_add(0xa0000000, SZ_64M);
 }
 
 MACHINE_START(TOSA, "SHARP Tosa")
diff --git a/arch/arm/mach-realview/core.c b/arch/arm/mach-realview/core.c
index 1d5ee5c..c2fae3a 100644
--- a/arch/arm/mach-realview/core.c
+++ b/arch/arm/mach-realview/core.c
@@ -31,6 +31,7 @@
 #include <linux/amba/mmci.h>
 #include <linux/gfp.h>
 #include <linux/mtd/physmap.h>
+#include <linux/memblock.h>
 
 #include <mach/hardware.h>
 #include <asm/irq.h>
@@ -370,19 +371,15 @@ void __init realview_timer_init(unsigned int timer_irq)
 /*
  * Setup the memory banks.
  */
-void realview_fixup(struct tag *tags, char **from, struct meminfo *meminfo)
+void realview_fixup(struct tag *tags, char **from)
 {
 	/*
 	 * Most RealView platforms have 512MB contiguous RAM at 0x70000000.
 	 * Half of this is mirrored at 0.
 	 */
 #ifdef CONFIG_REALVIEW_HIGH_PHYS_OFFSET
-	meminfo->bank[0].start = 0x70000000;
-	meminfo->bank[0].size = SZ_512M;
-	meminfo->nr_banks = 1;
+	memblock_add(0x70000000, SZ_512M);
 #else
-	meminfo->bank[0].start = 0;
-	meminfo->bank[0].size = SZ_256M;
-	meminfo->nr_banks = 1;
+	memblock_add(0, SZ_256M);
 #endif
 }
diff --git a/arch/arm/mach-realview/core.h b/arch/arm/mach-realview/core.h
index 602ca5e..844946d 100644
--- a/arch/arm/mach-realview/core.h
+++ b/arch/arm/mach-realview/core.h
@@ -51,8 +51,7 @@ extern int realview_flash_register(struct resource *res, u32 num);
 extern int realview_eth_register(const char *name, struct resource *res);
 extern int realview_usb_register(struct resource *res);
 extern void realview_init_early(void);
-extern void realview_fixup(struct tag *tags, char **from,
-			   struct meminfo *meminfo);
+extern void realview_fixup(struct tag *tags, char **from);
 
 extern struct smp_operations realview_smp_ops;
 extern void realview_cpu_die(unsigned int cpu);
diff --git a/arch/arm/mach-realview/realview_pb1176.c b/arch/arm/mach-realview/realview_pb1176.c
index c5eade7..6abf6a0 100644
--- a/arch/arm/mach-realview/realview_pb1176.c
+++ b/arch/arm/mach-realview/realview_pb1176.c
@@ -32,6 +32,7 @@
 #include <linux/irqchip/arm-gic.h>
 #include <linux/platform_data/clk-realview.h>
 #include <linux/reboot.h>
+#include <linux/memblock.h>
 
 #include <mach/hardware.h>
 #include <asm/irq.h>
@@ -339,15 +340,12 @@ static void realview_pb1176_restart(enum reboot_mode mode, const char *cmd)
 	dsb();
 }
 
-static void realview_pb1176_fixup(struct tag *tags, char **from,
-				  struct meminfo *meminfo)
+static void realview_pb1176_fixup(struct tag *tags, char **from)
 {
 	/*
 	 * RealView PB1176 only has 128MB of RAM mapped at 0.
 	 */
-	meminfo->bank[0].start = 0;
-	meminfo->bank[0].size = SZ_128M;
-	meminfo->nr_banks = 1;
+	memblock_add(0, SZ_128M);
 }
 
 static void __init realview_pb1176_init(void)
diff --git a/arch/arm/mach-realview/realview_pbx.c b/arch/arm/mach-realview/realview_pbx.c
index 9d75493..60d322a 100644
--- a/arch/arm/mach-realview/realview_pbx.c
+++ b/arch/arm/mach-realview/realview_pbx.c
@@ -29,6 +29,7 @@
 #include <linux/irqchip/arm-gic.h>
 #include <linux/platform_data/clk-realview.h>
 #include <linux/reboot.h>
+#include <linux/memblock.h>
 
 #include <asm/irq.h>
 #include <asm/mach-types.h>
@@ -325,23 +326,19 @@ static void __init realview_pbx_timer_init(void)
 	realview_pbx_twd_init();
 }
 
-static void realview_pbx_fixup(struct tag *tags, char **from,
-			       struct meminfo *meminfo)
+static void realview_pbx_fixup(struct tag *tags, char **from)
 {
 #ifdef CONFIG_SPARSEMEM
 	/*
 	 * Memory configuration with SPARSEMEM enabled on RealView PBX (see
 	 * asm/mach/memory.h for more information).
 	 */
-	meminfo->bank[0].start = 0;
-	meminfo->bank[0].size = SZ_256M;
-	meminfo->bank[1].start = 0x20000000;
-	meminfo->bank[1].size = SZ_512M;
-	meminfo->bank[2].start = 0x80000000;
-	meminfo->bank[2].size = SZ_256M;
-	meminfo->nr_banks = 3;
+
+	memblock_add(0, SZ_256M);
+	memblock_add(0x20000000, SZ_512M);
+	memblock_add(0x80000000, SZ_256M);
 #else
-	realview_fixup(tags, from, meminfo);
+	realview_fixup(tags, from);
 #endif
 }
 
diff --git a/arch/arm/mach-s3c24xx/mach-smdk2413.c b/arch/arm/mach-s3c24xx/mach-smdk2413.c
index 233fe52..a03c855 100644
--- a/arch/arm/mach-s3c24xx/mach-smdk2413.c
+++ b/arch/arm/mach-s3c24xx/mach-smdk2413.c
@@ -22,6 +22,7 @@
 #include <linux/serial_s3c.h>
 #include <linux/platform_device.h>
 #include <linux/io.h>
+#include <linux/memblock.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -93,13 +94,10 @@ static struct platform_device *smdk2413_devices[] __initdata = {
 	&s3c2412_device_dma,
 };
 
-static void __init smdk2413_fixup(struct tag *tags, char **cmdline,
-				  struct meminfo *mi)
+static void __init smdk2413_fixup(struct tag *tags, char **cmdline)
 {
 	if (tags != phys_to_virt(S3C2410_SDRAM_PA + 0x100)) {
-		mi->nr_banks=1;
-		mi->bank[0].start = 0x30000000;
-		mi->bank[0].size = SZ_64M;
+		memblock_add(0x30000000, SZ_64M);
 	}
 }
 
diff --git a/arch/arm/mach-s3c24xx/mach-vstms.c b/arch/arm/mach-s3c24xx/mach-vstms.c
index 40868c0..a79af78 100644
--- a/arch/arm/mach-s3c24xx/mach-vstms.c
+++ b/arch/arm/mach-s3c24xx/mach-vstms.c
@@ -23,6 +23,7 @@
 #include <linux/mtd/nand.h>
 #include <linux/mtd/nand_ecc.h>
 #include <linux/mtd/partitions.h>
+#include <linux/memblock.h>
 
 #include <asm/mach/arch.h>
 #include <asm/mach/map.h>
@@ -129,13 +130,10 @@ static struct platform_device *vstms_devices[] __initdata = {
 	&s3c2412_device_dma,
 };
 
-static void __init vstms_fixup(struct tag *tags, char **cmdline,
-			       struct meminfo *mi)
+static void __init vstms_fixup(struct tag *tags, char **cmdline)
 {
 	if (tags != phys_to_virt(S3C2410_SDRAM_PA + 0x100)) {
-		mi->nr_banks=1;
-		mi->bank[0].start = 0x30000000;
-		mi->bank[0].size = SZ_64M;
+		memblock_add(0x30000000, SZ_64M);
 	}
 }
 
diff --git a/arch/arm/mach-sa1100/assabet.c b/arch/arm/mach-sa1100/assabet.c
index 8443a27..7dd894e 100644
--- a/arch/arm/mach-sa1100/assabet.c
+++ b/arch/arm/mach-sa1100/assabet.c
@@ -531,7 +531,7 @@ static void __init get_assabet_scr(void)
 }
 
 static void __init
-fixup_assabet(struct tag *tags, char **cmdline, struct meminfo *mi)
+fixup_assabet(struct tag *tags, char **cmdline)
 {
 	/* This must be done before any call to machine_has_neponset() */
 	map_sa1100_gpio_regs();
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 42fc139..ba754b0 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -81,24 +81,21 @@ __tagtable(ATAG_INITRD2, parse_tag_initrd2);
  * initialization functions, as well as show_mem() for the skipping
  * of holes in the memory map.  It is populated by arm_add_memory().
  */
-struct meminfo meminfo;
-
 void show_mem(unsigned int filter)
 {
 	int free = 0, total = 0, reserved = 0;
-	int shared = 0, cached = 0, slab = 0, i;
-	struct meminfo * mi = &meminfo;
+	int shared = 0, cached = 0, slab = 0;
+	struct memblock_region *reg;
 
 	printk("Mem-info:\n");
 	show_free_areas(filter);
 
-	for_each_bank (i, mi) {
-		struct membank *bank = &mi->bank[i];
+	for_each_memblock (memory, reg) {
 		unsigned int pfn1, pfn2;
 		struct page *page, *end;
 
-		pfn1 = bank_pfn_start(bank);
-		pfn2 = bank_pfn_end(bank);
+		pfn1 = memblock_region_memory_base_pfn(reg);
+		pfn2 = memblock_region_memory_end_pfn(reg);
 
 		page = pfn_to_page(pfn1);
 		end  = pfn_to_page(pfn2 - 1) + 1;
@@ -130,16 +127,9 @@ void show_mem(unsigned int filter)
 static void __init find_limits(unsigned long *min, unsigned long *max_low,
 			       unsigned long *max_high)
 {
-	struct meminfo *mi = &meminfo;
-	int i;
-
-	/* This assumes the meminfo array is properly sorted */
-	*min = bank_pfn_start(&mi->bank[0]);
-	for_each_bank (i, mi)
-		if (mi->bank[i].highmem)
-				break;
-	*max_low = bank_pfn_end(&mi->bank[i - 1]);
-	*max_high = bank_pfn_end(&mi->bank[mi->nr_banks - 1]);
+	*max_low = PFN_DOWN(memblock_get_current_limit());
+	*min = PFN_UP(memblock_start_of_DRAM());
+	*max_high = PFN_DOWN(memblock_end_of_DRAM());
 }
 
 #ifdef CONFIG_ZONE_DMA
@@ -275,14 +265,8 @@ phys_addr_t __init arm_memblock_steal(phys_addr_t size, phys_addr_t align)
 	return phys;
 }
 
-void __init arm_memblock_init(struct meminfo *mi,
-	const struct machine_desc *mdesc)
+void __init arm_memblock_init(const struct machine_desc *mdesc)
 {
-	int i;
-
-	for (i = 0; i < mi->nr_banks; i++)
-		memblock_add(mi->bank[i].start, mi->bank[i].size);
-
 	/* Register the kernel text, kernel data and initrd with memblock. */
 #ifdef CONFIG_XIP_KERNEL
 	memblock_reserve(__pa(_sdata), _end - _sdata);
@@ -413,54 +397,53 @@ free_memmap(unsigned long start_pfn, unsigned long end_pfn)
 /*
  * The mem_map array can get very big.  Free the unused area of the memory map.
  */
-static void __init free_unused_memmap(struct meminfo *mi)
+static void __init free_unused_memmap(void)
 {
-	unsigned long bank_start, prev_bank_end = 0;
-	unsigned int i;
+	unsigned long start, prev_end = 0;
+	struct memblock_region *reg;
 
 	/*
 	 * This relies on each bank being in address order.
 	 * The banks are sorted previously in bootmem_init().
 	 */
-	for_each_bank(i, mi) {
-		struct membank *bank = &mi->bank[i];
-
-		bank_start = bank_pfn_start(bank);
+	for_each_memblock(memory, reg) {
+		start = memblock_region_memory_base_pfn(reg);
 
 #ifdef CONFIG_SPARSEMEM
 		/*
 		 * Take care not to free memmap entries that don't exist
 		 * due to SPARSEMEM sections which aren't present.
 		 */
-		bank_start = min(bank_start,
-				 ALIGN(prev_bank_end, PAGES_PER_SECTION));
+		start = min(start,
+				 ALIGN(prev_end, PAGES_PER_SECTION));
 #else
 		/*
 		 * Align down here since the VM subsystem insists that the
 		 * memmap entries are valid from the bank start aligned to
 		 * MAX_ORDER_NR_PAGES.
 		 */
-		bank_start = round_down(bank_start, MAX_ORDER_NR_PAGES);
+		start = round_down(start, MAX_ORDER_NR_PAGES);
 #endif
 		/*
 		 * If we had a previous bank, and there is a space
 		 * between the current bank and the previous, free it.
 		 */
-		if (prev_bank_end && prev_bank_end < bank_start)
-			free_memmap(prev_bank_end, bank_start);
+		if (prev_end && prev_end < start)
+			free_memmap(prev_end, start);
 
 		/*
 		 * Align up here since the VM subsystem insists that the
 		 * memmap entries are valid from the bank end aligned to
 		 * MAX_ORDER_NR_PAGES.
 		 */
-		prev_bank_end = ALIGN(bank_pfn_end(bank), MAX_ORDER_NR_PAGES);
+		prev_end = ALIGN(memblock_region_memory_end_pfn(reg),
+				 MAX_ORDER_NR_PAGES);
 	}
 
 #ifdef CONFIG_SPARSEMEM
-	if (!IS_ALIGNED(prev_bank_end, PAGES_PER_SECTION))
-		free_memmap(prev_bank_end,
-			    ALIGN(prev_bank_end, PAGES_PER_SECTION));
+	if (!IS_ALIGNED(prev_end, PAGES_PER_SECTION))
+		free_memmap(prev_end,
+			    ALIGN(prev_end, PAGES_PER_SECTION));
 #endif
 }
 
@@ -536,7 +519,7 @@ void __init mem_init(void)
 	set_max_mapnr(pfn_to_page(max_pfn) - mem_map);
 
 	/* this will put all unused low memory onto the freelists */
-	free_unused_memmap(&meminfo);
+	free_unused_memmap();
 	free_all_bootmem();
 
 #ifdef CONFIG_SA1111
diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index b68c6b2..c3ae96c 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1061,74 +1061,44 @@ phys_addr_t arm_lowmem_limit __initdata = 0;
 void __init sanity_check_meminfo(void)
 {
 	phys_addr_t memblock_limit = 0;
-	int i, j, highmem = 0;
+	int highmem = 0;
 	phys_addr_t vmalloc_limit = __pa(vmalloc_min - 1) + 1;
+	struct memblock_region *reg;
 
-	for (i = 0, j = 0; i < meminfo.nr_banks; i++) {
-		struct membank *bank = &meminfo.bank[j];
-		phys_addr_t size_limit;
-
-		*bank = meminfo.bank[i];
-		size_limit = bank->size;
+	for_each_memblock(memory, reg) {
+		phys_addr_t block_start = reg->base;
+		phys_addr_t block_end = reg->base + reg->size;
+		phys_addr_t size_limit = reg->size;
 
-		if (bank->start >= vmalloc_limit)
+		if (reg->base >= vmalloc_limit)
 			highmem = 1;
 		else
-			size_limit = vmalloc_limit - bank->start;
+			size_limit = vmalloc_limit - reg->base;
 
-		bank->highmem = highmem;
 
-#ifdef CONFIG_HIGHMEM
-		/*
-		 * Split those memory banks which are partially overlapping
-		 * the vmalloc area greatly simplifying things later.
-		 */
-		if (!highmem && bank->size > size_limit) {
-			if (meminfo.nr_banks >= NR_BANKS) {
-				printk(KERN_CRIT "NR_BANKS too low, "
-						 "ignoring high memory\n");
-			} else {
-				memmove(bank + 1, bank,
-					(meminfo.nr_banks - i) * sizeof(*bank));
-				meminfo.nr_banks++;
-				i++;
-				bank[1].size -= size_limit;
-				bank[1].start = vmalloc_limit;
-				bank[1].highmem = highmem = 1;
-				j++;
+		if (!IS_ENABLED(CONFIG_HIGHMEM) || cache_is_vipt_aliasing()) {
+
+			if (highmem) {
+				pr_notice("Ignoring RAM at %pa-%pa (!CONFIG_HIGHMEM)\n",
+					&block_start, &block_end);
+				memblock_remove(reg->base, reg->size);
+				continue;
 			}
-			bank->size = size_limit;
-		}
-#else
-		/*
-		 * Highmem banks not allowed with !CONFIG_HIGHMEM.
-		 */
-		if (highmem) {
-			printk(KERN_NOTICE "Ignoring RAM at %.8llx-%.8llx "
-			       "(!CONFIG_HIGHMEM).\n",
-			       (unsigned long long)bank->start,
-			       (unsigned long long)bank->start + bank->size - 1);
-			continue;
-		}
 
-		/*
-		 * Check whether this memory bank would partially overlap
-		 * the vmalloc area.
-		 */
-		if (bank->size > size_limit) {
-			printk(KERN_NOTICE "Truncating RAM at %.8llx-%.8llx "
-			       "to -%.8llx (vmalloc region overlap).\n",
-			       (unsigned long long)bank->start,
-			       (unsigned long long)bank->start + bank->size - 1,
-			       (unsigned long long)bank->start + size_limit - 1);
-			bank->size = size_limit;
+			if (reg->size > size_limit) {
+				phys_addr_t overlap_size = reg->size - size_limit;
+
+				pr_notice("Truncating RAM at %pa-%pa to -%pa",
+				      &block_start, &block_end, &vmalloc_limit);
+				memblock_remove(vmalloc_limit, overlap_size);
+				block_end = vmalloc_limit;
+			}
 		}
-#endif
-		if (!bank->highmem) {
-			phys_addr_t bank_end = bank->start + bank->size;
 
-			if (bank_end > arm_lowmem_limit)
-				arm_lowmem_limit = bank_end;
+		if (!highmem) {
+			if (block_end > arm_lowmem_limit)
+				arm_lowmem_limit = block_end;
+
 
 			/*
 			 * Find the first non-section-aligned page, and point
@@ -1144,35 +1114,16 @@ void __init sanity_check_meminfo(void)
 			 * occurs before any free memory is mapped.
 			 */
 			if (!memblock_limit) {
-				if (!IS_ALIGNED(bank->start, SECTION_SIZE))
-					memblock_limit = bank->start;
-				else if (!IS_ALIGNED(bank_end, SECTION_SIZE))
-					memblock_limit = bank_end;
+				if (!IS_ALIGNED(block_start, SECTION_SIZE))
+					memblock_limit = block_start;
+				else if (!IS_ALIGNED(block_end, SECTION_SIZE))
+					memblock_limit = block_end;
 			}
-		}
-		j++;
-	}
-#ifdef CONFIG_HIGHMEM
-	if (highmem) {
-		const char *reason = NULL;
 
-		if (cache_is_vipt_aliasing()) {
-			/*
-			 * Interactions between kmap and other mappings
-			 * make highmem support with aliasing VIPT caches
-			 * rather difficult.
-			 */
-			reason = "with VIPT aliasing cache";
-		}
-		if (reason) {
-			printk(KERN_CRIT "HIGHMEM is not supported %s, ignoring high memory\n",
-				reason);
-			while (j > 0 && meminfo.bank[j - 1].highmem)
-				j--;
 		}
+
 	}
-#endif
-	meminfo.nr_banks = j;
+
 	high_memory = __va(arm_lowmem_limit - 1) + 1;
 
 	/*
diff --git a/arch/arm/mm/nommu.c b/arch/arm/mm/nommu.c
index 55764a7..da1874f 100644
--- a/arch/arm/mm/nommu.c
+++ b/arch/arm/mm/nommu.c
@@ -88,30 +88,35 @@ static unsigned long irbar_read(void)
 void __init sanity_check_meminfo_mpu(void)
 {
 	int i;
-	struct membank *bank = meminfo.bank;
 	phys_addr_t phys_offset = PHYS_OFFSET;
 	phys_addr_t aligned_region_size, specified_mem_size, rounded_mem_size;
-
-	/* Initially only use memory continuous from PHYS_OFFSET */
-	if (bank_phys_start(&bank[0]) != phys_offset)
-		panic("First memory bank must be contiguous from PHYS_OFFSET");
-
-	/* Banks have already been sorted by start address */
-	for (i = 1; i < meminfo.nr_banks; i++) {
-		if (bank[i].start <= bank_phys_end(&bank[0]) &&
-		    bank_phys_end(&bank[i]) > bank_phys_end(&bank[0])) {
-			bank[0].size = bank_phys_end(&bank[i]) - bank[0].start;
+	struct memblock_region *reg;
+	bool first = true;
+	phys_addr_t mem_start;
+	phys_addr_t mem_end;
+
+	for_each_memblock(memory, reg) {
+		if (first) {
+			/*
+			 * Initially only use memory continuous from
+			 * PHYS_OFFSET */
+			if (reg->base != phys_offset)
+				panic("First memory bank must be contiguous from PHYS_OFFSET");
+
+			mem_start = reg->base;
+			mem_end = reg->base + reg->size;
+			specified_mem_size = reg->size;
+			first = false;
 		} else {
-			pr_notice("Ignoring RAM after 0x%.8lx. "
-			"First non-contiguous (ignored) bank start: 0x%.8lx\n",
-				(unsigned long)bank_phys_end(&bank[0]),
-				(unsigned long)bank_phys_start(&bank[i]));
-			break;
+			/*
+			 * memblock auto merges contiguous blocks, remove
+			 * all blocks afterwards
+			 */
+			pr_notice("Ignoring RAM after %pa, memory at %pa ignored\n",
+				  &mem_start, &reg->base);
+			memblock_remove(reg->base, reg->size);
 		}
 	}
-	/* All contiguous banks are now merged in to the first bank */
-	meminfo.nr_banks = 1;
-	specified_mem_size = bank[0].size;
 
 	/*
 	 * MPU has curious alignment requirements: Size must be power of 2, and
@@ -128,23 +133,24 @@ void __init sanity_check_meminfo_mpu(void)
 	 */
 	aligned_region_size = (phys_offset - 1) ^ (phys_offset);
 	/* Find the max power-of-two sized region that fits inside our bank */
-	rounded_mem_size = (1 <<  __fls(bank[0].size)) - 1;
+	rounded_mem_size = (1 <<  __fls(specified_mem_size)) - 1;
 
 	/* The actual region size is the smaller of the two */
 	aligned_region_size = aligned_region_size < rounded_mem_size
 				? aligned_region_size + 1
 				: rounded_mem_size + 1;
 
-	if (aligned_region_size != specified_mem_size)
-		pr_warn("Truncating memory from 0x%.8lx to 0x%.8lx (MPU region constraints)",
-				(unsigned long)specified_mem_size,
-				(unsigned long)aligned_region_size);
+	if (aligned_region_size != specified_mem_size) {
+		pr_warn("Truncating memory from %pa to %pa (MPU region constraints)",
+				&specified_mem_size, &aligned_region_size);
+		memblock_remove(mem_start + aligned_region_size,
+				specified_mem_size - aligned_round_size);
+
+		mem_end = mem_start + aligned_region_size;
+	}
 
-	meminfo.bank[0].size = aligned_region_size;
-	pr_debug("MPU Region from 0x%.8lx size 0x%.8lx (end 0x%.8lx))\n",
-		(unsigned long)phys_offset,
-		(unsigned long)aligned_region_size,
-		(unsigned long)bank_phys_end(&bank[0]));
+	pr_debug("MPU Region from %pa size %pa (end %pa))\n",
+		&phys_offset, &aligned_region_size, &mem_end);
 
 }
 
@@ -292,7 +298,7 @@ void __init sanity_check_meminfo(void)
 {
 	phys_addr_t end;
 	sanity_check_meminfo_mpu();
-	end = bank_phys_end(&meminfo.bank[meminfo.nr_banks - 1]);
+	end = memblock_end_of_DRAM();
 	high_memory = __va(end - 1) + 1;
 }
 
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
