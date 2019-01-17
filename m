Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A86688E000F
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 19:33:40 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id r9so6012624pfb.13
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:33:40 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 1si7848435plo.195.2019.01.16.16.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 16:33:39 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 10/17] x86: avoid W^X being broken during modules loading
Date: Wed, 16 Jan 2019 16:32:52 -0800
Message-Id: <20190117003259.23141-11-rick.p.edgecombe@intel.com>
In-Reply-To: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Nadav Amit <namit@vmware.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, Masami Hiramatsu <mhiramat@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>

From: Nadav Amit <namit@vmware.com>

When modules and BPF filters are loaded, there is a time window in
which some memory is both writable and executable. An attacker that has
already found another vulnerability (e.g., a dangling pointer) might be
able to exploit this behavior to overwrite kernel code. This patch
prevents having writable executable PTEs in this stage.

In addition, avoiding having R+X mappings can also slightly simplify the
patching of modules code on initialization (e.g., by alternatives and
static-key), as would be done in the next patch. This was actually the
main motivation for this patch.

To avoid having W+X mappings, set them initially as RW (NX) and after
they are set as RO set them as X as well. Setting them as executable is
done as a separate step to avoid one core in which the old PTE is cached
(hence writable), and another which sees the updated PTE (executable),
which would break the W^X protection.

Cc: Kees Cook <keescook@chromium.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Suggested-by: Andy Lutomirski <luto@amacapital.net>
Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/alternative.c | 28 +++++++++++++++++++++-------
 arch/x86/kernel/module.c      |  2 +-
 include/linux/filter.h        |  4 ++--
 kernel/module.c               |  5 +++++
 4 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/arch/x86/kernel/alternative.c b/arch/x86/kernel/alternative.c
index 8fc4685f3117..18415e3b6000 100644
--- a/arch/x86/kernel/alternative.c
+++ b/arch/x86/kernel/alternative.c
@@ -667,15 +667,29 @@ void __init alternative_instructions(void)
  * handlers seeing an inconsistent instruction while you patch.
  */
 void *__init_or_module text_poke_early(void *addr, const void *opcode,
-					      size_t len)
+				       size_t len)
 {
 	unsigned long flags;
-	local_irq_save(flags);
-	memcpy(addr, opcode, len);
-	local_irq_restore(flags);
-	sync_core();
-	/* Could also do a CLFLUSH here to speed up CPU recovery; but
-	   that causes hangs on some VIA CPUs. */
+
+	if (static_cpu_has(X86_FEATURE_NX) &&
+	    is_module_text_address((unsigned long)addr)) {
+		/*
+		 * Modules text is marked initially as non-executable, so the
+		 * code cannot be running and speculative code-fetches are
+		 * prevented. We can just change the code.
+		 */
+		memcpy(addr, opcode, len);
+	} else {
+		local_irq_save(flags);
+		memcpy(addr, opcode, len);
+		local_irq_restore(flags);
+		sync_core();
+
+		/*
+		 * Could also do a CLFLUSH here to speed up CPU recovery; but
+		 * that causes hangs on some VIA CPUs.
+		 */
+	}
 	return addr;
 }
 
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index b052e883dd8c..cfa3106faee4 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -87,7 +87,7 @@ void *module_alloc(unsigned long size)
 	p = __vmalloc_node_range(size, MODULE_ALIGN,
 				    MODULES_VADDR + get_module_load_offset(),
 				    MODULES_END, GFP_KERNEL,
-				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
+				    PAGE_KERNEL, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
 	if (p && (kasan_module_alloc(p, size) < 0)) {
 		vfree(p);
diff --git a/include/linux/filter.h b/include/linux/filter.h
index ad106d845b22..f18cd317faf8 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -483,7 +483,7 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1,	/* Passed set_memory_ro() checkpoint */
+				undo_set_mem:1, /* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -681,7 +681,6 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
-	fp->undo_set_mem = 1;
 	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
@@ -694,6 +693,7 @@ static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
 	set_memory_ro((unsigned long)hdr, hdr->pages);
+	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
 static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
diff --git a/kernel/module.c b/kernel/module.c
index 2ad1b5239910..ae1b77da6a20 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1950,8 +1950,13 @@ void module_enable_ro(const struct module *mod, bool after_init)
 		return;
 
 	frob_text(&mod->core_layout, set_memory_ro);
+	frob_text(&mod->core_layout, set_memory_x);
+
 	frob_rodata(&mod->core_layout, set_memory_ro);
+
 	frob_text(&mod->init_layout, set_memory_ro);
+	frob_text(&mod->init_layout, set_memory_x);
+
 	frob_rodata(&mod->init_layout, set_memory_ro);
 
 	if (after_init)
-- 
2.17.1
