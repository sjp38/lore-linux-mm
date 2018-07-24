Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADD86B000E
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:46:45 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id d6-v6so2712486ybn.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:46:45 -0700 (PDT)
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id b7-v6sor2963220ybn.63.2018.07.24.13.46.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 13:46:43 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 24 Jul 2018 13:46:39 -0700
Message-Id: <20180724204639.26934-1-cannonmatthews@google.com>
Subject: [PATCH] RFC: clear 1G pages with streaming stores on x86
From: Cannon Matthews <cannonmatthews@google.com>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>, Cannon Matthews <cannonmatthews@google.com>

Reimplement clear_gigantic_page() to clear gigabytes pages using the
non-temporal streaming store instructions that bypass the cache
(movnti), since an entire 1GiB region will not fit in the cache anyway.

Doing an mlock() on a 512GiB 1G-hugetlb region previously would take on
average 134 seconds, about 260ms/GiB which is quite slow. Using `movnti`
and optimizing the control flow over the constituent small pages, this
can be improved roughly by a factor of 3-4x, with the 512GiB mlock()
taking only 34 seconds on average, or 67ms/GiB.

The assembly code for the __clear_page_nt routine is more or less
taken directly from the output of gcc with -O3 for this function with
some tweaks to support arbitrary sizes and moving memory barriers:

void clear_page_nt_64i (void *page)
{
  for (int i = 0; i < GiB /sizeof(long long int); ++i)
    {
      _mm_stream_si64 (((long long int*)page) + i, 0);
    }
  sfence();
}

In general I would love to hear any thoughts and feedback on this
approach and any ways it could be improved.

Some specific questions:

- What is the appropriate method for defining an arch specific
implementation like this, is the #ifndef code sufficient, and did stuff
land in appropriate files?

- Are there any obvious pitfalls or caveats that have not been
considered? In particular the iterator over mem_map_next() seemed like a
no-op on x86, but looked like it could be important in certain
configurations or architectures I am not familiar with.

- Are there any x86_64 implementations that do not support SSE2
instructions like `movnti` ? What is the appropriate way to detect and
code around that if so?

- Is there anything that could be improved about the assembly code? I
originally wrote it in C and don't have much experience hand writing x86
asm, which seems riddled with optimization pitfalls.

- Is the highmem codepath really necessary? would 1GiB pages really be
of much use on a highmem system? We recently removed some other parts of
the code that support HIGHMEM for gigantic pages (see:
http://lkml.kernel.org/r/20180711195913.1294-1-mike.kravetz@oracle.com)
so this seems like a logical continuation.

- The calls to cond_resched() have been reduced from between every 4k
page to every 64, as between all of the 256K page seemed overly
frequent.  Does this seem like an appropriate frequency? On an idle
system with many spare CPUs it get's rescheduled typically once or twice
out of the 4096 times it calls cond_resched(), which seems like it is
maybe the right amount, but more insight from a scheduling/latency point
of view would be helpful.

- Any other thoughts on the change overall and ways that this could
be made more generally useful, and designed to be easily extensible to
other platforms with non-temporal instructions and 1G pages, or any
additional pitfalls I have not thought to consider.

Tested:
	Time to `mlock()` a 512GiB region on broadwell CPU
				AVG time (s)	% imp.	ms/page
	clear_page_erms		133.584		-	261
	clear_page_nt		34.154		74.43%	67

Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
---
 arch/x86/include/asm/page_64.h     |  3 +++
 arch/x86/lib/Makefile              |  2 +-
 arch/x86/lib/clear_gigantic_page.c | 30 ++++++++++++++++++++++++++++++
 arch/x86/lib/clear_page_64.S       | 20 ++++++++++++++++++++
 include/linux/mm.h                 |  3 +++
 mm/memory.c                        |  5 ++++-
 6 files changed, 61 insertions(+), 2 deletions(-)
 create mode 100644 arch/x86/lib/clear_gigantic_page.c

diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index 939b1cff4a7b..6c1ae21b4d84 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -56,6 +56,9 @@ static inline void clear_page(void *page)

 void copy_page(void *to, void *from);

+#define __HAVE_ARCH_CLEAR_GIGANTIC_PAGE
+void __clear_page_nt(void *page, u64 page_size);
+
 #endif	/* !__ASSEMBLY__ */

 #ifdef CONFIG_X86_VSYSCALL_EMULATION
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index 25a972c61b0a..4ba395234088 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -44,7 +44,7 @@ endif
 else
         obj-y += iomap_copy_64.o
         lib-y += csum-partial_64.o csum-copy_64.o csum-wrappers_64.o
-        lib-y += clear_page_64.o copy_page_64.o
+        lib-y += clear_page_64.o copy_page_64.o clear_gigantic_page.o
         lib-y += memmove_64.o memset_64.o
         lib-y += copy_user_64.o
 	lib-y += cmpxchg16b_emu.o
diff --git a/arch/x86/lib/clear_gigantic_page.c b/arch/x86/lib/clear_gigantic_page.c
new file mode 100644
index 000000000000..80e70f31ddbd
--- /dev/null
+++ b/arch/x86/lib/clear_gigantic_page.c
@@ -0,0 +1,30 @@
+#include <asm/page.h>
+
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
+#define PAGES_BETWEEN_RESCHED 64
+void clear_gigantic_page(struct page *page,
+				unsigned long addr,
+				unsigned int pages_per_huge_page)
+{
+	int i;
+	void *dest = page_to_virt(page);
+	int resched_count = 0;
+
+	BUG_ON(pages_per_huge_page % PAGES_BETWEEN_RESCHED != 0);
+	BUG_ON(!dest);
+
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page; i += PAGES_BETWEEN_RESCHED) {
+		__clear_page_nt(dest + (i * PAGE_SIZE),
+				PAGES_BETWEEN_RESCHED * PAGE_SIZE);
+		resched_count += cond_resched();
+	}
+	/* __clear_page_nt requrires and `sfence` barrier. */
+	wmb();
+	pr_debug("clear_gigantic_page: rescheduled %d times\n", resched_count);
+}
+#endif
diff --git a/arch/x86/lib/clear_page_64.S b/arch/x86/lib/clear_page_64.S
index 88acd349911b..81a39804ac72 100644
--- a/arch/x86/lib/clear_page_64.S
+++ b/arch/x86/lib/clear_page_64.S
@@ -49,3 +49,23 @@ ENTRY(clear_page_erms)
 	ret
 ENDPROC(clear_page_erms)
 EXPORT_SYMBOL_GPL(clear_page_erms)
+
+/*
+ * Zero memory using non temporal stores, bypassing the cache.
+ * Requires an `sfence` (wmb()) afterwards.
+ * %rdi - destination.
+ * %rsi - page size. Must be 64 bit aligned.
+*/
+ENTRY(__clear_page_nt)
+	leaq	(%rdi,%rsi), %rdx
+	xorl	%eax, %eax
+	.p2align 4,,10
+	.p2align 3
+.L2:
+	movnti	%rax, (%rdi)
+	addq	$8, %rdi
+	cmpq	%rdx, %rdi
+	jne	.L2
+	ret
+ENDPROC(__clear_page_nt)
+EXPORT_SYMBOL(__clear_page_nt)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0fbb9ffe380..d10ac4e7ef6a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2729,6 +2729,9 @@ enum mf_action_page_type {
 };

 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
+extern void clear_gigantic_page(struct page *page,
+			 unsigned long addr,
+			 unsigned int pages_per_huge_page);
 extern void clear_huge_page(struct page *page,
 			    unsigned long addr_hint,
 			    unsigned int pages_per_huge_page);
diff --git a/mm/memory.c b/mm/memory.c
index 7206a634270b..2515cae4af4e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -70,6 +70,7 @@
 #include <linux/dax.h>
 #include <linux/oom.h>

+
 #include <asm/io.h>
 #include <asm/mmu_context.h>
 #include <asm/pgalloc.h>
@@ -4568,7 +4569,8 @@ EXPORT_SYMBOL(__might_fault);
 #endif

 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
-static void clear_gigantic_page(struct page *page,
+#ifndef __HAVE_ARCH_CLEAR_GIGANTIC_PAGE
+void clear_gigantic_page(struct page *page,
 				unsigned long addr,
 				unsigned int pages_per_huge_page)
 {
@@ -4582,6 +4584,7 @@ static void clear_gigantic_page(struct page *page,
 		clear_user_highpage(p, addr + i * PAGE_SIZE);
 	}
 }
+#endif  /* __HAVE_ARCH_CLEAR_GIGANTIC_PAGE */
 void clear_huge_page(struct page *page,
 		     unsigned long addr_hint, unsigned int pages_per_huge_page)
 {
--
2.18.0.233.g985f88cf7e-goog
