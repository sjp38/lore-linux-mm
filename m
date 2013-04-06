Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 041896B014E
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 09:55:54 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id un15so2443228pbc.26
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 06:55:54 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH v4, part3 02/15] mm: enhance free_reserved_area() to support poisoning memory with zero
Date: Sat,  6 Apr 2013 21:54:56 +0800
Message-Id: <1365256509-29024-3-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com>
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
 arch/alpha/kernel/sys_nautilus.c |    2 +-
 arch/alpha/mm/init.c             |    4 ++--
 arch/arm/mm/init.c               |    8 ++++----
 arch/arm64/mm/init.c             |    4 ++--
 arch/avr32/mm/init.c             |    4 ++--
 arch/blackfin/mm/init.c          |    4 ++--
 arch/c6x/mm/init.c               |    4 ++--
 arch/cris/mm/init.c              |    2 +-
 arch/frv/mm/init.c               |    4 ++--
 arch/h8300/mm/init.c             |    4 ++--
 arch/ia64/mm/init.c              |    2 +-
 arch/m32r/mm/init.c              |    4 ++--
 arch/m68k/mm/init.c              |    4 ++--
 arch/microblaze/mm/init.c        |    4 ++--
 arch/openrisc/mm/init.c          |    4 ++--
 arch/parisc/mm/init.c            |    4 ++--
 arch/powerpc/kernel/kvm.c        |    2 +-
 arch/powerpc/mm/mem.c            |    2 +-
 arch/s390/mm/init.c              |    2 +-
 arch/sh/mm/init.c                |    4 ++--
 arch/um/kernel/mem.c             |    2 +-
 arch/unicore32/mm/init.c         |    4 ++--
 arch/xtensa/mm/init.c            |    4 ++--
 include/linux/mm.h               |   11 ++++++-----
 mm/page_alloc.c                  |    2 +-
 25 files changed, 48 insertions(+), 47 deletions(-)

diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index a8b9d66..7f4e7bf 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -234,7 +234,7 @@ nautilus_init_pci(void)
 		memtop = pci_mem;
 	if (memtop > alpha_mv.min_mem_address) {
 		free_reserved_area((unsigned long)__va(alpha_mv.min_mem_address),
-				   (unsigned long)__va(memtop), 0, NULL);
+				   (unsigned long)__va(memtop), -1, NULL);
 		printk("nautilus_init_pci: %ldk freed\n",
 			(memtop - alpha_mv.min_mem_address) >> 10);
 	}
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 0ba85ee..9930837 100644
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
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 7a82fcd..a2ab290 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -601,7 +601,7 @@ void __init mem_init(void)
 #ifdef CONFIG_SA1111
 	/* now that our DMA memory is actually so designated, we can free it */
 	free_reserved_area((unsigned long)__va(PHYS_PFN_OFFSET),
-			   (unsigned long)swapper_pg_dir, 0, NULL);
+			   (unsigned long)swapper_pg_dir, -1, NULL);
 #endif
 
 	free_highpages();
@@ -730,12 +730,12 @@ void free_initmem(void)
 
 	poison_init_mem(&__tcm_start, &__tcm_end - &__tcm_start);
 	free_reserved_area((unsigned long)&__tcm_start,
-			   (unsigned long)&__tcm_end, 0, "TCM link");
+			   (unsigned long)&__tcm_end, -1, "TCM link");
 #endif
 
 	poison_init_mem(__init_begin, __init_end - __init_begin);
 	if (!machine_is_integrator() && !machine_is_cintegrator())
-		free_initmem_default(0);
+		free_initmem_default(-1);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
@@ -746,7 +746,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area(start, end, -1, "initrd");
 	}
 }
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f497ca7..e58dd7f 100644
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
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area(start, end, -1, "initrd");
 	}
 }
 
diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index e66e840..871f98a 100644
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
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
index 82d01a7..e64286b 100644
--- a/arch/blackfin/mm/init.c
+++ b/arch/blackfin/mm/init.c
@@ -133,7 +133,7 @@ void __init mem_init(void)
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
 #ifndef CONFIG_MPU
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
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
index a9fcd89..ce39b48 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -77,11 +77,11 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
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
index dee354f..a421948 100644
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
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 } /* end free_initrd_mem() */
 #endif
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index ff349d7..488e2a3 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -161,7 +161,7 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
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
index d1fe4b4..941568a 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -156,7 +156,7 @@ free_initmem (void)
 {
 	free_reserved_area((unsigned long)ia64_imva(__init_begin),
 			   (unsigned long)ia64_imva(__init_end),
-			   0, "unused kernel");
+			   -1, "unused kernel");
 }
 
 void __init
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index ab4cbce..58ea4d6 100644
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
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 1af2ca3..75e1cbf 100644
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
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 4ec137d..53383e4 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -235,13 +235,13 @@ void __init setup_memory(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
 
 void __init mem_init(void)
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index b3cbc67..d19950c 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -261,11 +261,11 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 157b931..27f3f88 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -532,7 +532,7 @@ void free_initmem(void)
 	 * pages are no-longer executable */
 	flush_icache_range(init_begin, init_end);
 	
-	num_physpages += free_initmem_default(0);
+	num_physpages += free_initmem_default(-1);
 
 	/* set up a new led state on systems shipped LED State panel */
 	pdc_chassis_send_status(PDC_CHASSIS_DIRECT_BCOMPLETE);
@@ -1099,6 +1099,6 @@ void flush_tlb_all(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area(start, end, 0, "initrd");
+	num_physpages += free_reserved_area(start, end, -1, "initrd");
 }
 #endif
diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 6782221..4d3e37d 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -756,7 +756,7 @@ static __init void kvm_free_tmp(void)
 	end = (ulong)&kvm_tmp[ARRAY_SIZE(kvm_tmp)] & PAGE_MASK;
 
 	/* Free the tmp space we don't need */
-	free_reserved_area(start, end, 0, NULL);
+	free_reserved_area(start, end, -1, NULL);
 }
 
 static int __init kvm_guest_init(void)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index cd76c45..2e912ca 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -408,7 +408,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 0b09b23..275345e 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -164,7 +164,7 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(POISON_FREE_INITMEM);
 }
 
 #ifdef CONFIG_BLK_DEV_INITRD
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 20f9ead..31294f1 100644
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
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 9df292b..1e84189 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -244,7 +244,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area(start, end, -1, "initrd");
 }
 #endif
 
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 63df12d..5614b05 100644
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
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area(start, end, -1, "initrd");
 }
 
 static int __init keepinitrd_setup(char *__unused)
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index bba125b..6f70647 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -214,11 +214,11 @@ extern int initrd_is_mapped;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (initrd_is_mapped)
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area(start, end, -1, "initrd");
 }
 #endif
 
 void free_initmem(void)
 {
-	free_initmem_default(0);
+	free_initmem_default(-1);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index da099bc..1f03b0e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1296,7 +1296,7 @@ extern void free_initmem(void);
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
  * into the buddy system. The freed pages will be poisoned with pattern
- * "poison" if it's non-zero.
+ * "poison" if it's within range [0, UCHAR_MAX].
  * Return pages freed into the buddy system.
  */
 extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
@@ -1336,15 +1336,16 @@ static inline void mark_page_reserved(struct page *page)
 
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
 	extern char __init_begin[], __init_end[];
 
-	return free_reserved_area(PAGE_ALIGN((unsigned long)&__init_begin) ,
-				  ((unsigned long)&__init_end) & PAGE_MASK,
+	return free_reserved_area((unsigned long)&__init_begin ,
+				  (unsigned long)&__init_end,
 				  poison, "unused kernel");
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8bf7956..6bd697c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5194,7 +5194,7 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
 	pos = start = PAGE_ALIGN(start);
 	end &= PAGE_MASK;
 	for (pages = 0; pos < end; pos += PAGE_SIZE, pages++) {
-		if (poison)
+		if ((unsigned int)poison <= 0xFF)
 			memset((void *)pos, poison, PAGE_SIZE);
 		free_reserved_page(virt_to_page((void *)pos));
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
