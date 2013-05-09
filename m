Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 4E95B6B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 11:44:48 -0400 (EDT)
Received: by mail-da0-f50.google.com with SMTP id i23so1662273dad.9
        for <linux-mm@kvack.org>; Thu, 09 May 2013 08:44:47 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH] mm: change signature of free_reserved_area() to fix building warnings
Date: Thu,  9 May 2013 23:42:00 +0800
Message-Id: <1368114120-21716-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <20130508184555.GR18614@n2100.arm.linux.org.uk>
References: <20130508184555.GR18614@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Change signature of free_reserved_area() according to Russell King's
suggestion to fix following build warnings:

arch/arm/mm/init.c: In function 'mem_init':
arch/arm/mm/init.c:603:2: warning: passing argument 1 of 'free_reserved_area' makes integer from pointer without a cast [enabled by default]
  free_reserved_area(__va(PHYS_PFN_OFFSET), swapper_pg_dir, 0, NULL);
  ^
In file included from include/linux/mman.h:4:0,
                 from arch/arm/mm/init.c:15:
include/linux/mm.h:1301:22: note: expected 'long unsigned int' but argument is of type 'void *'
 extern unsigned long free_reserved_area(unsigned long start, unsigned long end,

   mm/page_alloc.c: In function 'free_reserved_area':
>> mm/page_alloc.c:5134:3: warning: passing argument 1 of 'virt_to_phys' makes pointer from integer without a cast [enabled by default]
   In file included from arch/mips/include/asm/page.h:49:0,
                    from include/linux/mmzone.h:20,
                    from include/linux/gfp.h:4,
                    from include/linux/mm.h:8,
                    from mm/page_alloc.c:18:
   arch/mips/include/asm/io.h:119:29: note: expected 'const volatile void *' but argument is of type 'long unsigned int'
   mm/page_alloc.c: In function 'free_area_init_nodes':
   mm/page_alloc.c:5030:34: warning: array subscript is below array bounds [-Warray-bounds]

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
---
Hi Russell,
	Thanks for your review. How about this change to fix the building
warning by change signature of free_reserved_area()?
	Thanks!
	Gerry
---
 arch/alpha/kernel/sys_nautilus.c |    4 ++--
 arch/alpha/mm/init.c             |    2 +-
 arch/arc/mm/init.c               |    2 +-
 arch/arm/mm/init.c               |    2 +-
 arch/arm64/mm/init.c             |    2 +-
 arch/avr32/mm/init.c             |    2 +-
 arch/blackfin/mm/init.c          |    2 +-
 arch/c6x/mm/init.c               |    2 +-
 arch/frv/mm/init.c               |    2 +-
 arch/h8300/mm/init.c             |    2 +-
 arch/ia64/mm/init.c              |    3 +--
 arch/m32r/mm/init.c              |    2 +-
 arch/m68k/mm/init.c              |    2 +-
 arch/metag/mm/init.c             |    3 ++-
 arch/microblaze/mm/init.c        |    2 +-
 arch/mips/mm/init.c              |    3 ++-
 arch/mn10300/mm/init.c           |    3 ++-
 arch/openrisc/mm/init.c          |    2 +-
 arch/parisc/mm/init.c            |    3 ++-
 arch/powerpc/kernel/kvm.c        |    2 +-
 arch/powerpc/mm/mem.c            |    2 +-
 arch/s390/mm/init.c              |    3 ++-
 arch/score/mm/init.c             |    3 ++-
 arch/sh/mm/init.c                |    2 +-
 arch/sparc/mm/init_32.c          |    4 ++--
 arch/sparc/mm/init_64.c          |    4 ++--
 arch/um/kernel/mem.c             |    2 +-
 arch/unicore32/mm/init.c         |    2 +-
 arch/xtensa/mm/init.c            |    2 +-
 include/linux/mm.h               |    5 ++---
 mm/page_alloc.c                  |   16 ++++++++--------
 31 files changed, 48 insertions(+), 44 deletions(-)

diff --git a/arch/alpha/kernel/sys_nautilus.c b/arch/alpha/kernel/sys_nautilus.c
index 1d4aabf..891bd27 100644
--- a/arch/alpha/kernel/sys_nautilus.c
+++ b/arch/alpha/kernel/sys_nautilus.c
@@ -238,8 +238,8 @@ nautilus_init_pci(void)
 	if (pci_mem < memtop)
 		memtop = pci_mem;
 	if (memtop > alpha_mv.min_mem_address) {
-		free_reserved_area((unsigned long)__va(alpha_mv.min_mem_address),
-				   (unsigned long)__va(memtop), 0, NULL);
+		free_reserved_area(__va(alpha_mv.min_mem_address),
+				   __va(memtop), 0, NULL);
 		printk("nautilus_init_pci: %ldk freed\n",
 			(memtop - alpha_mv.min_mem_address) >> 10);
 	}
diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 0ba85ee..d54848d 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -326,6 +326,6 @@ free_initmem(void)
 void
 free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index 4a17736..dce02e4 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -152,7 +152,7 @@ void __init_refok free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 9a5cdc0..59d6f76 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -744,7 +744,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, 0, "initrd");
 	}
 }
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f497ca7..6041e40 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -398,7 +398,7 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd) {
 		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, 0, "initrd");
 	}
 }
 
diff --git a/arch/avr32/mm/init.c b/arch/avr32/mm/init.c
index e66e840..5a79fa0 100644
--- a/arch/avr32/mm/init.c
+++ b/arch/avr32/mm/init.c
@@ -154,6 +154,6 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
index 82d01a7..8e9eab2 100644
--- a/arch/blackfin/mm/init.c
+++ b/arch/blackfin/mm/init.c
@@ -133,7 +133,7 @@ void __init mem_init(void)
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
 #ifndef CONFIG_MPU
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 #endif
 }
 #endif
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index a9fcd89..97914e5 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -77,7 +77,7 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/frv/mm/init.c b/arch/frv/mm/init.c
index dee354f..a67f3a5 100644
--- a/arch/frv/mm/init.c
+++ b/arch/frv/mm/init.c
@@ -173,6 +173,6 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 } /* end free_initrd_mem() */
 #endif
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index ff349d7..57e03c5 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -161,7 +161,7 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d1fe4b4..da568c2 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -154,8 +154,7 @@ ia64_init_addr_space (void)
 void
 free_initmem (void)
 {
-	free_reserved_area((unsigned long)ia64_imva(__init_begin),
-			   (unsigned long)ia64_imva(__init_end),
+	free_reserved_area(ia64_imva(__init_begin), ia64_imva(__init_end),
 			   0, "unused kernel");
 }
 
diff --git a/arch/m32r/mm/init.c b/arch/m32r/mm/init.c
index ab4cbce..d80412d 100644
--- a/arch/m32r/mm/init.c
+++ b/arch/m32r/mm/init.c
@@ -191,6 +191,6 @@ void free_initmem(void)
  *======================================================================*/
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 1af2ca3..95de725 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -202,6 +202,6 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
diff --git a/arch/metag/mm/init.c b/arch/metag/mm/init.c
index d05b845..5e2238d 100644
--- a/arch/metag/mm/init.c
+++ b/arch/metag/mm/init.c
@@ -414,7 +414,8 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
 
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 4ec137d..73a49c4 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -235,7 +235,7 @@ void __init setup_memory(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 3d0346d..3931be5 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -439,7 +439,8 @@ void free_init_pages(const char *what, unsigned long begin, unsigned long end)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
 
diff --git a/arch/mn10300/mm/init.c b/arch/mn10300/mm/init.c
index 5a8ace6..e19049d 100644
--- a/arch/mn10300/mm/init.c
+++ b/arch/mn10300/mm/init.c
@@ -152,6 +152,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index b3cbc67..ab11332 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -261,7 +261,7 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 157b931..7fd8c8d 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -1099,6 +1099,7 @@ void flush_tlb_all(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area(start, end, 0, "initrd");
+	num_physpages += free_reserved_area((void *)start, (void *)end, 0,
+					    "initrd");
 }
 #endif
diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 6782221..5e4830a 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -756,7 +756,7 @@ static __init void kvm_free_tmp(void)
 	end = (ulong)&kvm_tmp[ARRAY_SIZE(kvm_tmp)] & PAGE_MASK;
 
 	/* Free the tmp space we don't need */
-	free_reserved_area(start, end, 0, NULL);
+	free_reserved_area((void *)start, (void *)end, 0, NULL);
 }
 
 static int __init kvm_guest_init(void)
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 0988a26..347c5b1 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -407,7 +407,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 0b09b23..4c01c3a 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -170,7 +170,8 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void __init free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
 
diff --git a/arch/score/mm/init.c b/arch/score/mm/init.c
index 1592aad..7b78bd1 100644
--- a/arch/score/mm/init.c
+++ b/arch/score/mm/init.c
@@ -110,7 +110,8 @@ void __init mem_init(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, POISON_FREE_INITMEM, "initrd");
+	free_reserved_area((void *)start, (void *)end, POISON_FREE_INITMEM,
+			   "initrd");
 }
 #endif
 
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 20f9ead..b892a9b 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -505,7 +505,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index af472cf..d5f9c02 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -372,8 +372,8 @@ void free_initmem (void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area(start, end, POISON_FREE_INITMEM,
-					    "initrd");
+	num_physpages += free_reserved_area((void *)start, (void *)end,
+					    POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index a717199..a54cdcd 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2124,8 +2124,8 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	num_physpages += free_reserved_area(start, end, POISON_FREE_INITMEM,
-					    "initrd");
+	num_physpages += free_reserved_area((void *)start, (void *)end,
+					    POISON_FREE_INITMEM, "initrd");
 }
 #endif
 
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 9df292b..2aa7a24 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -244,7 +244,7 @@ void free_initmem(void)
 #ifdef CONFIG_BLK_DEV_INITRD
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
-	free_reserved_area(start, end, 0, "initrd");
+	free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 63df12d..220755c 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -486,7 +486,7 @@ static int keep_initrd;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (!keep_initrd)
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 
 static int __init keepinitrd_setup(char *__unused)
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index bba125b..4d658ef 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -214,7 +214,7 @@ extern int initrd_is_mapped;
 void free_initrd_mem(unsigned long start, unsigned long end)
 {
 	if (initrd_is_mapped)
-		free_reserved_area(start, end, 0, "initrd");
+		free_reserved_area((void *)start, (void *)end, 0, "initrd");
 }
 #endif
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1a7f19e..4daa3d1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1301,7 +1301,7 @@ extern void free_initmem(void);
  * "poison" if it's non-zero.
  * Return pages freed into the buddy system.
  */
-extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
+extern unsigned long free_reserved_area(void *start, void *end,
 					int poison, char *s);
 #ifdef	CONFIG_HIGHMEM
 /*
@@ -1345,8 +1345,7 @@ static inline unsigned long free_initmem_default(int poison)
 {
 	extern char __init_begin[], __init_end[];
 
-	return free_reserved_area(PAGE_ALIGN((unsigned long)&__init_begin) ,
-				  ((unsigned long)&__init_end) & PAGE_MASK,
+	return free_reserved_area(&__init_begin, &__init_end,
 				  poison, "unused kernel");
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 843e33d..91ceebc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5186,21 +5186,21 @@ early_param("movablecore", cmdline_parse_movablecore);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
 
-unsigned long free_reserved_area(unsigned long start, unsigned long end,
-				 int poison, char *s)
+unsigned long free_reserved_area(void *start, void *end, int poison, char *s)
 {
-	unsigned long pages, pos;
+	void *pos;
+	unsigned long pages = 0;
 
-	pos = start = PAGE_ALIGN(start);
-	end &= PAGE_MASK;
-	for (pages = 0; pos < end; pos += PAGE_SIZE, pages++) {
+	start = (void *)PAGE_ALIGN((unsigned long)start);
+	end = (void *)((unsigned long)end & PAGE_MASK);
+	for (pos = start; pos < end; pos += PAGE_SIZE, pages++) {
 		if (poison)
-			memset((void *)pos, poison, PAGE_SIZE);
+			memset(pos, poison, PAGE_SIZE);
 		free_reserved_page(virt_to_page(pos));
 	}
 
 	if (pages && s)
-		pr_info("Freeing %s memory: %ldK (%lx - %lx)\n",
+		pr_info("Freeing %s memory: %ldK (%p - %p)\n",
 			s, pages << (PAGE_SHIFT - 10), start, end);
 
 	return pages;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
