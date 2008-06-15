From: Andrea Righi <righi.andrea@gmail.com>
Subject: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit architectures (v2)
Date: Sun, 15 Jun 2008 17:23:56 +0200
Message-Id: <1213543436-15254-1-git-send-email-righi.andrea@gmail.com>
In-Reply-To: <>
References: <>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, Sudhir Kumar <skumar@linux.vnet.ibm.com>, yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-arch@vger.kernel.org, Andrea Righi <righi.andrea@gmail.com>
List-ID: <linux-mm.kvack.org>

On 32-bit architectures PAGE_ALIGN() truncates 64-bit values to the 32-bit
boundary. For example:

	u64 val = PAGE_ALIGN(size);

always returns a value < 4GB even if size is greater than 4GB.

The problem resides in PAGE_MASK definition (from include/asm-x86/page.h for
example):

 #define PAGE_SHIFT      12
 #define PAGE_SIZE       (_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK       (~(PAGE_SIZE-1))
 ...
 #define PAGE_ALIGN(addr)       (((addr)+PAGE_SIZE-1)&PAGE_MASK)

The "~" is performed on a 32-bit value, so everything in "and" with PAGE_MASK
greater than 4GB will be truncated to the 32-bit boundary. Using the ALIGN()
macro seems to be the right way, because it uses typeof(addr) for the mask.

Also move the PAGE_ALIGN() definitions out of include/asm-*/page.h in
include/linux/mm.h.

See also lkml discussion: http://lkml.org/lkml/2008/6/11/237

ChangeLog: v1 -> v2
 - fix some PAGE_ALIGN() undefined references due to the move of PAGE_ALIGN
   definition in linux/mm.h

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 arch/arm/kernel/module.c                     |    1 +
 arch/arm/plat-omap/fb.c                      |    1 +
 arch/avr32/mm/ioremap.c                      |    1 +
 arch/h8300/kernel/setup.c                    |    1 +
 arch/m68k/amiga/chipram.c                    |    1 +
 arch/m68knommu/kernel/setup.c                |    1 +
 arch/mips/kernel/module.c                    |    1 +
 arch/mips/sgi-ip27/ip27-klnuma.c             |    1 +
 arch/powerpc/boot/of.c                       |    1 +
 arch/powerpc/boot/page.h                     |    3 ---
 arch/powerpc/kernel/suspend.c                |    1 +
 arch/ppc/boot/simple/misc-embedded.c         |    1 +
 arch/ppc/boot/simple/misc.c                  |    1 +
 arch/sparc64/kernel/iommu_common.h           |    2 +-
 arch/x86/kernel/module_64.c                  |    1 +
 arch/xtensa/kernel/setup.c                   |    1 +
 drivers/char/random.c                        |    1 +
 drivers/ieee1394/iso.c                       |    1 +
 drivers/media/video/pvrusb2/pvrusb2-ioread.c |    1 +
 drivers/media/video/videobuf-core.c          |    1 +
 drivers/mtd/maps/uclinux.c                   |    1 +
 drivers/net/mlx4/eq.c                        |    1 +
 drivers/pci/intel-iommu.h                    |    2 +-
 drivers/pcmcia/electra_cf.c                  |    1 +
 drivers/scsi/sun_esp.c                       |    1 +
 drivers/video/acornfb.c                      |    1 +
 drivers/video/clps711xfb.c                   |    1 +
 drivers/video/imxfb.c                        |    1 +
 drivers/video/omap/dispc.c                   |    1 +
 drivers/video/omap/omapfb_main.c             |    1 +
 drivers/video/pxafb.c                        |    1 +
 drivers/video/sa1100fb.c                     |    1 +
 include/asm-alpha/page.h                     |    3 ---
 include/asm-arm/page-nommu.h                 |    4 +---
 include/asm-arm/page.h                       |    3 ---
 include/asm-avr32/page.h                     |    3 ---
 include/asm-blackfin/page.h                  |    3 ---
 include/asm-cris/page.h                      |    3 ---
 include/asm-frv/page.h                       |    3 ---
 include/asm-h8300/page.h                     |    3 ---
 include/asm-ia64/page.h                      |    1 -
 include/asm-m32r/page.h                      |    3 ---
 include/asm-m68k/dvma.h                      |    2 +-
 include/asm-m68k/page.h                      |    3 ---
 include/asm-m68knommu/page.h                 |    3 ---
 include/asm-mips/page.h                      |    3 ---
 include/asm-mn10300/page.h                   |    3 ---
 include/asm-parisc/page.h                    |    4 ----
 include/asm-powerpc/page.h                   |    3 ---
 include/asm-ppc/page.h                       |    4 ----
 include/asm-s390/page.h                      |    3 ---
 include/asm-sh/page.h                        |    3 ---
 include/asm-sparc/page.h                     |    3 ---
 include/asm-sparc64/page.h                   |    3 ---
 include/asm-um/page.h                        |    3 ---
 include/asm-x86/page.h                       |    3 ---
 include/asm-xtensa/page.h                    |    2 --
 include/linux/mm.h                           |    3 +++
 sound/core/info.c                            |    1 +
 59 files changed, 37 insertions(+), 77 deletions(-)

diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
index 79b7e5c..81891a2 100644
--- a/arch/arm/kernel/module.c
+++ b/arch/arm/kernel/module.c
@@ -14,6 +14,7 @@
 #include <linux/moduleloader.h>
 #include <linux/kernel.h>
 #include <linux/elf.h>
+#include <linux/mm.h>
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
 #include <linux/fs.h>
diff --git a/arch/arm/plat-omap/fb.c b/arch/arm/plat-omap/fb.c
index 96d6f06..5d10752 100644
--- a/arch/arm/plat-omap/fb.c
+++ b/arch/arm/plat-omap/fb.c
@@ -23,6 +23,7 @@
 
 #include <linux/module.h>
 #include <linux/kernel.h>
+#include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/platform_device.h>
 #include <linux/bootmem.h>
diff --git a/arch/avr32/mm/ioremap.c b/arch/avr32/mm/ioremap.c
index 3437c82..f03b79f 100644
--- a/arch/avr32/mm/ioremap.c
+++ b/arch/avr32/mm/ioremap.c
@@ -6,6 +6,7 @@
  * published by the Free Software Foundation.
  */
 #include <linux/vmalloc.h>
+#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/io.h>
 
diff --git a/arch/h8300/kernel/setup.c b/arch/h8300/kernel/setup.c
index b1f25c2..7fda657 100644
--- a/arch/h8300/kernel/setup.c
+++ b/arch/h8300/kernel/setup.c
@@ -20,6 +20,7 @@
 #include <linux/sched.h>
 #include <linux/delay.h>
 #include <linux/interrupt.h>
+#include <linux/mm.h>
 #include <linux/fs.h>
 #include <linux/fb.h>
 #include <linux/console.h>
diff --git a/arch/m68k/amiga/chipram.c b/arch/m68k/amiga/chipram.c
index cbe3653..61df1d3 100644
--- a/arch/m68k/amiga/chipram.c
+++ b/arch/m68k/amiga/chipram.c
@@ -9,6 +9,7 @@
 
 #include <linux/types.h>
 #include <linux/kernel.h>
+#include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/slab.h>
diff --git a/arch/m68knommu/kernel/setup.c b/arch/m68knommu/kernel/setup.c
index 03f4fe6..5985f19 100644
--- a/arch/m68knommu/kernel/setup.c
+++ b/arch/m68knommu/kernel/setup.c
@@ -22,6 +22,7 @@
 #include <linux/interrupt.h>
 #include <linux/fb.h>
 #include <linux/module.h>
+#include <linux/mm.h>
 #include <linux/console.h>
 #include <linux/errno.h>
 #include <linux/string.h>
diff --git a/arch/mips/kernel/module.c b/arch/mips/kernel/module.c
index e7ed0ac..a418b26 100644
--- a/arch/mips/kernel/module.c
+++ b/arch/mips/kernel/module.c
@@ -28,6 +28,7 @@
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/mm.h>
 #include <linux/spinlock.h>
 #include <asm/pgtable.h>	/* MODULE_START */
 
diff --git a/arch/mips/sgi-ip27/ip27-klnuma.c b/arch/mips/sgi-ip27/ip27-klnuma.c
index 48932ce..d9c79d8 100644
--- a/arch/mips/sgi-ip27/ip27-klnuma.c
+++ b/arch/mips/sgi-ip27/ip27-klnuma.c
@@ -4,6 +4,7 @@
  * Copyright 2000 - 2001 Kanoj Sarcar (kanoj@sgi.com)
  */
 #include <linux/init.h>
+#include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/kernel.h>
 #include <linux/nodemask.h>
diff --git a/arch/powerpc/boot/of.c b/arch/powerpc/boot/of.c
index 61d9899..6bc72b1 100644
--- a/arch/powerpc/boot/of.c
+++ b/arch/powerpc/boot/of.c
@@ -8,6 +8,7 @@
  */
 #include <stdarg.h>
 #include <stddef.h>
+#include <linux/mm.h>
 #include "types.h"
 #include "elf.h"
 #include "string.h"
diff --git a/arch/powerpc/boot/page.h b/arch/powerpc/boot/page.h
index 14eca30..aa42298 100644
--- a/arch/powerpc/boot/page.h
+++ b/arch/powerpc/boot/page.h
@@ -28,7 +28,4 @@
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 #endif				/* _PPC_BOOT_PAGE_H */
diff --git a/arch/powerpc/kernel/suspend.c b/arch/powerpc/kernel/suspend.c
index 8cee571..6fc6328 100644
--- a/arch/powerpc/kernel/suspend.c
+++ b/arch/powerpc/kernel/suspend.c
@@ -7,6 +7,7 @@
  * Copyright (c) 2001 Patrick Mochel <mochel@osdl.org>
  */
 
+#include <linux/mm.h>
 #include <asm/page.h>
 
 /* References to section boundaries */
diff --git a/arch/ppc/boot/simple/misc-embedded.c b/arch/ppc/boot/simple/misc-embedded.c
index d5a00eb..e390cb7 100644
--- a/arch/ppc/boot/simple/misc-embedded.c
+++ b/arch/ppc/boot/simple/misc-embedded.c
@@ -8,6 +8,7 @@
 
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/mm.h>
 #include <asm/bootinfo.h>
 #include <asm/mmu.h>
 #include <asm/page.h>
diff --git a/arch/ppc/boot/simple/misc.c b/arch/ppc/boot/simple/misc.c
index c3d3305..8c334a2 100644
--- a/arch/ppc/boot/simple/misc.c
+++ b/arch/ppc/boot/simple/misc.c
@@ -16,6 +16,7 @@
 
 #include <linux/types.h>
 #include <linux/string.h>
+#include <linux/mm.h>
 
 #include <asm/page.h>
 #include <asm/mmu.h>
diff --git a/arch/sparc64/kernel/iommu_common.h b/arch/sparc64/kernel/iommu_common.h
index f3575a6..53b19c8 100644
--- a/arch/sparc64/kernel/iommu_common.h
+++ b/arch/sparc64/kernel/iommu_common.h
@@ -23,7 +23,7 @@
 #define IO_PAGE_SHIFT			13
 #define IO_PAGE_SIZE			(1UL << IO_PAGE_SHIFT)
 #define IO_PAGE_MASK			(~(IO_PAGE_SIZE-1))
-#define IO_PAGE_ALIGN(addr)		(((addr)+IO_PAGE_SIZE-1)&IO_PAGE_MASK)
+#define IO_PAGE_ALIGN(addr)		ALIGN(addr, IO_PAGE_SIZE)
 
 #define IO_TSB_ENTRIES			(128*1024)
 #define IO_TSB_SIZE			(IO_TSB_ENTRIES * 8)
diff --git a/arch/x86/kernel/module_64.c b/arch/x86/kernel/module_64.c
index a888e67..adcab87 100644
--- a/arch/x86/kernel/module_64.c
+++ b/arch/x86/kernel/module_64.c
@@ -20,6 +20,7 @@
 #include <linux/elf.h>
 #include <linux/vmalloc.h>
 #include <linux/fs.h>
+#include <linux/mm.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
diff --git a/arch/xtensa/kernel/setup.c b/arch/xtensa/kernel/setup.c
index 5e6d75c..a00359e 100644
--- a/arch/xtensa/kernel/setup.c
+++ b/arch/xtensa/kernel/setup.c
@@ -16,6 +16,7 @@
 
 #include <linux/errno.h>
 #include <linux/init.h>
+#include <linux/mm.h>
 #include <linux/proc_fs.h>
 #include <linux/screen_info.h>
 #include <linux/bootmem.h>
diff --git a/drivers/char/random.c b/drivers/char/random.c
index 0cf98bd..e0d0e37 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -236,6 +236,7 @@
 #include <linux/fs.h>
 #include <linux/genhd.h>
 #include <linux/interrupt.h>
+#include <linux/mm.h>
 #include <linux/spinlock.h>
 #include <linux/percpu.h>
 #include <linux/cryptohash.h>
diff --git a/drivers/ieee1394/iso.c b/drivers/ieee1394/iso.c
index 07ca35c..1cf6487 100644
--- a/drivers/ieee1394/iso.c
+++ b/drivers/ieee1394/iso.c
@@ -11,6 +11,7 @@
 
 #include <linux/pci.h>
 #include <linux/sched.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 
 #include "hosts.h"
diff --git a/drivers/media/video/pvrusb2/pvrusb2-ioread.c b/drivers/media/video/pvrusb2/pvrusb2-ioread.c
index 05a1376..b482478 100644
--- a/drivers/media/video/pvrusb2/pvrusb2-ioread.c
+++ b/drivers/media/video/pvrusb2/pvrusb2-ioread.c
@@ -22,6 +22,7 @@
 #include "pvrusb2-debug.h"
 #include <linux/errno.h>
 #include <linux/string.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <asm/uaccess.h>
diff --git a/drivers/media/video/videobuf-core.c b/drivers/media/video/videobuf-core.c
index 0a88c44..b7b0584 100644
--- a/drivers/media/video/videobuf-core.c
+++ b/drivers/media/video/videobuf-core.c
@@ -16,6 +16,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 
diff --git a/drivers/mtd/maps/uclinux.c b/drivers/mtd/maps/uclinux.c
index bac000a..eca31a5 100644
--- a/drivers/mtd/maps/uclinux.c
+++ b/drivers/mtd/maps/uclinux.c
@@ -12,6 +12,7 @@
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
+#include <linux/mm.h>
 #include <linux/fs.h>
 #include <linux/major.h>
 #include <linux/mtd/mtd.h>
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 4ca78aa..7df928d 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -33,6 +33,7 @@
 
 #include <linux/init.h>
 #include <linux/interrupt.h>
+#include <linux/mm.h>
 #include <linux/dma-mapping.h>
 
 #include <linux/mlx4/cmd.h>
diff --git a/drivers/pci/intel-iommu.h b/drivers/pci/intel-iommu.h
index afc0ad9..339da69 100644
--- a/drivers/pci/intel-iommu.h
+++ b/drivers/pci/intel-iommu.h
@@ -35,7 +35,7 @@
 #define PAGE_SHIFT_4K		(12)
 #define PAGE_SIZE_4K		(1UL << PAGE_SHIFT_4K)
 #define PAGE_MASK_4K		(((u64)-1) << PAGE_SHIFT_4K)
-#define PAGE_ALIGN_4K(addr)	(((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
+#define PAGE_ALIGN_4K(addr)	ALIGN(addr, PAGE_SIZE_4K)
 
 #define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT_4K)
 #define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
diff --git a/drivers/pcmcia/electra_cf.c b/drivers/pcmcia/electra_cf.c
index 52d0aa8..257039e 100644
--- a/drivers/pcmcia/electra_cf.c
+++ b/drivers/pcmcia/electra_cf.c
@@ -28,6 +28,7 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/interrupt.h>
+#include <linux/mm.h>
 #include <linux/vmalloc.h>
 
 #include <pcmcia/ss.h>
diff --git a/drivers/scsi/sun_esp.c b/drivers/scsi/sun_esp.c
index 2c87db9..f9cf701 100644
--- a/drivers/scsi/sun_esp.c
+++ b/drivers/scsi/sun_esp.c
@@ -7,6 +7,7 @@
 #include <linux/types.h>
 #include <linux/delay.h>
 #include <linux/module.h>
+#include <linux/mm.h>
 #include <linux/init.h>
 
 #include <asm/irq.h>
diff --git a/drivers/video/acornfb.c b/drivers/video/acornfb.c
index eedb828..017233d 100644
--- a/drivers/video/acornfb.c
+++ b/drivers/video/acornfb.c
@@ -23,6 +23,7 @@
 #include <linux/string.h>
 #include <linux/ctype.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/init.h>
 #include <linux/fb.h>
 #include <linux/platform_device.h>
diff --git a/drivers/video/clps711xfb.c b/drivers/video/clps711xfb.c
index 9f8a389..bd017f2 100644
--- a/drivers/video/clps711xfb.c
+++ b/drivers/video/clps711xfb.c
@@ -22,6 +22,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/fb.h>
 #include <linux/init.h>
 #include <linux/proc_fs.h>
diff --git a/drivers/video/imxfb.c b/drivers/video/imxfb.c
index 94e4d3a..0c5a475 100644
--- a/drivers/video/imxfb.c
+++ b/drivers/video/imxfb.c
@@ -24,6 +24,7 @@
 #include <linux/string.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/fb.h>
 #include <linux/delay.h>
 #include <linux/init.h>
diff --git a/drivers/video/omap/dispc.c b/drivers/video/omap/dispc.c
index ab32ceb..ab77c51 100644
--- a/drivers/video/omap/dispc.c
+++ b/drivers/video/omap/dispc.c
@@ -20,6 +20,7 @@
  */
 #include <linux/kernel.h>
 #include <linux/dma-mapping.h>
+#include <linux/mm.h>
 #include <linux/vmalloc.h>
 #include <linux/clk.h>
 #include <linux/io.h>
diff --git a/drivers/video/omap/omapfb_main.c b/drivers/video/omap/omapfb_main.c
index 14d0f7a..f85af5c 100644
--- a/drivers/video/omap/omapfb_main.c
+++ b/drivers/video/omap/omapfb_main.c
@@ -25,6 +25,7 @@
  * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
 #include <linux/platform_device.h>
+#include <linux/mm.h>
 #include <linux/uaccess.h>
 
 #include <asm/mach-types.h>
diff --git a/drivers/video/pxafb.c b/drivers/video/pxafb.c
index 778b250..dc98c3b 100644
--- a/drivers/video/pxafb.c
+++ b/drivers/video/pxafb.c
@@ -30,6 +30,7 @@
 #include <linux/string.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/fb.h>
 #include <linux/delay.h>
 #include <linux/init.h>
diff --git a/drivers/video/sa1100fb.c b/drivers/video/sa1100fb.c
index 2dd1b8a..78bcdbc 100644
--- a/drivers/video/sa1100fb.c
+++ b/drivers/video/sa1100fb.c
@@ -167,6 +167,7 @@
 #include <linux/string.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/fb.h>
 #include <linux/delay.h>
 #include <linux/init.h>
diff --git a/include/asm-alpha/page.h b/include/asm-alpha/page.h
index 22ff976..0995f9d 100644
--- a/include/asm-alpha/page.h
+++ b/include/asm-alpha/page.h
@@ -80,9 +80,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define __pa(x)			((unsigned long) (x) - PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long) (x) + PAGE_OFFSET))
 #ifndef CONFIG_DISCONTIGMEM
diff --git a/include/asm-arm/page-nommu.h b/include/asm-arm/page-nommu.h
index a1bcad0..ea1cde8 100644
--- a/include/asm-arm/page-nommu.h
+++ b/include/asm-arm/page-nommu.h
@@ -7,6 +7,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
 #ifndef _ASMARM_PAGE_NOMMU_H
 #define _ASMARM_PAGE_NOMMU_H
 
@@ -42,9 +43,6 @@ typedef unsigned long pgprot_t;
 #define __pmd(x)        (x)
 #define __pgprot(x)     (x)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-arm/page.h b/include/asm-arm/page.h
index 8e05bdb..7c5fc55 100644
--- a/include/asm-arm/page.h
+++ b/include/asm-arm/page.h
@@ -15,9 +15,6 @@
 #define PAGE_SIZE		(1UL << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 
 #ifndef CONFIG_MMU
diff --git a/include/asm-avr32/page.h b/include/asm-avr32/page.h
index cbbc5ca..f805d1c 100644
--- a/include/asm-avr32/page.h
+++ b/include/asm-avr32/page.h
@@ -57,9 +57,6 @@ static inline int get_order(unsigned long size)
 
 #endif /* !__ASSEMBLY__ */
 
-/* Align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * The hardware maps the virtual addresses 0x80000000 -> 0x9fffffff
  * permanently to the physical addresses 0x00000000 -> 0x1fffffff when
diff --git a/include/asm-blackfin/page.h b/include/asm-blackfin/page.h
index c7db022..344f6a8 100644
--- a/include/asm-blackfin/page.h
+++ b/include/asm-blackfin/page.h
@@ -51,9 +51,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-cris/page.h b/include/asm-cris/page.h
index c45bb1e..d19272b 100644
--- a/include/asm-cris/page.h
+++ b/include/asm-cris/page.h
@@ -60,9 +60,6 @@ typedef struct page *pgtable_t;
 
 #define page_to_phys(page)     __pa((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 
 #endif /* __ASSEMBLY__ */
diff --git a/include/asm-frv/page.h b/include/asm-frv/page.h
index c2c1e89..bd9c220 100644
--- a/include/asm-frv/page.h
+++ b/include/asm-frv/page.h
@@ -40,9 +40,6 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 #define PTE_MASK	PAGE_MASK
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 #define devmem_is_allowed(pfn)	1
 
 #define __pa(vaddr)		virt_to_phys((void *) (unsigned long) (vaddr))
diff --git a/include/asm-h8300/page.h b/include/asm-h8300/page.h
index d6a3eaf..0b6acf0 100644
--- a/include/asm-h8300/page.h
+++ b/include/asm-h8300/page.h
@@ -43,9 +43,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
index 36f3932..5f271bc 100644
--- a/include/asm-ia64/page.h
+++ b/include/asm-ia64/page.h
@@ -40,7 +40,6 @@
 
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
 
 #define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
diff --git a/include/asm-m32r/page.h b/include/asm-m32r/page.h
index 8a677f3..c933308 100644
--- a/include/asm-m32r/page.h
+++ b/include/asm-m32r/page.h
@@ -41,9 +41,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * This handles the memory map.. We could make this a config
  * option, but too many people screw it up, and too few need
diff --git a/include/asm-m68k/dvma.h b/include/asm-m68k/dvma.h
index 5d28631..5bd2435 100644
--- a/include/asm-m68k/dvma.h
+++ b/include/asm-m68k/dvma.h
@@ -13,7 +13,7 @@
 #define DVMA_PAGE_SHIFT	13
 #define DVMA_PAGE_SIZE	(1UL << DVMA_PAGE_SHIFT)
 #define DVMA_PAGE_MASK	(~(DVMA_PAGE_SIZE-1))
-#define DVMA_PAGE_ALIGN(addr)	(((addr)+DVMA_PAGE_SIZE-1)&DVMA_PAGE_MASK)
+#define DVMA_PAGE_ALIGN(addr)	ALIGN(addr, DVMA_PAGE_SIZE)
 
 extern void dvma_init(void);
 extern int dvma_map_iommu(unsigned long kaddr, unsigned long baddr,
diff --git a/include/asm-m68k/page.h b/include/asm-m68k/page.h
index 880c2cb..a34b8ba 100644
--- a/include/asm-m68k/page.h
+++ b/include/asm-m68k/page.h
@@ -103,9 +103,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #endif /* !__ASSEMBLY__ */
 
 #include <asm/page_offset.h>
diff --git a/include/asm-m68knommu/page.h b/include/asm-m68knommu/page.h
index 1e82ebb..3a1ede4 100644
--- a/include/asm-m68knommu/page.h
+++ b/include/asm-m68knommu/page.h
@@ -43,9 +43,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-mips/page.h b/include/asm-mips/page.h
index 8735aa0..dd1cc0a 100644
--- a/include/asm-mips/page.h
+++ b/include/asm-mips/page.h
@@ -134,9 +134,6 @@ typedef struct { unsigned long pgprot; } pgprot_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * __pa()/__va() should be used only during mem init.
  */
diff --git a/include/asm-mn10300/page.h b/include/asm-mn10300/page.h
index 124971b..8288e12 100644
--- a/include/asm-mn10300/page.h
+++ b/include/asm-mn10300/page.h
@@ -61,9 +61,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * This handles the memory map.. We could make this a config
  * option, but too many people screw it up, and too few need
diff --git a/include/asm-parisc/page.h b/include/asm-parisc/page.h
index 27d50b8..c3941f0 100644
--- a/include/asm-parisc/page.h
+++ b/include/asm-parisc/page.h
@@ -119,10 +119,6 @@ extern int npmem_ranges;
 #define PMD_ENTRY_SIZE	(1UL << BITS_PER_PMD_ENTRY)
 #define PTE_ENTRY_SIZE	(1UL << BITS_PER_PTE_ENTRY)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
-
 #define LINUX_GATEWAY_SPACE     0
 
 /* This governs the relationship between virtual and physical addresses.
diff --git a/include/asm-powerpc/page.h b/include/asm-powerpc/page.h
index cffdf0e..e088545 100644
--- a/include/asm-powerpc/page.h
+++ b/include/asm-powerpc/page.h
@@ -119,9 +119,6 @@ extern phys_addr_t kernstart_addr;
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 /*
  * Don't compare things with KERNELBASE or PAGE_OFFSET to test for
  * "kernelness", use is_kernel_addr() - it should do what you want.
diff --git a/include/asm-ppc/page.h b/include/asm-ppc/page.h
index 37e4756..6a53965 100644
--- a/include/asm-ppc/page.h
+++ b/include/asm-ppc/page.h
@@ -43,10 +43,6 @@ typedef unsigned long pte_basic_t;
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
-
 #undef STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
diff --git a/include/asm-s390/page.h b/include/asm-s390/page.h
index 12fd9c4..991ba93 100644
--- a/include/asm-s390/page.h
+++ b/include/asm-s390/page.h
@@ -138,9 +138,6 @@ void arch_alloc_page(struct page *page, int order);
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)        (((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define __PAGE_OFFSET           0x0UL
 #define PAGE_OFFSET             0x0UL
 #define __pa(x)                 (unsigned long)(x)
diff --git a/include/asm-sh/page.h b/include/asm-sh/page.h
index 3b305ca..77fb8bf 100644
--- a/include/asm-sh/page.h
+++ b/include/asm-sh/page.h
@@ -24,9 +24,6 @@
 #define PAGE_MASK	(~(PAGE_SIZE-1))
 #define PTE_MASK	PAGE_MASK
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #if defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
 #define HPAGE_SHIFT	16
 #elif defined(CONFIG_HUGETLB_PAGE_SIZE_256K)
diff --git a/include/asm-sparc/page.h b/include/asm-sparc/page.h
index 6aa9e4c..a5029f2 100644
--- a/include/asm-sparc/page.h
+++ b/include/asm-sparc/page.h
@@ -136,9 +136,6 @@ BTFIXUPDEF_SETHI(sparc_unmapped_base)
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)  (((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define PAGE_OFFSET	0xf0000000
 #ifndef __ASSEMBLY__
 extern unsigned long phys_base;
diff --git a/include/asm-sparc64/page.h b/include/asm-sparc64/page.h
index 93f0881..c36a4ba 100644
--- a/include/asm-sparc64/page.h
+++ b/include/asm-sparc64/page.h
@@ -110,9 +110,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 /* We used to stick this into a hard-coded global register (%g4)
  * but that does not make sense anymore.
  */
diff --git a/include/asm-um/page.h b/include/asm-um/page.h
index 93655eb..a6df1f1 100644
--- a/include/asm-um/page.h
+++ b/include/asm-um/page.h
@@ -92,9 +92,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x) ((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long uml_physmem;
 
 #define PAGE_OFFSET (uml_physmem)
diff --git a/include/asm-x86/page.h b/include/asm-x86/page.h
index f409643..534f6f7 100644
--- a/include/asm-x86/page.h
+++ b/include/asm-x86/page.h
@@ -31,9 +31,6 @@
 
 #define HUGE_MAX_HSTATE 2
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
 #endif
diff --git a/include/asm-xtensa/page.h b/include/asm-xtensa/page.h
index 80a6ae0..11f7dc2 100644
--- a/include/asm-xtensa/page.h
+++ b/include/asm-xtensa/page.h
@@ -26,13 +26,11 @@
 
 /*
  * PAGE_SHIFT determines the page size
- * PAGE_ALIGN(x) aligns the pointer to the (next) page boundary
  */
 
 #define PAGE_SHIFT		12
 #define PAGE_SIZE		(__XTENSA_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE - 1) & PAGE_MASK)
 
 #define PAGE_OFFSET		XCHAL_KSEG_CACHED_VADDR
 #define MAX_MEM_PFN		XCHAL_KSEG_SIZE
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 460128d..4c36e83 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -41,6 +41,9 @@ extern unsigned long mmap_min_addr;
 
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
+/* to align the pointer to the (next) page boundary */
+#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way
diff --git a/sound/core/info.c b/sound/core/info.c
index cb5ead3..60edb0a 100644
--- a/sound/core/info.c
+++ b/sound/core/info.c
@@ -22,6 +22,7 @@
 #include <linux/init.h>
 #include <linux/time.h>
 #include <linux/smp_lock.h>
+#include <linux/mm.h>
 #include <linux/string.h>
 #include <sound/core.h>
 #include <sound/minors.h>
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
