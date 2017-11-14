Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBBA46B0033
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 18:04:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 4so20190184pge.8
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 15:04:37 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z79si18606818pfa.116.2017.11.14.15.04.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 15:04:36 -0800 (PST)
From: Tony Luck <tony.luck@intel.com>
Subject: [PATCH] x86/mm, mm/hwpoison: Don't unconditionally unmap kernel 1:1 pages.
Date: Tue, 14 Nov 2017 15:04:34 -0800
Message-Id: <20171114230434.7041-1-tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org

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

Cc: stable@vger.kernel.org #v4.14
Fixes: ce0fa3e56ad2 ("x86/mm, mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of poison pages")
Signed-off-by: Tony Luck <tony.luck@intel.com>
---
 arch/x86/include/asm/page_64.h   |  4 --
 arch/x86/kernel/cpu/mcheck/mce.c | 85 ++++++++++++++++++++--------------------
 include/linux/mm_inline.h        |  6 ---
 mm/memory-failure.c              |  2 -
 4 files changed, 42 insertions(+), 55 deletions(-)

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
diff --git a/arch/x86/kernel/cpu/mcheck/mce.c b/arch/x86/kernel/cpu/mcheck/mce.c
index 3b413065c613..06e8d9b699f5 100644
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -571,6 +571,44 @@ static struct notifier_block first_nb = {
 	.priority	= MCE_PRIO_FIRST,
 };
 
+static void mce_unmap_kpfn(unsigned long pfn)
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
+}
+
 static int srao_decode_notifier(struct notifier_block *nb, unsigned long val,
 				void *data)
 {
@@ -582,7 +620,8 @@ static int srao_decode_notifier(struct notifier_block *nb, unsigned long val,
 
 	if (mce_usable_address(mce) && (mce->severity == MCE_AO_SEVERITY)) {
 		pfn = mce->addr >> PAGE_SHIFT;
-		memory_failure(pfn, MCE_VECTOR, 0);
+		if (!memory_failure(pfn, MCE_VECTOR, 0))
+			mce_unmap_kpfn(pfn);
 	}
 
 	return NOTIFY_OK;
@@ -1049,51 +1088,11 @@ static int do_memory_failure(struct mce *m)
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
-	 * speculative access to the posion page because we'd have
-	 * the virtual address of the kernel 1:1 mapping sitting
-	 * around in registers.
-	 * Instead we get tricky.  We create a non-canonical address
-	 * that looks just like the one we want, but has bit 63 flipped.
-	 * This relies on set_memory_np() not checking whether we passed
-	 * a legal address.
-	 */
-
-/*
- * Build time check to see if we have a spare virtual bit. Don't want
- * to leave this until run time because most developers don't have a
- * system that can exercise this code path. This will only become a
- * problem if/when we move beyond 5-level page tables.
- *
- * Hard code "9" here because cpp doesn't grok ilog2(PTRS_PER_PGD)
- */
-#if PGDIR_SHIFT + 9 < 63
-	decoy_addr = (pfn << PAGE_SHIFT) + (PAGE_OFFSET ^ BIT(63));
-#else
-#error "no unused virtual bit available"
-#endif
-
-	if (set_memory_np(decoy_addr, 1))
-		pr_warn("Could not invalidate pfn=0x%lx from 1:1 map\n", pfn);
-
-}
-#endif
-
 /*
  * The actual machine check handler. This only handles real
  * exceptions when something got corrupted coming in through int 18.
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
index 88366626c0b7..1cd3b3569af8 100644
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
