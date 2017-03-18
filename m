Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C1A0D6B039A
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 20:55:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u4so63509259qtc.4
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:50 -0700 (PDT)
Received: from mail-qt0-f181.google.com (mail-qt0-f181.google.com. [209.85.216.181])
        by mx.google.com with ESMTPS id w3si7681379qkd.209.2017.03.17.17.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 17:55:49 -0700 (PDT)
Received: by mail-qt0-f181.google.com with SMTP id x35so75114181qtc.2
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 17:55:49 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC PATCHv2 15/21] staging: android: ion: Break the ABI in the name of forward progress
Date: Fri, 17 Mar 2017 17:54:47 -0700
Message-Id: <1489798493-16600-16-git-send-email-labbott@redhat.com>
In-Reply-To: <1489798493-16600-1-git-send-email-labbott@redhat.com>
References: <1489798493-16600-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Laura Abbott <labbott@redhat.com>, romlem@google.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linaro-mm-sig@lists.linaro.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org, Brian Starkey <brian.starkey@arm.com>, Daniel Vetter <daniel.vetter@intel.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, linux-mm@kvack.org, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

To: Sumit Semwal <sumit.semwal@linaro.org>
To: Riley Andrews <riandrews@android.com>
Cc: romlem@google.com
To: arve@android.com
To: Riley Andrews <riandrews@android.com>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
Cc: linaro-mm-sig@lists.linaro.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-media@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: Brian Starkey <brian.starkey@arm.com>
Cc: Daniel Vetter <daniel.vetter@intel.com>
Cc: Mark Brown <broonie@kernel.org>
Cc: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Cc: linux-mm@kvack.org
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>


Several of the Ion ioctls were designed in such a way that they
necessitate compat ioctls. We're breaking a bunch of other ABIs and
cleaning stuff up anyway so let's follow the ioctl guidelines and clean
things up while everyone is busy converting things over anyway. As part
of this, also remove the useless alignment field from the allocation
structure.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 drivers/staging/android/ion/Makefile     |   3 -
 drivers/staging/android/ion/compat_ion.c | 152 -------------------------------
 drivers/staging/android/ion/compat_ion.h |  29 ------
 drivers/staging/android/ion/ion-ioctl.c  |   1 -
 drivers/staging/android/ion/ion.c        |   5 +-
 drivers/staging/android/uapi/ion.h       |  19 ++--
 6 files changed, 11 insertions(+), 198 deletions(-)
 delete mode 100644 drivers/staging/android/ion/compat_ion.c
 delete mode 100644 drivers/staging/android/ion/compat_ion.h

diff --git a/drivers/staging/android/ion/Makefile b/drivers/staging/android/ion/Makefile
index 66d0c4a..a892afa 100644
--- a/drivers/staging/android/ion/Makefile
+++ b/drivers/staging/android/ion/Makefile
@@ -2,6 +2,3 @@ obj-$(CONFIG_ION) +=	ion.o ion-ioctl.o ion_heap.o \
 			ion_page_pool.o ion_system_heap.o \
 			ion_carveout_heap.o ion_chunk_heap.o
 obj-$(CONFIG_ION_CMA_HEAP) += ion_cma_heap.o
-ifdef CONFIG_COMPAT
-obj-$(CONFIG_ION) += compat_ion.o
-endif
diff --git a/drivers/staging/android/ion/compat_ion.c b/drivers/staging/android/ion/compat_ion.c
deleted file mode 100644
index 5037ddd..0000000
--- a/drivers/staging/android/ion/compat_ion.c
+++ /dev/null
@@ -1,152 +0,0 @@
-/*
- * drivers/staging/android/ion/compat_ion.c
- *
- * Copyright (C) 2013 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#include <linux/compat.h>
-#include <linux/fs.h>
-#include <linux/uaccess.h>
-
-#include "ion.h"
-#include "compat_ion.h"
-
-/* See drivers/staging/android/uapi/ion.h for the definition of these structs */
-struct compat_ion_allocation_data {
-	compat_size_t len;
-	compat_size_t align;
-	compat_uint_t heap_id_mask;
-	compat_uint_t flags;
-	compat_int_t handle;
-};
-
-struct compat_ion_handle_data {
-	compat_int_t handle;
-};
-
-#define COMPAT_ION_IOC_ALLOC	_IOWR(ION_IOC_MAGIC, 0, \
-				      struct compat_ion_allocation_data)
-#define COMPAT_ION_IOC_FREE	_IOWR(ION_IOC_MAGIC, 1, \
-				      struct compat_ion_handle_data)
-
-static int compat_get_ion_allocation_data(
-			struct compat_ion_allocation_data __user *data32,
-			struct ion_allocation_data __user *data)
-{
-	compat_size_t s;
-	compat_uint_t u;
-	compat_int_t i;
-	int err;
-
-	err = get_user(s, &data32->len);
-	err |= put_user(s, &data->len);
-	err |= get_user(s, &data32->align);
-	err |= put_user(s, &data->align);
-	err |= get_user(u, &data32->heap_id_mask);
-	err |= put_user(u, &data->heap_id_mask);
-	err |= get_user(u, &data32->flags);
-	err |= put_user(u, &data->flags);
-	err |= get_user(i, &data32->handle);
-	err |= put_user(i, &data->handle);
-
-	return err;
-}
-
-static int compat_get_ion_handle_data(
-			struct compat_ion_handle_data __user *data32,
-			struct ion_handle_data __user *data)
-{
-	compat_int_t i;
-	int err;
-
-	err = get_user(i, &data32->handle);
-	err |= put_user(i, &data->handle);
-
-	return err;
-}
-
-static int compat_put_ion_allocation_data(
-			struct compat_ion_allocation_data __user *data32,
-			struct ion_allocation_data __user *data)
-{
-	compat_size_t s;
-	compat_uint_t u;
-	compat_int_t i;
-	int err;
-
-	err = get_user(s, &data->len);
-	err |= put_user(s, &data32->len);
-	err |= get_user(s, &data->align);
-	err |= put_user(s, &data32->align);
-	err |= get_user(u, &data->heap_id_mask);
-	err |= put_user(u, &data32->heap_id_mask);
-	err |= get_user(u, &data->flags);
-	err |= put_user(u, &data32->flags);
-	err |= get_user(i, &data->handle);
-	err |= put_user(i, &data32->handle);
-
-	return err;
-}
-
-long compat_ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
-{
-	long ret;
-
-	if (!filp->f_op->unlocked_ioctl)
-		return -ENOTTY;
-
-	switch (cmd) {
-	case COMPAT_ION_IOC_ALLOC:
-	{
-		struct compat_ion_allocation_data __user *data32;
-		struct ion_allocation_data __user *data;
-		int err;
-
-		data32 = compat_ptr(arg);
-		data = compat_alloc_user_space(sizeof(*data));
-		if (!data)
-			return -EFAULT;
-
-		err = compat_get_ion_allocation_data(data32, data);
-		if (err)
-			return err;
-		ret = filp->f_op->unlocked_ioctl(filp, ION_IOC_ALLOC,
-							(unsigned long)data);
-		err = compat_put_ion_allocation_data(data32, data);
-		return ret ? ret : err;
-	}
-	case COMPAT_ION_IOC_FREE:
-	{
-		struct compat_ion_handle_data __user *data32;
-		struct ion_handle_data __user *data;
-		int err;
-
-		data32 = compat_ptr(arg);
-		data = compat_alloc_user_space(sizeof(*data));
-		if (!data)
-			return -EFAULT;
-
-		err = compat_get_ion_handle_data(data32, data);
-		if (err)
-			return err;
-
-		return filp->f_op->unlocked_ioctl(filp, ION_IOC_FREE,
-							(unsigned long)data);
-	}
-	case ION_IOC_SHARE:
-		return filp->f_op->unlocked_ioctl(filp, cmd,
-						(unsigned long)compat_ptr(arg));
-	default:
-		return -ENOIOCTLCMD;
-	}
-}
diff --git a/drivers/staging/android/ion/compat_ion.h b/drivers/staging/android/ion/compat_ion.h
deleted file mode 100644
index 9da8f91..0000000
--- a/drivers/staging/android/ion/compat_ion.h
+++ /dev/null
@@ -1,29 +0,0 @@
-/*
- * drivers/staging/android/ion/compat_ion.h
- *
- * Copyright (C) 2013 Google, Inc.
- *
- * This software is licensed under the terms of the GNU General Public
- * License version 2, as published by the Free Software Foundation, and
- * may be copied, distributed, and modified under those terms.
- *
- * This program is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- */
-
-#ifndef _LINUX_COMPAT_ION_H
-#define _LINUX_COMPAT_ION_H
-
-#if IS_ENABLED(CONFIG_COMPAT)
-
-long compat_ion_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);
-
-#else
-
-#define compat_ion_ioctl  NULL
-
-#endif /* CONFIG_COMPAT */
-#endif /* _LINUX_COMPAT_ION_H */
diff --git a/drivers/staging/android/ion/ion-ioctl.c b/drivers/staging/android/ion/ion-ioctl.c
index a361724..91b5c2b 100644
--- a/drivers/staging/android/ion/ion-ioctl.c
+++ b/drivers/staging/android/ion/ion-ioctl.c
@@ -20,7 +20,6 @@
 
 #include "ion.h"
 #include "ion_priv.h"
-#include "compat_ion.h"
 
 union ion_ioctl_arg {
 	struct ion_fd_data fd;
diff --git a/drivers/staging/android/ion/ion.c b/drivers/staging/android/ion/ion.c
index 65638f5..fbab1e3 100644
--- a/drivers/staging/android/ion/ion.c
+++ b/drivers/staging/android/ion/ion.c
@@ -40,7 +40,6 @@
 
 #include "ion.h"
 #include "ion_priv.h"
-#include "compat_ion.h"
 
 bool ion_buffer_cached(struct ion_buffer *buffer)
 {
@@ -1065,7 +1064,9 @@ static const struct file_operations ion_fops = {
 	.open           = ion_open,
 	.release        = ion_release,
 	.unlocked_ioctl = ion_ioctl,
-	.compat_ioctl   = compat_ion_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= ion_ioctl,
+#endif
 };
 
 static size_t ion_debug_heap_total(struct ion_client *client,
diff --git a/drivers/staging/android/uapi/ion.h b/drivers/staging/android/uapi/ion.h
index abd72fd..bba1c47 100644
--- a/drivers/staging/android/uapi/ion.h
+++ b/drivers/staging/android/uapi/ion.h
@@ -20,8 +20,6 @@
 #include <linux/ioctl.h>
 #include <linux/types.h>
 
-typedef int ion_user_handle_t;
-
 /**
  * enum ion_heap_types - list of all possible types of heaps
  * @ION_HEAP_TYPE_SYSTEM:	 memory allocated via vmalloc
@@ -76,7 +74,6 @@ enum ion_heap_type {
 /**
  * struct ion_allocation_data - metadata passed from userspace for allocations
  * @len:		size of the allocation
- * @align:		required alignment of the allocation
  * @heap_id_mask:	mask of heap ids to allocate from
  * @flags:		flags passed to heap
  * @handle:		pointer that will be populated with a cookie to use to
@@ -85,11 +82,11 @@ enum ion_heap_type {
  * Provided by userspace as an argument to the ioctl
  */
 struct ion_allocation_data {
-	size_t len;
-	size_t align;
-	unsigned int heap_id_mask;
-	unsigned int flags;
-	ion_user_handle_t handle;
+	__u64 len;
+	__u32 heap_id_mask;
+	__u32 flags;
+	__u32 handle;
+	__u32 unused;
 };
 
 /**
@@ -103,8 +100,8 @@ struct ion_allocation_data {
  * provides the file descriptor and the kernel returns the handle.
  */
 struct ion_fd_data {
-	ion_user_handle_t handle;
-	int fd;
+	__u32 handle;
+	__u32 fd;
 };
 
 /**
@@ -112,7 +109,7 @@ struct ion_fd_data {
  * @handle:	a handle
  */
 struct ion_handle_data {
-	ion_user_handle_t handle;
+	__u32 handle;
 };
 
 #define MAX_HEAP_NAME			32
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
