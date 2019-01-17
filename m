Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88F8D8E000F
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 19:33:41 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id i124so5030652pgc.2
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:33:41 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 1si7848435plo.195.2019.01.16.16.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 16:33:40 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 16/17] Plug in new special vfree flag
Date: Wed, 16 Jan 2019 16:32:58 -0800
Message-Id: <20190117003259.23141-17-rick.p.edgecombe@intel.com>
In-Reply-To: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
References: <20190117003259.23141-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, linux_dti@icloud.com, linux-integrity@vger.kernel.org, linux-security-module@vger.kernel.org, akpm@linux-foundation.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, will.deacon@arm.com, ard.biesheuvel@linaro.org, kristen@linux.intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Masami Hiramatsu <mhiramat@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, Alexei Starovoitov <ast@kernel.org>, Jessica Yu <jeyu@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E . McKenney" <paulmck@linux.ibm.com>

Add new flag for handling freeing of special permissioned memory in vmalloc
and remove places where memory was set RW before freeing which is no longer
needed.

In kprobes, bpf and ftrace this just adds the flag, and removes the now
unneeded set_memory_ calls before calling vfree.

In modules, the freeing of init sections is moved to a work queue, since
freeing of RO memory is not supported in an interrupt by vmalloc.
Instead of call_rcu, it now uses synchronize_rcu() in the work queue.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Masami Hiramatsu <mhiramat@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Jessica Yu <jeyu@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Paul E. McKenney <paulmck@linux.ibm.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/kernel/ftrace.c       |  6 +--
 arch/x86/kernel/kprobes/core.c |  7 +---
 include/linux/filter.h         | 16 ++-----
 kernel/bpf/core.c              |  1 -
 kernel/module.c                | 77 +++++++++++++++++-----------------
 5 files changed, 45 insertions(+), 62 deletions(-)

diff --git a/arch/x86/kernel/ftrace.c b/arch/x86/kernel/ftrace.c
index eb4a1937e72c..47597e028346 100644
--- a/arch/x86/kernel/ftrace.c
+++ b/arch/x86/kernel/ftrace.c
@@ -692,10 +692,6 @@ static inline void *alloc_tramp(unsigned long size)
 }
 static inline void tramp_free(void *tramp, int size)
 {
-	int npages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-	set_memory_nx((unsigned long)tramp, npages);
-	set_memory_rw((unsigned long)tramp, npages);
 	module_memfree(tramp);
 }
 #else
@@ -820,6 +816,8 @@ create_trampoline(struct ftrace_ops *ops, unsigned int *tramp_size)
 	/* ALLOC_TRAMP flags lets us know we created it */
 	ops->flags |= FTRACE_OPS_FL_ALLOC_TRAMP;
 
+	set_vm_special(trampoline);
+
 	/*
 	 * Module allocation needs to be completed by making the page
 	 * executable. The page is still writable, which is a security hazard,
diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
index fac692e36833..f2fab35bcb82 100644
--- a/arch/x86/kernel/kprobes/core.c
+++ b/arch/x86/kernel/kprobes/core.c
@@ -434,6 +434,7 @@ void *alloc_insn_page(void)
 	if (page == NULL)
 		return NULL;
 
+	set_vm_special(page);
 	/*
 	 * First make the page read-only, and then only then make it executable
 	 * to prevent it from being W+X in between.
@@ -452,12 +453,6 @@ void *alloc_insn_page(void)
 /* Recover page to RW mode before releasing it */
 void free_insn_page(void *page)
 {
-	/*
-	 * First make the page non-executable, and then only then make it
-	 * writable to prevent it from being W+X in between.
-	 */
-	set_memory_nx((unsigned long)page, 1);
-	set_memory_rw((unsigned long)page, 1);
 	module_memfree(page);
 }
 
diff --git a/include/linux/filter.h b/include/linux/filter.h
index f18cd317faf8..0abe812e7b75 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/set_memory.h>
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
 
 #include <net/sch_generic.h>
 
@@ -483,7 +484,6 @@ struct bpf_prog {
 	u16			pages;		/* Number of allocated pages */
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				jit_requested:1,/* archs need to JIT the prog */
-				undo_set_mem:1, /* Passed set_memory_ro() checkpoint */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
 				dst_needed:1,	/* Do we need dst entry? */
@@ -681,26 +681,17 @@ bpf_ctx_narrow_access_ok(u32 off, u32 size, u32 size_default)
 
 static inline void bpf_prog_lock_ro(struct bpf_prog *fp)
 {
+	set_vm_special(fp);
 	set_memory_ro((unsigned long)fp, fp->pages);
 }
 
-static inline void bpf_prog_unlock_ro(struct bpf_prog *fp)
-{
-	if (fp->undo_set_mem)
-		set_memory_rw((unsigned long)fp, fp->pages);
-}
-
 static inline void bpf_jit_binary_lock_ro(struct bpf_binary_header *hdr)
 {
+	set_vm_special(hdr);
 	set_memory_ro((unsigned long)hdr, hdr->pages);
 	set_memory_x((unsigned long)hdr, hdr->pages);
 }
 
-static inline void bpf_jit_binary_unlock_ro(struct bpf_binary_header *hdr)
-{
-	set_memory_rw((unsigned long)hdr, hdr->pages);
-}
-
 static inline struct bpf_binary_header *
 bpf_jit_binary_hdr(const struct bpf_prog *fp)
 {
@@ -735,7 +726,6 @@ void __bpf_prog_free(struct bpf_prog *fp);
 
 static inline void bpf_prog_unlock_free(struct bpf_prog *fp)
 {
-	bpf_prog_unlock_ro(fp);
 	__bpf_prog_free(fp);
 }
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index f908b9356025..a1a4d6f4253c 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -804,7 +804,6 @@ void __weak bpf_jit_free(struct bpf_prog *fp)
 	if (fp->jited) {
 		struct bpf_binary_header *hdr = bpf_jit_binary_hdr(fp);
 
-		bpf_jit_binary_unlock_ro(hdr);
 		bpf_jit_binary_free(hdr);
 
 		WARN_ON_ONCE(!bpf_prog_kallsyms_verify_off(fp));
diff --git a/kernel/module.c b/kernel/module.c
index ae1b77da6a20..1af5c8e19086 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -98,6 +98,10 @@ DEFINE_MUTEX(module_mutex);
 EXPORT_SYMBOL_GPL(module_mutex);
 static LIST_HEAD(modules);
 
+/* Work queue for freeing init sections in success case */
+static struct work_struct init_free_wq;
+static struct llist_head init_free_list;
+
 #ifdef CONFIG_MODULES_TREE_LOOKUP
 
 /*
@@ -1949,6 +1953,8 @@ void module_enable_ro(const struct module *mod, bool after_init)
 	if (!rodata_enabled)
 		return;
 
+	set_vm_special(mod->core_layout.base);
+	set_vm_special(mod->init_layout.base);
 	frob_text(&mod->core_layout, set_memory_ro);
 	frob_text(&mod->core_layout, set_memory_x);
 
@@ -1972,15 +1978,6 @@ static void module_enable_nx(const struct module *mod)
 	frob_writable_data(&mod->init_layout, set_memory_nx);
 }
 
-static void module_disable_nx(const struct module *mod)
-{
-	frob_rodata(&mod->core_layout, set_memory_x);
-	frob_ro_after_init(&mod->core_layout, set_memory_x);
-	frob_writable_data(&mod->core_layout, set_memory_x);
-	frob_rodata(&mod->init_layout, set_memory_x);
-	frob_writable_data(&mod->init_layout, set_memory_x);
-}
-
 /* Iterate through all modules and set each module's text as RW */
 void set_all_modules_text_rw(void)
 {
@@ -2024,23 +2021,8 @@ void set_all_modules_text_ro(void)
 	}
 	mutex_unlock(&module_mutex);
 }
-
-static void disable_ro_nx(const struct module_layout *layout)
-{
-	if (rodata_enabled) {
-		frob_text(layout, set_memory_rw);
-		frob_rodata(layout, set_memory_rw);
-		frob_ro_after_init(layout, set_memory_rw);
-	}
-	frob_rodata(layout, set_memory_x);
-	frob_ro_after_init(layout, set_memory_x);
-	frob_writable_data(layout, set_memory_x);
-}
-
 #else
-static void disable_ro_nx(const struct module_layout *layout) { }
 static void module_enable_nx(const struct module *mod) { }
-static void module_disable_nx(const struct module *mod) { }
 #endif
 
 #ifdef CONFIG_LIVEPATCH
@@ -2120,6 +2102,11 @@ static void free_module_elf(struct module *mod)
 
 void __weak module_memfree(void *module_region)
 {
+	/*
+	 * This memory may be RO, and freeing RO memory in an interrupt is not
+	 * supported by vmalloc.
+	 */
+	WARN_ON(in_interrupt());
 	vfree(module_region);
 }
 
@@ -2171,7 +2158,6 @@ static void free_module(struct module *mod)
 	mutex_unlock(&module_mutex);
 
 	/* This may be empty, but that's OK */
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	module_memfree(mod->init_layout.base);
 	kfree(mod->args);
@@ -2181,7 +2167,6 @@ static void free_module(struct module *mod)
 	lockdep_free_key_range(mod->core_layout.base, mod->core_layout.size);
 
 	/* Finally, free the core (containing the module structure) */
-	disable_ro_nx(&mod->core_layout);
 	module_memfree(mod->core_layout.base);
 }
 
@@ -3424,17 +3409,34 @@ static void do_mod_ctors(struct module *mod)
 
 /* For freeing module_init on success, in case kallsyms traversing */
 struct mod_initfree {
-	struct rcu_head rcu;
+	struct llist_node node;
 	void *module_init;
 };
 
-static void do_free_init(struct rcu_head *head)
+static void do_free_init(struct work_struct *w)
 {
-	struct mod_initfree *m = container_of(head, struct mod_initfree, rcu);
-	module_memfree(m->module_init);
-	kfree(m);
+	struct llist_node *pos, *n, *list;
+	struct mod_initfree *initfree;
+
+	list = llist_del_all(&init_free_list);
+
+	synchronize_rcu();
+
+	llist_for_each_safe(pos, n, list) {
+		initfree = container_of(pos, struct mod_initfree, node);
+		module_memfree(initfree->module_init);
+		kfree(initfree);
+	}
 }
 
+static int __init modules_wq_init(void)
+{
+	INIT_WORK(&init_free_wq, do_free_init);
+	init_llist_head(&init_free_list);
+	return 0;
+}
+module_init(modules_wq_init);
+
 /*
  * This is where the real work happens.
  *
@@ -3511,7 +3513,6 @@ static noinline int do_init_module(struct module *mod)
 #endif
 	module_enable_ro(mod, true);
 	mod_tree_remove_init(mod);
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	mod->init_layout.base = NULL;
 	mod->init_layout.size = 0;
@@ -3522,14 +3523,18 @@ static noinline int do_init_module(struct module *mod)
 	 * We want to free module_init, but be aware that kallsyms may be
 	 * walking this with preempt disabled.  In all the failure paths, we
 	 * call synchronize_rcu(), but we don't want to slow down the success
-	 * path, so use actual RCU here.
+	 * path. We can't do module_memfree in an interrupt, so we do the work
+	 * and call synchronize_rcu() in a work queue.
+	 *
 	 * Note that module_alloc() on most architectures creates W+X page
 	 * mappings which won't be cleaned up until do_free_init() runs.  Any
 	 * code such as mark_rodata_ro() which depends on those mappings to
 	 * be cleaned up needs to sync with the queued work - ie
 	 * rcu_barrier()
 	 */
-	call_rcu(&freeinit->rcu, do_free_init);
+	if (llist_add(&freeinit->node, &init_free_list))
+		schedule_work(&init_free_wq);
+
 	mutex_unlock(&module_mutex);
 	wake_up_all(&module_wq);
 
@@ -3826,10 +3831,6 @@ static int load_module(struct load_info *info, const char __user *uargs,
 	module_bug_cleanup(mod);
 	mutex_unlock(&module_mutex);
 
-	/* we can't deallocate the module until we clear memory protection */
-	module_disable_ro(mod);
-	module_disable_nx(mod);
-
  ddebug_cleanup:
 	ftrace_release_mod(mod);
 	dynamic_debug_remove(mod, info->debug);
-- 
2.17.1
