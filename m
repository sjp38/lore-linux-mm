Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F34B6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 13:18:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r62so19127436pfj.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:18:29 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l11si762485pgr.98.2017.08.16.10.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 10:18:25 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: [PATCH-resend] mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of poison pages
Date: Wed, 16 Aug 2017 10:18:03 -0700
Message-Id: <20170816171803.28342-1-tony.luck@intel.com>
In-Reply-To: <CAPcyv4gC_6TpwVSjuOzxrz3OdVZCVWD0QVWhBzAuOxUNHJHRMQ@mail.gmail.com>
References: <CAPcyv4gC_6TpwVSjuOzxrz3OdVZCVWD0QVWhBzAuOxUNHJHRMQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>, Dave Hansen <dave.hansen@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Tony Luck <tony.luck@intel.com>

Speculative processor accesses may reference any memory that has a
valid page table entry.  While a speculative access won't generate
a machine check, it will log the error in a machine check bank. That
could cause escalation of a subsequent error since the overflow bit
will be then set in the machine check bank status register.

Code has to be double-plus-tricky to avoid mentioning the 1:1 virtual
address of the page we want to map out otherwise we may trigger the
very problem we are trying to avoid.  We use a non-canonical address
that passes through the usual Linux table walking code to get to the
same "pte".

Thanks to Dave Hansen for reviewing several iterations of this.

Cc: Borislav Petkov <bp@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: stable@vger.kernel.org
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
Full previous thread here:
http://marc.info/?l=linux-mm&m=149860136413338&w=2 but the Cliff notes
are: Discussion on this stalled out at the end of June.  Robert Elliott
had raised questions on whether there needed to be a method to re-enable
the 1:1 mapping if the poison was cleared. I replied that would be a good
follow-on patch when we have a way to clear poison. Robert also asked
whether this needs to integrate with the handling of poison in NVDIMMs,
But discussions with Dan Williams ended up concluding that this code is
executed much earlier (right as the fault is detected) than the NVDIMM
code is prepared to take action. Dan thought this patch could move ahead.

 arch/x86/include/asm/page_64.h   |  4 ++++
 arch/x86/kernel/cpu/mcheck/mce.c | 43 ++++++++++++++++++++++++++++++++++++++++
 include/linux/mm_inline.h        |  6 ++++++
 mm/memory-failure.c              |  2 ++
 4 files changed, 55 insertions(+)

diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index b4a0d43248cf..b50df06ad251 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -51,6 +51,10 @@ static inline void clear_page(void *page)
 
 void copy_page(void *to, void *from);
 
+#ifdef CONFIG_X86_MCE
+#define arch_unmap_kpfn arch_unmap_kpfn
+#endif
+
 #endif	/* !__ASSEMBLY__ */
 
 #ifdef CONFIG_X86_VSYSCALL_EMULATION
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 6dde0497efc7..3b413065c613 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -51,6 +51,7 @@
 #include <asm/mce.h>
 #include <asm/msr.h>
 #include <asm/reboot.h>
+#include <asm/set_memory.h>
 
 #include "mce-internal.h"
 
@@ -1051,6 +1052,48 @@ static int do_memory_failure(struct mce *m)
 	return ret;
 }
 
+#if defined(arch_unmap_kpfn) && defined(CONFIG_MEMORY_FAILURE)
+
+void arch_unmap_kpfn(unsigned long pfn)
+{
+	unsigned long decoy_addr;
+
+	/*
+	 * Unmap this page from the kernel 1:1 mappings to make sure
+	 * we don't log more errors because of speculative access to
+	 * the page.
+	 * We would like to just call:
+	 *	set_memory_np((unsigned long)pfn_to_kaddr(pfn), 1);
+	 * but doing that would radically increase the odds of a
+	 * speculative access to the posion page because we'd have
+	 * the virtual address of the kernel 1:1 mapping sitting
+	 * around in registers.
+	 * Instead we get tricky.  We create a non-canonical address
+	 * that looks just like the one we want, but has bit 63 flipped.
+	 * This relies on set_memory_np() not checking whether we passed
+	 * a legal address.
+	 */
+
+/*
+ * Build time check to see if we have a spare virtual bit. Don't want
+ * to leave this until run time because most developers don't have a
+ * system that can exercise this code path. This will only become a
+ * problem if/when we move beyond 5-level page tables.
+ *
+ * Hard code "9" here because cpp doesn't grok ilog2(PTRS_PER_PGD)
+ */
+#if PGDIR_SHIFT + 9 < 63
+	decoy_addr = (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
+#else
+#error "no unused virtual bit available"
+#endif
+
+	if (set_memory_np(decoy_addr, 1))
+		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
+
+}
+#endif
+
 /*
  * The actual machine check handler. This only handles real
  * exceptions when something got corrupted coming in through int 18.
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index e030a68ead7e..25438b2b6f22 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -126,4 +126,10 @@ static __always_inline enum lru_list page_lru(struct page *page)
 
 #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+#ifdef arch_unmap_kpfn
+extern void arch_unmap_kpfn(unsigned long pfn);
+#else
+static __always_inline void arch_unmap_kpfn(unsigned long pfn) { }
+#endif
+
 #endif
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1cd3b3569af8..88366626c0b7 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1146,6 +1146,8 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		return 0;
 	}
 
+	arch_unmap_kpfn(pfn);
+
 	orig_head = hpage = compound_head(p);
 	num_poisoned_pages_inc();
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
