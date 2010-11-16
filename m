Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9E87A8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 08:08:28 -0500 (EST)
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 2C2FEF3
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:04 +0000 (GMT)
Received: from relay1.stm.gmessaging.net (unknown [10.230.100.17])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 27DE978C
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 13:08:03 +0000 (GMT)
Received: from exdcvycastm004.EQ1STM.local (alteon-source-exch [10.230.100.61])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(Client CN "exdcvycastm004", Issuer "exdcvycastm004" (not verified))
	by relay1.stm.gmessaging.net (Postfix) with ESMTPS id DA88324C2E5
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 14:07:55 +0100 (CET)
From: Johan Mossberg <johan.xx.mossberg@stericsson.com>
Subject: [PATCH 1/3] hwmem: Add hwmem (part 1)
Date: Tue, 16 Nov 2010 14:08:00 +0100
Message-ID: <1289912882-23996-2-git-send-email-johan.xx.mossberg@stericsson.com>
In-Reply-To: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
References: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Johan Mossberg <johan.xx.mossberg@stericsson.com>
List-ID: <linux-mm.kvack.org>

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
Acked-by: Linus Walleij <linus.walleij@stericsson.com>
---
 drivers/misc/Kconfig             |    7 +
 drivers/misc/Makefile            |    1 +
 drivers/misc/hwmem/Makefile      |    3 +
 drivers/misc/hwmem/hwmem-ioctl.c |  470 +++++++++++++++++++++++++++++
 drivers/misc/hwmem/hwmem-main.c  |  609 ++++++++++++++++++++++++++++++++++++++
 include/linux/hwmem.h            |  499 +++++++++++++++++++++++++++++++
 6 files changed, 1589 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/hwmem/Makefile
 create mode 100644 drivers/misc/hwmem/hwmem-ioctl.c
 create mode 100644 drivers/misc/hwmem/hwmem-main.c
 create mode 100644 include/linux/hwmem.h

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 4d073f1..9a74534 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -452,6 +452,13 @@ config PCH_PHUB
 	  To compile this driver as a module, choose M here: the module will
 	  be called pch_phub.
 
+config HWMEM
+	bool "Hardware memory driver"
+	default n
+	help
+	  Allocates buffers suitable for use with hardware. Also handles
+	  sharing of allocated buffers between processes.
+
 source "drivers/misc/c2port/Kconfig"
 source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 98009cc..50dfbbe 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -41,4 +41,5 @@ obj-$(CONFIG_VMWARE_BALLOON)	+= vmw_balloon.o
 obj-$(CONFIG_ARM_CHARLCD)	+= arm-charlcd.o
 obj-$(CONFIG_PCH_PHUB)		+= pch_phub.o
 obj-y				+= ti-st/
+obj-$(CONFIG_HWMEM)		+= hwmem/
 obj-$(CONFIG_AB8500_PWM)	+= ab8500-pwm.o
diff --git a/drivers/misc/hwmem/Makefile b/drivers/misc/hwmem/Makefile
new file mode 100644
index 0000000..da9080a
--- /dev/null
+++ b/drivers/misc/hwmem/Makefile
@@ -0,0 +1,3 @@
+hwmem-objs := hwmem-main.o hwmem-ioctl.o cache_handler.o cache_handler_u8500.o
+
+obj-$(CONFIG_HWMEM) += hwmem.o
diff --git a/drivers/misc/hwmem/hwmem-ioctl.c b/drivers/misc/hwmem/hwmem-ioctl.c
new file mode 100644
index 0000000..b1fc844
--- /dev/null
+++ b/drivers/misc/hwmem/hwmem-ioctl.c
@@ -0,0 +1,470 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
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
+/*
+ * TODO:
+ * Count pin unpin at this level to ensure applications can't interfer
+ * with each other.
+ */
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
+static int create_id(struct hwmem_file *hwfile, struct hwmem_alloc *alloc)
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
+	 * TODO: This isn't great as we destroy IDR's ability to reuse freed
+	 * IDs. Currently we can use 19 bits for the ID ie 524388 IDs can be
+	 * generated by a hwmem file instance before this function starts
+	 * failing. This should be enough for most scenarios but the final
+	 * solution for this problem is to change IDR so that you can specify
+	 * a maximum ID.
+	 */
+	if (id >= 1 << (31 - PAGE_SHIFT)) {
+		dev_err(hwmem_device.this_device, "ID overflow!\n");
+		idr_remove(&hwfile->idr, id);
+		return -ENOMSG;
+	}
+
+	return id << PAGE_SHIFT;
+}
+
+static void remove_id(struct hwmem_file *hwfile, int id)
+{
+	idr_remove(&hwfile->idr, id >> PAGE_SHIFT);
+}
+
+static struct hwmem_alloc *resolve_id(struct hwmem_file *hwfile, int id)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = id ? idr_find(&hwfile->idr, id >> PAGE_SHIFT) :
+			hwfile->fd_alloc;
+	if (alloc == NULL)
+		alloc = ERR_PTR(-EINVAL);
+
+	return alloc;
+}
+
+static int alloc(struct hwmem_file *hwfile, struct hwmem_alloc_request *req)
+{
+	int ret = 0;
+	struct hwmem_alloc *alloc;
+
+	alloc = hwmem_alloc(req->size, req->flags, req->default_access,
+			req->mem_type);
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
+		return -EBUSY;
+
+	alloc = hwmem_alloc(req->size, req->flags, req->default_access,
+			req->mem_type);
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
+static int hwmem_ioctl_set_domain(struct hwmem_file *hwfile,
+					struct hwmem_set_domain_request *req)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, req->id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	return hwmem_set_domain(alloc, req->access, req->domain, &req->region);
+}
+
+static int pin(struct hwmem_file *hwfile, struct hwmem_pin_request *req)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, req->id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	return hwmem_pin(alloc, &req->phys_addr, req->scattered_addrs);
+}
+
+static int unpin(struct hwmem_file *hwfile, s32 id)
+{
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, id);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	hwmem_unpin(alloc);
+
+	return 0;
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
+static int export(struct hwmem_file *hwfile, s32 id)
+{
+	int ret;
+	struct hwmem_alloc *alloc;
+
+	uint32_t size;
+	enum hwmem_mem_type mem_type;
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
+	hwmem_get_info(alloc, &size, &mem_type, &access);
+
+	ret = hwmem_set_access(alloc, (access | HWMEM_ACCESS_IMPORT),
+			task_tgid_nr(current));
+	if (ret < 0)
+		goto error;
+
+	return hwmem_get_name(alloc);
+
+error:
+	return ret;
+}
+
+static int import(struct hwmem_file *hwfile, s32 name)
+{
+	int ret = 0;
+	struct hwmem_alloc *alloc;
+
+	uint32_t size;
+	enum hwmem_mem_type mem_type;
+	enum hwmem_access access;
+
+	alloc = hwmem_resolve_by_name(name);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	/* Check access permissions for process */
+	hwmem_get_info(alloc, &size, &mem_type, &access);
+
+	if (!(access & HWMEM_ACCESS_IMPORT)) {
+		ret = -EPERM;
+		goto error;
+	}
+
+	ret = create_id(hwfile, alloc);
+	if (ret < 0)
+		hwmem_release(alloc);
+
+error:
+	return ret;
+}
+
+static int import_fd(struct hwmem_file *hwfile, s32 name)
+{
+	struct hwmem_alloc *alloc;
+
+	if (hwfile->fd_alloc)
+		return -EBUSY;
+
+	alloc = hwmem_resolve_by_name(name);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	hwfile->fd_alloc = alloc;
+
+	return 0;
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
+	struct hwmem_file *hwfile = (struct hwmem_file *)file->private_data;
+	struct hwmem_alloc *alloc;
+
+	alloc = resolve_id(hwfile, vma->vm_pgoff << PAGE_SHIFT);
+	if (IS_ERR(alloc))
+		return PTR_ERR(alloc);
+
+	return hwmem_mmap(alloc, vma);
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
+	case HWMEM_SET_DOMAIN_IOC:
+		{
+			struct hwmem_set_domain_request req;
+			if (copy_from_user(&req, (void __user *)arg,
+				sizeof(struct hwmem_set_domain_request)))
+				ret = -EFAULT;
+			else
+				ret = hwmem_ioctl_set_domain(hwfile, &req);
+		}
+		break;
+	case HWMEM_PIN_IOC:
+		{
+			struct hwmem_pin_request req;
+			/*
+			 * TODO: Validate and copy scattered_addrs. Not a
+			 * problem right now as it's never used.
+			 */
+			if (copy_from_user(&req, (void __user *)arg,
+				sizeof(struct hwmem_pin_request)))
+				ret = -EFAULT;
+			else
+				ret = pin(hwfile, &req);
+			if (ret == 0 && copy_to_user((void __user *)arg, &req,
+					sizeof(struct hwmem_pin_request)))
+				ret = -EFAULT;
+		}
+		break;
+	case HWMEM_UNPIN_IOC:
+		ret = unpin(hwfile, (s32)arg);
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
+	return misc_register(&hwmem_device);
+}
+
+void __exit hwmem_ioctl_exit(void)
+{
+	misc_deregister(&hwmem_device);
+}
diff --git a/drivers/misc/hwmem/hwmem-main.c b/drivers/misc/hwmem/hwmem-main.c
new file mode 100644
index 0000000..287cab5
--- /dev/null
+++ b/drivers/misc/hwmem/hwmem-main.c
@@ -0,0 +1,609 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ *
+ * Hardware memory driver, hwmem
+ *
+ * Author: Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>
+ * for ST-Ericsson.
+ *
+ * License terms: GNU General Public License (GPL), version 2.
+ */
+
+/*
+ * TODO:
+ * - Kernel addresses are non-cached which could be a problem when using them
+ * for cache synchronization operations, some CPU:s might skip the
+ * synchronization operation alltoghether.
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
+	u32 start;
+	u32 size;
+	u32 name;
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
+u32 hwmem_start;
+u32 hwmem_size;
+void *hwmem_kaddr;
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
+/* Helpers */
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
+	u32 offset;
+	void *v_start;
+
+	offset = alloc->start - hwmem_start;
+
+	v_start = (u8 *)hwmem_kaddr + offset;
+
+	/*
+	 * HWMEM_DOMAIN_SYNC is used as hwmem_kaddr is non-cached and any data
+	 * in the CPU caches should be flushed before we start using the
+	 * buffer. Usually the cache handler keeps track of these things but
+	 * since our kernel addresses don't have the cache settings specified
+	 * in the alloc we have to do it manually here.
+	 */
+	cach_set_domain(&alloc->cach_buf, HWMEM_ACCESS_WRITE,
+						HWMEM_DOMAIN_SYNC, NULL);
+
+	memset(v_start, 0, alloc->size);
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
+	new_alloc->start = alloc->start;
+	new_alloc->size = new_alloc_size;
+	alloc->size -= new_alloc_size;
+	alloc->start += new_alloc_size;
+
+	list_add_tail(&new_alloc->list, &alloc->list);
+
+	return new_alloc;
+}
+
+static int init_alloc_list(void)
+{
+	struct hwmem_alloc *first_alloc;
+
+	first_alloc = kzalloc(sizeof(struct hwmem_alloc), GFP_KERNEL);
+	if (first_alloc == NULL)
+		return -ENOMEM;
+
+	first_alloc->start = hwmem_start;
+	first_alloc->size = hwmem_size;
+	INIT_LIST_HEAD(&first_alloc->threadg_info_list);
+
+	list_add_tail(&first_alloc->list, &alloc_list);
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
+/* HWMEM API */
+
+struct hwmem_alloc *hwmem_alloc(u32 size, enum hwmem_alloc_flags flags,
+		enum hwmem_access def_access, enum hwmem_mem_type mem_type)
+{
+	struct hwmem_alloc *alloc;
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
+	cach_init_buf(&alloc->cach_buf, alloc->flags,
+		(u32)hwmem_kaddr + (alloc->start - hwmem_start), alloc->start,
+								alloc->size);
+
+	clear_alloc_mem(alloc);
+
+	goto out;
+
+split_alloc_failed:
+no_slot:
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
+int hwmem_pin(struct hwmem_alloc *alloc, uint32_t *phys_addr,
+					uint32_t *scattered_phys_addrs)
+{
+	mutex_lock(&lock);
+
+	*phys_addr = alloc->start;
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
+	if (vma_size > (unsigned long)alloc->size) {
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
+	ret = remap_pfn_range(vma, vma->vm_start, alloc->start >> PAGE_SHIFT,
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
+void hwmem_get_info(struct hwmem_alloc *alloc, uint32_t *size,
+	enum hwmem_mem_type *mem_type, enum hwmem_access *access)
+{
+	mutex_lock(&lock);
+
+	*size = alloc->size;
+	*mem_type = HWMEM_MEM_CONTIGUOUS_SYS;
+	*access = get_access(alloc);
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
+	if (hwdev || platform_data->size == 0) {
+		dev_info(&pdev->dev, "hwdev || platform_data->size == 0\n");
+		return -EINVAL;
+	}
+
+	hwdev = pdev;
+	hwmem_start = platform_data->start;
+	hwmem_size = platform_data->size;
+
+	/*
+	 * TODO: This will consume a lot of the kernel's virtual memory space.
+	 * Investigate if a better solution exists.
+	 */
+	hwmem_kaddr = ioremap_nocache(hwmem_start, hwmem_size);
+	if (hwmem_kaddr == NULL) {
+		ret = -ENOMEM;
+		goto ioremap_failed;
+	}
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
+	dev_info(&pdev->dev, "Hwmem probed, device contains %#x bytes\n",
+			hwmem_size);
+
+	goto out;
+
+ioctl_init_failed:
+	clean_alloc_list();
+init_alloc_list_failed:
+	iounmap(hwmem_kaddr);
+ioremap_failed:
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
+
diff --git a/include/linux/hwmem.h b/include/linux/hwmem.h
new file mode 100644
index 0000000..c3ba179
--- /dev/null
+++ b/include/linux/hwmem.h
@@ -0,0 +1,499 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ *
+ * ST-Ericsson HW memory driver
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
+	 * @brief Buffer will not be cached and not buffered
+	 */
+	HWMEM_ALLOC_UNCACHED             = (0 << 0),
+	/**
+	 * @brief Buffer will be buffered, but not cached
+	 */
+	HWMEM_ALLOC_BUFFERED             = (1 << 0),
+	/**
+	 * @brief Buffer will be cached and buffered, use cache hints to be
+	 * more specific
+	 */
+	HWMEM_ALLOC_CACHED               = (3 << 0),
+	/**
+	 * @brief Buffer should be cached write-back in both level 1 and 2 cache
+	 */
+	HWMEM_ALLOC_CACHE_HINT_WB        = (1 << 2),
+	/**
+	 * @brief Buffer should be cached write-through in both level 1 and
+	 * 2 cache
+	 */
+	HWMEM_ALLOC_CACHE_HINT_WT        = (2 << 2),
+	/**
+	 * @brief Buffer should be cached write-back in level 1 cache
+	 */
+	HWMEM_ALLOC_CACHE_HINT_WB_INNER  = (3 << 2),
+	/**
+	 * @brief Buffer should be cached write-through in level 1 cache
+	 */
+	HWMEM_ALLOC_CACHE_HINT_WT_INNER  = (4 << 2),
+	HWMEM_ALLOC_CACHE_HINT_MASK      = 0x1C,
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
+ * @brief Flags defining memory type.
+ */
+enum hwmem_mem_type {
+	/**
+	 * @brief Scattered system memory. Currently not supported!
+	 */
+	HWMEM_MEM_SCATTERED_SYS  = (1 << 0),
+	/**
+	 * @brief Contiguous system memory.
+	 */
+	HWMEM_MEM_CONTIGUOUS_SYS = (1 << 1),
+};
+
+/**
+ * @brief Values defining memory domain.
+ */
+enum hwmem_domain {
+	/**
+	 * @brief This value specifies the neutral memory domain. Setting this
+	 * domain will syncronize all supported memory domains (currently CPU).
+	 */
+	HWMEM_DOMAIN_SYNC = 0,
+	/**
+	 * @brief This value specifies the CPU memory domain.
+	 */
+	HWMEM_DOMAIN_CPU  = 1,
+};
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
+	uint32_t offset;
+	/**
+	 * @brief The number of blocks included in this region.
+	 */
+	uint32_t count;
+	/**
+	 * @brief The index of the first byte included in this block.
+	 */
+	uint32_t start;
+	/**
+	 * @brief The index of the last byte included in this block plus one.
+	 */
+	uint32_t end;
+	/**
+	 * @brief The size in bytes of each block.
+	 */
+	uint32_t size;
+};
+
+/* User space API */
+
+/**
+ * @brief Alloc request data.
+ */
+struct hwmem_alloc_request {
+	/**
+	 * @brief [in] Size of requested allocation in bytes. Size will be
+	 * aligned to PAGE_SIZE bytes.
+	 */
+	uint32_t size;
+	/**
+	 * @brief [in] Flags describing requested allocation options.
+	 */
+	uint32_t flags; /* enum hwmem_alloc_flags */
+	/**
+	 * @brief [in] Default access rights for buffer.
+	 */
+	uint32_t default_access; /* enum hwmem_access */
+	/**
+	 * @brief [in] Memory type of the buffer.
+	 */
+	uint32_t mem_type; /* enum hwmem_mem_type */
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
+	int32_t id;
+	/**
+	 * @brief [in] Value specifying the new memory domain.
+	 */
+	uint32_t domain; /* enum hwmem_domain */
+	/**
+	 * @brief [in] Flags specifying access mode of the operation.
+	 *
+	 * One of HWMEM_ACCESS_READ and HWMEM_ACCESS_WRITE is required.
+	 * For details, @see enum hwmem_access.
+	 */
+	uint32_t access; /* enum hwmem_access */
+	/**
+	 * @brief [in] The region of bytes to be prepared.
+	 *
+	 * For details, @see struct hwmem_region.
+	 */
+	struct hwmem_region region;
+};
+
+/**
+ * @brief Pin request data.
+ */
+struct hwmem_pin_request {
+	/**
+	 * @brief [in] Identifier of buffer to be pinned. If 0 is specified,
+	 * the buffer associated with the current file instance will be used.
+	 */
+	int32_t id;
+	/**
+	 * @brief [out] Physical address of first word in buffer.
+	 */
+	uint32_t phys_addr;
+	/**
+	 * @brief [in] Pointer to buffer for physical addresses of pinned
+	 * scattered buffer. Buffer must be (buffer_size / page_size) *
+	 * sizeof(uint32_t) bytes.
+	 * This field can be NULL for physically contiguos buffers.
+	 */
+	uint32_t *scattered_addrs;
+};
+
+/**
+ * @brief Set access rights request data.
+ */
+struct hwmem_set_access_request {
+	/**
+	 * @brief [in] Identifier of buffer to be pinned. If 0 is specified,
+	 * the buffer associated with the current file instance will be used.
+	 */
+	int32_t id;
+	/**
+	 * @param access Access value indicating what is allowed.
+	 */
+	uint32_t access; /* enum hwmem_access */
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
+	int32_t id;
+	/**
+	 * @brief [out] Size in bytes of buffer.
+	 */
+	uint32_t size;
+	/**
+	 * @brief [out] Memory type of buffer.
+	 */
+	uint32_t mem_type; /* enum hwmem_mem_type */
+	/**
+	 * @brief [out] Access rights for buffer.
+	 */
+	uint32_t access; /* enum hwmem_access */
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
+ * reference is released. Bufferes allocated with ALLOC_FD_IOC not allowed.
+ *
+ * Input is the buffer identifier.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_RELEASE_IOC _IO('W', 3)
+
+/**
+ * @brief Set the buffer's memory domain and prepares it for access.
+ *
+ * Input is a pointer to a hwmem_set_domain_request struct.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_SET_DOMAIN_IOC _IOR('W', 4, struct hwmem_set_domain_request)
+
+/**
+ * @brief Pins the buffer and returns the physical address of the buffer.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_PIN_IOC _IOWR('W', 5, struct hwmem_pin_request)
+
+/**
+ * @brief Unpins the buffer.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_UNPIN_IOC _IO('W', 6)
+
+/**
+ * @brief Set access rights for buffer.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_SET_ACCESS_IOC _IOW('W', 7, struct hwmem_set_access_request)
+
+/**
+ * @brief Get buffer information.
+ *
+ * Input is the buffer identifier. If 0 is specified the buffer associated
+ * with the current file instance will be used.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_GET_INFO_IOC _IOWR('W', 8, struct hwmem_get_info_request)
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
+#define HWMEM_EXPORT_IOC _IO('W', 9)
+
+/**
+ * @brief Import a buffer to allow local access to the buffer.
+ *
+ * Input is the buffer's global name.
+ *
+ * @return The imported buffer's identifier on success, or a negative error code.
+ */
+#define HWMEM_IMPORT_IOC _IO('W', 10)
+
+/**
+ * @brief Import a buffer to allow local access to the buffer using fd.
+ *
+ * Input is the buffer's global name.
+ *
+ * @return Zero on success, or a negative error code.
+ */
+#define HWMEM_IMPORT_FD_IOC _IO('W', 11)
+
+#ifdef __KERNEL__
+
+/* Kernel API */
+
+struct hwmem_alloc;
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
+struct hwmem_alloc *hwmem_alloc(u32 size, enum hwmem_alloc_flags flags,
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
+ * @param alloc Buffer to be pinned.
+ * @param phys_addr Reference to variable to receive physical address.
+ * @param scattered_phys_addrs Pointer to buffer to receive physical addresses
+ * of all pages in the scattered buffer. Can be NULL if buffer is contigous.
+ * Buffer size must be (buffer_size / page_size) * sizeof(uint32_t) bytes.
+ */
+int hwmem_pin(struct hwmem_alloc *alloc, uint32_t *phys_addr,
+					uint32_t *scattered_phys_addrs);
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
+ * @param alloc Buffer to be unpinned.
+ */
+int hwmem_mmap(struct hwmem_alloc *alloc, struct vm_area_struct *vma);
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
+ * @param size Pointer to size output variable.
+ * @param size Pointer to memory type output variable.
+ * @param size Pointer to access rights output variable.
+ */
+void hwmem_get_info(struct hwmem_alloc *alloc, uint32_t *size,
+	enum hwmem_mem_type *mem_type, enum hwmem_access *access);
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
+int hwmem_get_name(struct hwmem_alloc *alloc);
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
+	/* Starting physical address of memory region */
+	unsigned long start;
+	/* Size of memory region */
+	unsigned long size;
+};
+
+#endif
+
+#endif /* _HWMEM_H_ */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
