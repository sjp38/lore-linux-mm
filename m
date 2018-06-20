Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6320A6B0008
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:09:35 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f5-v6so511142plf.18
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 15:09:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r10-v6si3395620pfe.121.2018.06.20.15.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 15:09:34 -0700 (PDT)
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH 3/3] vmalloc: Add debugfs modfraginfo
Date: Wed, 20 Jun 2018 15:09:30 -0700
Message-Id: <1529532570-21765-4-git-send-email-rick.p.edgecombe@intel.com>
In-Reply-To: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
References: <1529532570-21765-1-git-send-email-rick.p.edgecombe@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com
Cc: kristen.c.accardi@intel.com, dave.hansen@intel.com, arjan.van.de.ven@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>

Add debugfs file "modfraginfo" for providing info on module space
fragmentation.  This can be used for determining if loadable module
randomization is causing any problems for extreme module loading situations,
like huge numbers of modules or extremely large modules.

Sample output when RANDOMIZE_BASE and X86_64 is configured:
Largest free space:		847253504
External Memory Fragementation:	20%
Allocations in backup area:	0

Sample output otherwise:
Largest free space:		847253504
External Memory Fragementation:	20%

Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 mm/vmalloc.c | 110 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 109 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 9e0820c9..afb8fe9 100644
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
 
@@ -2785,7 +2787,113 @@ static int __init proc_vmalloc_init(void)
 		proc_create_seq("vmallocinfo", 0400, NULL, &vmalloc_op);
 	return 0;
 }
-module_init(proc_vmalloc_init);
+#else
+static int proc_vmalloc_init(void)
+{
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_DEBUG_FS
+#if defined(CONFIG_RANDOMIZE_BASE) && defined(CONFIG_X86_64)
+static void print_backup_area(struct seq_file *m, unsigned long backup_cnt)
+{
+	if (kaslr_enabled())
+		seq_printf(m, "Allocations in backup area:\t%lu\n", backup_cnt);
+}
+static unsigned long get_backup_start(void)
+{
+	return MODULES_VADDR + MODULES_RAND_LEN;
+}
+#else
+static void print_backup_area(struct seq_file *m, unsigned long backup_cnt)
+{
+}
+static unsigned long get_backup_start(void)
+{
+	return 0;
+}
+#endif
+
+static int modulefraginfo_debug_show(struct seq_file *m, void *v)
+{
+	struct list_head *i;
+	unsigned long last_end = MODULES_VADDR;
+	unsigned long total_free = 0;
+	unsigned long largest_free = 0;
+	unsigned long backup_cnt = 0;
+	unsigned long gap;
+
+	spin_lock(&vmap_area_lock);
+
+	list_for_each(i, &vmap_area_list) {
+		struct vmap_area *obj = list_entry(i, struct vmap_area, list);
+
+		if (!(obj->flags & VM_LAZY_FREE)
+			&& obj->va_start >= MODULES_VADDR
+			&& obj->va_end <= MODULES_END) {
+
+			if (obj->va_start >= get_backup_start())
+				backup_cnt++;
+
+			gap = (obj->va_start - last_end);
+			if (gap > largest_free)
+				largest_free = gap;
+			total_free += gap;
+
+			last_end = obj->va_end;
+		}
+	}
+
+	gap = (MODULES_END - last_end);
+	if (gap > largest_free)
+		largest_free = gap;
+	total_free += gap;
+
+	spin_unlock(&vmap_area_lock);
+
+	seq_printf(m, "Largest free space:\t\t%lu\n", largest_free);
+	if (total_free)
+		seq_printf(m, "External Memory Fragementation:\t%lu%%\n",
+			100-(100*largest_free/total_free));
+	else
+		seq_puts(m, "External Memory Fragementation:\t0%%\n");
+
+	print_backup_area(m, backup_cnt);
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
 
+static void debug_modfrag_init(void)
+{
+	debugfs_create_file("modfraginfo", 0x0400, NULL, NULL,
+			&debug_module_frag_operations);
+}
+#else
+static void debug_modfrag_init(void)
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
