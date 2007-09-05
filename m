From: Avi Kivity <avi@qumranet.com>
Subject: [PATCH][RFC] pte notifiers -- support for external page tables
Date: Wed,  5 Sep 2007 22:32:44 +0300
Message-Id: <11890207643068-git-send-email-avi@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, shaohua.li@intel.com, Avi Kivity <avi@qumranet.com>
List-ID: <linux-mm.kvack.org>

[resend due to bad alias expansion resulting in some recipients
 being bogus]

Some hardware and software systems maintain page tables outside the normal
Linux page tables, which reference userspace memory.  This includes
Infiniband, other RDMA-capable devices, and kvm (with a pending patch).

Because these systems maintain external page tables (and external tlbs),
Linux cannot demand page this memory and it must be locked.  For kvm at
least, this is a significant reduction in functionality.

This sample patch adds a new mechanism, pte notifiers, that allows drivers
to register an interest in a changes to ptes. Whenever Linux changes a
pte, it will call a notifier to allow the driver to adjust the external
page table and flush its tlb.

Note that only one notifier is implemented, ->clear(), but others should be
similar.

pte notifiers are different from paravirt_ops: they extend the normal
page tables rather than replace them; and they provide high-level information
such as the vma and the virtual address for the driver to use.

Signed-off-by: Avi Kivity <avi@qumranet.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 655094d..5d2bbee 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -14,6 +14,7 @@
 #include <linux/debug_locks.h>
 #include <linux/backing-dev.h>
 #include <linux/mm_types.h>
+#include <linux/pte_notifier.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -108,6 +109,9 @@ struct vm_area_struct {
 #ifndef CONFIG_MMU
 	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
 #endif
+#ifdef CONFIG_PTE_NOTIFIERS
+	struct list_head pte_notifier_list;
+#endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
diff --git a/include/linux/pte_notifier.h b/include/linux/pte_notifier.h
new file mode 100644
index 0000000..d28832b
--- /dev/null
+++ b/include/linux/pte_notifier.h
@@ -0,0 +1,52 @@
+#ifndef _LINUX_PTE_NOTIFIER_H
+#define _LINUX_PTE_NOTIFIER_H
+
+#include <linux/list.h>
+
+struct vm_area_struct;
+
+#ifdef CONFIG_PTE_NOTIFIERS
+
+struct pte_notifier;
+
+struct pte_notifier_ops {
+	void (*close)(struct pte_notifier *pn, struct vm_area_struct *vma);
+	void (*clear)(struct pte_notifier *pn, struct vm_area_struct *vma,
+		      unsigned long address);
+};
+
+struct pte_notifier {
+	struct list_head link;
+	const struct pte_notifier_ops *ops;
+};
+
+
+void vma_init_pte_notifiers(struct vm_area_struct *vma);
+void vma_close_pte_notifiers(struct vm_area_struct *vma);
+void pte_notifier_register(struct pte_notifier *pn,
+			   struct vm_area_struct *vma);
+void pte_notifier_unregister(struct pte_notifier *pn);
+
+#define pte_notifier_call(vma, function, args...)			\
+	do {								\
+		struct pte_notifier *__pn;				\
+									\
+		list_for_each_entry(__pn, &vma->pte_notifier_list, link) \
+			__pn->ops->function(__pn, vma, args);		\
+	} while (0)
+
+#else
+
+static inline void vma_init_pte_notifiers(struct vm_area_struct *vma) {}
+static inline void vma_close_pte_notifiers(struct vm_area_struct *vma) {}
+static inline void pte_notifier_register(struct pte_notifier *pn,
+					 struct vm_area_struct *vma) {}
+static inline void pte_notifier_unregister(struct pte_notifier *pn) {}
+
+#define pte_notifier_call(vma, function, args...) \
+	do { } while (0)
+
+#endif
+
+
+#endif
diff --git a/mm/Kconfig b/mm/Kconfig
index e24d348..7b10151 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -176,3 +176,6 @@ config NR_QUICK
 config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
+
+config PTE_NOTIFIERS
+       bool
diff --git a/mm/Makefile b/mm/Makefile
index 245e33a..59f6a03 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -29,4 +29,5 @@ obj-$(CONFIG_FS_XIP) += filemap_xip.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_PTE_NOTIFIERS) += pte_notifiers.o
 
diff --git a/mm/mmap.c b/mm/mmap.c
index b653721..cc6c4fe 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1134,6 +1134,7 @@ munmap_back:
 	vma->vm_page_prot = protection_map[vm_flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
 	vma->vm_pgoff = pgoff;
+	vma_init_pte_notifiers(vma);
 
 	if (file) {
 		error = -EINVAL;
diff --git a/mm/pte_notifier.c b/mm/pte_notifier.c
new file mode 100644
index 0000000..0b9076c
--- /dev/null
+++ b/mm/pte_notifier.c
@@ -0,0 +1,32 @@
+
+#include <linux/pte_notifier.h>
+
+void vma_init_pte_notifiers(struct vm_area_struct *vma)
+{
+	INIT_LIST_HEAD(&vma->pte_notifier_list);
+}
+EXPORT_SYMBOL_GPL(vma_init_pte_notifiers);
+
+void vma_destroy_pte_notifiers(struct vm_area_struct *vma)
+{
+	struct pte_notifier *pn;
+	struct list_head *n;
+
+	list_for_each_entry_safe(pn, n, &vma->pte_notifier_list, link) {
+		pn->ops->close(__pn, vma);
+		__list_del(n);
+	}
+}
+
+void pte_notifier_register(struct pte_notifier *pn, struct vm_area_struct *vma)
+{
+	list_add(&pn->link, &vma->pte_notifier_list);
+}
+EXPORT_SYMBOL_GPL(pte_notifier_register);
+
+void pte_notifier_unregister(struct pte_notifier *pn)
+{
+	list_del(&pn->link);
+}
+EXPORT_SYMBOL_GPL(pte_notifier_unregister);
+
diff --git a/mm/rmap.c b/mm/rmap.c
index 41ac397..3f61d38 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -682,6 +682,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	}
 
 	/* Nuke the page table entry. */
+	pte_notifier_call(vma, clear, address);
 	flush_cache_page(vma, address, page_to_pfn(page));
 	pteval = ptep_clear_flush(vma, address, pte);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
