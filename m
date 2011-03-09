Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 863958D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 07:45:06 -0500 (EST)
From: <johan.xx.mossberg@stericsson.com>
Subject: [PATCHv2 3/3] hwmem: Add hwmem to ux500
Date: Wed, 9 Mar 2011 13:18:53 +0100
Message-ID: <1299673133-26464-4-git-send-email-johan.xx.mossberg@stericsson.com>
In-Reply-To: <1299673133-26464-1-git-send-email-johan.xx.mossberg@stericsson.com>
References: <1299673133-26464-1-git-send-email-johan.xx.mossberg@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: johan.xx.mossberg@stericsson.com, linux-mm@kvack.org, linaro-dev@lists.linaro.org, linux-media@vger.kernel.org
Cc: gstreamer-devel@lists.freedesktop.org, m.nazarewicz@samsung.com

Signed-off-by: Johan Mossberg <johan.xx.mossberg@stericsson.com>
---
 arch/arm/mach-ux500/Makefile               |    2 +-
 arch/arm/mach-ux500/board-mop500.c         |    1 +
 arch/arm/mach-ux500/dcache.c               |  266 ++++++++++++++++++++++++++++
 arch/arm/mach-ux500/devices.c              |   31 ++++
 arch/arm/mach-ux500/include/mach/dcache.h  |   26 +++
 arch/arm/mach-ux500/include/mach/devices.h |    1 +
 6 files changed, 326 insertions(+), 1 deletions(-)
 create mode 100644 arch/arm/mach-ux500/dcache.c
 create mode 100644 arch/arm/mach-ux500/include/mach/dcache.h

diff --git a/arch/arm/mach-ux500/Makefile b/arch/arm/mach-ux500/Makefile
index b549a8f..b8f02aa 100644
--- a/arch/arm/mach-ux500/Makefile
+++ b/arch/arm/mach-ux500/Makefile
@@ -3,7 +3,7 @@
 #
 
 obj-y				:= clock.o cpu.o devices.o devices-common.o \
-				   id.o usb.o
+				   id.o usb.o dcache.o
 obj-$(CONFIG_UX500_SOC_DB5500)	+= cpu-db5500.o dma-db5500.o
 obj-$(CONFIG_UX500_SOC_DB8500)	+= cpu-db8500.o devices-db8500.o prcmu.o
 obj-$(CONFIG_MACH_U8500)	+= board-mop500.o board-mop500-sdi.o \
diff --git a/arch/arm/mach-ux500/board-mop500.c b/arch/arm/mach-ux500/board-mop500.c
index 648da5a..3003b65 100644
--- a/arch/arm/mach-ux500/board-mop500.c
+++ b/arch/arm/mach-ux500/board-mop500.c
@@ -248,6 +248,7 @@ static void mop500_prox_deactivate(struct device *dev)
 /* add any platform devices here - TODO */
 static struct platform_device *platform_devs[] __initdata = {
 	&mop500_gpio_keys_device,
+	&ux500_hwmem_device,
 };
 
 #ifdef CONFIG_STE_DMA40
diff --git a/arch/arm/mach-ux500/dcache.c b/arch/arm/mach-ux500/dcache.c
new file mode 100644
index 0000000..314e78b
--- /dev/null
+++ b/arch/arm/mach-ux500/dcache.c
@@ -0,0 +1,266 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ *
+ * Cache handler integration and data cache helpers.
+ *
+ * Author: Johan Mossberg <johan.xx.mossberg@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+#include <linux/hwmem.h>
+#include <linux/dma-mapping.h>
+
+#include <asm/pgtable.h>
+#include <asm/cacheflush.h>
+#include <asm/outercache.h>
+#include <asm/system.h>
+
+/*
+ * Values are derived from measurements on HREFP_1.1_V32_OM_S10 running
+ * u8500-android-2.2_r1.1_v0.21.
+ *
+ * A lot of time can be spent trying to figure out the perfect breakpoints but
+ * for now I've chosen the following simple way.
+ *
+ * breakpoint = best_case + (worst_case - best_case) * 0.666
+ * The breakpoint is moved slightly towards the worst case because a full
+ * clean/flush affects the entire system so we should be a bit careful.
+ *
+ * BEST CASE:
+ * Best case is that the cache is empty and the system is idling. The case
+ * where the cache contains only targeted data could be better in some cases
+ * but it's hard to do measurements and calculate on that case so I choose the
+ * easier alternative.
+ *
+ * outer_clean_breakpoint = time_2_range_clean_on_empty_cache(
+ *					complete_clean_on_empty_cache_time)
+ * outer_flush_breakpoint = time_2_range_flush_on_empty_cache(
+ *					complete_flush_on_empty_cache_time)
+ *
+ * WORST CASE:
+ * Worst case is that the cache is filled with dirty non targeted data that
+ * will be used after the synchronization and the system is under heavy load.
+ *
+ * outer_clean_breakpoint = time_2_range_clean_on_empty_cache(
+ *					complete_clean_on_full_cache_time +
+ *					(complete_clean_on_full_cache_time -
+ *					complete_clean_on_empty_cache_time))
+ * Plus "(complete_flush_on_full_cache_time -
+ * complete_flush_on_empty_cache_time)" because no one else can work when we
+ * hog the bus with our unecessary transfer.
+ * outer_flush_breakpoint = time_2_range_flush_on_empty_cache(
+ *					complete_flush_on_full_cache_time * 2 +
+ *					(complete_flush_on_full_cache_time -
+ *				complete_flush_on_empty_cache_time) * 2)
+ *
+ * These values might have to be updated if changes are made to the CPU, L2$,
+ * memory bus or memory.
+ */
+/* 254069 */
+static const u32 outer_clean_breakpoint = 68041 + (347363 - 68041) * 0.666;
+/* 485414 */
+static const u32 outer_flush_breakpoint = 68041 + (694727 - 68041) * 0.666;
+
+static bool is_cache_exclusive(void);
+
+enum hwmem_alloc_flags cachi_get_cache_settings(
+			enum hwmem_alloc_flags requested_cache_settings)
+{
+	static const u32 CACHE_ON_FLAGS_MASK = HWMEM_ALLOC_HINT_CACHED |
+		HWMEM_ALLOC_HINT_CACHE_WB | HWMEM_ALLOC_HINT_CACHE_WT |
+		HWMEM_ALLOC_HINT_CACHE_NAOW | HWMEM_ALLOC_HINT_CACHE_AOW |
+				HWMEM_ALLOC_HINT_INNER_AND_OUTER_CACHE |
+					HWMEM_ALLOC_HINT_INNER_CACHE_ONLY;
+
+	enum hwmem_alloc_flags cache_settings;
+
+	if (!(requested_cache_settings & CACHE_ON_FLAGS_MASK) &&
+		requested_cache_settings & (HWMEM_ALLOC_HINT_NO_WRITE_COMBINE |
+		HWMEM_ALLOC_HINT_UNCACHED | HWMEM_ALLOC_HINT_WRITE_COMBINE))
+		/*
+		 * We never use uncached as it's extremely slow and there is
+		 * no scenario where it would be better than buffered memory.
+		 */
+		return HWMEM_ALLOC_HINT_WRITE_COMBINE;
+
+	/*
+	 * The user has specified cached or nothing at all, both are treated as
+	 * cached.
+	 */
+	cache_settings = (requested_cache_settings &
+		 ~(HWMEM_ALLOC_HINT_UNCACHED |
+		HWMEM_ALLOC_HINT_NO_WRITE_COMBINE |
+		HWMEM_ALLOC_HINT_INNER_CACHE_ONLY |
+		HWMEM_ALLOC_HINT_CACHE_NAOW)) |
+		HWMEM_ALLOC_HINT_WRITE_COMBINE | HWMEM_ALLOC_HINT_CACHED |
+		HWMEM_ALLOC_HINT_CACHE_AOW |
+		HWMEM_ALLOC_HINT_INNER_AND_OUTER_CACHE;
+	if (!(cache_settings & (HWMEM_ALLOC_HINT_CACHE_WB |
+						HWMEM_ALLOC_HINT_CACHE_WT)))
+		cache_settings |= HWMEM_ALLOC_HINT_CACHE_WB;
+	/*
+	 * On ARMv7 "alloc on write" is just a hint so we need to assume the
+	 * worst case ie "alloc on write". We would however like to remember
+	 * the requested "alloc on write" setting so that we can pass it on to
+	 * the hardware, we use the reserved bit in the alloc flags to do that.
+	 */
+	if (requested_cache_settings & HWMEM_ALLOC_HINT_CACHE_AOW)
+		cache_settings |= HWMEM_ALLOC_RESERVED_CHI;
+	else
+		cache_settings &= ~HWMEM_ALLOC_RESERVED_CHI;
+
+	return cache_settings;
+}
+
+void cachi_set_pgprot_cache_options(enum hwmem_alloc_flags cache_settings,
+							pgprot_t *pgprot)
+{
+	if (cache_settings & HWMEM_ALLOC_HINT_CACHED) {
+		if (cache_settings & HWMEM_ALLOC_HINT_CACHE_WT)
+			*pgprot = __pgprot_modify(*pgprot, L_PTE_MT_MASK,
+							L_PTE_MT_WRITETHROUGH);
+		else {
+			if (cache_settings & HWMEM_ALLOC_RESERVED_CHI)
+				*pgprot = __pgprot_modify(*pgprot,
+					L_PTE_MT_MASK, L_PTE_MT_WRITEALLOC);
+			else
+				*pgprot = __pgprot_modify(*pgprot,
+					L_PTE_MT_MASK, L_PTE_MT_WRITEBACK);
+		}
+	} else {
+		*pgprot = pgprot_writecombine(*pgprot);
+	}
+}
+
+void drain_cpu_write_buf(void)
+{
+	dsb();
+	outer_cache.sync();
+}
+
+void clean_cpu_dcache(void *vaddr, u32 paddr, u32 length, bool inner_only,
+						bool *cleaned_everything)
+{
+	/*
+	 * There is no problem with exclusive caches here as the Cortex-A9
+	 * documentation (8.1.4. Exclusive L2 cache) says that when a dirty
+	 * line is moved from L2 to L1 it is first written to mem. Because
+	 * of this there is no way a line can avoid the clean by jumping
+	 * between the cache levels.
+	 */
+	*cleaned_everything = true;
+
+	/* Inner clean range */
+	dmac_map_area(vaddr, length, DMA_TO_DEVICE);
+	*cleaned_everything = false;
+
+	if (!inner_only) {
+		/*
+		 * There is currently no outer_cache.clean_all() so we use
+		 * flush instead, which is ok as clean is a subset of flush.
+		 * Clean range and flush range take the same amount of time
+		 * so we can use outer_flush_breakpoint here.
+		 */
+		if (length < outer_flush_breakpoint) {
+			outer_cache.clean_range(paddr, paddr + length);
+			*cleaned_everything = false;
+		} else {
+			outer_cache.flush_all();
+		}
+	}
+}
+
+void flush_cpu_dcache(void *vaddr, u32 paddr, u32 length, bool inner_only,
+						bool *flushed_everything)
+{
+	/*
+	 * There might still be stale data in the caches after this call if the
+	 * cache levels are exclusive. The follwing can happen.
+	 * 1. Clean L1 moves the data to L2.
+	 * 2. Speculative prefetch, preemption or loads on the other core moves
+	 * all the data back to L1, any dirty data will be written to mem as a
+	 * result of this.
+	 * 3. Flush L2 does nothing as there is no targeted data in L2.
+	 * 4. Flush L1 moves the data to L2. Notice that this does not happen
+	 * when the cache levels are non-exclusive as clean pages are not
+	 * written to L2 in that case.
+	 * 5. Stale data is still present in L2!
+	 * I see two possible solutions, don't use exclusive caches or
+	 * (temporarily) disable prefetching to L1, preeemption and the other
+	 * core.
+	 *
+	 * A situation can occur where the operation does not seem atomic from
+	 * the other core's point of view, even on a non-exclusive cache setup.
+	 * Replace step 2 in the previous scenarion with a write from the other
+	 * core. The other core will write on top of the old data but the
+	 * result will not be written to memory. One would expect either that
+	 * the write was performed on top of the old data and was written to
+	 * memory (the write occured before the flush) or that the write was
+	 * performed on top of the new data and was not written to memory (the
+	 * write occured after the flush). The same problem can occur with one
+	 * core if kernel preemption is enabled. The solution is to
+	 * (temporarily) disable the other core and preemption. I can't think
+	 * of any situation where this would be a problem and disabling the
+	 * other core for the duration of this call is mighty expensive so for
+	 * now I just ignore the problem.
+	 */
+
+	*flushed_everything = true;
+
+	if (!inner_only) {
+		/*
+		 * Beautiful solution for the exclusive problems :)
+		 */
+		if (is_cache_exclusive())
+			panic("%s can't handle exclusive CPU caches\n",
+								__func__);
+
+		/* Inner clean range */
+		dmac_map_area(vaddr, length, DMA_TO_DEVICE);
+		*flushed_everything = false;
+
+		if (length < outer_flush_breakpoint) {
+			outer_cache.flush_range(paddr, paddr + length);
+			*flushed_everything = false;
+		} else {
+			outer_cache.flush_all();
+		}
+	}
+
+	/* Inner flush range */
+	dmac_flush_range(vaddr, (void *)((u32)vaddr + length));
+	*flushed_everything = false;
+}
+
+bool speculative_data_prefetch(void)
+{
+	return true;
+}
+
+u32 get_dcache_granularity(void)
+{
+	return 32;
+}
+
+/*
+ * Local functions
+ */
+
+static bool is_cache_exclusive(void)
+{
+	static const u32 CA9_ACTLR_EXCL = 0x80;
+
+	u32 armv7_actlr;
+
+	asm (
+		"mrc	p15, 0, %0, c1, c0, 1"
+		: "=r" (armv7_actlr)
+	);
+
+	if (armv7_actlr & CA9_ACTLR_EXCL)
+		return true;
+	else
+		return false;
+}
diff --git a/arch/arm/mach-ux500/devices.c b/arch/arm/mach-ux500/devices.c
index ea0a2f9..2ea8d35 100644
--- a/arch/arm/mach-ux500/devices.c
+++ b/arch/arm/mach-ux500/devices.c
@@ -10,6 +10,7 @@
 #include <linux/interrupt.h>
 #include <linux/io.h>
 #include <linux/amba/bus.h>
+#include <linux/hwmem.h>
 
 #include <mach/hardware.h>
 #include <mach/setup.h>
@@ -23,3 +24,33 @@ void __init amba_add_devices(struct amba_device *devs[], int num)
 		amba_device_register(d, &iomem_resource);
 	}
 }
+
+static struct hwmem_platform_data hwmem_pdata = {
+	.start = 0,
+	.size = 0,
+};
+
+static int __init early_hwmem(char *p)
+{
+	hwmem_pdata.size = memparse(p, &p);
+
+	if (*p != '@')
+		goto no_at;
+
+	hwmem_pdata.start = memparse(p + 1, &p);
+
+	return 0;
+
+no_at:
+	hwmem_pdata.size = 0;
+
+	return -EINVAL;
+}
+early_param("hwmem", early_hwmem);
+
+struct platform_device ux500_hwmem_device = {
+	.name = "hwmem",
+	.dev = {
+		.platform_data = &hwmem_pdata,
+	},
+};
diff --git a/arch/arm/mach-ux500/include/mach/dcache.h b/arch/arm/mach-ux500/include/mach/dcache.h
new file mode 100644
index 0000000..83fe618
--- /dev/null
+++ b/arch/arm/mach-ux500/include/mach/dcache.h
@@ -0,0 +1,26 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2011
+ *
+ * Data cache helpers
+ *
+ * Author: Johan Mossberg <johan.xx.mossberg@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+#ifndef _MACH_UX500_DCACHE_H_
+#define _MACH_UX500_DCACHE_H_
+
+#include <linux/types.h>
+
+void drain_cpu_write_buf(void);
+void clean_cpu_dcache(void *vaddr, u32 paddr, u32 length, bool inner_only,
+						bool *cleaned_everything);
+void flush_cpu_dcache(void *vaddr, u32 paddr, u32 length, bool inner_only,
+						bool *flushed_everything);
+bool speculative_data_prefetch(void);
+/* Returns 1 if no cache is present */
+u32 get_dcache_granularity(void);
+
+#endif /* _MACH_UX500_DCACHE_H_ */
diff --git a/arch/arm/mach-ux500/include/mach/devices.h b/arch/arm/mach-ux500/include/mach/devices.h
index 020b636..d5182e2 100644
--- a/arch/arm/mach-ux500/include/mach/devices.h
+++ b/arch/arm/mach-ux500/include/mach/devices.h
@@ -17,6 +17,7 @@ extern struct amba_device ux500_pl031_device;
 
 extern struct platform_device u8500_dma40_device;
 extern struct platform_device ux500_ske_keypad_device;
+extern struct platform_device ux500_hwmem_device;
 
 void dma40_u8500ed_fixup(void);
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
