Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7F046B0389
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 13:05:29 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j5so313198390pfb.3
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:05:29 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t187sor1659229pgc.22.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Mar 2017 10:05:29 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v7 1/3] x86/mm: Adapt MODULES_END based on Fixmap section size
Date: Tue, 14 Mar 2017 10:05:06 -0700
Message-Id: <20170314170508.100882-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Thomas Garnier <thgarnie@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm@vger.kernel.org, kernel-hardening@lists.openwall.com

This patch aligns MODULES_END to the beginning of the Fixmap section.
It optimizes the space available for both sections. The address is
pre-computed based on the number of pages required by the Fixmap
section.

It will allow GDT remapping in the Fixmap section. The current
MODULES_END static address does not provide enough space for the kernel
to support a large number of processors.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20170308
---
 Documentation/x86/x86_64/mm.txt         | 5 ++++-
 arch/x86/include/asm/pgtable_64_types.h | 3 ++-
 arch/x86/kernel/module.c                | 1 +
 arch/x86/mm/dump_pagetables.c           | 1 +
 arch/x86/mm/kasan_init_64.c             | 1 +
 mm/vmalloc.c                            | 1 +
 6 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 5724092db811..ee3f9c30957c 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -19,7 +19,7 @@ ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
 ... unused hole ...
 ffffffff80000000 - ffffffff9fffffff (=512 MB)  kernel text mapping, from phys 0
-ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
+ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space (variable)
 ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
 ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
 
@@ -39,6 +39,9 @@ memory window (this size is arbitrary, it can be raised later if needed).
 The mappings are not part of any other kernel PGD and are only available
 during EFI runtime calls.
 
+The module mapping space size changes based on the CONFIG requirements for the
+following fixmap section.
+
 Note that if CONFIG_RANDOMIZE_MEMORY is enabled, the direct mapping of all
 physical memory, vmalloc/ioremap space and virtual memory map are randomized.
 Their order is preserved but their base will be offset early at boot time.
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 3a264200c62f..bb05e21cf3c7 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -67,7 +67,8 @@ typedef struct { pteval_t pte; } pte_t;
 #endif /* CONFIG_RANDOMIZE_MEMORY */
 #define VMALLOC_END	(VMALLOC_START + _AC((VMALLOC_SIZE_TB << 40) - 1, UL))
 #define MODULES_VADDR    (__START_KERNEL_map + KERNEL_IMAGE_SIZE)
-#define MODULES_END      _AC(0xffffffffff000000, UL)
+/* The module sections ends with the start of the fixmap */
+#define MODULES_END   __fix_to_virt(__end_of_fixed_addresses + 1)
 #define MODULES_LEN   (MODULES_END - MODULES_VADDR)
 #define ESPFIX_PGD_ENTRY _AC(-2, UL)
 #define ESPFIX_BASE_ADDR (ESPFIX_PGD_ENTRY << PGDIR_SHIFT)
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index 477ae806c2fa..fad61caac75e 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -35,6 +35,7 @@
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/setup.h>
+#include <asm/fixmap.h>
 
 #if 0
 #define DEBUGP(fmt, ...)				\
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 58b5bee7ea27..75efeecc85eb 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -20,6 +20,7 @@
 
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
+#include <asm/fixmap.h>
 
 /*
  * The dumper groups pagetable entries of the same type into one, and for
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 8d63d7a104c3..1bde19ef86bd 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -9,6 +9,7 @@
 
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
+#include <asm/fixmap.h>
 
 extern pgd_t early_level4_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_X_MAX];
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 32979d945766..1fc9598ed019 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -35,6 +35,7 @@
 #include <linux/uaccess.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
+#include <asm/fixmap.h>
 
 #include "internal.h"
 
-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
