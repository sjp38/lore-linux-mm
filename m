Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 411566B0253
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:40 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so501625553pfx.1
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:40 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m18si13093225pgd.76.2016.12.26.17.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 02/29] asm-generic: introduce 5level-fixup.h
Date: Tue, 27 Dec 2016 04:53:46 +0300
Message-Id: <20161227015413.187403-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to switch core MM to 5-level paging abstraction.

This is preparation step which adds <asm-generic/5level-fixup.h>
As with 4level-fixup.h, the new header allows quickly make all
architectures compatible with 5-level paging in core MM.

In long run we would like to switch architectures to properly folded p4d
level by using <asm-generic/pgtable-nop4d.h>, but it requires more
changes to arch-specific code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/asm-generic/4level-fixup.h |  3 ++-
 include/asm-generic/5level-fixup.h | 41 ++++++++++++++++++++++++++++++++++++++
 include/linux/mm.h                 |  3 +++
 3 files changed, 46 insertions(+), 1 deletion(-)
 create mode 100644 include/asm-generic/5level-fixup.h

diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index 5bdab6bffd23..928fd66b1271 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -15,7 +15,6 @@
 	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address))? \
  		NULL: pmd_offset(pud, address))
 
-#define pud_alloc(mm, pgd, address)	(pgd)
 #define pud_offset(pgd, start)		(pgd)
 #define pud_none(pud)			0
 #define pud_bad(pud)			0
@@ -35,4 +34,6 @@
 #undef  pud_addr_end
 #define pud_addr_end(addr, end)		(end)
 
+#include <asm-generic/5level-fixup.h>
+
 #endif
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
new file mode 100644
index 000000000000..b5ca82dc4175
--- /dev/null
+++ b/include/asm-generic/5level-fixup.h
@@ -0,0 +1,41 @@
+#ifndef _5LEVEL_FIXUP_H
+#define _5LEVEL_FIXUP_H
+
+#define __ARCH_HAS_5LEVEL_HACK
+#define __PAGETABLE_P4D_FOLDED
+
+#define P4D_SHIFT			PGDIR_SHIFT
+#define P4D_SIZE			PGDIR_SIZE
+#define P4D_MASK			PGDIR_MASK
+#define PTRS_PER_P4D			1
+
+#define p4d_t				pgd_t
+
+#define pud_alloc(mm, p4d, address) \
+	((unlikely(pgd_none(*(p4d))) && __pud_alloc(mm, p4d, address)) ? \
+		NULL : pud_offset(p4d, address))
+
+#define p4d_alloc(mm, pgd, address)	(pgd)
+#define p4d_offset(pgd, start)		(pgd)
+#define p4d_none(p4d)			0
+#define p4d_bad(p4d)			0
+#define p4d_present(p4d)		1
+#define p4d_ERROR(p4d)			do { } while (0)
+#define p4d_clear(p4d)			pgd_clear(p4d)
+#define p4d_val(p4d)			pgd_val(p4d)
+#define p4d_populate(mm, p4d, pud)	pgd_populate(mm, p4d, pud)
+#define p4d_page(p4d)			pgd_page(p4d)
+#define p4d_page_vaddr(p4d)		pgd_page_vaddr(p4d)
+
+#define __p4d(x)			__pgd(x)
+#define set_p4d(p4dp, p4d)		set_pgd(p4dp, p4d)
+
+#undef p4d_free_tlb
+#define p4d_free_tlb(tlb, x, addr)	do { } while (0)
+#define p4d_free(mm, x)			do { } while (0)
+#define __p4d_free_tlb(tlb, x, addr)	do { } while (0)
+
+#undef  p4d_addr_end
+#define p4d_addr_end(addr, end)		(end)
+
+#endif
diff --git a/include/linux/mm.h b/include/linux/mm.h
index fe6b4036664a..58fab8917bbe 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1574,11 +1574,14 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
  * Remove it when 4level-fixup.h has been removed.
  */
 #if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
+
+#ifndef __ARCH_HAS_5LEVEL_HACK
 static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
 	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
 		NULL: pud_offset(pgd, address);
 }
+#endif /* !__ARCH_HAS_5LEVEL_HACK */
 
 static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
