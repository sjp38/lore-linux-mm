Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D225A6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 08:17:27 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id x13so13386109wgg.12
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 05:17:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o13si2283642wie.7.2015.02.10.05.17.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Feb 2015 05:17:23 -0800 (PST)
Date: Tue, 10 Feb 2015 14:17:21 +0100 (CET)
From: Jiri Kosina <jkosina@suse.cz>
Subject: [PATCH] x86, kaslr: propagate base load address calculation
Message-ID: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, "H. Peter Anvin" <hpa@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, live-patching@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

Commit e2b32e678 ("x86, kaslr: randomize module base load address") makes 
the base address for module to be unconditionally randomized in case when 
CONFIG_RANDOMIZE_BASE is defined and "nokaslr" option isn't present on the 
commandline.

This is not consistent with how choose_kernel_location() decides whether 
it will randomize kernel load base.

Namely, CONFIG_HIBERNATION disables kASLR (unless "kaslr" option is 
explicitly specified on kernel commandline), which makes the state space 
larger than what module loader is looking at. IOW CONFIG_HIBERNATION && 
CONFIG_RANDOMIZE_BASE is a valid config option, kASLR wouldn't be applied 
by default in that case, but module loader is not aware of that.

Instead of fixing the logic in module.c, this patch takes more generic 
aproach, and exposes __KERNEL_OFFSET macro, which calculates the real 
offset that has been established by choose_kernel_location() during boot. 
This can be used later by other kernel code as well (such as, but not 
limited to, live patching).

OOPS offset dumper and module loader are converted to that they make use 
of this macro as well.

Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 arch/x86/include/asm/page_types.h |  4 ++++
 arch/x86/kernel/module.c          | 10 +---------
 arch/x86/kernel/setup.c           |  4 ++--
 3 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index f97fbe3..7f18eaf 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -46,6 +46,10 @@
 
 #ifndef __ASSEMBLY__
 
+/* Return kASLR relocation offset */
+extern char _text[];
+#define __KERNEL_OFFSET ((unsigned long)&_text - __START_KERNEL)
+
 extern int devmem_is_allowed(unsigned long pagenr);
 
 extern unsigned long max_low_pfn_mapped;
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index e69f988..d236bd2 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -46,21 +46,13 @@ do {							\
 
 #ifdef CONFIG_RANDOMIZE_BASE
 static unsigned long module_load_offset;
-static int randomize_modules = 1;
 
 /* Mutex protects the module_load_offset. */
 static DEFINE_MUTEX(module_kaslr_mutex);
 
-static int __init parse_nokaslr(char *p)
-{
-	randomize_modules = 0;
-	return 0;
-}
-early_param("nokaslr", parse_nokaslr);
-
 static unsigned long int get_module_load_offset(void)
 {
-	if (randomize_modules) {
+	if (__KERNEL_OFFSET) {
 		mutex_lock(&module_kaslr_mutex);
 		/*
 		 * Calculate the module_load_offset the first time this
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index c4648ada..08124a1 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -833,8 +833,8 @@ dump_kernel_offset(struct notifier_block *self, unsigned long v, void *p)
 {
 	pr_emerg("Kernel Offset: 0x%lx from 0x%lx "
 		 "(relocation range: 0x%lx-0x%lx)\n",
-		 (unsigned long)&_text - __START_KERNEL, __START_KERNEL,
-		 __START_KERNEL_map, MODULES_VADDR-1);
+		 __KERNEL_OFFSET, __START_KERNEL, __START_KERNEL_map,
+		 MODULES_VADDR-1);
 
 	return 0;
 }

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
