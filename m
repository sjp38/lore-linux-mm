Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 879956B03BD
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:09:08 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k62so7133378oia.6
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:08 -0700 (PDT)
Received: from mail-io0-x233.google.com (mail-io0-x233.google.com. [2607:f8b0:4001:c06::233])
        by mx.google.com with ESMTPS id g186si3380499oia.177.2017.08.09.13.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:09:07 -0700 (PDT)
Received: by mail-io0-x233.google.com with SMTP id m88so2367508iod.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:07 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v5 10/10] lkdtm: Add test for XPFO
Date: Wed,  9 Aug 2017 14:07:55 -0600
Message-Id: <20170809200755.11234-11-tycho@docker.com>
In-Reply-To: <20170809200755.11234-1-tycho@docker.com>
References: <20170809200755.11234-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

This test simply reads from userspace memory via the kernel's linear
map.

hugepages is only supported on x86 right now, hence the ifdef.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
---
 drivers/misc/Makefile     |  1 +
 drivers/misc/lkdtm.h      |  4 +++
 drivers/misc/lkdtm_core.c |  4 +++
 drivers/misc/lkdtm_xpfo.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 71 insertions(+)

diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index b0b766416306..8447b42a447d 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -62,6 +62,7 @@ lkdtm-$(CONFIG_LKDTM)		+= lkdtm_heap.o
 lkdtm-$(CONFIG_LKDTM)		+= lkdtm_perms.o
 lkdtm-$(CONFIG_LKDTM)		+= lkdtm_rodata_objcopy.o
 lkdtm-$(CONFIG_LKDTM)		+= lkdtm_usercopy.o
+lkdtm-$(CONFIG_LKDTM)		+= lkdtm_xpfo.o
 
 KCOV_INSTRUMENT_lkdtm_rodata.o	:= n
 
diff --git a/drivers/misc/lkdtm.h b/drivers/misc/lkdtm.h
index 3b4976396ec4..fc53546113c1 100644
--- a/drivers/misc/lkdtm.h
+++ b/drivers/misc/lkdtm.h
@@ -64,4 +64,8 @@ void lkdtm_USERCOPY_STACK_FRAME_FROM(void);
 void lkdtm_USERCOPY_STACK_BEYOND(void);
 void lkdtm_USERCOPY_KERNEL(void);
 
+/* lkdtm_xpfo.c */
+void lkdtm_XPFO_READ_USER(void);
+void lkdtm_XPFO_READ_USER_HUGE(void);
+
 #endif
diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
index 42d2b8e31e6b..9431f80886bc 100644
--- a/drivers/misc/lkdtm_core.c
+++ b/drivers/misc/lkdtm_core.c
@@ -235,6 +235,10 @@ struct crashtype crashtypes[] = {
 	CRASHTYPE(USERCOPY_STACK_FRAME_FROM),
 	CRASHTYPE(USERCOPY_STACK_BEYOND),
 	CRASHTYPE(USERCOPY_KERNEL),
+	CRASHTYPE(XPFO_READ_USER),
+#ifdef CONFIG_X86
+	CRASHTYPE(XPFO_READ_USER_HUGE),
+#endif
 };
 
 
diff --git a/drivers/misc/lkdtm_xpfo.c b/drivers/misc/lkdtm_xpfo.c
new file mode 100644
index 000000000000..c72509128eb3
--- /dev/null
+++ b/drivers/misc/lkdtm_xpfo.c
@@ -0,0 +1,62 @@
+/*
+ * This is for all the tests related to XPFO (eXclusive Page Frame Ownership).
+ */
+
+#include "lkdtm.h"
+
+#include <linux/mman.h>
+#include <linux/uaccess.h>
+#include <linux/xpfo.h>
+
+void read_user_with_flags(unsigned long flags)
+{
+	unsigned long user_addr, user_data = 0xdeadbeef;
+	phys_addr_t phys_addr;
+	void *virt_addr;
+
+	user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
+			    PROT_READ | PROT_WRITE | PROT_EXEC,
+			    flags, 0);
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
+
+/* Read from userspace via the kernel's linear map. */
+void lkdtm_XPFO_READ_USER(void)
+{
+	read_user_with_flags(MAP_PRIVATE | MAP_ANONYMOUS);
+}
+
+void lkdtm_XPFO_READ_USER_HUGE(void)
+{
+	read_user_with_flags(MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
