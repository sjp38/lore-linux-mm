Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F0B1E8D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 07:19:32 -0500 (EST)
From: <johan.xx.mossberg@stericsson.com>
Subject: [PATCHv2 1/3] hwmem: Add hwmem (part 1)
Date: Wed, 9 Mar 2011 13:18:51 +0100
Message-ID: <1299673133-26464-2-git-send-email-johan.xx.mossberg@stericsson.com>
In-Reply-To: <1299673133-26464-1-git-send-email-johan.xx.mossberg@stericsson.com>
References: <1299673133-26464-1-git-send-email-johan.xx.mossberg@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: johan.xx.mossberg@stericsson.com, linux-mm@kvack.org, linaro-dev@lists.linaro.org, linux-media@vger.kernel.org
Cc: gstreamer-devel@lists.freedesktop.org, m.nazarewicz@samsung.com

Add hardware memory driver, part 1.

The main purpose of hwmem is:

* To allocate buffers suitable for use with hardware. Currently
this means contiguous buffers.
* To synchronize the caches for the allocated buffers. This is
achieved by keeping track of when the CPU uses a buffer and when
other hardware uses the buffer, when we switch from CPU to other
hardware or vice versa the caches are synchronized.
* To handle sharing of allocated buffers between processes i.e.
import, export.

Hwmem is available both through a user space API and through a
kernel API.

Signed-off-by: Johan Mossberg <johan.xx.mossberg@stericsson.com>
---
 drivers/misc/Kconfig             |    1 +
 drivers/misc/Makefile            |    1 +
 drivers/misc/hwmem/Kconfig       |    7 +
 drivers/misc/hwmem/Makefile      |    3 +
 drivers/misc/hwmem/hwmem-ioctl.c |  455 ++++++++++++++++++++++
 drivers/misc/hwmem/hwmem-main.c  |  799 ++++++++++++++++++++++++++++++++++++++
 include/linux/hwmem.h            |  536 +++++++++++++++++++++++++
 7 files changed, 1802 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/hwmem/Kconfig
 create mode 100644 drivers/misc/hwmem/Makefile
 create mode 100644 drivers/misc/hwmem/hwmem-ioctl.c
 create mode 100644 drivers/misc/hwmem/hwmem-main.c
 create mode 100644 include/linux/hwmem.h

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index cc8e49d..6d83fb8 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -457,5 +457,6 @@ source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
 source "drivers/misc/iwmc3200top/Kconfig"
 source "drivers/misc/ti-st/Kconfig"
+source "drivers/misc/hwmem/Kconfig"
 
 endif # MISC_DEVICES
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 98009cc..698b4f6 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -42,3 +42,4 @@ obj-$(CONFIG_ARM_CHARLCD)	+= arm-charlcd.o
 obj-$(CONFIG_PCH_PHUB)		+= pch_phub.o
 obj-y				+= ti-st/
 obj-$(CONFIG_AB8500_PWM)	+= ab8500-pwm.o
+obj-$(CONFIG_HWMEM)		+= hwmem/
diff --git a/drivers/misc/hwmem/Kconfig b/drivers/misc/hwmem/Kconfig
new file mode 100644
index 0000000..c161875
--- /dev/null
+++ b/drivers/misc/hwmem/Kconfig
@@ -0,0 +1,7 @@
+config HWMEM
+	bool "Hardware memory driver"
+	default n
+	help
+	  This driver provides a way to allocate memory suitable for use with
+	  both CPU and non-CPU hardware, handles the caches for allocated
+	  memory and enables inter-process sharing of allocated memory.
diff --git a/drivers/misc/hwmem/Makefile b/drivers/misc/hwmem/Makefile
new file mode 100644
index 0000000..18da2ad
--- /dev/null
+++ b/drivers/misc/hwmem/Makefile
@@ -0,0 +1,3 @@
+hwmem-objs := hwmem-main.o hwmem-ioctl.o cache_handler.o
+
+obj-$(CONFIG_HWMEM) += hwmem.o
diff --git a/drivers/misc/hwmem/hwmem-ioctl.c b/drivers/misc/hwmem/hwmem-ioctl.c
new file mode 100644
index 0000000..69a15a6
--- /dev/null
+++ b/drivers/misc/hwmem/hwmem-ioctl.c
@@ -0,0 +1,455 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2010
+ *
+ * Hardware memory driver, hwmem
+ *
+ * Author: Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+#include <linux/kernel.h>
+#include <linux/fs.h>
+#include <linux/idr.h>
+#include <linux/err.h>
+#include <linux/slab.h>
+#include <linux/miscdevice.h>
+#include <linux/uaccess.h>
+#include <linux/mm_types.h>
+#include <linux/hwmem.h>
+#include <linux/device.h>
+#include <linux/sched.h>
+
+static int hwmem_open(struct inode *inode, struct file *file);
+static int hwmem_ioctl_mmap(struct file *file, struct vm_area_struct *vma);
+static int hwmem_release_fop(struct inode *inode, struct file *file);
+static long hwmem_ioctl(struct file *file, unsigned int cmd,
+	unsigned long arg);
+static unsigned long hwmem_get_unmapped_area(struct file *file,
+	unsigned long addr, unsigned long len, unsigned long pgoff,
+	unsigned long flags);
+
+static const struct file_operations hwmem_fops = {
+	.open = hwmem_open,
+	.mmap = hwmem_ioctl_mmap,
+	.unlocked_ioctl = hwmem_ioctl,
+	.release = hwmem_release_fop,
+	.get_unmapped_area = hwmem_get_unmapped_area,
+};
+
+static struct miscdevice hwmem_device = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = "hwmem",
+	.fops = &hwmem_fops,
+};
+
+struct hwmem_file {
+	struct mutex lock;
+	struct idr idr; /* id -> struct hwmem_alloc*, ref counted */
+	struct hwmem_alloc *fd_alloc; /* Ref counted */
+};
+
+static s32 create_id(struct hwmem_file *hwfile, struct hwmem_alloc *alloc)
+{
+	int id, ret;
+
+	while (true) {
+		if (idr_pre_get(&hwfile->idr, GFP_KERNEL) == 0)
+			return -ENOMEM;
+
+		ret = idr_get_new_above(&hwfile->idr, alloc, 1, &id);
+		if (ret == 0)
+			break;
+		else if (ret != -EAGAIN)
+			return -ENOMEM;
+	}
+
+	/*
+	 * IDR always returns the lowest free id so there is no wrapping issue
+	 * because of this.
+	 */
+	if (id >= (s32)1 << (31 - PAGE_SHIFT)) {
+		dev_err(hwmem_device.this_device, "Out of IDs!\n");
+		idr_remove(&hwfile->idr, id);
+		return -ENOMSG;
+	}
+
+	return (s32)id << PAGE_SHIFT;
+}
+
+static void remove_id(struct hwmem_file *hwfile, s32 id)
+{
+	idr_remove(&hwfile->idr, id >> PAGE_SHIFT);
+}
+
+static struct hwmem_alloc *resolve_id(struct hwmem_file *hwfile, s32 id)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = id ? idr_find(&hwfile->idr, id >> PAGE_SHIFT) :
+							hwfile->fd_alloc;
+	if (alloc == NULL)
+		alloc = ERR_PTR(-EINVAL);
+
+	return alloc;
+}
+
+static s32 alloc(struct hwmem_file *hwfile, struct hwmem_alloc_request *req)
+{
+	s32 ret = 0;
+	struct hwmem_alloc *alloc;
+
+	alloc = hwmem_alloc(req->size, req->flags, req->default_access,
+								req->mem_type);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	ret = create_id(hwfile, alloc);
+	if (ret < 0)
+		hwmem_release(alloc);
+
+	return ret;
+}
+
+static int alloc_fd(struct hwmem_file *hwfile, struct hwmem_alloc_request *req)
+{
+	struct hwmem_alloc *alloc;
+
+	if (hwfile->fd_alloc)
+		return -EINVAL;
+
+	alloc = hwmem_alloc(req->size, req->flags, req->default_access,
+								req->mem_type);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	hwfile->fd_alloc = alloc;
+
+	return 0;
+}
+
+static int release(struct hwmem_file *hwfile, s32 id)
+{
+	struct hwmem_alloc *alloc;
+
+	if (id == 0)
+		return -EINVAL;
+
+	alloc = resolve_id(hwfile, id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	remove_id(hwfile, id);
+	hwmem_release(alloc);
+
+	return 0;
+}
+
+static int set_cpu_domain(struct hwmem_file *hwfile,
+					struct hwmem_set_domain_request *req)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, req->id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	return hwmem_set_domain(alloc, req->access, HWMEM_DOMAIN_CPU,
+					(struct hwmem_region *)&req->region);
+}
+
+static int set_access(struct hwmem_file *hwfile,
+		struct hwmem_set_access_request *req)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, req->id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	return hwmem_set_access(alloc, req->access, req->pid);
+}
+
+static int get_info(struct hwmem_file *hwfile,
+		struct hwmem_get_info_request *req)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, req->id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	hwmem_get_info(alloc, &req->size, &req->mem_type, &req->access);
+
+	return 0;
+}
+
+static s32 export(struct hwmem_file *hwfile, s32 id)
+{
+	s32 ret;
+	struct hwmem_alloc *alloc;
+	enum hwmem_access access;
+
+	alloc = resolve_id(hwfile, id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	/*
+	 * The user could be about to send the buffer to a driver but
+	 * there is a chance the current thread group don't have import rights
+	 * if it gained access to the buffer via a inter-process fd transfer
+	 * (fork, Android binder), if this is the case the driver will not be
+	 * able to resolve the buffer name. To avoid this situation we give the
+	 * current thread group import rights. This will not breach the
+	 * security as the process already has access to the buffer (otherwise
+	 * it would not be able to get here).
+	 */
+	hwmem_get_info(alloc, NULL, NULL, &access);
+
+	ret = hwmem_set_access(alloc, (access | HWMEM_ACCESS_IMPORT),
+							task_tgid_nr(current));
+	if (ret < 0)
+		return ret;
+
+	return hwmem_get_name(alloc);
+}
+
+static s32 import(struct hwmem_file *hwfile, s32 name)
+{
+	s32 ret = 0;
+	struct hwmem_alloc *alloc;
+	enum hwmem_access access;
+
+	alloc = hwmem_resolve_by_name(name);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	/* Check access permissions for process */
+	hwmem_get_info(alloc, NULL, NULL, &access);
+	if (!(access & HWMEM_ACCESS_IMPORT)) {
+		ret = -EPERM;
+		goto error;
+	}
+
+	ret = create_id(hwfile, alloc);
+	if (ret < 0)
+		goto error;
+
+	return ret;
+
+error:
+	hwmem_release(alloc);
+
+	return ret;
+}
+
+static int import_fd(struct hwmem_file *hwfile, s32 name)
+{
+	int ret;
+	struct hwmem_alloc *alloc;
+	enum hwmem_access access;
+
+	if (hwfile->fd_alloc)
+		return -EINVAL;
+
+	alloc = hwmem_resolve_by_name(name);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	/* Check access permissions for process */
+	hwmem_get_info(alloc, NULL, NULL, &access);
+	if (!(access & HWMEM_ACCESS_IMPORT)) {
+		ret = -EPERM;
+		goto error;
+	}
+
+	hwfile->fd_alloc = alloc;
+
+	return 0;
+
+error:
+	hwmem_release(alloc);
+
+	return ret;
+}
+
+static int hwmem_open(struct inode *inode, struct file *file)
+{
+	struct hwmem_file *hwfile;
+
+	hwfile = kzalloc(sizeof(struct hwmem_file), GFP_KERNEL);
+	if (hwfile == NULL)
+		return -ENOMEM;
+
+	idr_init(&hwfile->idr);
+	mutex_init(&hwfile->lock);
+	file->private_data = hwfile;
+
+	return 0;
+}
+
+static int hwmem_ioctl_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	int ret;
+	struct hwmem_file *hwfile = (struct hwmem_file *)file->private_data;
+	struct hwmem_alloc *alloc;
+
+	mutex_lock(&hwfile->lock);
+
+	alloc = resolve_id(hwfile, (s32)vma->vm_pgoff << PAGE_SHIFT);
+	if (IS_ERR(alloc)) {
+		ret = PTR_ERR(alloc);
+		goto out;
+	}
+
+	ret = hwmem_mmap(alloc, vma);
+
+out:
+	mutex_unlock(&hwfile->lock);
+
+	return ret;
+}
+
+static int hwmem_release_idr_for_each_wrapper(int id, void *ptr, void *data)
+{
+	hwmem_release((struct hwmem_alloc *)ptr);
+
+	return 0;
+}
+
+static int hwmem_release_fop(struct inode *inode, struct file *file)
+{
+	struct hwmem_file *hwfile = (struct hwmem_file *)file->private_data;
+
+	idr_for_each(&hwfile->idr, hwmem_release_idr_for_each_wrapper, NULL);
+	idr_remove_all(&hwfile->idr);
+	idr_destroy(&hwfile->idr);
+
+	if (hwfile->fd_alloc)
+		hwmem_release(hwfile->fd_alloc);
+
+	mutex_destroy(&hwfile->lock);
+
+	kfree(hwfile);
+
+	return 0;
+}
+
+static long hwmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	int ret = -ENOSYS;
+	struct hwmem_file *hwfile = (struct hwmem_file *)file->private_data;
+
+	mutex_lock(&hwfile->lock);
+
+	switch (cmd) {
+	case HWMEM_ALLOC_IOC:
+		{
+			struct hwmem_alloc_request req;
+			if (copy_from_user(&req, (void __user *)arg,
+					sizeof(struct hwmem_alloc_request)))
+				ret = -EFAULT;
+			else
+				ret = alloc(hwfile, &req);
+		}
+		break;
+	case HWMEM_ALLOC_FD_IOC:
+		{
+			struct hwmem_alloc_request req;
+			if (copy_from_user(&req, (void __user *)arg,
+					sizeof(struct hwmem_alloc_request)))
+				ret = -EFAULT;
+			else
+				ret = alloc_fd(hwfile, &req);
+		}
+		break;
+	case HWMEM_RELEASE_IOC:
+		ret = release(hwfile, (s32)arg);
+		break;
+	case HWMEM_SET_CPU_DOMAIN_IOC:
+		{
+			struct hwmem_set_domain_request req;
+			if (copy_from_user(&req, (void __user *)arg,
+				sizeof(struct hwmem_set_domain_request)))
+				ret = -EFAULT;
+			else
+				ret = set_cpu_domain(hwfile, &req);
+		}
+		break;
+	case HWMEM_SET_ACCESS_IOC:
+		{
+			struct hwmem_set_access_request req;
+			if (copy_from_user(&req, (void __user *)arg,
+				sizeof(struct hwmem_set_access_request)))
+				ret = -EFAULT;
+			else
+				ret = set_access(hwfile, &req);
+		}
+		break;
+	case HWMEM_GET_INFO_IOC:
+		{
+			struct hwmem_get_info_request req;
+			if (copy_from_user(&req, (void __user *)arg,
+				sizeof(struct hwmem_get_info_request)))
+				ret = -EFAULT;
+			else
+				ret = get_info(hwfile, &req);
+			if (ret == 0 && copy_to_user((void __user *)arg, &req,
+					sizeof(struct hwmem_get_info_request)))
+				ret = -EFAULT;
+		}
+		break;
+	case HWMEM_EXPORT_IOC:
+		ret = export(hwfile, (s32)arg);
+		break;
+	case HWMEM_IMPORT_IOC:
+		ret = import(hwfile, (s32)arg);
+		break;
+	case HWMEM_IMPORT_FD_IOC:
+		ret = import_fd(hwfile, (s32)arg);
+		break;
+	}
+
+	mutex_unlock(&hwfile->lock);
+
+	return ret;
+}
+
+static unsigned long hwmem_get_unmapped_area(struct file *file,
+	unsigned long addr, unsigned long len, unsigned long pgoff,
+	unsigned long flags)
+{
+	/*
+	 * pgoff will not be valid as it contains a buffer id (right shifted
+	 * PAGE_SHIFT bits). To not confuse get_unmapped_area we'll not pass
+	 * on file or pgoff.
+	 */
+	return current->mm->get_unmapped_area(NULL, addr, len, 0, flags);
+}
+
+int __init hwmem_ioctl_init(void)
+{
+	if (PAGE_SHIFT < 1 || PAGE_SHIFT > 30 || sizeof(size_t) != 4 ||
+		sizeof(int) > 4 || sizeof(enum hwmem_alloc_flags) != 4 ||
+					sizeof(enum hwmem_access) != 4 ||
+					 sizeof(enum hwmem_mem_type) != 4) {
+		dev_err(hwmem_device.this_device, "PAGE_SHIFT < 1 || PAGE_SHIFT"
+			" > 30 || sizeof(size_t) != 4 || sizeof(int) > 4 ||"
+			" sizeof(enum hwmem_alloc_flags) != 4 || sizeof(enum"
+			" hwmem_access) != 4 || sizeof(enum hwmem_mem_type)"
+								" != 4\n");
+		return -ENOMSG;
+	}
+	if (PAGE_SHIFT > 15)
+		dev_warn(hwmem_device.this_device, "Due to the page size only"
+				" %u id:s per file instance are available\n",
+					((u32)1 << (31 - PAGE_SHIFT)) - 1);
+
+	return misc_register(&hwmem_device);
+}
+
+void __exit hwmem_ioctl_exit(void)
+{
+	misc_deregister(&hwmem_device);
+}
diff --git a/drivers/misc/hwmem/hwmem-main.c b/drivers/misc/hwmem/hwmem-main.c
new file mode 100644
index 0000000..e0f9b99
--- /dev/null
+++ b/drivers/misc/hwmem/hwmem-main.c
@@ -0,0 +1,799 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2010
+ *
+ * Hardware memory driver, hwmem
+ *
+ * Author: Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>,
+ * Johan Mossberg <johan.xx.mossberg@stericsson.com> for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/device.h>
+#include <linux/dma-mapping.h>
+#include <linux/idr.h>
+#include <linux/mm.h>
+#include <linux/sched.h>
+#include <linux/err.h>
+#include <linux/platform_device.h>
+#include <linux/slab.h>
+#include <linux/pid.h>
+#include <linux/list.h>
+#include <linux/hwmem.h>
+#include <linux/debugfs.h>
+#include <linux/uaccess.h>
+#include <linux/vmalloc.h>
+#include <linux/io.h>
+#include <asm/sizes.h>
+#include "cache_handler.h"
+
+struct hwmem_alloc_threadg_info {
+	struct list_head list;
+
+	struct pid *threadg_pid; /* Ref counted */
+
+	enum hwmem_access access;
+};
+
+struct hwmem_alloc {
+	struct list_head list;
+
+	atomic_t ref_cnt;
+	enum hwmem_alloc_flags flags;
+	u32 paddr;
+	void *kaddr;
+	u32 size;
+	s32 name;
+
+	/* Access control */
+	enum hwmem_access default_access;
+	struct list_head threadg_info_list;
+
+	/* Cache handling */
+	struct cach_buf cach_buf;
+};
+
+static struct platform_device *hwdev;
+
+static u32 hwmem_paddr;
+static u32 hwmem_size;
+
+static LIST_HEAD(alloc_list);
+static DEFINE_IDR(global_idr);
+static DEFINE_MUTEX(lock);
+
+static void vm_open(struct vm_area_struct *vma);
+static void vm_close(struct vm_area_struct *vma);
+static struct vm_operations_struct vm_ops = {
+	.open = vm_open,
+	.close = vm_close,
+};
+
+#ifdef CONFIG_DEBUG_FS
+
+static int debugfs_allocs_read(struct file *filp, char __user *buf,
+						size_t count, loff_t *f_pos);
+static const struct file_operations debugfs_allocs_fops = {
+	.owner = THIS_MODULE,
+	.read  = debugfs_allocs_read,
+};
+
+#endif /* #ifdef CONFIG_DEBUG_FS */
+
+static void clean_alloc_list(void);
+static void kunmap_alloc(struct hwmem_alloc *alloc);
+
+/* Helpers */
+
+static u32 get_alloc_offset(struct hwmem_alloc *alloc)
+{
+	return alloc->paddr - hwmem_paddr;
+}
+
+static void destroy_hwmem_alloc_threadg_info(
+		struct hwmem_alloc_threadg_info *info)
+{
+	if (info->threadg_pid)
+		put_pid(info->threadg_pid);
+
+	kfree(info);
+}
+
+static void clean_hwmem_alloc_threadg_info_list(struct hwmem_alloc *alloc)
+{
+	struct hwmem_alloc_threadg_info *info;
+	struct hwmem_alloc_threadg_info *tmp;
+
+	list_for_each_entry_safe(info, tmp, &(alloc->threadg_info_list), list) {
+		list_del(&info->list);
+		destroy_hwmem_alloc_threadg_info(info);
+	}
+}
+
+static enum hwmem_access get_access(struct hwmem_alloc *alloc)
+{
+	struct hwmem_alloc_threadg_info *info;
+	struct pid *my_pid;
+	bool found = false;
+
+	my_pid = find_get_pid(task_tgid_nr(current));
+	if (!my_pid)
+		return 0;
+
+	list_for_each_entry(info, &(alloc->threadg_info_list), list) {
+		if (info->threadg_pid == my_pid) {
+			found = true;
+			break;
+		}
+	}
+
+	put_pid(my_pid);
+
+	if (found)
+		return info->access;
+	else
+		return alloc->default_access;
+}
+
+static void clear_alloc_mem(struct hwmem_alloc *alloc)
+{
+	cach_set_domain(&alloc->cach_buf, HWMEM_ACCESS_WRITE,
+						HWMEM_DOMAIN_CPU, NULL);
+
+	memset(alloc->kaddr, 0, alloc->size);
+}
+
+static void clean_alloc(struct hwmem_alloc *alloc)
+{
+	if (alloc->name) {
+		idr_remove(&global_idr, alloc->name);
+		alloc->name = 0;
+	}
+
+	alloc->flags = 0;
+
+	clean_hwmem_alloc_threadg_info_list(alloc);
+
+	kunmap_alloc(alloc);
+}
+
+static void destroy_alloc(struct hwmem_alloc *alloc)
+{
+	clean_alloc(alloc);
+
+	kfree(alloc);
+}
+
+static void __hwmem_release(struct hwmem_alloc *alloc)
+{
+	struct hwmem_alloc *other;
+
+	clean_alloc(alloc);
+
+	other = list_entry(alloc->list.prev, struct hwmem_alloc, list);
+	if ((alloc->list.prev != &alloc_list) &&
+			atomic_read(&other->ref_cnt) == 0) {
+		other->size += alloc->size;
+		list_del(&alloc->list);
+		destroy_alloc(alloc);
+		alloc = other;
+	}
+	other = list_entry(alloc->list.next, struct hwmem_alloc, list);
+	if ((alloc->list.next != &alloc_list) &&
+			atomic_read(&other->ref_cnt) == 0) {
+		alloc->size += other->size;
+		list_del(&other->list);
+		destroy_alloc(other);
+	}
+}
+
+static struct hwmem_alloc *find_free_alloc_bestfit(u32 size)
+{
+	u32 best_diff = ~0;
+	struct hwmem_alloc *alloc = NULL, *i;
+
+	list_for_each_entry(i, &alloc_list, list) {
+		u32 diff = i->size - size;
+		if (atomic_read(&i->ref_cnt) > 0 || i->size < size)
+			continue;
+		if (diff < best_diff) {
+			alloc = i;
+			best_diff = diff;
+		}
+	}
+
+	return alloc != NULL ? alloc : ERR_PTR(-ENOMEM);
+}
+
+static struct hwmem_alloc *split_allocation(struct hwmem_alloc *alloc,
+							u32 new_alloc_size)
+{
+	struct hwmem_alloc *new_alloc;
+
+	new_alloc = kzalloc(sizeof(struct hwmem_alloc), GFP_KERNEL);
+	if (new_alloc == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	atomic_inc(&new_alloc->ref_cnt);
+	INIT_LIST_HEAD(&new_alloc->threadg_info_list);
+	new_alloc->paddr = alloc->paddr;
+	new_alloc->size = new_alloc_size;
+	alloc->size -= new_alloc_size;
+	alloc->paddr += new_alloc_size;
+
+	list_add_tail(&new_alloc->list, &alloc->list);
+
+	return new_alloc;
+}
+
+static int init_alloc_list(void)
+{
+	struct hwmem_alloc *alloc = kzalloc(sizeof(struct hwmem_alloc),
+								GFP_KERNEL);
+	if (alloc == NULL)
+		return -ENOMEM;
+	alloc->paddr = hwmem_paddr;
+	alloc->size = hwmem_size;
+	INIT_LIST_HEAD(&alloc->threadg_info_list);
+	list_add_tail(&alloc->list, &alloc_list);
+
+	return 0;
+}
+
+static void clean_alloc_list(void)
+{
+	while (list_empty(&alloc_list) == 0) {
+		struct hwmem_alloc *i = list_first_entry(&alloc_list,
+						struct hwmem_alloc, list);
+
+		list_del(&i->list);
+
+		destroy_alloc(i);
+	}
+}
+
+static int kmap_alloc(struct hwmem_alloc *alloc)
+{
+	int ret;
+	pgprot_t pgprot;
+
+	struct vm_struct *area = get_vm_area(alloc->size, VM_IOREMAP);
+	if (area == NULL) {
+		dev_info(&hwdev->dev, "Failed to allocate %u bytes virtual"
+						" memory", alloc->size);
+		return -ENOMSG;
+	}
+
+	pgprot = PAGE_KERNEL;
+	cach_set_pgprot_cache_options(&alloc->cach_buf, &pgprot);
+
+	ret = ioremap_page_range((unsigned long)area->addr,
+		(unsigned long)area->addr + alloc->size, alloc->paddr, pgprot);
+	if (ret < 0) {
+		dev_info(&hwdev->dev, "Failed to map %#x - %#x", alloc->paddr,
+						alloc->paddr + alloc->size);
+		goto failed_to_map;
+	}
+
+	alloc->kaddr = area->addr;
+
+	return 0;
+
+failed_to_map:
+	area = remove_vm_area(area->addr);
+	if (area == NULL)
+		dev_err(&hwdev->dev,
+				"Failed to unmap alloc, resource leak!\n");
+
+	kfree(area);
+
+	return ret;
+}
+
+static void kunmap_alloc(struct hwmem_alloc *alloc)
+{
+	struct vm_struct *area;
+
+	if (alloc->kaddr == NULL)
+		return;
+
+	area = remove_vm_area(alloc->kaddr);
+	if (area == NULL) {
+		dev_err(&hwdev->dev,
+				"Failed to unmap alloc, resource leak!\n");
+		return;
+	}
+
+	kfree(area);
+
+	alloc->kaddr = NULL;
+}
+
+/* HWMEM API */
+
+struct hwmem_alloc *hwmem_alloc(u32 size, enum hwmem_alloc_flags flags,
+		enum hwmem_access def_access, enum hwmem_mem_type mem_type)
+{
+	struct hwmem_alloc *alloc;
+	int ret;
+
+	if (!hwdev) {
+		printk(KERN_ERR "hwmem: Badly configured\n");
+		return ERR_PTR(-EINVAL);
+	}
+
+	if (size == 0)
+		return ERR_PTR(-EINVAL);
+
+	mutex_lock(&lock);
+
+	size = PAGE_ALIGN(size);
+
+	alloc = find_free_alloc_bestfit(size);
+	if (IS_ERR(alloc)) {
+		dev_info(&hwdev->dev, "Allocation failed, no free slot\n");
+		goto no_slot;
+	}
+
+	if (size < alloc->size) {
+		alloc = split_allocation(alloc, size);
+		if (IS_ERR(alloc))
+			goto split_alloc_failed;
+	} else {
+		atomic_inc(&alloc->ref_cnt);
+	}
+
+	alloc->flags = flags;
+	alloc->default_access = def_access;
+	cach_init_buf(&alloc->cach_buf, alloc->flags, alloc->size);
+	ret = kmap_alloc(alloc);
+	if (ret < 0)
+		goto kmap_alloc_failed;
+	cach_set_buf_addrs(&alloc->cach_buf, alloc->kaddr, alloc->paddr);
+
+	clear_alloc_mem(alloc);
+
+	goto out;
+
+kmap_alloc_failed:
+	__hwmem_release(alloc);
+	alloc = ERR_PTR(ret);
+split_alloc_failed:
+no_slot:
+
+out:
+	mutex_unlock(&lock);
+
+	return alloc;
+}
+EXPORT_SYMBOL(hwmem_alloc);
+
+void hwmem_release(struct hwmem_alloc *alloc)
+{
+	mutex_lock(&lock);
+
+	if (atomic_dec_and_test(&alloc->ref_cnt))
+		__hwmem_release(alloc);
+
+	mutex_unlock(&lock);
+}
+EXPORT_SYMBOL(hwmem_release);
+
+int hwmem_set_domain(struct hwmem_alloc *alloc, enum hwmem_access access,
+		enum hwmem_domain domain, struct hwmem_region *region)
+{
+	mutex_lock(&lock);
+
+	cach_set_domain(&alloc->cach_buf, access, domain, region);
+
+	mutex_unlock(&lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(hwmem_set_domain);
+
+int hwmem_pin(struct hwmem_alloc *alloc, struct hwmem_mem_chunk *mem_chunks,
+						u32 *mem_chunks_length)
+{
+	if (*mem_chunks_length < 1) {
+		*mem_chunks_length = 1;
+		return -ENOSPC;
+	}
+
+	mutex_lock(&lock);
+
+	mem_chunks[0].paddr = alloc->paddr;
+	mem_chunks[0].size = alloc->size;
+	*mem_chunks_length = 1;
+
+	mutex_unlock(&lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(hwmem_pin);
+
+void hwmem_unpin(struct hwmem_alloc *alloc)
+{
+}
+EXPORT_SYMBOL(hwmem_unpin);
+
+static void vm_open(struct vm_area_struct *vma)
+{
+	atomic_inc(&((struct hwmem_alloc *)vma->vm_private_data)->ref_cnt);
+}
+
+static void vm_close(struct vm_area_struct *vma)
+{
+	hwmem_release((struct hwmem_alloc *)vma->vm_private_data);
+}
+
+int hwmem_mmap(struct hwmem_alloc *alloc, struct vm_area_struct *vma)
+{
+	int ret = 0;
+	unsigned long vma_size = vma->vm_end - vma->vm_start;
+	enum hwmem_access access;
+	mutex_lock(&lock);
+
+	access = get_access(alloc);
+
+	/* Check permissions */
+	if ((!(access & HWMEM_ACCESS_WRITE) &&
+				(vma->vm_flags & VM_WRITE)) ||
+			(!(access & HWMEM_ACCESS_READ) &&
+				(vma->vm_flags & VM_READ))) {
+		ret = -EPERM;
+		goto illegal_access;
+	}
+
+	if (vma_size > alloc->size) {
+		ret = -EINVAL;
+		goto illegal_size;
+	}
+
+	/*
+	 * We don't want Linux to do anything (merging etc) with our VMAs as
+	 * the offset is not necessarily valid
+	 */
+	vma->vm_flags |= VM_SPECIAL;
+	cach_set_pgprot_cache_options(&alloc->cach_buf, &vma->vm_page_prot);
+	vma->vm_private_data = (void *)alloc;
+	atomic_inc(&alloc->ref_cnt);
+	vma->vm_ops = &vm_ops;
+
+	ret = remap_pfn_range(vma, vma->vm_start, alloc->paddr >> PAGE_SHIFT,
+		min(vma_size, (unsigned long)alloc->size), vma->vm_page_prot);
+	if (ret < 0)
+		goto map_failed;
+
+	goto out;
+
+map_failed:
+	atomic_dec(&alloc->ref_cnt);
+illegal_size:
+illegal_access:
+
+out:
+	mutex_unlock(&lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(hwmem_mmap);
+
+void *hwmem_kmap(struct hwmem_alloc *alloc)
+{
+	void *ret;
+
+	mutex_lock(&lock);
+
+	ret = alloc->kaddr;
+
+	mutex_unlock(&lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(hwmem_kmap);
+
+void hwmem_kunmap(struct hwmem_alloc *alloc)
+{
+}
+EXPORT_SYMBOL(hwmem_kunmap);
+
+int hwmem_set_access(struct hwmem_alloc *alloc,
+		enum hwmem_access access, pid_t pid_nr)
+{
+	int ret;
+	struct hwmem_alloc_threadg_info *info;
+	struct pid *pid;
+	bool found = false;
+
+	pid = find_get_pid(pid_nr);
+	if (!pid) {
+		ret = -EINVAL;
+		goto error_get_pid;
+	}
+
+	list_for_each_entry(info, &(alloc->threadg_info_list), list) {
+		if (info->threadg_pid == pid) {
+			found = true;
+			break;
+		}
+	}
+
+	if (!found) {
+		info = kmalloc(sizeof(*info), GFP_KERNEL);
+		if (!info) {
+			ret = -ENOMEM;
+			goto error_alloc_info;
+		}
+
+		info->threadg_pid = pid;
+		info->access = access;
+
+		list_add_tail(&(info->list), &(alloc->threadg_info_list));
+	} else {
+		info->access = access;
+	}
+
+	return 0;
+
+error_alloc_info:
+	put_pid(pid);
+error_get_pid:
+	return ret;
+}
+EXPORT_SYMBOL(hwmem_set_access);
+
+void hwmem_get_info(struct hwmem_alloc *alloc, u32 *size,
+	enum hwmem_mem_type *mem_type, enum hwmem_access *access)
+{
+	mutex_lock(&lock);
+
+	if (size != NULL)
+		*size = alloc->size;
+	if (mem_type != NULL)
+		*mem_type = HWMEM_MEM_CONTIGUOUS_SYS;
+	if (access != NULL)
+		*access = get_access(alloc);
+
+	mutex_unlock(&lock);
+}
+EXPORT_SYMBOL(hwmem_get_info);
+
+int hwmem_get_name(struct hwmem_alloc *alloc)
+{
+	int ret = 0, name;
+
+	mutex_lock(&lock);
+
+	if (alloc->name != 0) {
+		ret = alloc->name;
+		goto out;
+	}
+
+	while (true) {
+		if (idr_pre_get(&global_idr, GFP_KERNEL) == 0) {
+			ret = -ENOMEM;
+			goto pre_get_id_failed;
+		}
+
+		ret = idr_get_new_above(&global_idr, alloc, 1, &name);
+		if (ret == 0)
+			break;
+		else if (ret != -EAGAIN)
+			goto get_id_failed;
+	}
+
+	alloc->name = name;
+
+	ret = name;
+	goto out;
+
+get_id_failed:
+pre_get_id_failed:
+
+out:
+	mutex_unlock(&lock);
+
+	return ret;
+}
+EXPORT_SYMBOL(hwmem_get_name);
+
+struct hwmem_alloc *hwmem_resolve_by_name(s32 name)
+{
+	struct hwmem_alloc *alloc;
+
+	mutex_lock(&lock);
+
+	alloc = idr_find(&global_idr, name);
+	if (alloc == NULL) {
+		alloc = ERR_PTR(-EINVAL);
+		goto find_failed;
+	}
+	atomic_inc(&alloc->ref_cnt);
+
+	goto out;
+
+find_failed:
+
+out:
+	mutex_unlock(&lock);
+
+	return alloc;
+}
+EXPORT_SYMBOL(hwmem_resolve_by_name);
+
+/* Debug */
+
+static int print_alloc(struct hwmem_alloc *alloc, char **buf, size_t buf_size)
+{
+	int ret;
+
+	if (buf_size < 134)
+		return -EINVAL;
+
+	ret = sprintf(*buf, "paddr: %#10x\tsize: %10u\tref cnt: %2i\t"
+				"name: %#10x\tflags: %#4x\t$ settings: %#4x\t"
+				"def acc: %#3x\n", alloc->paddr, alloc->size,
+				atomic_read(&alloc->ref_cnt), alloc->name,
+				alloc->flags, alloc->cach_buf.cache_settings,
+							alloc->default_access);
+	if (ret < 0)
+		return -ENOMSG;
+
+	*buf += ret;
+
+	return 0;
+}
+
+#ifdef CONFIG_DEBUG_FS
+
+static int debugfs_allocs_read(struct file *file, char __user *buf,
+						size_t count, loff_t *f_pos)
+{
+	/*
+	 * We assume the supplied buffer and PAGE_SIZE is large enough to hold
+	 * information about at least one alloc, if not no data will be
+	 * returned.
+	 */
+
+	int ret;
+	struct hwmem_alloc *curr_alloc;
+	char *local_buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	char *local_buf_pos = local_buf;
+	size_t available_space = min((size_t)PAGE_SIZE, count);
+	/* private_data is intialized to NULL in open which I assume is 0. */
+	u32 *curr_pos = (u32 *)&file->private_data;
+	size_t bytes_read;
+
+	if (local_buf == NULL)
+		return -ENOMEM;
+
+	mutex_lock(&lock);
+
+	list_for_each_entry(curr_alloc, &alloc_list, list) {
+		u32 alloc_offset = get_alloc_offset(curr_alloc);
+
+		if (alloc_offset < *curr_pos)
+			continue;
+
+		ret = print_alloc(curr_alloc, &local_buf_pos, available_space -
+					(size_t)(local_buf_pos - local_buf));
+		if (ret == -EINVAL) /* No more room */
+			break;
+		else if (ret < 0)
+			goto out;
+
+		*curr_pos = alloc_offset + 1;
+	}
+
+	bytes_read = (size_t)(local_buf_pos - local_buf);
+
+	ret = copy_to_user(buf, local_buf, bytes_read);
+	if (ret < 0)
+		goto out;
+
+	ret = bytes_read;
+
+out:
+	kfree(local_buf);
+
+	mutex_unlock(&lock);
+
+	return ret;
+}
+
+static void init_debugfs(void)
+{
+	/* Hwmem is never unloaded so dropping the dentrys is ok. */
+	struct dentry *debugfs_root_dir = debugfs_create_dir("hwmem", NULL);
+	(void)debugfs_create_file("allocs", 0444, debugfs_root_dir, 0,
+							&debugfs_allocs_fops);
+}
+
+#endif /* #ifdef CONFIG_DEBUG_FS */
+
+/* Module */
+
+extern int hwmem_ioctl_init(void);
+extern void hwmem_ioctl_exit(void);
+
+static int __devinit hwmem_probe(struct platform_device *pdev)
+{
+	int ret = 0;
+	struct hwmem_platform_data *platform_data = pdev->dev.platform_data;
+
+	if (sizeof(int) != 4 || sizeof(phys_addr_t) < 4 ||
+				sizeof(void *) < 4 || sizeof(size_t) != 4) {
+		dev_err(&pdev->dev, "sizeof(int) != 4 || sizeof(phys_addr_t)"
+			" < 4 || sizeof(void *) < 4 || sizeof(size_t) !="
+								" 4\n");
+		return -ENOMSG;
+	}
+
+	if (hwdev || platform_data->size == 0 ||
+		platform_data->start != PAGE_ALIGN(platform_data->start) ||
+		platform_data->size != PAGE_ALIGN(platform_data->size)) {
+		dev_err(&pdev->dev, "hwdev || platform_data->size == 0 ||"
+					"platform_data->start !="
+					" PAGE_ALIGN(platform_data->start) ||"
+					"platform_data->size !="
+					" PAGE_ALIGN(platform_data->size)\n");
+		return -EINVAL;
+	}
+
+	hwdev = pdev;
+	hwmem_paddr = platform_data->start;
+	hwmem_size = platform_data->size;
+
+	/*
+	 * No need to flush the caches here. If we can keep track of the cache
+	 * content then none of our memory will be in the caches, if we can't
+	 * keep track of the cache content we always assume all our memory is
+	 * in the caches.
+	 */
+
+	ret = init_alloc_list();
+	if (ret < 0)
+		goto init_alloc_list_failed;
+
+	ret = hwmem_ioctl_init();
+	if (ret)
+		goto ioctl_init_failed;
+
+#ifdef CONFIG_DEBUG_FS
+	init_debugfs();
+#endif
+
+	dev_info(&pdev->dev, "Hwmem probed, device contains %#x bytes\n",
+			hwmem_size);
+
+	goto out;
+
+ioctl_init_failed:
+	clean_alloc_list();
+init_alloc_list_failed:
+	hwdev = NULL;
+
+out:
+	return ret;
+}
+
+static struct platform_driver hwmem_driver = {
+	.probe	= hwmem_probe,
+	.driver = {
+		.name	= "hwmem",
+	},
+};
+
+static int __init hwmem_init(void)
+{
+	return platform_driver_register(&hwmem_driver);
+}
+subsys_initcall(hwmem_init);
+
+MODULE_AUTHOR("Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Hardware memory driver");
diff --git a/include/linux/hwmem.h b/include/linux/hwmem.h
new file mode 100644
index 0000000..dd99c44
--- /dev/null
+++ b/include/linux/hwmem.h
@@ -0,0 +1,536 @@
+/*
+ * Copyright (C) ST-Ericsson SA 2010
+ *
+ * Hardware memory driver, hwmem
+ *
+ * Author: Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+#ifndef _HWMEM_H_
+#define _HWMEM_H_
+
+#if !defined(__KERNEL__) && !defined(_KERNEL)
+#include <stdint.h>
+#include <sys/types.h>
+#else
+#include <linux/types.h>
+#include <linux/mm_types.h>
+#endif
+
+#define HWMEM_DEFAULT_DEVICE_NAME "hwmem"
+
+/**
+ * @brief Flags defining behavior of allocation
+ */
+enum hwmem_alloc_flags {
+	/**
+	 * @brief Buffered
+	 */
+	HWMEM_ALLOC_HINT_WRITE_COMBINE         = (1 << 0),
+	/**
+	 * @brief Non-buffered
+	 */
+	HWMEM_ALLOC_HINT_NO_WRITE_COMBINE      = (1 << 1),
+	/**
+	 * @brief Cached
+	 */
+	HWMEM_ALLOC_HINT_CACHED                = (1 << 2),
+	/**
+	 * @brief Uncached
+	 */
+	HWMEM_ALLOC_HINT_UNCACHED              = (1 << 3),
+	/**
+	 * @brief Write back
+	 */
+	HWMEM_ALLOC_HINT_CACHE_WB              = (1 << 4),
+	/**
+	 * @brief Write through
+	 */
+	HWMEM_ALLOC_HINT_CACHE_WT              = (1 << 5),
+	/**
+	 * @brief No alloc on write
+	 */
+	HWMEM_ALLOC_HINT_CACHE_NAOW            = (1 << 6),
+	/**
+	 * @brief Alloc on write
+	 */
+	HWMEM_ALLOC_HINT_CACHE_AOW             = (1 << 7),
+	/**
+	 * @brief Inner and outer cache
+	 */
+	HWMEM_ALLOC_HINT_INNER_AND_OUTER_CACHE = (1 << 8),
+	/**
+	 * @brief Inner cache only
+	 */
+	HWMEM_ALLOC_HINT_INNER_CACHE_ONLY      = (1 << 9),
+	/**
+	 * @brief Reserved for use by the cache handler integration
+	 */
+	HWMEM_ALLOC_RESERVED_CHI               = (1 << 31),
+};
+
+/**
+ * @brief Flags defining buffer access mode.
+ */
+enum hwmem_access {
+	/**
+	 * @brief Buffer will be read from.
+	 */
+	HWMEM_ACCESS_READ  = (1 << 0),
+	/**
+	 * @brief Buffer will be written to.
+	 */
+	HWMEM_ACCESS_WRITE = (1 << 1),
+	/**
+	 * @brief Buffer will be imported.
+	 */
+	HWMEM_ACCESS_IMPORT = (1 << 2),
+};
+
+/**
+ * @brief Values defining memory types.
+ */
+enum hwmem_mem_type {
+	/**
+	 * @brief Scattered system memory.
+	 */
+	HWMEM_MEM_SCATTERED_SYS,
+	/**
+	 * @brief Contiguous system memory.
+	 */
+	HWMEM_MEM_CONTIGUOUS_SYS,
+};
+
+/* User space API */
+
+/**
+ * @see struct hwmem_region.
+ */
+struct hwmem_region_us {
+	__u32 offset;
+	__u32 count;
+	__u32 start;
+	__u32 end;
+	__u32 size;
+};
+
+/**
+ * @brief Alloc request data.
+ */
+struct hwmem_alloc_request {
+	/**
+	 * @brief [in] Size of requested allocation in bytes. Size will be
+	 * aligned to PAGE_SIZE bytes.
+	 */
+	__u32 size;
+	/**
+	 * @brief [in] Flags describing requested allocation options.
+	 */
+	__u32 flags; /* enum hwmem_alloc_flags */
+	/**
+	 * @brief [in] Default access rights for buffer.
+	 */
+	__u32 default_access; /* enum hwmem_access */
+	/**
+	 * @brief [in] Memory type of the buffer.
+	 */
+	__u32 mem_type; /* enum hwmem_mem_type */
+};
+
+/**
+ * @brief Set domain request data.
+ */
+struct hwmem_set_domain_request {
+	/**
+	 * @brief [in] Identifier of buffer to be prepared. If 0 is specified
+	 * the buffer associated with the current file instance will be used.
+	 */
+	__s32 id;
+	/**
+	 * @brief [in] Flags specifying access mode of the operation.
+	 *
+	 * One of HWMEM_ACCESS_READ and HWMEM_ACCESS_WRITE is required.
+	 * For details, @see enum hwmem_access.
+	 */
+	__u32 access; /* enum hwmem_access */
+	/**
+	 * @brief [in] The region of bytes to be prepared.
+	 *
+	 * For details, @see struct hwmem_region.
+	 */
+	struct hwmem_region_us region;
+};
+
+/**
+ * @brief Set access rights request data.
+ */
+struct hwmem_set_access_request {
+	/**
+	 * @brief [in] Identifier of buffer to set access rights for. If 0 is
+	 * specified, the buffer associated with the current file instance will
+	 * be used.
+	 */
+	__s32 id;
+	/**
+	 * @param access Access value indicating what is allowed.
+	 */
+	__u32 access; /* enum hwmem_access */
+	/**
+	 * @param pid Process ID to set rights for.
+	 */
+	pid_t pid;
+};
+
+/**
+ * @brief Get info request data.
+ */
+struct hwmem_get_info_request {
+	/**
+	 * @brief [in] Identifier of buffer to get info about. If 0 is specified,
+	 * the buffer associated with the current file instance will be used.
+	 */
+	__s32 id;
+	/**
+	 * @brief [out] Size in bytes of buffer.
+	 */
+	__u32 size;
+	/**
+	 * @brief [out] Memory type of buffer.
+	 */
+	__u32 mem_type; /* enum hwmem_mem_type */
+	/**
+	 * @brief [out] Access rights for buffer.
+	 */
+	__u32 access; /* enum hwmem_access */
+};
+
+/**
+ * @brief Allocates <size> number of bytes and returns a buffer identifier.
+ *
+ * Input is a pointer to a hwmem_alloc_request struct.
+ *
+ * @return A buffer identifier on success, or a negative error code.
+ */
+#define HWMEM_ALLOC_IOC _IOW('W', 1, struct hwmem_alloc_request)
+
+/**
+ * @brief Allocates <size> number of bytes and associates the created buffer
+ * with the current file instance.
+ *
+ * If the current file instance is already associated with a buffer the call
+ * will fail. Buffers referenced through files instances shall not be released
+ * with HWMEM_RELEASE_IOC, instead the file instance shall be closed.
+ *
+ * Input is a pointer to a hwmem_alloc_request struct.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_ALLOC_FD_IOC _IOW('W', 2, struct hwmem_alloc_request)
+
+/**
+ * @brief Releases buffer.
+ *
+ * Buffers are reference counted and will not be destroyed until the last
+ * reference is released. Buffers allocated with ALLOC_FD_IOC shall not be
+ * released with this IOC, @see HWMEM_ALLOC_FD_IOC.
+ *
+ * Input is the buffer identifier.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_RELEASE_IOC _IO('W', 3)
+
+/**
+ * Memory Mapping
+ *
+ * To map a hwmem buffer mmap the hwmem fd and supply the buffer identifier as
+ * the offset. If the buffer is linked to the fd and thus have no buffer
+ * identifier supply 0 as the offset. Note that the offset feature of mmap is
+ * disabled in both cases, you can only mmap starting a position 0.
+ */
+
+/**
+ * @brief Prepares the buffer for CPU access.
+ *
+ * Input is a pointer to a hwmem_set_domain_request struct.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_SET_CPU_DOMAIN_IOC _IOW('W', 4, struct hwmem_set_domain_request)
+
+/**
+ * @brief Set access rights for buffer.
+ *
+ * Input is a pointer to a hwmem_set_access_request struct.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_SET_ACCESS_IOC _IOW('W', 8, struct hwmem_set_access_request)
+
+/**
+ * @brief Get buffer information.
+ *
+ * Input is a pointer to a hwmem_get_info_request struct.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_GET_INFO_IOC _IOWR('W', 9, struct hwmem_get_info_request)
+
+/**
+ * @brief Export the buffer identifier for use in another process.
+ *
+ * The global name will not increase the buffers reference count and will
+ * therefore not keep the buffer alive.
+ *
+ * Input is the buffer identifier. If 0 is specified the buffer associated with
+ * the current file instance will be exported.
+ *
+ * @return A global buffer name on success, or a negative error code.
+ */
+#define HWMEM_EXPORT_IOC _IO('W', 10)
+
+/**
+ * @brief Import a buffer to allow local access to the buffer.
+ *
+ * Input is the buffer's global name.
+ *
+ * @return The imported buffer's identifier on success, or a negative error
+ * code.
+ */
+#define HWMEM_IMPORT_IOC _IO('W', 11)
+
+/**
+ * @brief Import a buffer to allow local access to the buffer using the current
+ * fd.
+ *
+ * Input is the buffer's global name.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_IMPORT_FD_IOC _IO('W', 12)
+
+#ifdef __KERNEL__
+
+/* Kernel API */
+
+/**
+ * @brief Values defining memory domain.
+ */
+enum hwmem_domain {
+	/**
+	 * @brief This value specifies the neutral memory domain. Setting this
+	 * domain will syncronize all supported memory domains.
+	 */
+	HWMEM_DOMAIN_SYNC = 0,
+	/**
+	 * @brief This value specifies the CPU memory domain.
+	 */
+	HWMEM_DOMAIN_CPU,
+};
+
+struct hwmem_alloc;
+
+/**
+ * @brief Structure defining a region of a memory buffer.
+ *
+ * A buffer is defined to contain a number of equally sized blocks. Each block
+ * has a part of it included in the region [<start>-<end>). That is
+ * <end>-<start> bytes. Each block is <size> bytes long. Total number of bytes
+ * in the region is (<end> - <start>) * <count>. First byte of the region is
+ * <offset> + <start> bytes into the buffer.
+ *
+ * Here's an example of a region in a graphics buffer (X = buffer, R = region):
+ *
+ * XXXXXXXXXXXXXXXXXXXX \
+ * XXXXXXXXXXXXXXXXXXXX |-- offset = 60
+ * XXXXXXXXXXXXXXXXXXXX /
+ * XXRRRRRRRRXXXXXXXXXX \
+ * XXRRRRRRRRXXXXXXXXXX |-- count = 4
+ * XXRRRRRRRRXXXXXXXXXX |
+ * XXRRRRRRRRXXXXXXXXXX /
+ * XXXXXXXXXXXXXXXXXXXX
+ * --| start = 2
+ * ----------| end = 10
+ * --------------------| size = 20
+ */
+struct hwmem_region {
+	/**
+	 * @brief The first block's offset from beginning of buffer.
+	 */
+	size_t offset;
+	/**
+	 * @brief The number of blocks included in this region.
+	 */
+	size_t count;
+	/**
+	 * @brief The index of the first byte included in this block.
+	 */
+	size_t start;
+	/**
+	 * @brief The index of the last byte included in this block plus one.
+	 */
+	size_t end;
+	/**
+	 * @brief The size in bytes of each block.
+	 */
+	size_t size;
+};
+
+struct hwmem_mem_chunk {
+	phys_addr_t paddr;
+	size_t size;
+};
+
+/**
+ * @brief Allocates <size> number of bytes.
+ *
+ * @param size Number of bytes to allocate. All allocations are page aligned.
+ * @param flags Allocation options.
+ * @param def_access Default buffer access rights.
+ * @param mem_type Memory type.
+ *
+ * @return Pointer to allocation, or a negative error code.
+ */
+struct hwmem_alloc *hwmem_alloc(size_t size, enum hwmem_alloc_flags flags,
+		enum hwmem_access def_access, enum hwmem_mem_type mem_type);
+
+/**
+ * @brief Release a previously allocated buffer.
+ * When last reference is released, the buffer will be freed.
+ *
+ * @param alloc Buffer to be released.
+ */
+void hwmem_release(struct hwmem_alloc *alloc);
+
+/**
+ * @brief Set the buffer domain and prepare it for access.
+ *
+ * @param alloc Buffer to be prepared.
+ * @param access Flags defining memory access mode of the call.
+ * @param domain Value specifying the memory domain.
+ * @param region Structure defining the minimum area of the buffer to be
+ * prepared.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+int hwmem_set_domain(struct hwmem_alloc *alloc, enum hwmem_access access,
+		enum hwmem_domain domain, struct hwmem_region *region);
+
+/**
+ * @brief Pins the buffer.
+ *
+ * Notice that the number of mem chunks a buffer consists of can change at any
+ * time if the buffer is not pinned. Because of this one can not assume that
+ * pin will succeed if <mem_chunks> has the length specified by a previous call
+ * to pin as the buffer layout may have changed between the calls. There are
+ * two ways of handling this situation, keep redoing the pin procedure till it
+ * succeeds or allocate enough mem chunks for the worst case ("buffer size" /
+ * "page size" mem chunks). Contiguous buffers always require only one mem
+ * chunk.
+ *
+ * @param alloc Buffer to be pinned.
+ * @param mem_chunks Pointer to array of mem chunks.
+ * @param mem_chunks_length Pointer to variable that contains the length of
+ * <mem_chunks> array. On success the number of written mem chunks will be
+ * stored in this variable. If the call fails with -ENOSPC the required length
+ * of <mem_chunks> will be stored in this variable.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+int hwmem_pin(struct hwmem_alloc *alloc, struct hwmem_mem_chunk *mem_chunks,
+						size_t *mem_chunks_length);
+
+/**
+ * @brief Unpins the buffer.
+ *
+ * @param alloc Buffer to be unpinned.
+ */
+void hwmem_unpin(struct hwmem_alloc *alloc);
+
+/**
+ * @brief Map the buffer to user space.
+ *
+ * @param alloc Buffer to be mapped.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+int hwmem_mmap(struct hwmem_alloc *alloc, struct vm_area_struct *vma);
+
+/**
+ * @brief Map the buffer for use in the kernel.
+ *
+ * This function implicitly pins the buffer.
+ *
+ * @param alloc Buffer to be mapped.
+ *
+ * @return Pointer to buffer, or a negative error code.
+ */
+void *hwmem_kmap(struct hwmem_alloc *alloc);
+
+/**
+ * @brief Un-map a buffer previously mapped with hwmem_kmap.
+ *
+ * This function implicitly unpins the buffer.
+ *
+ * @param alloc Buffer to be un-mapped.
+ */
+void hwmem_kunmap(struct hwmem_alloc *alloc);
+
+/**
+ * @brief Set access rights for buffer.
+ *
+ * @param alloc Buffer to set rights for.
+ * @param access Access value indicating what is allowed.
+ * @param pid Process ID to set rights for.
+ */
+int hwmem_set_access(struct hwmem_alloc *alloc, enum hwmem_access access,
+								pid_t pid);
+
+/**
+ * @brief Get buffer information.
+ *
+ * @param alloc Buffer to get information about.
+ * @param size Pointer to size output variable. Can be NULL.
+ * @param size Pointer to memory type output variable. Can be NULL.
+ * @param size Pointer to access rights output variable. Can be NULL.
+ */
+void hwmem_get_info(struct hwmem_alloc *alloc, size_t *size,
+		enum hwmem_mem_type *mem_type, enum hwmem_access *access);
+
+/**
+ * @brief Allocate a global buffer name.
+ * Generated buffer name is valid in all processes. Consecutive calls will get
+ * the same name for the same buffer.
+ *
+ * @param alloc Buffer to be made public.
+ *
+ * @return Positive global name on success, or a negative error code.
+ */
+s32 hwmem_get_name(struct hwmem_alloc *alloc);
+
+/**
+ * @brief Import the global buffer name to allow local access to the buffer.
+ * This call will add a buffer reference. Resulting buffer should be
+ * released with a call to hwmem_release.
+ *
+ * @param name A valid global buffer name.
+ *
+ * @return Pointer to allocation, or a negative error code.
+ */
+struct hwmem_alloc *hwmem_resolve_by_name(s32 name);
+
+/* Internal */
+
+struct hwmem_platform_data {
+	/* Physical address of memory region */
+	u32 start;
+	/* Size of memory region */
+	u32 size;
+};
+
+#endif
+
+#endif /* _HWMEM_H_ */
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
