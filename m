Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A28026B026B
	for <linux-mm@kvack.org>; Sun,  3 Jun 2018 01:33:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f6-v6so8297374pgs.13
        for <linux-mm@kvack.org>; Sat, 02 Jun 2018 22:33:19 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u3-v6si44613626plb.2.2018.06.02.22.33.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Jun 2018 22:33:18 -0700 (PDT)
Subject: [PATCH v2 07/11] x86, memory_failure: Introduce {set,
 clear}_mce_nospec()
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 02 Jun 2018 22:23:20 -0700
Message-ID: <152800340082.17112.1154560126059273408.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, linux-edac@vger.kernel.org, x86@kernel.org, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

Currently memory_failure() returns zero if the error was handled. On
that result mce_unmap_kpfn() is called to zap the page out of the kernel
linear mapping to prevent speculative fetches of potentially poisoned
memory. However, in the case of dax mapped devmap pages the page may be
in active permanent use by the device driver, so it cannot be unmapped
from the kernel.

Instead of marking the page not present, marking the page UC should
be sufficient for preventing poison from being pre-fetched into the
cache. Convert mce_unmap_pfn() to set_mce_nospec() remapping the page as
UC, to hide it from speculative accesses.

Given that that persistent memory errors can be cleared by the driver,
include a facility to restore the page to cacheable operation,
clear_mce_nospec().

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: <linux-edac@vger.kernel.org>
Cc: <x86@kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/include/asm/set_memory.h         |   29 ++++++++++++++++++++++
 arch/x86/kernel/cpu/mcheck/mce-internal.h |   15 -----------
 arch/x86/kernel/cpu/mcheck/mce.c          |   38 ++---------------------------
 include/linux/set_memory.h                |   14 +++++++++++
 4 files changed, 46 insertions(+), 50 deletions(-)

diff --git a/arch/x86/include/asm/set_memory.h b/arch/x86/include/asm/set_memory.h
index bd090367236c..debc1fee1457 100644
--- a/arch/x86/include/asm/set_memory.h
+++ b/arch/x86/include/asm/set_memory.h
@@ -88,4 +88,33 @@ extern int kernel_set_to_readonly;
 void set_kernel_text_rw(void);
 void set_kernel_text_ro(void);
 
+#ifdef CONFIG_X86_64
+/*
+ * Mark the linear address as UC to disable speculative pre-fetches into
+ * potentially poisoned memory.
+ */
+static inline int set_mce_nospec(unsigned long pfn)
+{
+	int rc;
+
+	rc = set_memory_uc((unsigned long) __va(PFN_PHYS(pfn)), 1);
+	if (rc)
+		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
+	return rc;
+}
+#define set_mce_nospec set_mce_nospec
+
+/* Restore full speculative operation to the pfn. */
+static inline int clear_mce_nospec(unsigned long pfn)
+{
+	return set_memory_wb((unsigned long) __va(PFN_PHYS(pfn)), 1);
+}
+#define clear_mce_nospec clear_mce_nospec
+#else
+/*
+ * Few people would run a 32-bit kernel on a machine that supports
+ * recoverable errors because they have too much memory to boot 32-bit.
+ */
+#endif
+
 #endif /* _ASM_X86_SET_MEMORY_H */
diff --git a/arch/x86/kernel/cpu/mcheck/mce-internal.h b/arch/x86/kernel/cpu/mcheck/mce-internal.h
index 374d1aa66952..ceb67cd5918f 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-internal.h
+++ b/arch/x86/kernel/cpu/mcheck/mce-internal.h
@@ -113,21 +113,6 @@ static inline void mce_register_injector_chain(struct notifier_block *nb)	{ }
 static inline void mce_unregister_injector_chain(struct notifier_block *nb)	{ }
 #endif
 
-#ifndef CONFIG_X86_64
-/*
- * On 32-bit systems it would be difficult to safely unmap a poison page
- * from the kernel 1:1 map because there are no non-canonical addresses that
- * we can use to refer to the address without risking a speculative access.
- * However, this isn't much of an issue because:
- * 1) Few unmappable pages are in the 1:1 map. Most are in HIGHMEM which
- *    are only mapped into the kernel as needed
- * 2) Few people would run a 32-bit kernel on a machine that supports
- *    recoverable errors because they have too much memory to boot 32-bit.
- */
-static inline void mce_unmap_kpfn(unsigned long pfn) {}
-#define mce_unmap_kpfn mce_unmap_kpfn
-#endif
-
 struct mca_config {
 	bool dont_log_ce;
 	bool cmci_disabled;
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 42cf2880d0ed..a0fbf0a8b7e6 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -42,6 +42,7 @@
 #include <linux/irq_work.h>
 #include <linux/export.h>
 #include <linux/jump_label.h>
+#include <linux/set_memory.h>
 
 #include <asm/intel-family.h>
 #include <asm/processor.h>
@@ -50,7 +51,6 @@
 #include <asm/mce.h>
 #include <asm/msr.h>
 #include <asm/reboot.h>
-#include <asm/set_memory.h>
 
 #include "mce-internal.h"
 
@@ -108,10 +108,6 @@ static struct irq_work mce_irq_work;
 
 static void (*quirk_no_way_out)(int bank, struct mce *m, struct pt_regs *regs);
 
-#ifndef mce_unmap_kpfn
-static void mce_unmap_kpfn(unsigned long pfn);
-#endif
-
 /*
  * CPU/chipset specific EDAC code can register a notifier call here to print
  * MCE errors in a human-readable form.
@@ -602,7 +598,7 @@ static int srao_decode_notifier(struct notifier_block *nb, unsigned long val,
 	if (mce_usable_address(mce) && (mce->severity == MCE_AO_SEVERITY)) {
 		pfn = mce->addr >> PAGE_SHIFT;
 		if (!memory_failure(pfn, 0))
-			mce_unmap_kpfn(pfn);
+			set_mce_nospec(pfn);
 	}
 
 	return NOTIFY_OK;
@@ -1070,38 +1066,10 @@ static int do_memory_failure(struct mce *m)
 	if (ret)
 		pr_err("Memory error not recovered");
 	else
-		mce_unmap_kpfn(m->addr >> PAGE_SHIFT);
+		set_mce_nospec(m->addr >> PAGE_SHIFT);
 	return ret;
 }
 
-#ifndef mce_unmap_kpfn
-static void mce_unmap_kpfn(unsigned long pfn)
-{
-	unsigned long decoy_addr;
-
-	/*
-	 * Unmap this page from the kernel 1:1 mappings to make sure
-	 * we don't log more errors because of speculative access to
-	 * the page.
-	 * We would like to just call:
-	 *	set_memory_np((unsigned long)pfn_to_kaddr(pfn), 1);
-	 * but doing that would radically increase the odds of a
-	 * speculative access to the poison page because we'd have
-	 * the virtual address of the kernel 1:1 mapping sitting
-	 * around in registers.
-	 * Instead we get tricky.  We create a non-canonical address
-	 * that looks just like the one we want, but has bit 63 flipped.
-	 * This relies on set_memory_np() not checking whether we passed
-	 * a legal address.
-	 */
-
-	decoy_addr = (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
-
-	if (set_memory_np(decoy_addr, 1))
-		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
-}
-#endif
-
 /*
  * The actual machine check handler. This only handles real
  * exceptions when something got corrupted coming in through int 18.
diff --git a/include/linux/set_memory.h b/include/linux/set_memory.h
index da5178216da5..2a986d282a97 100644
--- a/include/linux/set_memory.h
+++ b/include/linux/set_memory.h
@@ -17,6 +17,20 @@ static inline int set_memory_x(unsigned long addr,  int numpages) { return 0; }
 static inline int set_memory_nx(unsigned long addr, int numpages) { return 0; }
 #endif
 
+#ifndef set_mce_nospec
+static inline int set_mce_nospec(unsigned long pfn)
+{
+	return 0;
+}
+#endif
+
+#ifndef clear_mce_nospec
+static inline int clear_mce_nospec(unsigned long pfn)
+{
+	return 0;
+}
+#endif
+
 #ifndef CONFIG_ARCH_HAS_MEM_ENCRYPT
 static inline int set_memory_encrypted(unsigned long addr, int numpages)
 {
