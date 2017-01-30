Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B38B6B0289
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:55 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r141so3992887wmg.4
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:39:55 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g9si11706164wmc.77.2017.01.29.19.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:39:53 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YPKF082466
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:52 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289he1j4v3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:52 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:39:49 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id E53F03578052
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:45 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3dbEZ24051814
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:45 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3dDPl023008
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:13 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 20/21] drivers: Add two drivers for coherent device memory tests
Date: Mon, 30 Jan 2017 09:06:01 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-21-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

This adds two different drivers inside drivers/char/ directory under two
new kernel config options COHERENT_HOTPLUG_DEMO and COHERENT_MEMORY_DEMO.

1) coherent_hotplug_demo: Detects, hoptlugs the coherent device memory
2) coherent_memory_demo:  Exports debugfs interface for VMA migrations

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 drivers/char/Kconfig                 |  23 +++
 drivers/char/Makefile                |   2 +
 drivers/char/coherent_hotplug_demo.c | 133 ++++++++++++++
 drivers/char/coherent_memory_demo.c  | 337 +++++++++++++++++++++++++++++++++++
 drivers/char/memory_online_sysfs.h   | 148 +++++++++++++++
 mm/mempolicy.c                       |   9 +-
 6 files changed, 651 insertions(+), 1 deletion(-)
 create mode 100644 drivers/char/coherent_hotplug_demo.c
 create mode 100644 drivers/char/coherent_memory_demo.c
 create mode 100644 drivers/char/memory_online_sysfs.h

diff --git a/drivers/char/Kconfig b/drivers/char/Kconfig
index fde005e..0a9fb82 100644
--- a/drivers/char/Kconfig
+++ b/drivers/char/Kconfig
@@ -588,6 +588,29 @@ config TILE_SROM
 	  device appear much like a simple EEPROM, and knows
 	  how to partition a single ROM for multiple purposes.
 
+config COHERENT_HOTPLUG_DEMO
+	tristate "Demo driver to test coherent memory node hotplug"
+	depends on PPC64 || COHERENT_DEVICE
+	default n
+	help
+	  Say yes when you want to build a test driver to hotplug all
+	  the coherent memory nodes present on the system. This driver
+	  scans through the device tree, checks on "ibm,memory-device"
+	  property device nodes and onlines its memory. When unloaded,
+	  it goes through the list of memory ranges it onlined before
+	  and oflines them one by one. If not sure, select N.
+
+config COHERENT_MEMORY_DEMO
+	tristate "Demo driver to test coherent memory node functionality"
+	depends on PPC64 || COHERENT_DEVICE
+	default n
+	help
+	  Say yes when you want to build a test driver to demonstrate
+	  the coherent memory functionalities, capabilities and probable
+	  utilizaton. It also exports a debugfs file to accept inputs for
+	  virtual address range migration for any process. If not sure,
+	  select N.
+
 source "drivers/char/xillybus/Kconfig"
 
 endmenu
diff --git a/drivers/char/Makefile b/drivers/char/Makefile
index 6e6c244..92fa338 100644
--- a/drivers/char/Makefile
+++ b/drivers/char/Makefile
@@ -60,3 +60,5 @@ js-rtc-y = rtc.o
 obj-$(CONFIG_TILE_SROM)		+= tile-srom.o
 obj-$(CONFIG_XILLYBUS)		+= xillybus/
 obj-$(CONFIG_POWERNV_OP_PANEL)	+= powernv-op-panel.o
+obj-$(CONFIG_COHERENT_HOTPLUG_DEMO)	+= coherent_hotplug_demo.o
+obj-$(CONFIG_COHERENT_MEMORY_DEMO)	+= coherent_memory_demo.o
diff --git a/drivers/char/coherent_hotplug_demo.c b/drivers/char/coherent_hotplug_demo.c
new file mode 100644
index 0000000..bfc1254
--- /dev/null
+++ b/drivers/char/coherent_hotplug_demo.c
@@ -0,0 +1,133 @@
+/*
+ * Memory hotplug support for coherent memory nodes in runtime.
+ *
+ * Copyright (C) 2016, Reza Arbab, IBM Corporation.
+ * Copyright (C) 2016, Anshuman Khandual, IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include <linux/of.h>
+#include <linux/export.h>
+#include <linux/spinlock.h>
+#include <linux/init.h>
+#include <linux/memblock.h>
+#include <linux/module.h>
+#include <linux/memory.h>
+#include <linux/sizes.h>
+#include <linux/bitops.h>
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/migrate.h>
+#include <linux/memblock.h>
+#include <linux/uaccess.h>
+
+#include <asm/mmu.h>
+#include <asm/pgalloc.h>
+#include "memory_online_sysfs.h"
+
+#define MAX_HOTADD_NODES 100
+phys_addr_t addr[MAX_HOTADD_NODES][2];
+int nr_addr;
+
+/*
+ * extern int memory_failure(unsigned long pfn, int trapno, int flags);
+ * extern int min_free_kbytes;
+ * extern int user_min_free_kbytes;
+ *
+ * extern unsigned long nr_kernel_pages;
+ * extern unsigned long nr_all_pages;
+ * extern unsigned long dma_reserve;
+ */
+
+static void dump_core_vm_tunables(void)
+{
+/*
+ *	printk(":::::::: VM TUNABLES :::::::\n");
+ *	printk("[min_free_kbytes]	%d\n", min_free_kbytes);
+ *	printk("[user_min_free_kbytes]	%d\n", user_min_free_kbytes);
+ *	printk("[nr_kernel_pages]	%ld\n", nr_kernel_pages);
+ *	printk("[nr_all_pages]		%ld\n", nr_all_pages);
+ *	printk("[dma_reserve]		%ld\n", dma_reserve);
+ */
+}
+
+
+
+static int online_coherent_memory(void)
+{
+	struct device_node *memory;
+
+	nr_addr = 0;
+	disable_auto_online();
+	dump_core_vm_tunables();
+	for_each_compatible_node(memory, NULL, "ibm,memory-device") {
+		struct device_node *mem;
+		const __be64 *reg;
+		unsigned int len, ret;
+		phys_addr_t start, size;
+
+		mem = of_parse_phandle(memory, "memory-region", 0);
+		if (!mem) {
+			pr_info("memory-region property not found\n");
+			return -1;
+		}
+
+		reg = of_get_property(mem, "reg", &len);
+		if (!reg || len <= 0) {
+			pr_info("memory-region property not found\n");
+			return -1;
+		}
+		start = be64_to_cpu(*reg);
+		size = be64_to_cpu(*(reg + 1));
+		pr_info("Coherent memory start %llx size %llx\n", start, size);
+		ret = memory_probe_store(start, size);
+		if (ret)
+			pr_info("probe failed\n");
+
+		ret = store_mem_state(start, size, "online_movable");
+		if (ret)
+			pr_info("online_movable failed\n");
+
+		addr[nr_addr][0] = start;
+		addr[nr_addr][1] = size;
+		nr_addr++;
+	}
+	dump_core_vm_tunables();
+	enable_auto_online();
+	return 0;
+}
+
+static int offline_coherent_memory(void)
+{
+	int i;
+
+	for (i = 0; i < nr_addr; i++)
+		store_mem_state(addr[i][0], addr[i][1], "offline");
+	return 0;
+}
+
+static void __exit coherent_hotplug_exit(void)
+{
+	pr_info("%s\n", __func__);
+	offline_coherent_memory();
+}
+
+static int __init coherent_hotplug_init(void)
+{
+	pr_info("%s\n", __func__);
+	return online_coherent_memory();
+}
+module_init(coherent_hotplug_init);
+module_exit(coherent_hotplug_exit);
+MODULE_LICENSE("GPL");
diff --git a/drivers/char/coherent_memory_demo.c b/drivers/char/coherent_memory_demo.c
new file mode 100644
index 0000000..e711165
--- /dev/null
+++ b/drivers/char/coherent_memory_demo.c
@@ -0,0 +1,337 @@
+/*
+ * Demonstrating various aspects of the coherent memory.
+ *
+ * Copyright (C) 2016, Anshuman Khandual, IBM Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+#include <linux/of.h>
+#include <linux/export.h>
+#include <linux/spinlock.h>
+#include <linux/init.h>
+#include <linux/memblock.h>
+#include <linux/module.h>
+#include <linux/memory.h>
+#include <linux/sizes.h>
+#include <linux/bitops.h>
+#include <linux/device.h>
+#include <linux/fs.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/migrate.h>
+#include <linux/memblock.h>
+#include <linux/debugfs.h>
+#include <linux/uaccess.h>
+
+#include <asm/mmu.h>
+#include <asm/pgalloc.h>
+
+#define COHERENT_DEV_MAJOR 89
+#define COHERENT_DEV_NAME  "coherent_memory"
+
+#define CRNT_NODE_NID1 1
+#define CRNT_NODE_NID2 2
+#define CRNT_NODE_NID3 3
+
+#define RAM_CRNT_MIGRATE 1
+#define CRNT_RAM_MIGRATE 2
+
+struct vma_map_info {
+	struct list_head list;
+	unsigned long nr_pages;
+	spinlock_t lock;
+};
+
+static void vma_map_info_init(struct vm_area_struct *vma)
+{
+	struct vma_map_info *info = kmalloc(sizeof(struct vma_map_info),
+								GFP_KERNEL);
+
+	WARN_ON(!info);
+	INIT_LIST_HEAD(&info->list);
+	spin_lock_init(&info->lock);
+	vma->vm_private_data = info;
+	info->nr_pages = 0;
+}
+
+static void coherent_vmops_open(struct vm_area_struct *vma)
+{
+	vma_map_info_init(vma);
+}
+
+static void coherent_vmops_close(struct vm_area_struct *vma)
+{
+	struct vma_map_info *info = vma->vm_private_data;
+
+	WARN_ON(!info);
+again:
+	cond_resched();
+	spin_lock(&info->lock);
+	while (info->nr_pages) {
+		struct page *page, *page2;
+
+		list_for_each_entry_safe(page, page2, &info->list, lru) {
+			if (!trylock_page(page)) {
+				spin_unlock(&info->lock);
+				goto again;
+			}
+
+			list_del_init(&page->lru);
+			info->nr_pages--;
+			unlock_page(page);
+			SetPageReclaim(page);
+			put_page(page);
+		}
+		spin_unlock(&info->lock);
+		cond_resched();
+		spin_lock(&info->lock);
+	}
+	spin_unlock(&info->lock);
+	kfree(info);
+	vma->vm_private_data = NULL;
+}
+
+static int coherent_vmops_fault(struct vm_area_struct *vma,
+					struct vm_fault *vmf)
+{
+	struct vma_map_info *info;
+	struct page *page;
+	static int coherent_node = CRNT_NODE_NID1;
+
+	if (coherent_node == CRNT_NODE_NID1)
+		coherent_node = CRNT_NODE_NID2;
+	else
+		coherent_node = CRNT_NODE_NID1;
+
+	page = alloc_pages_node(coherent_node,
+				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
+	if (!page)
+		return VM_FAULT_SIGBUS;
+
+	info = (struct vma_map_info *) vma->vm_private_data;
+	WARN_ON(!info);
+	spin_lock(&info->lock);
+	list_add(&page->lru, &info->list);
+	info->nr_pages++;
+	spin_unlock(&info->lock);
+
+	page->index = vmf->pgoff;
+	get_page(page);
+	vmf->page = page;
+	return 0;
+}
+
+static const struct vm_operations_struct coherent_memory_vmops = {
+	.open = coherent_vmops_open,
+	.close = coherent_vmops_close,
+	.fault = coherent_vmops_fault,
+};
+
+static int coherent_memory_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	pr_info("Mmap opened (file: %lx vma: %lx)\n",
+			(unsigned long) file, (unsigned long) vma);
+	vma->vm_ops = &coherent_memory_vmops;
+	coherent_vmops_open(vma);
+	return 0;
+}
+
+static int coherent_memory_open(struct inode *inode, struct file *file)
+{
+	pr_info("Device opened (inode: %lx file: %lx)\n",
+			(unsigned long) inode, (unsigned long) file);
+	return 0;
+}
+
+static int coherent_memory_close(struct inode *inode, struct file *file)
+{
+	pr_info("Device closed (inode: %lx file: %lx)\n",
+			(unsigned long) inode, (unsigned long) file);
+	return 0;
+}
+
+static void lru_ram_coherent_migrate(unsigned long addr)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	nodemask_t nmask;
+	LIST_HEAD(mlist);
+
+	nodes_clear(nmask);
+	nodes_setall(nmask);
+	down_write(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if  ((addr < vma->vm_start) || (addr > vma->vm_end))
+			continue;
+		break;
+	}
+	up_write(&mm->mmap_sem);
+	if (!vma) {
+		pr_info("%s: No VMA found\n", __func__);
+		return;
+	}
+	migrate_virtual_range(current->pid, vma->vm_start, vma->vm_end, 2);
+}
+
+static void lru_coherent_ram_migrate(unsigned long addr)
+{
+	struct mm_struct *mm = current->mm;
+	struct vm_area_struct *vma;
+	nodemask_t nmask;
+	LIST_HEAD(mlist);
+
+	nodes_clear(nmask);
+	nodes_setall(nmask);
+	down_write(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		if  ((addr < vma->vm_start) || (addr > vma->vm_end))
+			continue;
+		break;
+	}
+	up_write(&mm->mmap_sem);
+	if (!vma) {
+		pr_info("%s: No VMA found\n", __func__);
+		return;
+	}
+	migrate_virtual_range(current->pid, vma->vm_start, vma->vm_end, 0);
+}
+
+static long coherent_memory_ioctl(struct file *file,
+					unsigned int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case RAM_CRNT_MIGRATE:
+		lru_ram_coherent_migrate(arg);
+		break;
+
+	case CRNT_RAM_MIGRATE:
+		lru_coherent_ram_migrate(arg);
+		break;
+
+	default:
+		pr_info("%s Invalid ioctl() command: %d\n", __func__, cmd);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static const struct file_operations fops = {
+	.mmap = coherent_memory_mmap,
+	.open = coherent_memory_open,
+	.release = coherent_memory_close,
+	.unlocked_ioctl = &coherent_memory_ioctl
+};
+
+static char kbuf[100];	/* Will store original user passed buffer */
+static char str[100];	/* Working copy for individual substring */
+
+static u64 args[4];
+static u64 index;
+static void convert_substring(const char *buf)
+{
+	u64 val = 0;
+
+	if (kstrtou64(buf, 0, &val))
+		pr_info("String conversion failed\n");
+
+	args[index] = val;
+	index++;
+}
+
+static ssize_t coherent_debug_write(struct file *file,
+					const char __user *user_buf,
+					size_t count, loff_t *ppos)
+{
+	char *tmp, *tmp1;
+	size_t ret;
+
+	memset(args, 0, sizeof(args));
+	index = 0;
+
+	ret = simple_write_to_buffer(kbuf, sizeof(kbuf), ppos, user_buf, count);
+	if (ret < 0)
+		return ret;
+
+	kbuf[ret] = '\0';
+	tmp = kbuf;
+	do {
+		tmp1 = strchr(tmp, ',');
+		if (tmp1) {
+			*tmp1 = '\0';
+			strncpy(str, (const char *)tmp, strlen(tmp));
+			convert_substring(str);
+		} else {
+			strncpy(str, (const char *)tmp, strlen(tmp));
+			convert_substring(str);
+			break;
+		}
+		tmp = tmp1 + 1;
+		memset(str, 0, sizeof(str));
+	} while (true);
+	migrate_virtual_range(args[0], args[1], args[2], args[3]);
+	return ret;
+}
+
+static int coherent_debug_show(struct seq_file *m, void *v)
+{
+	seq_puts(m, "Expected Value: <pid,vaddr,size,nid>\n");
+	return 0;
+}
+
+static int coherent_debug_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, coherent_debug_show, NULL);
+}
+
+static const struct file_operations coherent_debug_fops = {
+	.open		= coherent_debug_open,
+	.write		= coherent_debug_write,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static struct dentry *debugfile;
+
+static void coherent_memory_debugfs(void)
+{
+
+	debugfile = debugfs_create_file("coherent_debug", 0644, NULL, NULL,
+				&coherent_debug_fops);
+	if (!debugfile)
+		pr_warn("Failed to create coherent_memory in debugfs");
+}
+
+static void __exit coherent_memory_exit(void)
+{
+	pr_info("%s\n", __func__);
+	debugfs_remove(debugfile);
+	unregister_chrdev(COHERENT_DEV_MAJOR, COHERENT_DEV_NAME);
+}
+
+static int __init coherent_memory_init(void)
+{
+	int ret;
+
+	pr_info("%s\n", __func__);
+	ret = register_chrdev(COHERENT_DEV_MAJOR, COHERENT_DEV_NAME, &fops);
+	if (ret < 0) {
+		pr_info("%s register_chrdev() failed\n", __func__);
+		return -1;
+	}
+	coherent_memory_debugfs();
+	return 0;
+}
+
+module_init(coherent_memory_init);
+module_exit(coherent_memory_exit);
+MODULE_LICENSE("GPL");
diff --git a/drivers/char/memory_online_sysfs.h b/drivers/char/memory_online_sysfs.h
new file mode 100644
index 0000000..a5f022d
--- /dev/null
+++ b/drivers/char/memory_online_sysfs.h
@@ -0,0 +1,148 @@
+/*
+ * Accessing sysfs interface for memory hotplug operation from
+ * inside the kernel.
+ *
+ * Licensed under GPL V2
+ */
+#ifndef __SYSFS_H
+#define __SYSFS_H
+
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+
+#define AUTO_ONLINE_BLOCKS "/sys/devices/system/memory/auto_online_blocks"
+#define BLOCK_SIZE_BYTES   "/sys/devices/system/memory/block_size_bytes"
+#define MEMORY_PROBE       "/sys/devices/system/memory/probe"
+
+static ssize_t read_buf(char *filename, char *buf, ssize_t count)
+{
+	mm_segment_t old_fs;
+	struct file *filp;
+	loff_t pos = 0;
+
+	if (!count)
+		return 0;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+
+	filp = filp_open(filename, O_RDONLY, 0);
+	if (IS_ERR(filp)) {
+		count = PTR_ERR(filp);
+		goto err_open;
+	}
+
+	count = vfs_read(filp, buf, count - 1, &pos);
+	buf[count] = '\0';
+
+	filp_close(filp, NULL);
+
+err_open:
+	set_fs(old_fs);
+
+	return count;
+}
+
+static unsigned long long read_0x(char *filename)
+{
+	unsigned long long ret;
+	char buf[32];
+
+	if (read_buf(filename, buf, 32) <= 0)
+		return 0;
+
+	if (kstrtoull(buf, 16, &ret))
+		return 0;
+
+	return ret;
+}
+
+static ssize_t write_buf(char *filename, char *buf)
+{
+	int ret;
+	mm_segment_t old_fs;
+	struct file *filp;
+	loff_t pos = 0;
+
+	old_fs = get_fs();
+	set_fs(KERNEL_DS);
+
+	filp = filp_open(filename, O_WRONLY, 0);
+	if (IS_ERR(filp)) {
+		ret = PTR_ERR(filp);
+		goto err_open;
+	}
+
+	ret = vfs_write(filp, buf, strlen(buf), &pos);
+
+	filp_close(filp, NULL);
+
+err_open:
+	set_fs(old_fs);
+
+	return ret;
+}
+
+int memory_probe_store(phys_addr_t addr, phys_addr_t size)
+{
+	phys_addr_t block_sz =
+		read_0x(BLOCK_SIZE_BYTES);
+	long i;
+
+	for (i = 0; i < size / block_sz; i++, addr += block_sz) {
+		char s[32];
+		ssize_t count;
+
+		snprintf(s, 32, "0x%llx", addr);
+
+		count = write_buf(MEMORY_PROBE, s);
+		if (count < 0)
+			return count;
+	}
+
+	return 0;
+}
+
+int store_mem_state(phys_addr_t addr, phys_addr_t size, char *state)
+{
+	phys_addr_t block_sz = read_0x(BLOCK_SIZE_BYTES);
+	unsigned long start_block, end_block, i;
+
+	start_block = addr / block_sz;
+	end_block = start_block + size / block_sz;
+
+	for (i = end_block - 1; i >= start_block; i--) {
+		char filename[64];
+		ssize_t count;
+
+		snprintf(filename, 64,
+			 "/sys/devices/system/memory/memory%ld/state", i);
+
+		count = write_buf(filename, state);
+		if (count < 0)
+			return count;
+	}
+
+	return 0;
+}
+
+int disable_auto_online(void)
+{
+	int ret;
+
+	ret = write_buf(AUTO_ONLINE_BLOCKS, "offline");
+	if (ret)
+		return ret;
+	return 0;
+}
+
+int enable_auto_online(void)
+{
+	int ret;
+
+	ret = write_buf(AUTO_ONLINE_BLOCKS, "online");
+	if (ret)
+		return ret;
+	return 0;
+}
+#endif
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 13cd5eb..f65810a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2946,6 +2946,7 @@ int migrate_virtual_range(int pid, unsigned long start,
 		goto out;
 	}
 
+	pr_info("%s: %d %lx %lx %d: ", __func__, pid, start, end, nid);
 	rcu_read_lock();
 	mm = find_task_by_vpid(pid)->mm;
 	rcu_read_unlock();
@@ -2956,8 +2957,14 @@ int migrate_virtual_range(int pid, unsigned long start,
 	if (!list_empty(&mlist)) {
 		ret = migrate_pages(&mlist, new_node_page, NULL,
 					nid, MIGRATE_SYNC, MR_NUMA_MISPLACED);
-		if (ret)
+		if (ret) {
+			pr_info("migration_failed for %d pages\n", ret);
 			putback_movable_pages(&mlist);
+		} else {
+			pr_info("migration_passed\n");
+		}
+	} else {
+		pr_info("list_empty\n");
 	}
 	up_write(&mm->mmap_sem);
 out:
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
