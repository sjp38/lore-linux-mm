Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37A598E00E4
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 19:12:11 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id p15so13958736pfk.7
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 16:12:11 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id f18si13139318pgl.457.2018.12.11.16.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 16:12:09 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v2 2/4] modules: Add new special vfree flags
Date: Tue, 11 Dec 2018 16:03:52 -0800
Message-Id: <20181212000354.31955-3-rick.p.edgecombe@intel.com>
In-Reply-To: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, luto@kernel.org, will.deacon@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, naveen.n.rao@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, mhiramat@kernel.org, rostedt@goodmis.org, mingo@redhat.com, ast@kernel.org, daniel@iogearbox.net, jeyu@kernel.org, namit@vmware.com, netdev@vger.kernel.org, ard.biesheuvel@linaro.org, jannh@google.com
Cc: kristen@linux.intel.com, dave.hansen@intel.com, deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Add new flags for handling freeing of special permissioned memory in vmalloc,
and remove places where the handling was done in module.c.

This will enable this flag for all architectures.

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 kernel/module.c | 43 ++++++++++++-------------------------------
 1 file changed, 12 insertions(+), 31 deletions(-)

diff --git a/kernel/module.c b/kernel/module.c
index 49a405891587..910f92b402f8 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -1941,11 +1941,23 @@ void module_disable_ro(const struct module *mod)
 	frob_rodata(&mod->init_layout, set_memory_rw);
 }
 
+static void module_set_vm_flags(const struct module_layout *layout)
+{
+	struct vm_struct *vm = find_vm_area(layout->base);
+
+	if (vm) {
+		vm->flags |= VM_HAS_SPECIAL_PERMS;
+		vm->flags |= VM_IMMEDIATE_UNMAP;
+	}
+}
+
 void module_enable_ro(const struct module *mod, bool after_init)
 {
 	if (!rodata_enabled)
 		return;
 
+	module_set_vm_flags(&mod->core_layout);
+	module_set_vm_flags(&mod->init_layout);
 	frob_text(&mod->core_layout, set_memory_ro);
 	frob_rodata(&mod->core_layout, set_memory_ro);
 	frob_text(&mod->init_layout, set_memory_ro);
@@ -1964,15 +1976,6 @@ static void module_enable_nx(const struct module *mod)
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
@@ -2016,23 +2019,8 @@ void set_all_modules_text_ro(void)
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
@@ -2163,7 +2151,6 @@ static void free_module(struct module *mod)
 	mutex_unlock(&module_mutex);
 
 	/* This may be empty, but that's OK */
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	module_memfree(mod->init_layout.base);
 	kfree(mod->args);
@@ -2173,7 +2160,6 @@ static void free_module(struct module *mod)
 	lockdep_free_key_range(mod->core_layout.base, mod->core_layout.size);
 
 	/* Finally, free the core (containing the module structure) */
-	disable_ro_nx(&mod->core_layout);
 	module_memfree(mod->core_layout.base);
 }
 
@@ -3497,7 +3483,6 @@ static noinline int do_init_module(struct module *mod)
 #endif
 	module_enable_ro(mod, true);
 	mod_tree_remove_init(mod);
-	disable_ro_nx(&mod->init_layout);
 	module_arch_freeing_init(mod);
 	mod->init_layout.base = NULL;
 	mod->init_layout.size = 0;
@@ -3812,10 +3797,6 @@ static int load_module(struct load_info *info, const char __user *uargs,
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
