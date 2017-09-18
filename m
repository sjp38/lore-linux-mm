Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7973F6B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 05:19:26 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w12so8697750wrc.2
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 02:19:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l13si5560017wrf.144.2017.09.18.02.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 02:19:25 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.13 20/52] x86/mm, mm/hwpoison: Clear PRESENT bit for kernel 1:1 mappings of poison pages
Date: Mon, 18 Sep 2017 11:09:48 +0200
Message-Id: <20170918090907.041255824@linuxfoundation.org>
In-Reply-To: <20170918090904.072766209@linuxfoundation.org>
References: <20170918090904.072766209@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Borislav Petkov <bp@suse.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.13-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Tony Luck <tony.luck@intel.com>

commit ce0fa3e56ad20f04d8252353dcd24e924abdafca upstream.

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

Also see:

  http://marc.info/?l=linux-mm&m=149860136413338&w=2

Signed-off-by: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Borislav Petkov <bp@suse.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Elliott, Robert (Persistent Memory) <elliott@hpe.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/20170816171803.28342-1-tony.luck@intel.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/include/asm/page_64.h   |    4 +++
 arch/x86/kernel/cpu/mcheck/mce.c |   43 +++++++++++++++++++++++++++++++++++++++
 include/linux/mm_inline.h        |    6 +++++
 mm/memory-failure.c              |    2 +
 4 files changed, 55 insertions(+)

--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -51,6 +51,10 @@ static inline void clear_page(void *page
 
 void copy_page(void *to, void *from);
 
+#ifdef CONFIG_X86_MCE
+#define arch_unmap_kpfn arch_unmap_kpfn
+#endif
+
 #endif	/* !__ASSEMBLY__ */
 
 #ifdef CONFIG_X86_VSYSCALL_EMULATION
--- a/arch/x86/kernel/cpu/mcheck/mce.c
+++ b/arch/x86/kernel/cpu/mcheck/mce.c
@@ -51,6 +51,7 @@
 #include <asm/mce.h>
 #include <asm/msr.h>
 #include <asm/reboot.h>
+#include <asm/set_memory.h>
 
 #include "mce-internal.h"
 
@@ -1051,6 +1052,48 @@ static int do_memory_failure(struct mce
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
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -126,4 +126,10 @@ static __always_inline enum lru_list pag
 
 #define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+#ifdef arch_unmap_kpfn
+extern void arch_unmap_kpfn(unsigned long pfn);
+#else
+static __always_inline void arch_unmap_kpfn(unsigned long pfn) { }
+#endif
+
 #endif
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1146,6 +1146,8 @@ int memory_failure(unsigned long pfn, in
 		return 0;
 	}
 
+	arch_unmap_kpfn(pfn);
+
 	orig_head = hpage = compound_head(p);
 	num_poisoned_pages_inc();
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
