Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id EEA116B0037
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:33:08 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 2/8] mm, vmalloc: move get_vmalloc_info() to vmalloc.c
Date: Wed, 13 Mar 2013 15:32:54 +0900
Message-Id: <1363156381-2881-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1363156381-2881-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Anderson <anderson@redhat.com>, Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, Bob Liu <lliubbo@gmail.com>, Pekka Enberg <penberg@kernel.org>, kexec@lists.infradead.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <js1304@gmail.com>

Now get_vmalloc_info() is in fs/proc/mmu.c. There is no reason
that this code must be here and it's implementation needs vmlist_lock
and it iterate a vmlist which may be internal data structure for vmalloc.

It is preferable that vmlist_lock and vmlist is only used in vmalloc.c
for maintainability. So move the code to vmalloc.c

Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/fs/proc/Makefile b/fs/proc/Makefile
index 712f24d..ab30716 100644
--- a/fs/proc/Makefile
+++ b/fs/proc/Makefile
@@ -5,7 +5,7 @@
 obj-y   += proc.o
 
 proc-y			:= nommu.o task_nommu.o
-proc-$(CONFIG_MMU)	:= mmu.o task_mmu.o
+proc-$(CONFIG_MMU)	:= task_mmu.o
 
 proc-y       += inode.o root.o base.o generic.o array.o \
 		fd.o
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 85ff3a4..7571035 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -30,24 +30,6 @@ extern int proc_net_init(void);
 static inline int proc_net_init(void) { return 0; }
 #endif
 
-struct vmalloc_info {
-	unsigned long	used;
-	unsigned long	largest_chunk;
-};
-
-#ifdef CONFIG_MMU
-#define VMALLOC_TOTAL (VMALLOC_END - VMALLOC_START)
-extern void get_vmalloc_info(struct vmalloc_info *vmi);
-#else
-
-#define VMALLOC_TOTAL 0UL
-#define get_vmalloc_info(vmi)			\
-do {						\
-	(vmi)->used = 0;			\
-	(vmi)->largest_chunk = 0;		\
-} while(0)
-#endif
-
 extern int proc_tid_stat(struct seq_file *m, struct pid_namespace *ns,
 				struct pid *pid, struct task_struct *task);
 extern int proc_tgid_stat(struct seq_file *m, struct pid_namespace *ns,
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 1efaaa1..5aa847a 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -11,6 +11,7 @@
 #include <linux/swap.h>
 #include <linux/vmstat.h>
 #include <linux/atomic.h>
+#include <linux/vmalloc.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include "internal.h"
diff --git a/fs/proc/mmu.c b/fs/proc/mmu.c
deleted file mode 100644
index 8ae221d..0000000
--- a/fs/proc/mmu.c
+++ /dev/null
@@ -1,60 +0,0 @@
-/* mmu.c: mmu memory info files
- *
- * Copyright (C) 2004 Red Hat, Inc. All Rights Reserved.
- * Written by David Howells (dhowells@redhat.com)
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version
- * 2 of the License, or (at your option) any later version.
- */
-#include <linux/spinlock.h>
-#include <linux/vmalloc.h>
-#include <linux/highmem.h>
-#include <asm/pgtable.h>
-#include "internal.h"
-
-void get_vmalloc_info(struct vmalloc_info *vmi)
-{
-	struct vm_struct *vma;
-	unsigned long free_area_size;
-	unsigned long prev_end;
-
-	vmi->used = 0;
-
-	if (!vmlist) {
-		vmi->largest_chunk = VMALLOC_TOTAL;
-	}
-	else {
-		vmi->largest_chunk = 0;
-
-		prev_end = VMALLOC_START;
-
-		read_lock(&vmlist_lock);
-
-		for (vma = vmlist; vma; vma = vma->next) {
-			unsigned long addr = (unsigned long) vma->addr;
-
-			/*
-			 * Some archs keep another range for modules in vmlist
-			 */
-			if (addr < VMALLOC_START)
-				continue;
-			if (addr >= VMALLOC_END)
-				break;
-
-			vmi->used += vma->size;
-
-			free_area_size = addr - prev_end;
-			if (vmi->largest_chunk < free_area_size)
-				vmi->largest_chunk = free_area_size;
-
-			prev_end = vma->size + addr;
-		}
-
-		if (VMALLOC_END - prev_end > vmi->largest_chunk)
-			vmi->largest_chunk = VMALLOC_END - prev_end;
-
-		read_unlock(&vmlist_lock);
-	}
-}
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 6071e91..698b1e5 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -158,4 +158,22 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 # endif
 #endif
 
+struct vmalloc_info {
+	unsigned long   used;
+	unsigned long   largest_chunk;
+};
+
+#ifdef CONFIG_MMU
+#define VMALLOC_TOTAL (VMALLOC_END - VMALLOC_START)
+extern void get_vmalloc_info(struct vmalloc_info *vmi);
+#else
+
+#define VMALLOC_TOTAL 0UL
+#define get_vmalloc_info(vmi)			\
+do {						\
+	(vmi)->used = 0;			\
+	(vmi)->largest_chunk = 0;		\
+} while (0)
+#endif
+
 #endif /* _LINUX_VMALLOC_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 0f751f2..1d9878b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2645,5 +2645,49 @@ static int __init proc_vmalloc_init(void)
 	return 0;
 }
 module_init(proc_vmalloc_init);
+
+void get_vmalloc_info(struct vmalloc_info *vmi)
+{
+	struct vm_struct *vma;
+	unsigned long free_area_size;
+	unsigned long prev_end;
+
+	vmi->used = 0;
+
+	if (!vmlist) {
+		vmi->largest_chunk = VMALLOC_TOTAL;
+	} else {
+		vmi->largest_chunk = 0;
+
+		prev_end = VMALLOC_START;
+
+		read_lock(&vmlist_lock);
+
+		for (vma = vmlist; vma; vma = vma->next) {
+			unsigned long addr = (unsigned long) vma->addr;
+
+			/*
+			 * Some archs keep another range for modules in vmlist
+			 */
+			if (addr < VMALLOC_START)
+				continue;
+			if (addr >= VMALLOC_END)
+				break;
+
+			vmi->used += vma->size;
+
+			free_area_size = addr - prev_end;
+			if (vmi->largest_chunk < free_area_size)
+				vmi->largest_chunk = free_area_size;
+
+			prev_end = vma->size + addr;
+		}
+
+		if (VMALLOC_END - prev_end > vmi->largest_chunk)
+			vmi->largest_chunk = VMALLOC_END - prev_end;
+
+		read_unlock(&vmlist_lock);
+	}
+}
 #endif
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
