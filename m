Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6CC6B0003
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 02:21:08 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c142so2355055wmh.4
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 23:21:07 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:8b0:10b:1236::1])
        by mx.google.com with ESMTPS id j3si3191172wmb.84.2018.02.11.23.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 11 Feb 2018 23:21:06 -0800 (PST)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] headers: untangle kmemleak.h from mm.h
Message-ID: <a4629db7-194d-3c7c-c8fd-24f61b220a70@infradead.org>
Date: Sun, 11 Feb 2018 23:20:48 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>
Cc: iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-s390 <linux-s390@vger.kernel.org>, sparclinux@vger.kernel.org, X86 ML <x86@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-wireless <linux-wireless@vger.kernel.org>, virtualization@lists.linux-foundation.org, John Johansen <john.johansen@canonical.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Currently <linux/slab.h> #includes <linux/kmemleak.h> for no obvious
reason. It looks like it's only a convenience, so remove kmemleak.h
from slab.h and add <linux/kmemleak.h> to any users of kmemleak_*
that don't already #include it.
Also remove <linux/kmemleak.h> from source files that do not use it.

This is tested on i386 allmodconfig and x86_64 allmodconfig. It
would be good to run it through the 0day bot for other $ARCHes.
I have neither the horsepower nor the storage space for the other
$ARCHes.

[slab.h is the second most used header file after module.h; kernel.h
is right there with slab.h. There could be some minor error in the
counting due to some #includes having comments after them and I
didn't combine all of those.]

This is Lingchi patch #1 (death by a thousand cuts, applied to kernel
header files).

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---

Fengguang, can you have this patch run thru 0day builds, please?

 arch/powerpc/sysdev/dart_iommu.c                          |    1 +
 arch/powerpc/sysdev/msi_bitmap.c                          |    1 +
 arch/s390/kernel/nmi.c                                    |    2 +-
 arch/s390/kernel/smp.c                                    |    1 -
 arch/sparc/kernel/irq_64.c                                |    1 -
 arch/x86/kernel/pci-dma.c                                 |    1 -
 drivers/iommu/exynos-iommu.c                              |    1 +
 drivers/iommu/mtk_iommu_v1.c                              |    1 -
 drivers/net/ethernet/ti/cpsw.c                            |    1 +
 drivers/net/wireless/realtek/rtlwifi/pci.c                |    1 -
 drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c |    1 -
 drivers/staging/rtl8188eu/hal/fw.c                        |    2 +-
 drivers/staging/rtlwifi/pci.c                             |    1 -
 drivers/virtio/virtio_ring.c                              |    1 -
 include/linux/slab.h                                      |    1 -
 kernel/ucount.c                                           |    1 +
 mm/cma.c                                                  |    1 +
 mm/memblock.c                                             |    1 +
 net/core/sysctl_net_core.c                                |    1 -
 net/ipv4/route.c                                          |    1 -
 security/apparmor/lsm.c                                   |    1 -
 21 files changed, 9 insertions(+), 14 deletions(-)

--- lnx-416-rc1.orig/include/linux/slab.h
+++ lnx-416-rc1/include/linux/slab.h
@@ -125,7 +125,6 @@
 #define ZERO_OR_NULL_PTR(x) ((unsigned long)(x) <= \
 				(unsigned long)ZERO_SIZE_PTR)
 
-#include <linux/kmemleak.h>
 #include <linux/kasan.h>
 
 struct mem_cgroup;
--- lnx-416-rc1.orig/kernel/ucount.c
+++ lnx-416-rc1/kernel/ucount.c
@@ -10,6 +10,7 @@
 #include <linux/slab.h>
 #include <linux/cred.h>
 #include <linux/hash.h>
+#include <linux/kmemleak.h>
 #include <linux/user_namespace.h>
 
 #define UCOUNTS_HASHTABLE_BITS 10
--- lnx-416-rc1.orig/mm/memblock.c
+++ lnx-416-rc1/mm/memblock.c
@@ -17,6 +17,7 @@
 #include <linux/poison.h>
 #include <linux/pfn.h>
 #include <linux/debugfs.h>
+#include <linux/kmemleak.h>
 #include <linux/seq_file.h>
 #include <linux/memblock.h>
 
--- lnx-416-rc1.orig/mm/cma.c
+++ lnx-416-rc1/mm/cma.c
@@ -35,6 +35,7 @@
 #include <linux/cma.h>
 #include <linux/highmem.h>
 #include <linux/io.h>
+#include <linux/kmemleak.h>
 #include <trace/events/cma.h>
 
 #include "cma.h"
--- lnx-416-rc1.orig/drivers/staging/rtl8188eu/hal/fw.c
+++ lnx-416-rc1/drivers/staging/rtl8188eu/hal/fw.c
@@ -30,7 +30,7 @@
 #include "rtl8188e_hal.h"
 
 #include <linux/firmware.h>
-#include <linux/kmemleak.h>
+#include <linux/slab.h>
 
 static void _rtl88e_enable_fw_download(struct adapter *adapt, bool enable)
 {
--- lnx-416-rc1.orig/drivers/iommu/exynos-iommu.c
+++ lnx-416-rc1/drivers/iommu/exynos-iommu.c
@@ -17,6 +17,7 @@
 #include <linux/io.h>
 #include <linux/iommu.h>
 #include <linux/interrupt.h>
+#include <linux/kmemleak.h>
 #include <linux/list.h>
 #include <linux/of.h>
 #include <linux/of_iommu.h>
--- lnx-416-rc1.orig/arch/s390/kernel/nmi.c
+++ lnx-416-rc1/arch/s390/kernel/nmi.c
@@ -15,7 +15,7 @@
 #include <linux/hardirq.h>
 #include <linux/log2.h>
 #include <linux/kprobes.h>
-#include <linux/slab.h>
+#include <linux/kmemleak.h>
 #include <linux/time.h>
 #include <linux/module.h>
 #include <linux/sched/signal.h>
--- lnx-416-rc1.orig/arch/powerpc/sysdev/dart_iommu.c
+++ lnx-416-rc1/arch/powerpc/sysdev/dart_iommu.c
@@ -38,6 +38,7 @@
 #include <linux/suspend.h>
 #include <linux/memblock.h>
 #include <linux/gfp.h>
+#include <linux/kmemleak.h>
 #include <asm/io.h>
 #include <asm/prom.h>
 #include <asm/iommu.h>
--- lnx-416-rc1.orig/arch/powerpc/sysdev/msi_bitmap.c
+++ lnx-416-rc1/arch/powerpc/sysdev/msi_bitmap.c
@@ -10,6 +10,7 @@
 
 #include <linux/slab.h>
 #include <linux/kernel.h>
+#include <linux/kmemleak.h>
 #include <linux/bitmap.h>
 #include <linux/bootmem.h>
 #include <asm/msi_bitmap.h>
--- lnx-416-rc1.orig/drivers/net/ethernet/ti/cpsw.c
+++ lnx-416-rc1/drivers/net/ethernet/ti/cpsw.c
@@ -35,6 +35,7 @@
 #include <linux/of_net.h>
 #include <linux/of_device.h>
 #include <linux/if_vlan.h>
+#include <linux/kmemleak.h>
 
 #include <linux/pinctrl/consumer.h>
 
--- lnx-416-rc1.orig/drivers/virtio/virtio_ring.c
+++ lnx-416-rc1/drivers/virtio/virtio_ring.c
@@ -23,7 +23,6 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/hrtimer.h>
-#include <linux/kmemleak.h>
 #include <linux/dma-mapping.h>
 #include <xen/xen.h>
 
--- lnx-416-rc1.orig/security/apparmor/lsm.c
+++ lnx-416-rc1/security/apparmor/lsm.c
@@ -23,7 +23,6 @@
 #include <linux/sysctl.h>
 #include <linux/audit.h>
 #include <linux/user_namespace.h>
-#include <linux/kmemleak.h>
 #include <net/sock.h>
 
 #include "include/apparmor.h"
--- lnx-416-rc1.orig/drivers/iommu/mtk_iommu_v1.c
+++ lnx-416-rc1/drivers/iommu/mtk_iommu_v1.c
@@ -25,7 +25,6 @@
 #include <linux/io.h>
 #include <linux/iommu.h>
 #include <linux/iopoll.h>
-#include <linux/kmemleak.h>
 #include <linux/list.h>
 #include <linux/of_address.h>
 #include <linux/of_iommu.h>
--- lnx-416-rc1.orig/drivers/staging/rtlwifi/pci.c
+++ lnx-416-rc1/drivers/staging/rtlwifi/pci.c
@@ -31,7 +31,6 @@
 #include "efuse.h"
 #include <linux/interrupt.h>
 #include <linux/export.h>
-#include <linux/kmemleak.h>
 #include <linux/module.h>
 
 MODULE_AUTHOR("lizhaoming	<chaoming_li@realsil.com.cn>");
--- lnx-416-rc1.orig/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ lnx-416-rc1/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -31,7 +31,6 @@
 #include "efuse.h"
 #include <linux/interrupt.h>
 #include <linux/export.h>
-#include <linux/kmemleak.h>
 #include <linux/module.h>
 
 MODULE_AUTHOR("lizhaoming	<chaoming_li@realsil.com.cn>");
--- lnx-416-rc1.orig/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
+++ lnx-416-rc1/drivers/net/wireless/realtek/rtlwifi/rtl8192c/fw_common.c
@@ -32,7 +32,6 @@
 #include "../rtl8192ce/def.h"
 #include "fw_common.h"
 #include <linux/export.h>
-#include <linux/kmemleak.h>
 
 static void _rtl92c_enable_fw_download(struct ieee80211_hw *hw, bool enable)
 {
--- lnx-416-rc1.orig/arch/s390/kernel/smp.c
+++ lnx-416-rc1/arch/s390/kernel/smp.c
@@ -27,7 +27,6 @@
 #include <linux/err.h>
 #include <linux/spinlock.h>
 #include <linux/kernel_stat.h>
-#include <linux/kmemleak.h>
 #include <linux/delay.h>
 #include <linux/interrupt.h>
 #include <linux/irqflags.h>
--- lnx-416-rc1.orig/arch/sparc/kernel/irq_64.c
+++ lnx-416-rc1/arch/sparc/kernel/irq_64.c
@@ -22,7 +22,6 @@
 #include <linux/seq_file.h>
 #include <linux/ftrace.h>
 #include <linux/irq.h>
-#include <linux/kmemleak.h>
 
 #include <asm/ptrace.h>
 #include <asm/processor.h>
--- lnx-416-rc1.orig/arch/x86/kernel/pci-dma.c
+++ lnx-416-rc1/arch/x86/kernel/pci-dma.c
@@ -6,7 +6,6 @@
 #include <linux/bootmem.h>
 #include <linux/gfp.h>
 #include <linux/pci.h>
-#include <linux/kmemleak.h>
 
 #include <asm/proto.h>
 #include <asm/dma.h>
--- lnx-416-rc1.orig/net/core/sysctl_net_core.c
+++ lnx-416-rc1/net/core/sysctl_net_core.c
@@ -15,7 +15,6 @@
 #include <linux/vmalloc.h>
 #include <linux/init.h>
 #include <linux/slab.h>
-#include <linux/kmemleak.h>
 
 #include <net/ip.h>
 #include <net/sock.h>
--- lnx-416-rc1.orig/net/ipv4/route.c
+++ lnx-416-rc1/net/ipv4/route.c
@@ -108,7 +108,6 @@
 #include <net/rtnetlink.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
-#include <linux/kmemleak.h>
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
