Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E47876B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 14:06:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n126so7299403wma.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 11:06:59 -0800 (PST)
Received: from mx02.buh.bitdefender.com (mx02.bbu.dsd.mx.bitdefender.com. [91.199.104.133])
        by mx.google.com with ESMTPS id g52si2946002wrd.475.2017.12.18.11.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 11:06:58 -0800 (PST)
From: =?UTF-8?q?Adalber=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v4 02/18] add memory map/unmap support for VM introspection on the guest side
Date: Mon, 18 Dec 2017 21:06:26 +0200
Message-Id: <20171218190642.7790-3-alazar@bitdefender.com>
In-Reply-To: <20171218190642.7790-1-alazar@bitdefender.com>
References: <20171218190642.7790-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>, Adalbert Lazar <alazar@bitdefender.com>, =?UTF-8?q?Mircea=20C=C3=AErjaliu?= <mcirjaliu@bitdefender.com>

From: Adalbert Lazar <alazar@bitdefender.com>

An introspection tool running in a dedicated VM can use the new device
(/dev/kvmmem) to map memory from other introspected VM-s.

Two ioctl operations are supported:
  - KVM_INTRO_MEM_MAP/struct kvmi_mem_map
  - KVM_INTRO_MEM_UNMAP/unsigned long

In order to map an introspected gpa to the local gva, the process using
this device needs to obtain a token from the host KVMI subsystem (see
Documentation/virtual/kvm/kvmi.rst - KVMI_GET_MAP_TOKEN).

Both operations use hypercalls (KVM_HC_MEM_MAP, KVM_INTRO_MEM_UNMAP)
to pass the requests to the host kernel/KVMi (see hypercalls.txt).

Signed-off-by: Mircea CA(R)rjaliu <mcirjaliu@bitdefender.com>
---
 arch/x86/Kconfig                  |   9 +
 arch/x86/include/asm/kvmi_guest.h |  10 +
 arch/x86/kernel/Makefile          |   1 +
 arch/x86/kernel/kvmi_mem_guest.c  |  26 +++
 virt/kvm/kvmi_mem_guest.c         | 379 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 425 insertions(+)
 create mode 100644 arch/x86/include/asm/kvmi_guest.h
 create mode 100644 arch/x86/kernel/kvmi_mem_guest.c
 create mode 100644 virt/kvm/kvmi_mem_guest.c

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8eed3f94bfc7..6e2548f4d44c 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -782,6 +782,15 @@ config KVM_DEBUG_FS
 	  Statistics are displayed in debugfs filesystem. Enabling this option
 	  may incur significant overhead.
 
+config KVMI_MEM_GUEST
+	bool "KVM Memory Introspection support on Guest"
+	depends on KVM_GUEST
+	default n
+	---help---
+	  This option enables functions and hypercalls for security applications
+	  running in a separate VM to control the execution of other VM-s, query
+	  the state of the vCPU-s (GPR-s, MSR-s etc.).
+
 config PARAVIRT_TIME_ACCOUNTING
 	bool "Paravirtual steal time accounting"
 	depends on PARAVIRT
diff --git a/arch/x86/include/asm/kvmi_guest.h b/arch/x86/include/asm/kvmi_guest.h
new file mode 100644
index 000000000000..c7ed53a938e0
--- /dev/null
+++ b/arch/x86/include/asm/kvmi_guest.h
@@ -0,0 +1,10 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef __KVMI_GUEST_H__
+#define __KVMI_GUEST_H__
+
+long kvmi_arch_map_hc(struct kvmi_map_mem_token *tknp,
+	gpa_t req_gpa, gpa_t map_gpa);
+long kvmi_arch_unmap_hc(gpa_t map_gpa);
+
+
+#endif
diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index 81bb565f4497..fdb54b65e46e 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -111,6 +111,7 @@ obj-$(CONFIG_PARAVIRT)		+= paravirt.o paravirt_patch_$(BITS).o
 obj-$(CONFIG_PARAVIRT_SPINLOCKS)+= paravirt-spinlocks.o
 obj-$(CONFIG_PARAVIRT_CLOCK)	+= pvclock.o
 obj-$(CONFIG_X86_PMEM_LEGACY_DEVICE) += pmem.o
+obj-$(CONFIG_KVMI_MEM_GUEST)	+= kvmi_mem_guest.o ../../../virt/kvm/kvmi_mem_guest.o
 
 obj-$(CONFIG_EISA)		+= eisa.o
 obj-$(CONFIG_PCSPKR_PLATFORM)	+= pcspeaker.o
diff --git a/arch/x86/kernel/kvmi_mem_guest.c b/arch/x86/kernel/kvmi_mem_guest.c
new file mode 100644
index 000000000000..c4e2613f90f3
--- /dev/null
+++ b/arch/x86/kernel/kvmi_mem_guest.c
@@ -0,0 +1,26 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KVM introspection guest implementation
+ *
+ * Copyright (C) 2017 Bitdefender S.R.L.
+ *
+ * Author:
+ *   Mircea Cirjaliu <mcirjaliu@bitdefender.com>
+ */
+
+#include <uapi/linux/kvmi.h>
+#include <uapi/linux/kvm_para.h>
+#include <linux/kvm_types.h>
+#include <asm/kvm_para.h>
+
+long kvmi_arch_map_hc(struct kvmi_map_mem_token *tknp,
+		       gpa_t req_gpa, gpa_t map_gpa)
+{
+	return kvm_hypercall3(KVM_HC_MEM_MAP, (unsigned long)tknp,
+			      req_gpa, map_gpa);
+}
+
+long kvmi_arch_unmap_hc(gpa_t map_gpa)
+{
+	return kvm_hypercall1(KVM_HC_MEM_UNMAP, map_gpa);
+}
diff --git a/virt/kvm/kvmi_mem_guest.c b/virt/kvm/kvmi_mem_guest.c
new file mode 100644
index 000000000000..118c22ca47c5
--- /dev/null
+++ b/virt/kvm/kvmi_mem_guest.c
@@ -0,0 +1,379 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KVM introspection guest implementation
+ *
+ * Copyright (C) 2017 Bitdefender S.R.L.
+ *
+ * Author:
+ *   Mircea Cirjaliu <mcirjaliu@bitdefender.com>
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/miscdevice.h>
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/types.h>
+#include <linux/kvm_host.h>
+#include <linux/kvm_para.h>
+#include <linux/uaccess.h>
+#include <linux/slab.h>
+#include <linux/rmap.h>
+#include <linux/sched.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+#include <uapi/linux/kvmi.h>
+#include <asm/kvmi_guest.h>
+
+#define ASSERT(exp) BUG_ON(!(exp))
+
+
+static struct list_head file_list;
+static spinlock_t file_lock;
+
+struct file_map {
+	struct list_head file_list;
+	struct file *file;
+	struct list_head map_list;
+	struct mutex lock;
+	int active;	/* for tearing down */
+};
+
+struct page_map {
+	struct list_head map_list;
+	__u64 gpa;
+	unsigned long vaddr;
+	unsigned long paddr;
+};
+
+
+static int kvm_dev_open(struct inode *inodep, struct file *filp)
+{
+	struct file_map *fmp;
+
+	pr_debug("kvmi: file %016lx opened by process %s\n",
+		 (unsigned long) filp, current->comm);
+
+	/* link the file 1:1 with such a structure */
+	fmp = kmalloc(sizeof(struct file_map), GFP_KERNEL);
+	if (fmp == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&fmp->file_list);
+	fmp->file = filp;
+	filp->private_data = fmp;
+	INIT_LIST_HEAD(&fmp->map_list);
+	mutex_init(&fmp->lock);
+	fmp->active = 1;
+
+	/* add the entry to the global list */
+	spin_lock(&file_lock);
+	list_add_tail(&fmp->file_list, &file_list);
+	spin_unlock(&file_lock);
+
+	return 0;
+}
+
+/* actually does the mapping of a page */
+static long _do_mapping(struct kvmi_mem_map *map_req, struct page_map *pmap)
+{
+	unsigned long paddr;
+	struct vm_area_struct *vma = NULL;
+	struct page *page;
+	long result;
+
+	pr_debug("kvmi: mapping remote GPA %016llx into %016llx\n",
+		 map_req->gpa, map_req->gva);
+
+	/* check access to memory location */
+	if (!access_ok(VERIFY_READ, map_req->gva, PAGE_SIZE)) {
+		pr_err("kvmi: invalid virtual address for mapping\n");
+		return -EINVAL;
+	}
+
+	down_read(&current->mm->mmap_sem);
+
+	/* find the page to be replaced */
+	vma = find_vma(current->mm, map_req->gva);
+	if (IS_ERR_OR_NULL(vma)) {
+		result = PTR_ERR(vma);
+		pr_err("kvmi: find_vma() failed with result %ld\n", result);
+		goto out;
+	}
+
+	page = follow_page(vma, map_req->gva, 0);
+	if (IS_ERR_OR_NULL(page)) {
+		result = PTR_ERR(page);
+		pr_err("kvmi: follow_page() failed with result %ld\n", result);
+		goto out;
+	}
+
+	if (IS_ENABLED(CONFIG_DEBUG_VM))
+		dump_page(page, "page to map_req into");
+
+	WARN(is_zero_pfn(page_to_pfn(page)), "zero-page still mapped");
+
+	/* get the physical address and store it in page_map */
+	paddr = page_to_phys(page);
+	pr_debug("kvmi: page phys addr %016lx\n", paddr);
+	pmap->paddr = paddr;
+
+	/* last thing to do is host mapping */
+	result = kvmi_arch_map_hc(&map_req->token, map_req->gpa, paddr);
+	if (IS_ERR_VALUE(result)) {
+		pr_err("kvmi: HC failed with result %ld\n", result);
+		goto out;
+	}
+
+out:
+	up_read(&current->mm->mmap_sem);
+
+	return result;
+}
+
+/* actually does the unmapping of a page */
+static long _do_unmapping(unsigned long paddr)
+{
+	long result;
+
+	pr_debug("kvmi: unmapping request for phys addr %016lx\n", paddr);
+
+	/* local GPA uniquely identifies the mapping on the host */
+	result = kvmi_arch_unmap_hc(paddr);
+	if (IS_ERR_VALUE(result))
+		pr_warn("kvmi: HC failed with result %ld\n", result);
+
+	return result;
+}
+
+static long kvm_dev_ioctl_map(struct file_map *fmp, struct kvmi_mem_map *map)
+{
+	struct page_map *pmp;
+	long result = 0;
+
+	if (!access_ok(VERIFY_READ, map->gva, PAGE_SIZE))
+		return -EINVAL;
+	if (!access_ok(VERIFY_WRITE, map->gva, PAGE_SIZE))
+		return -EINVAL;
+
+	/* prepare list entry */
+	pmp = kmalloc(sizeof(struct page_map), GFP_KERNEL);
+	if (pmp == NULL)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&pmp->map_list);
+	pmp->gpa = map->gpa;
+	pmp->vaddr = map->gva;
+
+	/* acquire the file mapping */
+	mutex_lock(&fmp->lock);
+
+	/* check if other thread is closing the file */
+	if (!fmp->active) {
+		result = -ENODEV;
+		pr_warn("kvmi: unable to map, file is being closed\n");
+		goto out_err;
+	}
+
+	/* do the actual mapping */
+	result = _do_mapping(map, pmp);
+	if (IS_ERR_VALUE(result))
+		goto out_err;
+
+	/* link to list */
+	list_add_tail(&pmp->map_list, &fmp->map_list);
+
+	/* all fine */
+	result = 0;
+	goto out_finalize;
+
+out_err:
+	kfree(pmp);
+
+out_finalize:
+	mutex_unlock(&fmp->lock);
+
+	return result;
+}
+
+static long kvm_dev_ioctl_unmap(struct file_map *fmp, unsigned long vaddr)
+{
+	struct list_head *cur;
+	struct page_map *pmp;
+	bool found = false;
+
+	/* acquire the file */
+	mutex_lock(&fmp->lock);
+
+	/* check if other thread is closing the file */
+	if (!fmp->active) {
+		mutex_unlock(&fmp->lock);
+		pr_warn("kvmi: unable to unmap, file is being closed\n");
+		return -ENODEV;
+	}
+
+	/* check that this address belongs to us */
+	list_for_each(cur, &fmp->map_list) {
+		pmp = list_entry(cur, struct page_map, map_list);
+
+		/* found */
+		if (pmp->vaddr == vaddr) {
+			found = true;
+			break;
+		}
+	}
+
+	/* not found ? */
+	if (!found) {
+		mutex_unlock(&fmp->lock);
+		pr_err("kvmi: address %016lx not mapped\n", vaddr);
+		return -ENOENT;
+	}
+
+	/* decouple guest mapping */
+	list_del(&pmp->map_list);
+	mutex_unlock(&fmp->lock);
+
+	/* unmap & ignore result */
+	_do_unmapping(pmp->paddr);
+
+	/* free guest mapping */
+	kfree(pmp);
+
+	return 0;
+}
+
+static long kvm_dev_ioctl(struct file *filp,
+			  unsigned int ioctl, unsigned long arg)
+{
+	void __user *argp = (void __user *) arg;
+	struct file_map *fmp;
+	long result;
+
+	/* minor check */
+	fmp = filp->private_data;
+	ASSERT(fmp->file == filp);
+
+	switch (ioctl) {
+	case KVM_INTRO_MEM_MAP: {
+		struct kvmi_mem_map map;
+
+		result = -EFAULT;
+		if (copy_from_user(&map, argp, sizeof(map)))
+			break;
+
+		result = kvm_dev_ioctl_map(fmp, &map);
+		if (IS_ERR_VALUE(result))
+			break;
+
+		result = 0;
+		break;
+	}
+	case KVM_INTRO_MEM_UNMAP: {
+		unsigned long vaddr = (unsigned long) arg;
+
+		result = kvm_dev_ioctl_unmap(fmp, vaddr);
+		if (IS_ERR_VALUE(result))
+			break;
+
+		result = 0;
+		break;
+	}
+	default:
+		pr_err("kvmi: ioctl %d not implemented\n", ioctl);
+		result = -ENOTTY;
+	}
+
+	return result;
+}
+
+static int kvm_dev_release(struct inode *inodep, struct file *filp)
+{
+	int result = 0;
+	struct file_map *fmp;
+	struct list_head *cur, *next;
+	struct page_map *pmp;
+
+	pr_debug("kvmi: file %016lx closed by process %s\n",
+		 (unsigned long) filp, current->comm);
+
+	/* acquire the file */
+	fmp = filp->private_data;
+	mutex_lock(&fmp->lock);
+
+	/* mark for teardown */
+	fmp->active = 0;
+
+	/* release mappings taken on this instance of the file */
+	list_for_each_safe(cur, next, &fmp->map_list) {
+		pmp = list_entry(cur, struct page_map, map_list);
+
+		/* unmap address */
+		_do_unmapping(pmp->paddr);
+
+		/* decouple & free guest mapping */
+		list_del(&pmp->map_list);
+		kfree(pmp);
+	}
+
+	/* done processing this file mapping */
+	mutex_unlock(&fmp->lock);
+
+	/* decouple file mapping */
+	spin_lock(&file_lock);
+	list_del(&fmp->file_list);
+	spin_unlock(&file_lock);
+
+	/* free it */
+	kfree(fmp);
+
+	return result;
+}
+
+
+static const struct file_operations kvmmem_ops = {
+	.open		= kvm_dev_open,
+	.unlocked_ioctl = kvm_dev_ioctl,
+	.compat_ioctl   = kvm_dev_ioctl,
+	.release	= kvm_dev_release,
+};
+
+static struct miscdevice kvm_mem_dev = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = "kvmmem",
+	.fops = &kvmmem_ops,
+};
+
+int __init kvm_intro_guest_init(void)
+{
+	int result;
+
+	if (!kvm_para_available()) {
+		pr_err("kvmi: paravirt not available\n");
+		return -EPERM;
+	}
+
+	result = misc_register(&kvm_mem_dev);
+	if (result) {
+		pr_err("kvmi: misc device register failed: %d\n", result);
+		return result;
+	}
+
+	INIT_LIST_HEAD(&file_list);
+	spin_lock_init(&file_lock);
+
+	pr_info("kvmi: guest introspection device created\n");
+
+	return 0;
+}
+
+void kvm_intro_guest_exit(void)
+{
+	misc_deregister(&kvm_mem_dev);
+}
+
+module_init(kvm_intro_guest_init)
+module_exit(kvm_intro_guest_exit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
