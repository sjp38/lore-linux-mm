Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 881B16B0301
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:37:17 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id b142so418617ioe.7
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:37:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z188sor20928itg.100.2017.09.07.10.37.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 10:37:16 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v6 11/11] lkdtm: Add test for XPFO
Date: Thu,  7 Sep 2017 11:36:09 -0600
Message-Id: <20170907173609.22696-12-tycho@docker.com>
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
References: <20170907173609.22696-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

This test simply reads from userspace memory via the kernel's linear
map.

v6: * drop an #ifdef, just let the test fail if XPFO is not supported
    * add XPFO_SMP test to try and test the case when one CPU does an xpfo
      unmap of an address, that it can't be used accidentally by other
      CPUs.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Tested-by: Marco Benatto <marco.antonio.780@gmail.com>
---
 drivers/misc/Makefile     |   1 +
 drivers/misc/lkdtm.h      |   5 ++
 drivers/misc/lkdtm_core.c |   3 +
 drivers/misc/lkdtm_xpfo.c | 194 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 203 insertions(+)

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
index 3b4976396ec4..34a6ee37f216 100644
--- a/drivers/misc/lkdtm.h
+++ b/drivers/misc/lkdtm.h
@@ -64,4 +64,9 @@ void lkdtm_USERCOPY_STACK_FRAME_FROM(void);
 void lkdtm_USERCOPY_STACK_BEYOND(void);
 void lkdtm_USERCOPY_KERNEL(void);
 
+/* lkdtm_xpfo.c */
+void lkdtm_XPFO_READ_USER(void);
+void lkdtm_XPFO_READ_USER_HUGE(void);
+void lkdtm_XPFO_SMP(void);
+
 #endif
diff --git a/drivers/misc/lkdtm_core.c b/drivers/misc/lkdtm_core.c
index 42d2b8e31e6b..9544e329de4b 100644
--- a/drivers/misc/lkdtm_core.c
+++ b/drivers/misc/lkdtm_core.c
@@ -235,6 +235,9 @@ struct crashtype crashtypes[] = {
 	CRASHTYPE(USERCOPY_STACK_FRAME_FROM),
 	CRASHTYPE(USERCOPY_STACK_BEYOND),
 	CRASHTYPE(USERCOPY_KERNEL),
+	CRASHTYPE(XPFO_READ_USER),
+	CRASHTYPE(XPFO_READ_USER_HUGE),
+	CRASHTYPE(XPFO_SMP),
 };
 
 
diff --git a/drivers/misc/lkdtm_xpfo.c b/drivers/misc/lkdtm_xpfo.c
new file mode 100644
index 000000000000..d903063bdd0b
--- /dev/null
+++ b/drivers/misc/lkdtm_xpfo.c
@@ -0,0 +1,194 @@
+/*
+ * This is for all the tests related to XPFO (eXclusive Page Frame Ownership).
+ */
+
+#include "lkdtm.h"
+
+#include <linux/cpumask.h>
+#include <linux/mman.h>
+#include <linux/uaccess.h>
+#include <linux/xpfo.h>
+#include <linux/kthread.h>
+
+#include <linux/delay.h>
+#include <linux/sched/task.h>
+
+#define XPFO_DATA 0xdeadbeef
+
+static unsigned long do_map(unsigned long flags)
+{
+	unsigned long user_addr, user_data = XPFO_DATA;
+
+	user_addr = vm_mmap(NULL, 0, PAGE_SIZE,
+			    PROT_READ | PROT_WRITE | PROT_EXEC,
+			    flags, 0);
+	if (user_addr >= TASK_SIZE) {
+		pr_warn("Failed to allocate user memory\n");
+		return 0;
+	}
+
+	if (copy_to_user((void __user *)user_addr, &user_data,
+			 sizeof(user_data))) {
+		pr_warn("copy_to_user failed\n");
+		goto free_user;
+	}
+
+	return user_addr;
+
+free_user:
+	vm_munmap(user_addr, PAGE_SIZE);
+	return 0;
+}
+
+static unsigned long *user_to_kernel(unsigned long user_addr)
+{
+	phys_addr_t phys_addr;
+	void *virt_addr;
+
+	phys_addr = user_virt_to_phys(user_addr);
+	if (!phys_addr) {
+		pr_warn("Failed to get physical address of user memory\n");
+		return NULL;
+	}
+
+	virt_addr = phys_to_virt(phys_addr);
+	if (phys_addr != virt_to_phys(virt_addr)) {
+		pr_warn("Physical address of user memory seems incorrect\n");
+		return NULL;
+	}
+
+	return virt_addr;
+}
+
+static void read_map(unsigned long *virt_addr)
+{
+	pr_info("Attempting bad read from kernel address %p\n", virt_addr);
+	if (*(unsigned long *)virt_addr == XPFO_DATA)
+		pr_err("FAIL: Bad read succeeded?!\n");
+	else
+		pr_err("FAIL: Bad read didn't fail but data is incorrect?!\n");
+}
+
+static void read_user_with_flags(unsigned long flags)
+{
+	unsigned long user_addr, *kernel;
+
+	user_addr = do_map(flags);
+	if (!user_addr) {
+		pr_err("FAIL: map failed\n");
+		return;
+	}
+
+	kernel = user_to_kernel(user_addr);
+	if (!kernel) {
+		pr_err("FAIL: user to kernel conversion failed\n");
+		goto free_user;
+	}
+
+	read_map(kernel);
+
+free_user:
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
+
+struct smp_arg {
+	unsigned long *virt_addr;
+	unsigned int cpu;
+};
+
+static int smp_reader(void *parg)
+{
+	struct smp_arg *arg = parg;
+	unsigned long *virt_addr;
+
+	if (arg->cpu != smp_processor_id()) {
+		pr_err("FAIL: scheduled on wrong CPU?\n");
+		return 0;
+	}
+
+	virt_addr = smp_cond_load_acquire(&arg->virt_addr, VAL != NULL);
+	read_map(virt_addr);
+
+	return 0;
+}
+
+#ifdef CONFIG_X86
+#define XPFO_SMP_KILLED SIGKILL
+#elif CONFIG_ARM64
+#define XPFO_SMP_KILLED SIGSEGV
+#else
+#error unsupported arch
+#endif
+
+/* The idea here is to read from the kernel's map on a different thread than
+ * did the mapping (and thus the TLB flushing), to make sure that the page
+ * faults on other cores too.
+ */
+void lkdtm_XPFO_SMP(void)
+{
+	unsigned long user_addr, *virt_addr;
+	struct task_struct *thread;
+	int ret;
+	struct smp_arg arg;
+
+	if (num_online_cpus() < 2) {
+		pr_err("not enough to do a multi cpu test\n");
+		return;
+	}
+
+	arg.virt_addr = NULL;
+	arg.cpu = (smp_processor_id() + 1) % num_online_cpus();
+	thread = kthread_create(smp_reader, &arg, "lkdtm_xpfo_test");
+	if (IS_ERR(thread)) {
+		pr_err("couldn't create kthread? %ld\n", PTR_ERR(thread));
+		return;
+	}
+
+	kthread_bind(thread, arg.cpu);
+	get_task_struct(thread);
+	wake_up_process(thread);
+
+	user_addr = do_map(MAP_PRIVATE | MAP_ANONYMOUS);
+	if (!user_addr)
+		goto kill_thread;
+
+	virt_addr = user_to_kernel(user_addr);
+	if (!virt_addr) {
+		/*
+		 * let's store something that will fail, so we can unblock the
+		 * thread
+		 */
+		smp_store_release(&arg.virt_addr, &arg);
+		goto free_user;
+	}
+
+	smp_store_release(&arg.virt_addr, virt_addr);
+
+	/* there must be a better way to do this. */
+	while (1) {
+		if (thread->exit_state)
+			break;
+		msleep_interruptible(100);
+	}
+
+free_user:
+	if (user_addr)
+		vm_munmap(user_addr, PAGE_SIZE);
+
+kill_thread:
+	ret = kthread_stop(thread);
+	if (ret != XPFO_SMP_KILLED)
+		pr_err("FAIL: thread wasn't killed: %d\n", ret);
+	put_task_struct(thread);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
