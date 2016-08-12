Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F09C86B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 10:21:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so50104482pfg.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:21:37 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id y8si9155971pab.178.2016.08.12.07.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Aug 2016 07:21:37 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id cf3so1557474pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 07:21:37 -0700 (PDT)
From: Ronit Halder <ronit.crj@gmail.com>
Subject: [RFC 1/4] Creating one or two CMA area at Boot time
Date: Fri, 12 Aug 2016 19:50:32 +0530
Message-Id: <20160812142032.6036-1-ronit.crj@gmail.com>
In-Reply-To: <20160812141838.5973-1-ronit.crj@gmail.com>
References: <20160812141838.5973-1-ronit.crj@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, dyoung@redhat.com, jroedel@suse.de, krzysiek@podlesie.net, msalter@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, bhe@redhat.com, vgoyal@redhat.com, mnfhuang@gmail.com, kexec@lists.infradead.org, kirill.shutemov@linux.intel.com, mchehab@osg.samsung.com, aarcange@redhat.com, vdavydov@parallels.com, dan.j.williams@intel.com, jack@suse.cz, linux-mm@kvack.org, Ronit Halder <ronit.crj@gmail.com>

This patch create CMA area(s) at boot time. In case of x86_32
only one CMA area will be created. In case of x86_64 if the
user wants to reserve high memory for crash kernel, then there
must be at least 256MB (needed for swiotlb and DMA buffers)
low memory. In that case two CMA areas (one in low memory and
one in high memory) will be created.

Signed-off-by: Ronit Halder <ronit.crj@gmail.com>

---
 arch/x86/kernel/setup.c | 44 +++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 41 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index d2bbe34..87c16c7 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -69,6 +69,7 @@
 #include <linux/crash_dump.h>
 #include <linux/tboot.h>
 #include <linux/jiffies.h>
+#include <linux/cma.h>
 
 #include <video/edid.h>
 
@@ -123,6 +124,10 @@
 unsigned long max_low_pfn_mapped;
 unsigned long max_pfn_mapped;
 
+#ifdef CONFIG_KEXEC_CMA
+struct cma *crashk_cma;
+struct cma *crashk_cma_low;
+#endif
 #ifdef CONFIG_DMI
 RESERVE_BRK(dmi_alloc, 65536);
 #endif
@@ -532,6 +537,18 @@ static int __init reserve_crashkernel_low(void)
 		return -ENOMEM;
 	}
 
+#ifdef CONFIG_KEXEC_CMA
+	ret =  cma_declare_contiguous(low_base, low_size, 0, CRASH_ALIGN, 0, 1, &crashk_cma_low);
+	if (ret) {
+		pr_err("%s: Error reserving CMA area for crashkernel low.\n", __func__);
+		return ret;
+	}
+
+	pr_info("Reserving %ldMB of low memory at %ldMB for CMA area for crashkernel low(System low RAM: %ldMB)\n",
+		(unsigned long)(low_size >> 20),
+		(unsigned long)(low_base >> 20),
+		(unsigned long)(total_low_mem >> 20));
+#else
 	ret = memblock_reserve(low_base, low_size);
 	if (ret) {
 		pr_err("%s: Error reserving crashkernel low memblock.\n", __func__);
@@ -547,6 +564,7 @@ static int __init reserve_crashkernel_low(void)
 	crashk_low_res.end   = low_base + low_size - 1;
 	insert_resource(&iomem_resource, &crashk_low_res);
 #endif
+#endif
 	return 0;
 }
 
@@ -578,8 +596,10 @@ static void __init reserve_crashkernel(void)
 						    high ? CRASH_ADDR_HIGH_MAX
 							 : CRASH_ADDR_LOW_MAX,
 						    crash_size, CRASH_ALIGN);
+		pr_info("Crash_base %llu crash_size %llu\n", crash_base, crash_size);
+
 		if (!crash_base) {
-			pr_info("crashkernel reservation failed - No suitable area found.\n");
+			pr_info("Crashkernel reservation failed - No suitable area found.\n");
 			return;
 		}
 
@@ -589,11 +609,28 @@ static void __init reserve_crashkernel(void)
 		start = memblock_find_in_range(crash_base,
 					       crash_base + crash_size,
 					       crash_size, 1 << 20);
+		pr_info("Base_mentioned crash_base %llu crash_size %llu\n", crash_base, crash_size);
 		if (start != crash_base) {
 			pr_info("crashkernel reservation failed - memory is in use.\n");
 			return;
 		}
 	}
+#ifdef CONFIG_KEXEC_CMA
+	crashk_cma = NULL;
+	crashk_cma_low = NULL;
+	if (crash_base >= (1ULL << 32) && reserve_crashkernel_low())
+		return;
+	ret =  cma_declare_contiguous(crash_base, crash_size, 0, CRASH_ALIGN, 0, 1, &crashk_cma);
+	if (ret) {
+		pr_err("%s: Error reserving CMA area for crashkernel.\n", __func__);
+		return;
+	}
+
+	pr_info("Reserving %ldMB of memory at %ldMB for crashkernel (System RAM: %ldMB)\n",
+		(unsigned long)(crash_size >> 20),
+		(unsigned long)(crash_base >> 20),
+		(unsigned long)(total_mem >> 20));
+#else
 	ret = memblock_reserve(crash_base, crash_size);
 	if (ret) {
 		pr_err("%s: Error reserving crashkernel memblock.\n", __func__);
@@ -613,6 +650,7 @@ static void __init reserve_crashkernel(void)
 	crashk_res.start = crash_base;
 	crashk_res.end   = crash_base + crash_size - 1;
 	insert_resource(&iomem_resource, &crashk_res);
+#endif
 }
 #else
 static void __init reserve_crashkernel(void)
@@ -720,7 +758,7 @@ static void __init trim_snb_memory(void)
 	 * already been reserved.
 	 */
 	memblock_reserve(0, 1<<20);
-	
+
 	for (i = 0; i < ARRAY_SIZE(bad_pages); i++) {
 		if (memblock_reserve(bad_pages[i], PAGE_SIZE))
 			printk(KERN_WARNING "failed to reserve 0x%08lx\n",
@@ -812,7 +850,7 @@ static void __init trim_low_memory_range(void)
 {
 	memblock_reserve(0, ALIGN(reserve_low, PAGE_SIZE));
 }
-	
+
 /*
  * Dump out kernel offset information on panic.
  */
-- 
2.9.0.GIT

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
