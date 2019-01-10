Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E38C28E0008
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:40 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id l22so8676400pfb.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:40 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id d9si5491130pgb.105.2019.01.10.13.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:39 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 10/16] lkdtm: Add test for XPFO
Date: Thu, 10 Jan 2019 14:09:42 -0700
Message-Id: <5a8bb25b1f2209ea40160c6cabf2bc850800e3ad.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tycho Andersen <tycho@docker.com>, Khalid Aziz <khalid.aziz@oracle.com>

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
[jsteckli@amazon.de: rebased from v4.13 to v4.19]
Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 drivers/misc/lkdtm/Makefile |   1 +
 drivers/misc/lkdtm/core.c   |   3 +
 drivers/misc/lkdtm/lkdtm.h  |   5 +
 drivers/misc/lkdtm/xpfo.c   | 194 ++++++++++++++++++++++++++++++++++++
 4 files changed, 203 insertions(+)
 create mode 100644 drivers/misc/lkdtm/xpfo.c

diff --git a/drivers/misc/lkdtm/Makefile b/drivers/misc/lkdtm/Makefile
index 951c984de61a..97c6b7818cce 100644
--- a/drivers/misc/lkdtm/Makefile
+++ b/drivers/misc/lkdtm/Makefile
@@ -9,6 +9,7 @@ lkdtm-$(CONFIG_LKDTM)		+= refcount.o
 lkdtm-$(CONFIG_LKDTM)		+= rodata_objcopy.o
 lkdtm-$(CONFIG_LKDTM)		+= usercopy.o
 lkdtm-$(CONFIG_LKDTM)		+= stackleak.o
+lkdtm-$(CONFIG_LKDTM)		+= xpfo.o
 
 KASAN_SANITIZE_stackleak.o	:= n
 KCOV_INSTRUMENT_rodata.o	:= n
diff --git a/drivers/misc/lkdtm/core.c b/drivers/misc/lkdtm/core.c
index 2837dc77478e..25f4ab4ebf50 100644
--- a/drivers/misc/lkdtm/core.c
+++ b/drivers/misc/lkdtm/core.c
@@ -185,6 +185,9 @@ static const struct crashtype crashtypes[] = {
 	CRASHTYPE(USERCOPY_KERNEL),
 	CRASHTYPE(USERCOPY_KERNEL_DS),
 	CRASHTYPE(STACKLEAK_ERASING),
+	CRASHTYPE(XPFO_READ_USER),
+	CRASHTYPE(XPFO_READ_USER_HUGE),
+	CRASHTYPE(XPFO_SMP),
 };
 
 
diff --git a/drivers/misc/lkdtm/lkdtm.h b/drivers/misc/lkdtm/lkdtm.h
index 3c6fd327e166..6b31ff0c7f8f 100644
--- a/drivers/misc/lkdtm/lkdtm.h
+++ b/drivers/misc/lkdtm/lkdtm.h
@@ -87,4 +87,9 @@ void lkdtm_USERCOPY_KERNEL_DS(void);
 /* lkdtm_stackleak.c */
 void lkdtm_STACKLEAK_ERASING(void);
 
+/* lkdtm_xpfo.c */
+void lkdtm_XPFO_READ_USER(void);
+void lkdtm_XPFO_READ_USER_HUGE(void);
+void lkdtm_XPFO_SMP(void);
+
 #endif
diff --git a/drivers/misc/lkdtm/xpfo.c b/drivers/misc/lkdtm/xpfo.c
new file mode 100644
index 000000000000..d903063bdd0b
--- /dev/null
+++ b/drivers/misc/lkdtm/xpfo.c
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
2.17.1
