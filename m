Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A09D6B04F1
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:05:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e2so13579919pgf.7
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:05:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s11si1033205plj.782.2017.08.23.05.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:05:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 09/19] x86/mm: Make MAX_PHYSADDR_BITS and MAX_PHYSMEM_BITS dynamic
Date: Wed, 23 Aug 2017 15:03:22 +0300
Message-Id: <20170823120332.2288-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
References: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For boot-time switching between paging modes, we need to be able to
adjust size of physical address space at runtime.

As part of making physical address space size variable, we have to make
X86_5LEVEL dependent on SPARSEMEM_VMEMMAP. !SPARSEMEM_VMEMMAP
configuration doesn't work well with variable MAX_PHYSMEM_BITS.

Affect on kernel image size:

   text    data     bss     dec     hex filename
10710340        4880000  860160 16450500         fb03c4 vmlinux.before
10710666        4880000  860160 16450826         fb050a vmlinux.after

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig                        | 1 +
 arch/x86/include/asm/pgtable_64_types.h | 2 +-
 arch/x86/include/asm/sparsemem.h        | 9 ++-------
 arch/x86/kernel/setup.c                 | 5 ++---
 4 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 9067a0a9a166..1e48d2fd8db9 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1403,6 +1403,7 @@ config X86_PAE
 config X86_5LEVEL
 	bool "Enable 5-level page tables support"
 	depends on X86_64
+	depends on SPARSEMEM_VMEMMAP
 	---help---
 	  5-level paging enables access to larger address space:
 	  upto 128 PiB of virtual address space and 4 PiB of
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 163a049bbb56..51364e705b35 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -86,7 +86,7 @@ extern unsigned int ptrs_per_p4d;
 #define PGDIR_MASK	(~(PGDIR_SIZE - 1))
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
-#define MAXMEM		_AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
+#define MAXMEM		(1UL << MAX_PHYSMEM_BITS)
 #ifdef CONFIG_X86_5LEVEL
 #define VMALLOC_SIZE_TB _AC(16384, UL)
 #define __VMALLOC_BASE	_AC(0xff92000000000000, UL)
diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 1f5bee2c202f..b857715633de 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -26,13 +26,8 @@
 # endif
 #else /* CONFIG_X86_32 */
 # define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
-# ifdef CONFIG_X86_5LEVEL
-#  define MAX_PHYSADDR_BITS	52
-#  define MAX_PHYSMEM_BITS	52
-# else
-#  define MAX_PHYSADDR_BITS	44
-#  define MAX_PHYSMEM_BITS	46
-# endif
+# define MAX_PHYSADDR_BITS	(pgtable_l5_enabled ? 52 : 44)
+# define MAX_PHYSMEM_BITS	(pgtable_l5_enabled ? 52 : 46)
 #endif
 
 #endif /* CONFIG_SPARSEMEM */
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 022ebddb3734..10e6dd1cb948 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -202,9 +202,7 @@ struct ist_info ist_info;
 #endif
 
 #else
-struct cpuinfo_x86 boot_cpu_data __read_mostly = {
-	.x86_phys_bits = MAX_PHYSMEM_BITS,
-};
+struct cpuinfo_x86 boot_cpu_data __read_mostly;
 EXPORT_SYMBOL(boot_cpu_data);
 #endif
 
@@ -892,6 +890,7 @@ void __init setup_arch(char **cmdline_p)
 	__flush_tlb_all();
 #else
 	printk(KERN_INFO "Command line: %s\n", boot_command_line);
+	boot_cpu_data.x86_phys_bits = MAX_PHYSMEM_BITS;
 #endif
 
 	/*
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
