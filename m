Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0CBF06B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 17:23:52 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u65so6937803pfd.7
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 14:23:52 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id t11si2116398pgn.568.2018.01.25.14.23.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 14:23:50 -0800 (PST)
From: Tony Luck <tony.luck@intel.com>
Subject: [PATCH v3] x86/mm, mm/hwpoison: Don't unconditionally unmap kernel 1:1 pages.
Date: Thu, 25 Jan 2018 14:23:48 -0800
Message-Id: <20180125222348.11518-1-tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@suse.de>, Denys Vlasenko <dvlasenk@redhat.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Brian Gerst <brgerst@gmail.com>, "Hansen, Dave" <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Robert (Persistent Memory)" <elliott@hpe.com>, Thomas Gleixner <tglx@linutronix.de>

In ce0fa3e56ad2 ("x86/mm, mm/hwpoison: Clear PRESENT bit for kernel 1:1
mappings of poison pages") we added code to memory_failure() to unmap
the page from the kernel 1:1 virtual address space to avoid speculative
access to the page logging additional errors.

But memory_failure() may not always succeed in taking the page offline,
especially if the page belongs to the kernel.  This can happen if
there are too many corrected errors on a page and either mcelog(8)
or drivers/ras/cec.c asks to take a page offline.

Since we remove the 1:1 mapping early in memory_failure(), we can
end up with the page unmapped, but still in use. On the next access
the kernel crashes :-(

There are also various debug paths that call memory_failure() to simulate
occurrence of an error. Since there is no actual error in memory, we
don't need to map out the page for those cases.

Revert most of the previous attempt and keep the solution local to
arch/x86/kernel/cpu/mcheck/mce.c. Unmap the page only when:

	1) there is a real error
	2) memory_failure() succeeds.

All of this only applies to 64-bit systems. 32-bit kernel doesn't map
all of memory into kernel space. It isn't worth adding the code to unmap
the piece that is mapped because nobody would run a 32-bit kernel on a
machine that has recoverable machine checks.

Cc: stable@vger.kernel.org #v4.14
Fixes: ce0fa3e56ad2 ("x86/mm, mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of poison pages")
Signed-off-by: Tony Luck <tony.luck@intel.com>
---

V3: Still only for 64-bit. But moved the hated "#ifdef CONFIG_X86_64" from
    mce.c to mce-internal.h.
    Provided commentary in the code as to why 32-bit support isn't pratical
    or useful.

 arch/x86/include/asm/page_64.h            |  4 ----
 arch/x86/kernel/cpu/mcheck/mce-internal.h | 15 +++++++++++++++
 arch/x86/kernel/cpu/mcheck/mce.c          | 17 +++++++++++------
 include/linux/mm_inline.h                 |  6 ------
 mm/memory-failure.c                       |  2 --
 5 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index 4baa6bceb232..d652a3808065 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -52,10 +52,6 @@ static inline void clear_page(void *page)
 
 void copy_page(void *to, void *from);
 
-#ifdef CONFIG_X86_MCE
-#define arch_unmap_kpfn arch_unmap_kpfn
-#endif
-
 #endif	/* !__ASSEMBLY__ */
 
 #ifdef CONFIG_X86_VSYSCALL_EMULATION
diff --git a/arch/x86/kernel/cpu/mcheck/mce-internal.h b/arch/x86/kernel/cpu/mcheck/mce-internal.h
index aa0d5df9dc60..e956eb267061 100644
--- a/arch/x86/kernel/cpu/mcheck/mce-internal.h
+++ b/arch/x86/kernel/cpu/mcheck/mce-internal.h
@@ -115,4 +115,19 @@ static inline void mce_unregister_injector_chain(struct notifier_block *nb)	{ }
 
 extern struct mca_config mca_cfg;
 
+#ifndef CONFIG_X86_64
+/*
+ * On 32-bit systems it would be difficult to safely unmap a poison page
+ * from the kernel 1:1 map because there are no non-canonical addresses that
+ * we can use to refer to the address without risking a speculative access.
+ * However, this isn't much of an issue because:
+ * 1) Few unmappable pages are in the 1:1 map. Most are in HIGHMEM which
+ *    are only mapped into the kernel as needed
+ * 2) Few people would run a 32-bit kernel on a machine that supports
+ *    recoverable errors because they have too much memory to boot 32-bit.
+ */
+static inline void mce_unmap_kpfn(unsigned long pfn) {}
+#define mce_unmap_kpfn mce_unmap_kpfn
+#endif
+
 #endif /* __X86_MCE_INTERNAL_H__ */
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 868e412b4f0c..4146d85370ab 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -106,6 +106,10 @@ static struct irq_work mce_irq_work;
 
 static void (*quirk_no_way_out)(int bank, struct mce *m, struct pt_regs *regs);
 
+#ifndef mce_unmap_kpfn
+static void mce_unmap_kpfn(unsigned long pfn);
+#endif
+
 /*
  * CPU/chipset specific EDAC code can register a notifier call here to print
  * MCE errors in a human-readable form.
@@ -582,7 +586,8 @@ static int srao_decode_notifier(struct notifier_block *nb, unsigned long val,
 
 	if (mce_usable_address(mce) && (mce->severity == MCE_AO_SEVERITY)) {
 		pfn = mce->addr >> PAGE_SHIFT;
-		memory_failure(pfn, MCE_VECTOR, 0);
+		if (!memory_failure(pfn, MCE_VECTOR, 0))
+			mce_unmap_kpfn(pfn);
 	}
 
 	return NOTIFY_OK;
@@ -1049,12 +1054,13 @@ static int do_memory_failure(struct mce *m)
 	ret = memory_failure(m->addr >> PAGE_SHIFT, MCE_VECTOR, flags);
 	if (ret)
 		pr_err("Memory error not recovered");
+	else
+		mce_unmap_kpfn(m->addr >> PAGE_SHIFT);
 	return ret;
 }
 
-#if defined(arch_unmap_kpfn) && defined(CONFIG_MEMORY_FAILURE)
-
-void arch_unmap_kpfn(unsigned long pfn)
+#ifndef mce_unmap_kpfn
+static void mce_unmap_kpfn(unsigned long pfn)
 {
 	unsigned long decoy_addr;
 
@@ -1065,7 +1071,7 @@ void arch_unmap_kpfn(unsigned long pfn)
 	 * We would like to just call:
 	 *	set_memory_np((unsigned long)pfn_to_kaddr(pfn), 1);
 	 * but doing that would radically increase the odds of a
-	 * speculative access to the posion page because we'd have
+	 * speculative access to the poison page because we'd have
 	 * the virtual address of the kernel 1:1 mapping sitting
 	 * around in registers.
 	 * Instead we get tricky.  We create a non-canonical address
@@ -1090,7 +1096,6 @@ void arch_unmap_kpfn(unsigned long pfn)
 
 	if (set_memory_np(decoy_addr, 1))
 		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
-
 }
 #endif
 
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index c30b32e3c862..10191c28fc04 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -127,10 +127,4 @@ static __always_inline enum lru_list page_lru(struct page *page)
 
 #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
 
-#ifdef arch_unmap_kpfn
-extern void arch_unmap_kpfn(unsigned long pfn);
-#else
-static __always_inline void arch_unmap_kpfn(unsigned long pfn) { }
-#endif
-
 #endif
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 4acdf393a801..c85fa0038848 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1146,8 +1146,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 		return 0;
 	}
 
-	arch_unmap_kpfn(pfn);
-
 	orig_head = hpage = compound_head(p);
 	num_poisoned_pages_inc();
 
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
