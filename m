Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8A456B026E
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 16:34:21 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id d10-v6so1260289pll.22
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 13:34:21 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id n3-v6si18917408pld.146.2018.08.15.13.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 13:34:20 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v3 3/3] vmalloc: Add debugfs modfraginfo
Date: Wed, 15 Aug 2018 13:30:19 -0700
Message-Id: <1534365020-18943-4-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1534365020-18943-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1534365020-18943-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, daniel@iogearbox.net, jannh@google.com, keescook@chromium.org
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
---
 mm/vmalloc.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 88 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fb85ec9..cb55138 100644
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
@@ -33,6 +34,7 @@
 #include <linux/bitops.h>
 
 #include <linux/uaccess.h>
+#include <asm/setup.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
@@ -2925,7 +2927,92 @@ static int __init proc_vmalloc_init(void)
 		proc_create_seq("vmallocinfo", 0400, NULL, &vmalloc_op);
 	return 0;
 }
-module_init(proc_vmalloc_init);
+#else
+static int __init proc_vmalloc_init(void)
+{
+	return 0;
+}
+#endif
+
+#if defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_64)
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
+		if ((cur->flags & VM_LAZY_FREE))
+			continue;
+
+		if (cur->va_start >= MODULES_VADDR + MODULES_RAND_LEN)
+			backup_cnt++;
+		gap = cur->va_start - last_end;
+		if (gap > largest_free)
+			largest_free = gap;
+		total_free += gap;
+		last_end = cur->va_end;
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
+
+	spin_unlock(&vmap_area_lock);
 
+	seq_printf(m, "\tLargest free space:\t%lu kB\n", largest_free / 1024);
+	seq_printf(m, "\t  Total free space:\t%lu kB\n", total_free / 1024);
+
+	if (IS_ENABLED(CONFIG_RANDOMIZE_BASE) && kaslr_enabled())
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
+#else /* defined(CONFIG_DEBUG_FS) && defined(CONFIG_X86_64) */
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
2.7.4
