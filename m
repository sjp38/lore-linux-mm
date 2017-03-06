Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 524996B038C
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:46:07 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v190so81468844pfb.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:46:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q124si20122481pfb.137.2017.03.06.12.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:46:06 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/7] asm-generic: introduce __ARCH_USE_5LEVEL_HACK
Date: Mon,  6 Mar 2017 23:45:10 +0300
Message-Id: <20170306204514.1852-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
References: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We are going to introduce <asm-generic/pgtable-nop4d.h> to provide
abstraction for properly (in opposite to 5level-fixup.h hack) folded
p4d level. The new header will be included from pgtable-nopud.h.

If an architecture uses <asm-generic/nop*d.h>, we cannot use
5level-fixup.h directly to quickly convert the architecture to 5-level
paging as it would conflict with pgtable-nop4d.h.

With this patch an architecture can define __ARCH_USE_5LEVEL_HACK before
inclusion <asm-genenric/nop*d.h> to use 5level-fixup.h.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/asm-generic/pgtable-nop4d-hack.h | 62 ++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable-nopud.h      |  5 +++
 2 files changed, 67 insertions(+)
 create mode 100644 include/asm-generic/pgtable-nop4d-hack.h

diff --git a/include/asm-generic/pgtable-nop4d-hack.h b/include/asm-generic/pgtable-nop4d-hack.h
new file mode 100644
index 000000000000..752fb7511750
--- /dev/null
+++ b/include/asm-generic/pgtable-nop4d-hack.h
@@ -0,0 +1,62 @@
+#ifndef _PGTABLE_NOP4D_HACK_H
+#define _PGTABLE_NOP4D_HACK_H
+
+#ifndef __ASSEMBLY__
+#include <asm-generic/5level-fixup.h>
+
+#define __PAGETABLE_PUD_FOLDED
+
+/*
+ * Having the pud type consist of a pgd gets the size right, and allows
+ * us to conceptually access the pgd entry that this pud is folded into
+ * without casting.
+ */
+typedef struct { pgd_t pgd; } pud_t;
+
+#define PUD_SHIFT	PGDIR_SHIFT
+#define PTRS_PER_PUD	1
+#define PUD_SIZE	(1UL << PUD_SHIFT)
+#define PUD_MASK	(~(PUD_SIZE-1))
+
+/*
+ * The "pgd_xxx()" functions here are trivial for a folded two-level
+ * setup: the pud is never bad, and a pud always exists (as it's folded
+ * into the pgd entry)
+ */
+static inline int pgd_none(pgd_t pgd)		{ return 0; }
+static inline int pgd_bad(pgd_t pgd)		{ return 0; }
+static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline void pgd_clear(pgd_t *pgd)	{ }
+#define pud_ERROR(pud)				(pgd_ERROR((pud).pgd))
+
+#define pgd_populate(mm, pgd, pud)		do { } while (0)
+/*
+ * (puds are folded into pgds so this doesn't get actually called,
+ * but the define is needed for a generic inline function.)
+ */
+#define set_pgd(pgdptr, pgdval)	set_pud((pud_t *)(pgdptr), (pud_t) { pgdval })
+
+static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
+{
+	return (pud_t *)pgd;
+}
+
+#define pud_val(x)				(pgd_val((x).pgd))
+#define __pud(x)				((pud_t) { __pgd(x) })
+
+#define pgd_page(pgd)				(pud_page((pud_t){ pgd }))
+#define pgd_page_vaddr(pgd)			(pud_page_vaddr((pud_t){ pgd }))
+
+/*
+ * allocating and freeing a pud is trivial: the 1-entry pud is
+ * inside the pgd, so has no extra memory associated with it.
+ */
+#define pud_alloc_one(mm, address)		NULL
+#define pud_free(mm, x)				do { } while (0)
+#define __pud_free_tlb(tlb, x, a)		do { } while (0)
+
+#undef  pud_addr_end
+#define pud_addr_end(addr, end)			(end)
+
+#endif /* __ASSEMBLY__ */
+#endif /* _PGTABLE_NOP4D_HACK_H */
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index 810431d8351b..5e49430a30a4 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -3,6 +3,10 @@
 
 #ifndef __ASSEMBLY__
 
+#ifdef __ARCH_USE_5LEVEL_HACK
+#include <asm-generic/pgtable-nop4d-hack.h>
+#else
+
 #define __PAGETABLE_PUD_FOLDED
 
 /*
@@ -58,4 +62,5 @@ static inline pud_t * pud_offset(pgd_t * pgd, unsigned long address)
 #define pud_addr_end(addr, end)			(end)
 
 #endif /* __ASSEMBLY__ */
+#endif /* !__ARCH_USE_5LEVEL_HACK */
 #endif /* _PGTABLE_NOPUD_H */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
