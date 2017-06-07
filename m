Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CDEE26B037C
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 17:17:53 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 67so7124352itx.11
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 14:17:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c204sor1243369ioc.92.2017.06.07.14.17.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 14:17:53 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [RFC v4 2/3] lkdtm: Add tests for XPFO
Date: Wed,  7 Jun 2017 15:16:52 -0600
Message-Id: <20170607211653.14536-3-tycho@docker.com>
In-Reply-To: <20170607211653.14536-1-tycho@docker.com>
References: <20170607211653.14536-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Juerg Haefliger <juergh@gmail.com>, kernel-hardening@lists.openwall.com, Juerg Haefliger <juerg.haefliger@hpe.com>, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
minor fixups for 5-level paging, whitespace
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 drivers/misc/Makefile     |   1 +
 drivers/misc/lkdtm.h      |   3 ++
 drivers/misc/lkdtm_core.c |   1 +
 drivers/misc/lkdtm_xpfo.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 110 insertions(+)

diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 81ef3e67acc9..e0b5065478be 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -61,6 +61,7 @@ lkdtm-$(CONFIG_LKDTM)		+= lkdtm_heap.o
 lkdtm-$(CONFIG_LKDTM)		+= lkdtm_perms.o
 lkdtm-$(CONFIG_LKDTM)		+= lkdtm_rodata_objcopy.o
 lkdtm-$(CONFIG_LKDTM)		+= lkdtm_usercopy.o
+lkdtm-$(CONFIG_LKDTM)		+= lkdtm_xpfo.o
 
 KCOV_INSTRUMENT_lkdtm_rodata.o	:= n
 
diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
index 3b4976396ec4..ed9c3131bf41 100644
--- a/drivers/misc/lkdtm.h
+++ b/drivers/misc/lkdtm.h
@@ -64,4 +64,7 @@ void lkdtm_USERCOPY_STACK_FRAME_FROM(void);
 void lkdtm_USERCOPY_STACK_BEYOND(void);
 void lkdtm_USERCOPY_KERNEL(void);
 
+/* lkdtm_xpfo.c */
+void lkdtm_XPFO_READ_USER(void);
+
 #endif
diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
index 42d2b8e31e6b..4f3b60bb2d31 100644
--- a/drivers/misc/lkdtm_core.c
+++ b/drivers/misc/lkdtm_core.c
@@ -235,6 +235,7 @@ struct crashtype crashtypes[] = {
 	CRASHTYPE(USERCOPY_STACK_FRAME_FROM),
 	CRASHTYPE(USERCOPY_STACK_BEYOND),
 	CRASHTYPE(USERCOPY_KERNEL),
+	CRASHTYPE(XPFO_READ_USER),
 };
 
 
diff --git a/drivers/misc/lkdtm_xpfo.c b/drivers/misc/lkdtm_xpfo.c
new file mode 100644
index 000000000000..540a2539a88b
--- /dev/null
+++ b/drivers/misc/lkdtm_xpfo.c
@@ -0,0 +1,105 @@
+/*
+ * This is for all the tests related to XPFO (eXclusive Page Frame Ownership).
+ */
+
+#include "lkdtm.h"
+
+#include <linux/mman.h>
+#include <linux/uaccess.h>
+
+/* This is hacky... */
+#ifdef CONFIG_ARM64
+#define pud_large(pud) (pud_sect(pud))
+#define pmd_large(pmd) (pmd_sect(pmd))
+#define PUD_PAGE_MASK PUD_MASK
+#define PMD_PAGE_MASK PMD_MASK
+#endif
+
+static phys_addr_t user_virt_to_phys(unsigned long addr)
+{
+	phys_addr_t phys_addr;
+	unsigned long offset;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+	p4d_t *p4d;
+
+	pgd = pgd_offset(current->mm, addr);
+	if (pgd_none(*pgd))
+                return 0;
+
+	p4d = p4d_offset(pgd, addr);
+	if (p4d_none(*p4d))
+		return 0;
+
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return 0;
+
+	if (pud_large(*pud) || !pud_present(*pud)) {
+		phys_addr = (unsigned long)pud_pfn(*pud) << PAGE_SHIFT;
+		offset = addr & ~PUD_PAGE_MASK;
+		goto out;
+	}
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return 0;
+
+	if (pmd_large(*pmd) || !pmd_present(*pmd)) {
+		phys_addr = (unsigned long)pmd_pfn(*pmd) << PAGE_SHIFT;
+		offset = addr & ~PMD_PAGE_MASK;
+		goto out;
+	}
+
+	pte =  pte_offset_kernel(pmd, addr);
+	phys_addr = (phys_addr_t)pte_pfn(*pte) << PAGE_SHIFT;
+	offset = addr & ~PAGE_MASK;
+
+out:
+	return (phys_addr_t)(phys_addr | offset);
+}
+
+/* Read from userspace via the kernel's linear map */
+void lkdtm_XPFO_READ_USER(void)
+{
+	unsigned long user_addr, user_data = 0xdeadbeef;
+	phys_addr_t phys_addr;
+	void *virt_addr;
+
+	user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
+			    PROT_READ | PROT_WRITE | PROT_EXEC,
+			    MAP_ANONYMOUS | MAP_PRIVATE, 0);
+	if (user_addr >= TASK_SIZE) {
+		pr_warn("Failed to allocate user memory\n");
+		return;
+	}
+
+	if (copy_to_user((void __user *)user_addr, &user_data,
+			 sizeof(user_data))) {
+		pr_warn("copy_to_user failed\n");
+		goto free_user;
+	}
+
+	phys_addr = user_virt_to_phys(user_addr);
+	if (!phys_addr) {
+		pr_warn("Failed to get physical address of user memory\n");
+		goto free_user;
+	}
+
+	virt_addr = phys_to_virt(phys_addr);
+	if (phys_addr != virt_to_phys(virt_addr)) {
+		pr_warn("Physical address of user memory seems incorrect\n");
+		goto free_user;
+	}
+
+	pr_info("Attempting bad read from kernel address %p\n", virt_addr);
+	if (*(unsigned long *)virt_addr == user_data)
+		pr_info("Huh? Bad read succeeded?!\n");
+	else
+		pr_info("Huh? Bad read didn't fail but data is incorrect?!\n");
+
+ free_user:
+	vm_munmap(user_addr, PAGE_SIZE);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
