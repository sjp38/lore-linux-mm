Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68D2F6B227A
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 18:22:08 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 4so4268874plc.5
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 15:22:08 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id o3-v6si47169979pld.329.2018.11.20.15.22.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 15:22:06 -0800 (PST)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v9 RESEND 3/4] vmalloc: Add debugfs modfraginfo
Date: Tue, 20 Nov 2018 15:23:11 -0800
Message-Id: <20181120232312.30037-4-rick.p.edgecombe@intel.com>
In-Reply-To: <20181120232312.30037-1-rick.p.edgecombe@intel.com>
References: <20181120232312.30037-1-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jeyu@kernel.org, akpm@linux-foundation.org, willy@infradead.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
Cc: kristen@linux.intel.com, dave.hansen@intel.com, arjan@linux.intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Add debugfs file "modfraginfo" for providing info on module space fragmentation.
This can be used for determining if loadable module randomization is causing any
problems for extreme module loading situations, like huge numbers of modules or
extremely large modules.

Sample output when KASLR is enabled and X86_64 is configured:
	Largest free space:	897912 kB
	  Total free space:	1025424 kB
Allocations in backup area:	0

Sample output when just X86_64:
	Largest free space:	897912 kB
	  Total free space:	1025424 kB

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
---
 mm/vmalloc.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 98 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b8b34d319c85..63894cb50873 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -18,6 +18,7 @@
 #include <linux/interrupt.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/debugfs.h>
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
 #include <linux/list.h>
@@ -36,6 +37,12 @@
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
+#ifdef CONFIG_X86
+#include <asm/page_types.h>
+#include <asm/setup.h>
+#include <asm/kaslr_modules.h>
+#endif
+
 #include "internal.h"
 
 struct vfree_deferred {
@@ -2415,7 +2422,6 @@ void free_vm_area(struct vm_struct *area)
 }
 EXPORT_SYMBOL_GPL(free_vm_area);
 
-#ifdef CONFIG_SMP
 static struct vmap_area *node_to_va(struct rb_node *n)
 {
 	return rb_entry_safe(n, struct vmap_area, rb_node);
@@ -2463,6 +2469,7 @@ static bool pvm_find_next_prev(unsigned long end,
 	return true;
 }
 
+#ifdef CONFIG_SMP
 /**
  * pvm_determine_end - find the highest aligned address between two vmap_areas
  * @pnext: in/out arg for the next vmap_area
@@ -2804,7 +2811,96 @@ static int __init proc_vmalloc_init(void)
 		proc_create_seq("vmallocinfo", 0400, NULL, &vmalloc_op);
 	return 0;
 }
-module_init(proc_vmalloc_init);
+#elif defined(CONFIG_DEBUG_FS)
+static int __init proc_vmalloc_init(void)
+{
+	return 0;
+}
+#endif
+
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_RANDOMIZE_FINE_MODULE)
+static inline unsigned long is_in_backup(unsigned long addr)
+{
+	return addr >= MODULES_VADDR + get_modules_rand_len();
+}
+
+static int modulefraginfo_debug_show(struct seq_file *m, void *v)
+{
+	unsigned long last_end = MODULES_VADDR;
+	unsigned long total_free = 0;
+	unsigned long largest_free = 0;
+	unsigned long backup_cnt = 0;
+	unsigned long gap;
+	struct vmap_area *prev, *cur = NULL;
+
+	spin_lock(&vmap_area_lock);
+
+	if (!pvm_find_next_prev(MODULES_VADDR, &cur, &prev) || !cur)
+		goto done;
+
+	for (; cur->va_end <= MODULES_END; cur = list_next_entry(cur, list)) {
+		/* Don't count areas that are marked to be lazily freed */
+		if (!(cur->flags & VM_LAZY_FREE)) {
+			if (kaslr_mod_randomize_each_module())
+				backup_cnt += is_in_backup(cur->va_start);
+			gap = cur->va_start - last_end;
+			if (gap > largest_free)
+				largest_free = gap;
+			total_free += gap;
+			last_end = cur->va_end;
+		}
+
+		if (list_is_last(&cur->list, &vmap_area_list))
+			break;
+	}
+
+done:
+	gap = (MODULES_END - last_end);
+	if (gap > largest_free)
+		largest_free = gap;
+	total_free += gap;
 
+	spin_unlock(&vmap_area_lock);
+
+	seq_printf(m, "\tLargest free space:\t%lu kB\n", largest_free / 1024);
+	seq_printf(m, "\t  Total free space:\t%lu kB\n", total_free / 1024);
+
+	if (kaslr_mod_randomize_each_module())
+		seq_printf(m, "Allocations in backup area:\t%lu\n", backup_cnt);
+
+	return 0;
+}
+
+static int proc_module_frag_debug_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, modulefraginfo_debug_show, NULL);
+}
+
+static const struct file_operations debug_module_frag_operations = {
+	.open       = proc_module_frag_debug_open,
+	.read       = seq_read,
+	.llseek     = seq_lseek,
+	.release    = single_release,
+};
+
+static void __init debug_modfrag_init(void)
+{
+	debugfs_create_file("modfraginfo", 0400, NULL, NULL,
+			&debug_module_frag_operations);
+}
+#elif defined(CONFIG_DEBUG_FS) || defined(CONFIG_PROC_FS)
+static void __init debug_modfrag_init(void)
+{
+}
 #endif
 
+#if defined(CONFIG_DEBUG_FS) || defined(CONFIG_PROC_FS)
+static int __init info_vmalloc_init(void)
+{
+	proc_vmalloc_init();
+	debug_modfrag_init();
+	return 0;
+}
+
+module_init(info_vmalloc_init);
+#endif
-- 
2.17.1
