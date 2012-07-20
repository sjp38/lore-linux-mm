Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D7DC96B006C
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 08:48:55 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 4/6] x86: Add clear_page_nocache
Date: Fri, 20 Jul 2012 15:50:20 +0300
Message-Id: <1342788622-10290-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1342788622-10290-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Add a cache avoiding version of clear_page. Straight forward integer variant
of the existing 64bit clear_page, for both 32bit and 64bit.

Also add the necessary glue for highmem including a layer that non cache
coherent architectures that use the virtual address for flushing can
hook in. This is not needed on x86 of course.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/page.h          |    2 ++
 arch/x86/include/asm/string_32.h     |    5 +++++
 arch/x86/include/asm/string_64.h     |    5 +++++
 arch/x86/lib/Makefile                |    1 +
 arch/x86/lib/clear_page_nocache_32.S |   30 ++++++++++++++++++++++++++++++
 arch/x86/lib/clear_page_nocache_64.S |   29 +++++++++++++++++++++++++++++
 arch/x86/mm/fault.c                  |    7 +++++++
 7 files changed, 79 insertions(+), 0 deletions(-)
 create mode 100644 arch/x86/lib/clear_page_nocache_32.S
 create mode 100644 arch/x86/lib/clear_page_nocache_64.S

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 8ca8283..aa83a1b 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -29,6 +29,8 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
 	copy_page(to, from);
 }
 
+void clear_user_highpage_nocache(struct page *page, unsigned long vaddr);
+
 #define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
 	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
diff --git a/arch/x86/include/asm/string_32.h b/arch/x86/include/asm/string_32.h
index 3d3e835..3f2fbcf 100644
--- a/arch/x86/include/asm/string_32.h
+++ b/arch/x86/include/asm/string_32.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/linkage.h>
+
 /* Let gcc decide whether to inline or use the out of line functions */
 
 #define __HAVE_ARCH_STRCPY
@@ -337,6 +339,9 @@ void *__constant_c_and_count_memset(void *s, unsigned long pattern,
 #define __HAVE_ARCH_MEMSCAN
 extern void *memscan(void *addr, int c, size_t size);
 
+#define ARCH_HAS_USER_NOCACHE 1
+asmlinkage void clear_page_nocache(void *page);
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_X86_STRING_32_H */
diff --git a/arch/x86/include/asm/string_64.h b/arch/x86/include/asm/string_64.h
index 19e2c46..ca23d1d 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#include <linux/linkage.h>
+
 /* Written 2002 by Andi Kleen */
 
 /* Only used for special circumstances. Stolen from i386/string.h */
@@ -63,6 +65,9 @@ char *strcpy(char *dest, const char *src);
 char *strcat(char *dest, const char *src);
 int strcmp(const char *cs, const char *ct);
 
+#define ARCH_HAS_USER_NOCACHE 1
+asmlinkage void clear_page_nocache(void *page);
+
 #endif /* __KERNEL__ */
 
 #endif /* _ASM_X86_STRING_64_H */
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index b00f678..a8ad6dd 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -23,6 +23,7 @@ lib-y += memcpy_$(BITS).o
 lib-$(CONFIG_SMP) += rwlock.o
 lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
+lib-y += clear_page_nocache_$(BITS).o
 
 obj-y += msr.o msr-reg.o msr-reg-export.o
 
diff --git a/arch/x86/lib/clear_page_nocache_32.S b/arch/x86/lib/clear_page_nocache_32.S
new file mode 100644
index 0000000..2394e0c
--- /dev/null
+++ b/arch/x86/lib/clear_page_nocache_32.S
@@ -0,0 +1,30 @@
+#include <linux/linkage.h>
+#include <asm/dwarf2.h>
+
+/*
+ * Zero a page avoiding the caches
+ * rdi	page
+ */
+ENTRY(clear_page_nocache)
+	CFI_STARTPROC
+	mov    %eax,%edi
+	xorl   %eax,%eax
+	movl   $4096/64,%ecx
+	.p2align 4
+.Lloop:
+	decl	%ecx
+#define PUT(x) movnti %eax,x*8(%edi) ; movnti %eax,x*8+4(%edi)
+	PUT(0)
+	PUT(1)
+	PUT(2)
+	PUT(3)
+	PUT(4)
+	PUT(5)
+	PUT(6)
+	PUT(7)
+	lea	64(%edi),%edi
+	jnz	.Lloop
+	nop
+	ret
+	CFI_ENDPROC
+ENDPROC(clear_page_nocache)
diff --git a/arch/x86/lib/clear_page_nocache_64.S b/arch/x86/lib/clear_page_nocache_64.S
new file mode 100644
index 0000000..ee16d15
--- /dev/null
+++ b/arch/x86/lib/clear_page_nocache_64.S
@@ -0,0 +1,29 @@
+#include <linux/linkage.h>
+#include <asm/dwarf2.h>
+
+/*
+ * Zero a page avoiding the caches
+ * rdi	page
+ */
+ENTRY(clear_page_nocache)
+	CFI_STARTPROC
+	xorl   %eax,%eax
+	movl   $4096/64,%ecx
+	.p2align 4
+.Lloop:
+	decl	%ecx
+#define PUT(x) movnti %rax,x*8(%rdi)
+	movnti %rax,(%rdi)
+	PUT(1)
+	PUT(2)
+	PUT(3)
+	PUT(4)
+	PUT(5)
+	PUT(6)
+	PUT(7)
+	leaq	64(%rdi),%rdi
+	jnz	.Lloop
+	nop
+	ret
+	CFI_ENDPROC
+ENDPROC(clear_page_nocache)
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 76dcd9d..20888b4 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -1209,3 +1209,10 @@ good_area:
 
 	up_read(&mm->mmap_sem);
 }
+
+void clear_user_highpage_nocache(struct page *page, unsigned long vaddr)
+{
+	void *p = kmap_atomic(page, KM_USER0);
+	clear_page_nocache(p);
+	kunmap_atomic(p);
+}
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
