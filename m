Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 5E9E06B0034
	for <linux-mm@kvack.org>; Fri, 17 May 2013 11:45:43 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so3701101pad.37
        for <linux-mm@kvack.org>; Fri, 17 May 2013 08:45:42 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v7, part3 02/16] mm: enhance free_reserved_area() to support poisoning memory with zero
Date: Fri, 17 May 2013 23:45:04 +0800
Message-Id: <1368805518-2634-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
References: <1368805518-2634-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <James.Bottomley@HansenPartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

Address more review comments from last round of code review.
1) Enhance free_reserved_area() to support poisoning freed memory with
   pattern '0'. This could be used to get rid of poison_init_mem()
   on ARM64.
2) A previous patch has disabled memory poison for initmem on s390
   by mistake, so restore to the original behavior.
3) Remove redundant PAGE_ALIGN() when calling free_reserved_area().

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
---
 arch/alpha/kernel/sys_nautilus.c | 2 +-
 arch/alpha/mm/init.c             | 4 ++--
 arch/arc/mm/init.c               | 4 ++--
 arch/arm/mm/init.c               | 8 ++++----
 arch/arm64/mm/init.c             | 4 ++--
 arch/avr32/mm/init.c             | 4 ++--
 arch/blackfin/mm/init.c          | 4 ++--
 arch/c6x/mm/init.c               | 4 ++--
 arch/cris/mm/init.c              | 2 +-
 arch/frv/mm/init.c               | 4 ++--
 arch/h8300/mm/init.c             | 4 ++--
 arch/ia64/mm/init.c              | 2 +-
 arch/m32r/mm/init.c              | 4 ++--
 arch/m68k/mm/init.c              | 4 ++--
 arch/microblaze/mm/init.c        | 4 ++--
 arch/openrisc/mm/init.c          | 4 ++--
 arch/parisc/mm/init.c            | 4 ++--
 arch/powerpc/kernel/kvm.c        | 9 ++-------
 arch/powerpc/mm/mem.c            | 2 +-
 arch/s390/mm/init.c              | 2 +-
 arch/sh/mm/init.c                | 4 ++--
 arch/um/kernel/mem.c             | 2 +-
 arch/unicore32/mm/init.c         | 4 ++--
 arch/xtensa/mm/init.c            | 4 ++--
 include/linux/mm.h               | 7 ++++---
 mm/page_alloc.c                  | 2 +-
 26 files changed, 49 insertions(+), 53 deletions(-)

diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index 891bd27..837c0fa 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -239,7 +239,7 @@ nautilus_init_pci(void)
 		memtop = pci_mem;
 	if (memtop > alpha_mv.min_mem_address) {
 		free_reserved_area(__va(alpha_mv.min_mem_address),
-				   __va(memtop), 0, NULL);
+				   __va(memtop), -1, NULL);
 		printk("nautilus_init_pci: %ldk freed\n",
 			(memtop - alpha_mv.min_mem_address) >> 10);
 	}
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index d54848d..218c29c 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -319,13 +319,13 @@ mem_init(void)
 void
 free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void
 free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index dce02e4..f9c7077 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -146,13 +146,13 @@ void __init mem_init(void)
  */
 void __init_refok free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 59d6f76..f223394 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -600,7 +600,7 @@ void __init mem_init(void)
 
 #ifdef CONFIG_SA1111
 	/* now that our DMA memory is actually so designated, we can free it */
-	free_reserved_area(__va(PHYS_PFN_OFFSET), swapper_pg_dir, 0, NULL);
+	free_reserved_area(__va(PHYS_PFN_OFFSET), swapper_pg_dir, -1, NULL);
 #endif
 
 	free_highpages();
@@ -728,12 +728,12 @@ void free_initmem(void)
 	extern char __tcm_start, __tcm_end;
 
 	poison_init_mem(&__tcm_start, &__tcm_end - &__tcm_start);
-	free_reserved_area(&__tcm_start, &__tcm_end, 0, "TCM link");
+	free_reserved_area(&__tcm_start, &__tcm_end, -1, "TCM link");
 #endif
 
 	poison_init_mem(__init_begin, __init_end - __init_begin);
 	if (!machine_is_integrator() && !machine_is_cintegrator())
-		free_initmem_default(0);
+		free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -744,7 +744,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		free_reserved_area((void *)start, (void *)end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, -1, "initrd");
 	}
 }
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 6041e40..997c634 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -387,7 +387,7 @@ void __init mem_init(void)
 void free_initmem(void)
 {
 	poison_init_mem(__init_begin, __init_end - __init_begin);
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -398,7 +398,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		free_reserved_area((void *)start, (void *)end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, -1, "initrd");
 	}
 }
 
diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index 5a79fa0..b079e04 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -148,12 +148,12 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
index 8e9eab2..fa241f5 100644
--- a/arch/blackfin/mm/init.c
+++ b/arch/blackfin/mm/init.c
@@ -133,7 +133,7 @@ void __init mem_init(void)
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
 #ifndef CONFIG_MPU
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 #endif
 }
 #endif
@@ -141,7 +141,7 @@ void __init free_initrd_mem(unsigned long start, unsigned long end)
 void __init_refok free_initmem(void)
 {
 #if defined CONFIG_RAMKERNEL && !defined CONFIG_MPU
-	free_initmem_default(0);
+	free_initmem_default(-1);
 	if (memory_start == (unsigned long)(&__init_end))
 		memory_start = (unsigned long)(&__init_begin);
 #endif
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index 97914e5..7f25bef 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -77,11 +77,11 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
 void __init free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
diff --git a/arch/cris/mm/init.c b/arch/cris/mm/init.c
index 9ac8094..8fec263 100644
--- a/arch/cris/mm/init.c
+++ b/arch/cris/mm/init.c
@@ -65,5 +65,5 @@ mem_init(void)
 void 
 free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index a67f3a5..8ba9d22 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -162,7 +162,7 @@ void __init mem_init(void)
 void free_initmem(void)
 {
 #if defined(CONFIG_RAMKERNEL) && !defined(CONFIG_PROTECT_KERNEL)
-	free_initmem_default(0);
+	free_initmem_default(-1);
 #endif
 } /* end free_initmem() */
 
@@ -173,6 +173,6 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 } /* end free_initrd_mem() */
 #endif
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 57e03c5..c831f1d 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -161,7 +161,7 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
@@ -169,7 +169,7 @@ void
 free_initmem(void)
 {
 #ifdef CONFIG_RAMKERNEL
-	free_initmem_default(0);
+	free_initmem_default(-1);
 #endif
 }
 
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index da568c2..f8a4f38 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -155,7 +155,7 @@ void
 free_initmem (void)
 {
 	free_reserved_area(ia64_imva(__init_begin), ia64_imva(__init_end),
-			   0, "unused kernel");
+			   -1, "unused kernel");
 }
 
 void __init
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index d80412d..cca87d9 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -181,7 +181,7 @@ void __init mem_init(void)
  *======================================================================*/
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -191,6 +191,6 @@ void free_initmem(void)
  *======================================================================*/
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 95de725..ab0b54c 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -110,7 +110,7 @@ void __init paging_init(void)
 void free_initmem(void)
 {
 #ifndef CONFIG_MMU_SUN3
-	free_initmem_default(0);
+	free_initmem_default(-1);
 #endif /* CONFIG_MMU_SUN3 */
 }
 
@@ -202,6 +202,6 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index d7b8ada..d149e0e 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -235,13 +235,13 @@ void __init setup_memory(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 void __init mem_init(void)
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index ab11332..c371e4a 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -261,11 +261,11 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 59cec60..aaa1fbc 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -532,7 +532,7 @@ void free_initmem(void)
 	 * pages are no-longer executable */
 	flush_icache_range(init_begin, init_end);
 	
-	num_physpages += free_initmem_default(0);
+	num_physpages += free_initmem_default(-1);
 
 	/* set up a new led state on systems shipped LED State panel */
 	pdc_chassis_send_status(PDC_CHASSIS_DIRECT_BCOMPLETE);
@@ -1101,7 +1101,7 @@ void flush_tlb_all(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area((void *)start, (void *)end, 0,
+	num_physpages += free_reserved_area((void *)start, (void *)end, -1,
 					    "initrd");
 }
 #endif
diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 5e4830a..db28032 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -750,13 +750,8 @@ EXPORT_SYMBOL_GPL(kvm_hypercall);
 
 static __init void kvm_free_tmp(void)
 {
-	unsigned long start, end;
-
-	start = (ulong)&kvm_tmp[kvm_tmp_index + (PAGE_SIZE - 1)] & PAGE_MASK;
-	end = (ulong)&kvm_tmp[ARRAY_SIZE(kvm_tmp)] & PAGE_MASK;
-
-	/* Free the tmp space we don't need */
-	free_reserved_area((void *)start, (void *)end, 0, NULL);
+	free_reserved_area(&kvm_tmp[kvm_tmp_index],
+			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
 }
 
 static int __init kvm_guest_init(void)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 347c5b1..7f47a05 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -407,7 +407,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 0878c89..bf01d18 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -166,7 +166,7 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index b892a9b..d3af56b 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -499,13 +499,13 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 2aa7a24..8ff0b7a 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -244,7 +244,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area((void *)start, (void *)end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 220755c..df9b8ab 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -476,7 +476,7 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -486,7 +486,7 @@ static int keep_initrd;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd)
-		free_reserved_area((void *)start, (void *)end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 
 static int __init keepinitrd_setup(char *__unused)
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index 4d658ef..026d29b 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -214,11 +214,11 @@ extern int initrd_is_mapped;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (initrd_is_mapped)
-		free_reserved_area((void *)start, (void *)end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, -1, "initrd");
 }
 #endif
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 771769f..a56bcaa 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1304,7 +1304,7 @@ extern void free_initmem(void);
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
  * into the buddy system. The freed pages will be poisoned with pattern
- * "poison" if it's non-zero.
+ * "poison" if it's within range [0, UCHAR_MAX].
  * Return pages freed into the buddy system.
  */
 extern unsigned long free_reserved_area(void *start, void *end,
@@ -1344,8 +1344,9 @@ static inline void mark_page_reserved(struct page *page)
 
 /*
  * Default method to free all the __init memory into the buddy system.
- * The freed pages will be poisoned with pattern "poison" if it is
- * non-zero. Return pages freed into the buddy system.
+ * The freed pages will be poisoned with pattern "poison" if it's within
+ * range [0, UCHAR_MAX].
+ * Return pages freed into the buddy system.
  */
 static inline unsigned long free_initmem_default(int poison)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9fe3061..13e566a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5196,7 +5196,7 @@ unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
 	start = (void *)PAGE_ALIGN((unsigned long)start);
 	end = (void *)((unsigned long)end & PAGE_MASK);
 	for (pos = start; pos < end; pos += PAGE_SIZE, pages++) {
-		if (poison)
+		if ((unsigned int)poison <= 0xFF)
 			memset(pos, poison, PAGE_SIZE);
 		free_reserved_page(virt_to_page(pos));
 	}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
