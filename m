Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id BA0666B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 14:26:08 -0400 (EDT)
Subject: [PATCH 03/28] proc: Split kcore bits from linux/procfs.h into
 linux/kcore.h [RFC]
From: David Howells <dhowells@redhat.com>
Date: Tue, 16 Apr 2013 19:26:01 +0100
Message-ID: <20130416182601.27773.46395.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
References: <20130416182550.27773.89310.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org, linux-mm@kvack.org, x86@kernel.org, sparclinux@vger.kernel.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org

Split kcore bits from linux/procfs.h into linux/kcore.h.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: linux-mips@linux-mips.org
cc: sparclinux@vger.kernel.org
cc: x86@kernel.org
cc: linux-mm@kvack.org
---

 arch/mips/mm/init.c     |    1 +
 arch/score/mm/init.c    |    2 +-
 arch/x86/mm/init_64.c   |    1 +
 fs/proc/kcore.c         |    1 +
 fs/proc/vmcore.c        |    3 ++-
 include/linux/kcore.h   |   38 ++++++++++++++++++++++++++++++++++++++
 include/linux/proc_fs.h |   31 -------------------------------
 7 files changed, 44 insertions(+), 33 deletions(-)
 create mode 100644 include/linux/kcore.h

diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index 6792925..60547b7 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -29,6 +29,7 @@
 #include <linux/pfn.h>
 #include <linux/hardirq.h>
 #include <linux/gfp.h>
+#include <linux/kcore.h>
 
 #include <asm/asm-offsets.h>
 #include <asm/bootinfo.h>
diff --git a/arch/score/mm/init.c b/arch/score/mm/init.c
index cee6bce..8b6f796 100644
--- a/arch/score/mm/init.c
+++ b/arch/score/mm/init.c
@@ -31,7 +31,7 @@
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/pagemap.h>
-#include <linux/proc_fs.h>
+#include <linux/kcore.h>
 #include <linux/sched.h>
 #include <linux/initrd.h>
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..24ceda0 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -32,6 +32,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/nmi.h>
 #include <linux/gfp.h>
+#include <linux/kcore.h>
 
 #include <asm/processor.h>
 #include <asm/bios_ebda.h>
diff --git a/fs/proc/kcore.c b/fs/proc/kcore.c
index eda6f01..8e6ce83 100644
--- a/fs/proc/kcore.c
+++ b/fs/proc/kcore.c
@@ -11,6 +11,7 @@
 
 #include <linux/mm.h>
 #include <linux/proc_fs.h>
+#include <linux/kcore.h>
 #include <linux/user.h>
 #include <linux/capability.h>
 #include <linux/elf.h>
diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
index b870f74..38edddc 100644
--- a/fs/proc/vmcore.c
+++ b/fs/proc/vmcore.c
@@ -8,7 +8,7 @@
  */
 
 #include <linux/mm.h>
-#include <linux/proc_fs.h>
+#include <linux/kcore.h>
 #include <linux/user.h>
 #include <linux/elf.h>
 #include <linux/elfcore.h>
@@ -22,6 +22,7 @@
 #include <linux/list.h>
 #include <asm/uaccess.h>
 #include <asm/io.h>
+#include "internal.h"
 
 /* List representing chunks of contiguous memory areas and their offsets in
  * vmcore file.
diff --git a/include/linux/kcore.h b/include/linux/kcore.h
new file mode 100644
index 0000000..d927622
--- /dev/null
+++ b/include/linux/kcore.h
@@ -0,0 +1,38 @@
+/*
+ * /proc/kcore definitions
+ */
+#ifndef _LINUX_KCORE_H
+#define _LINUX_KCORE_H
+
+enum kcore_type {
+	KCORE_TEXT,
+	KCORE_VMALLOC,
+	KCORE_RAM,
+	KCORE_VMEMMAP,
+	KCORE_OTHER,
+};
+
+struct kcore_list {
+	struct list_head list;
+	unsigned long addr;
+	size_t size;
+	int type;
+};
+
+struct vmcore {
+	struct list_head list;
+	unsigned long long paddr;
+	unsigned long long size;
+	loff_t offset;
+};
+
+#ifdef CONFIG_PROC_KCORE
+extern void kclist_add(struct kcore_list *, void *, size_t, int type);
+#else
+static inline
+void kclist_add(struct kcore_list *new, void *addr, size_t size, int type)
+{
+}
+#endif
+
+#endif /* _LINUX_KCORE_H */
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index f5105f4..805edac 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -68,28 +68,6 @@ struct proc_dir_entry {
 	char name[];
 };
 
-enum kcore_type {
-	KCORE_TEXT,
-	KCORE_VMALLOC,
-	KCORE_RAM,
-	KCORE_VMEMMAP,
-	KCORE_OTHER,
-};
-
-struct kcore_list {
-	struct list_head list;
-	unsigned long addr;
-	size_t size;
-	int type;
-};
-
-struct vmcore {
-	struct list_head list;
-	unsigned long long paddr;
-	unsigned long long size;
-	loff_t offset;
-};
-
 #ifdef CONFIG_PROC_FS
 
 extern void proc_root_init(void);
@@ -214,15 +192,6 @@ static inline void proc_free_inum(unsigned int inum)
 }
 #endif /* CONFIG_PROC_FS */
 
-#if !defined(CONFIG_PROC_KCORE)
-static inline void
-kclist_add(struct kcore_list *new, void *addr, size_t size, int type)
-{
-}
-#else
-extern void kclist_add(struct kcore_list *, void *, size_t, int type);
-#endif
-
 struct nsproxy;
 struct proc_ns_operations {
 	const char *name;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
