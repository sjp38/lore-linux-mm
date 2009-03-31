Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2F5D06B005C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:30 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 1/2] qemu: add ksm support
Date: Tue, 31 Mar 2009 03:00:27 +0300
Message-Id: <1238457628-7668-2-git-send-email-ieidus@redhat.com>
In-Reply-To: <1238457628-7668-1-git-send-email-ieidus@redhat.com>
References: <1238457628-7668-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 qemu/ksm.h |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 qemu/vl.c  |   34 +++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+), 0 deletions(-)
 create mode 100644 qemu/ksm.h

diff --git a/qemu/ksm.h b/qemu/ksm.h
new file mode 100644
index 0000000..2fb91a8
--- /dev/null
+++ b/qemu/ksm.h
@@ -0,0 +1,70 @@
+#ifndef __LINUX_KSM_H
+#define __LINUX_KSM_H
+
+/*
+ * Userspace interface for /dev/ksm - kvm shared memory
+ */
+
+
+#include <sys/types.h>
+#include <sys/ioctl.h>
+
+#include <asm/types.h>
+
+#define KSM_API_VERSION 1
+
+#define ksm_control_flags_run 1
+
+/* for KSM_REGISTER_MEMORY_REGION */
+struct ksm_memory_region {
+	__u32 npages; /* number of pages to share */
+	__u32 pad;
+	__u64 addr; /* the begining of the virtual address */
+        __u64 reserved_bits;
+};
+
+struct ksm_kthread_info {
+	__u32 sleep; /* number of microsecoends to sleep */
+	__u32 pages_to_scan; /* number of pages to scan */
+	__u32 flags; /* control flags */
+        __u32 pad;
+        __u64 reserved_bits;
+};
+
+#define KSMIO 0xAB
+
+/* ioctls for /dev/ksm */
+
+#define KSM_GET_API_VERSION              _IO(KSMIO,   0x00)
+/*
+ * KSM_CREATE_SHARED_MEMORY_AREA - create the shared memory reagion fd
+ */
+#define KSM_CREATE_SHARED_MEMORY_AREA    _IO(KSMIO,   0x01) /* return SMA fd */
+/*
+ * KSM_START_STOP_KTHREAD - control the kernel thread scanning speed
+ * (can stop the kernel thread from working by setting running = 0)
+ */
+#define KSM_START_STOP_KTHREAD		 _IOW(KSMIO,  0x02,\
+					      struct ksm_kthread_info)
+/*
+ * KSM_GET_INFO_KTHREAD - return information about the kernel thread
+ * scanning speed.
+ */
+#define KSM_GET_INFO_KTHREAD		 _IOW(KSMIO,  0x03,\
+					      struct ksm_kthread_info)
+
+
+/* ioctls for SMA fds */
+
+/*
+ * KSM_REGISTER_MEMORY_REGION - register virtual address memory area to be
+ * scanned by kvm.
+ */
+#define KSM_REGISTER_MEMORY_REGION       _IOW(KSMIO,  0x20,\
+					      struct ksm_memory_region)
+/*
+ * KSM_REMOVE_MEMORY_REGION - remove virtual address memory area from ksm.
+ */
+#define KSM_REMOVE_MEMORY_REGION         _IO(KSMIO,   0x21)
+
+#endif
diff --git a/qemu/vl.c b/qemu/vl.c
index c52d2d7..54a9dd9 100644
--- a/qemu/vl.c
+++ b/qemu/vl.c
@@ -130,6 +130,7 @@ int main(int argc, char **argv)
 #define main qemu_main
 #endif /* CONFIG_COCOA */
 
+#include "ksm.h"
 #include "hw/hw.h"
 #include "hw/boards.h"
 #include "hw/usb.h"
@@ -4873,6 +4874,37 @@ static void termsig_setup(void)
 
 #endif
 
+static int ksm_register_memory(void)
+{
+    int fd;
+    int ksm_fd;
+    int r = 1;
+    struct ksm_memory_region ksm_region;
+
+    fd = open("/dev/ksm", O_RDWR | O_TRUNC, (mode_t)0600);
+    if (fd == -1)
+        goto out;
+
+    ksm_fd = ioctl(fd, KSM_CREATE_SHARED_MEMORY_AREA);
+    if (ksm_fd == -1)
+        goto out_free;
+
+    ksm_region.npages = phys_ram_size / TARGET_PAGE_SIZE;
+    ksm_region.addr = (unsigned long)phys_ram_base;
+    r = ioctl(ksm_fd, KSM_REGISTER_MEMORY_REGION, &ksm_region);
+    if (r)
+        goto out_free1;
+
+    return r;
+
+out_free1:
+    close(ksm_fd);
+out_free:
+    close(fd);
+out:
+    return r;
+}
+
 int main(int argc, char **argv, char **envp)
 {
 #ifdef CONFIG_GDBSTUB
@@ -5862,6 +5894,8 @@ int main(int argc, char **argv, char **envp)
     /* init the dynamic translator */
     cpu_exec_init_all(tb_size * 1024 * 1024);
 
+    ksm_register_memory();
+
     bdrv_init();
     dma_helper_init();
 
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
