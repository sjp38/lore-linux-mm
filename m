Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCA236B000A
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 18:24:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d13so5329384pfn.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:24:21 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e7-v6si6548979plk.397.2018.04.20.15.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 15:24:20 -0700 (PDT)
Subject: [PATCH 5/5] x86, pti: filter at vma->vm_page_prot population
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 20 Apr 2018 15:20:28 -0700
References: <20180420222018.E7646EE1@viggo.jf.intel.com>
In-Reply-To: <20180420222018.E7646EE1@viggo.jf.intel.com>
Message-Id: <20180420222028.99D72858@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, fengguang.wu@intel.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, keescook@google.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de, mingo@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

0day reported warnings at boot on 32-bit systems without NX support:

 [   12.349193] attempted to set unsupported pgprot: 8000000000000025 bits: 8000000000000000 supported: 7fffffffffffffff
 [   12.350792] WARNING: CPU: 0 PID: 1 at arch/x86/include/asm/pgtable.h:540 handle_mm_fault+0xfc1/0xfe0:
 						check_pgprot at arch/x86/include/asm/pgtable.h:535
 						 (inlined by) pfn_pte at arch/x86/include/asm/pgtable.h:549
 						 (inlined by) do_anonymous_page at mm/memory.c:3169
 						 (inlined by) handle_pte_fault at mm/memory.c:3961
 						 (inlined by) __handle_mm_fault at mm/memory.c:4087
 						 (inlined by) handle_mm_fault at mm/memory.c:4124

The problem was that we stopped massaging page permissions at PTE creation
time, so vma->vm_page_prot was passed unfiltered to PTE creation.

To fix it, filter the page protections before they are installed in
vma->vm_page_prot.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Fixes: fb43d6cb91 ("x86/mm: Do not auto-massage page protections")
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kees Cook <keescook@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-mm@kvack.org
Cc: Ingo Molnar <mingo@kernel.org>
---

 b/arch/x86/Kconfig               |    4 ++++
 b/arch/x86/include/asm/pgtable.h |    5 +++++
 b/mm/mmap.c                      |   11 ++++++++++-
 3 files changed, 19 insertions(+), 1 deletion(-)

diff -puN arch/x86/include/asm/pgtable.h~pti-glb-protection_map arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~pti-glb-protection_map	2018-04-20 14:10:08.251749151 -0700
+++ b/arch/x86/include/asm/pgtable.h	2018-04-20 14:10:08.260749151 -0700
@@ -601,6 +601,11 @@ static inline pgprot_t pgprot_modify(pgp
 
 #define canon_pgprot(p) __pgprot(massage_pgprot(p))
 
+static inline pgprot_t arch_filter_pgprot(pgprot_t prot)
+{
+	return canon_pgprot(prot);
+}
+
 static inline int is_new_memtype_allowed(u64 paddr, unsigned long size,
 					 enum page_cache_mode pcm,
 					 enum page_cache_mode new_pcm)
diff -puN arch/x86/Kconfig~pti-glb-protection_map arch/x86/Kconfig
--- a/arch/x86/Kconfig~pti-glb-protection_map	2018-04-20 14:10:08.253749151 -0700
+++ b/arch/x86/Kconfig	2018-04-20 14:10:08.260749151 -0700
@@ -52,6 +52,7 @@ config X86
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
+	select ARCH_HAS_FILTER_PGPROT
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_KCOV			if X86_64
@@ -273,6 +274,9 @@ config ARCH_HAS_CPU_RELAX
 config ARCH_HAS_CACHE_LINE_SIZE
 	def_bool y
 
+config ARCH_HAS_FILTER_PGPROT
+	def_bool y
+
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
diff -puN mm/mmap.c~pti-glb-protection_map mm/mmap.c
--- a/mm/mmap.c~pti-glb-protection_map	2018-04-20 14:10:08.256749151 -0700
+++ b/mm/mmap.c	2018-04-20 14:10:08.261749151 -0700
@@ -100,11 +100,20 @@ pgprot_t protection_map[16] __ro_after_i
 	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
 };
 
+#ifndef CONFIG_ARCH_HAS_FILTER_PGPROT
+static inline pgprot_t arch_filter_pgprot(pgprot_t prot)
+{
+	return prot;
+}
+#endif
+
 pgprot_t vm_get_page_prot(unsigned long vm_flags)
 {
-	return __pgprot(pgprot_val(protection_map[vm_flags &
+	pgprot_t ret = __pgprot(pgprot_val(protection_map[vm_flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
 			pgprot_val(arch_vm_get_page_prot(vm_flags)));
+
+	return arch_filter_pgprot(ret);
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 
_
