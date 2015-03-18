Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 397A16B006E
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 15:35:26 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so51476331pab.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 12:35:25 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id he4si37939502pac.34.2015.03.18.12.35.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 12:35:25 -0700 (PDT)
Message-ID: <5509D375.7000809@parallels.com>
Date: Wed, 18 Mar 2015 22:35:17 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 2/3] uffd: Introduce the v2 API
References: <5509D342.7000403@parallels.com>
In-Reply-To: <5509D342.7000403@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>
Cc: Sanidhya Kashyap <sanidhya.gatech@gmail.com>

The new API will report more than just the page-faults. The
reason for this is -- when the task whose mm we monitor with 
uffd and the monitor task itself cannot cooperate with each
other, the former one can screw things up. Like this.

If task fork()-s the child process is detached from uffd and
thus all not-yet-faulted-in memory gets mapped with zero-pages
on touch.

Another example is mremap(). When the victim remaps the uffd-ed
region and starts touching it the monitor would receive fault
messages with addresses that were not register-ed with uffd
ioctl before it. Thus monitor will have no idea how to handle
those faults.

To address both we can send more events to the monitor. In
particular, on fork() we can create another uffd context,
register the same set of regions in it and "send" the descriptor
to monitor.

For mremap() we can send the message describing what change
has been performed.

So this patch prepares to ground for the described above feature
by introducing the v2 API of uffd. With new API the kernel would
respond with a message containing the event type (pagefault,
fork or remap) and argument (fault address, new uffd descriptor
or region change respectively).

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 fs/userfaultfd.c                 | 56 ++++++++++++++++++++++++++++++----------
 include/uapi/linux/userfaultfd.h | 21 ++++++++++++++-
 2 files changed, 62 insertions(+), 15 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 6c9a2d6..bd629b4 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -41,6 +41,8 @@ struct userfaultfd_ctx {
 	wait_queue_head_t fd_wqh;
 	/* userfaultfd syscall flags */
 	unsigned int flags;
+	/* features flags */
+	unsigned int features;
 	/* state machine */
 	enum userfaultfd_state state;
 	/* released */
@@ -49,6 +51,8 @@ struct userfaultfd_ctx {
 	struct mm_struct *mm;
 };
 
+#define UFFD_FEATURE_LONGMSG	0x1
+
 struct userfaultfd_wait_queue {
 	unsigned long address;
 	wait_queue_t wq;
@@ -369,7 +373,7 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 }
 
 static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
-				    __u64 *addr)
+				    __u64 *mtype, __u64 *addr)
 {
 	ssize_t ret;
 	DECLARE_WAITQUEUE(wait, current);
@@ -383,6 +387,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 		if (find_userfault(ctx, &uwq)) {
 			uwq->pending = false;
 			/* careful to always initialize addr if ret == 0 */
+			*mtype = UFFD_PAGEFAULT;
 			*addr = uwq->address;
 			ret = 0;
 			break;
@@ -411,8 +416,6 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
 	ssize_t _ret, ret = 0;
-	/* careful to always initialize addr if ret == 0 */
-	__u64 uninitialized_var(addr);
 	int no_wait = file->f_flags & O_NONBLOCK;
 
 	if (ctx->state == UFFD_STATE_WAIT_API)
@@ -420,16 +423,34 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 	BUG_ON(ctx->state != UFFD_STATE_RUNNING);
 
 	for (;;) {
-		if (count < sizeof(addr))
-			return ret ? ret : -EINVAL;
-		_ret = userfaultfd_ctx_read(ctx, no_wait, &addr);
-		if (_ret < 0)
-			return ret ? ret : _ret;
-		if (put_user(addr, (__u64 __user *) buf))
-			return ret ? ret : -EFAULT;
-		ret += sizeof(addr);
-		buf += sizeof(addr);
-		count -= sizeof(addr);
+		if (!(ctx->features & UFFD_FEATURE_LONGMSG)) {
+			/* careful to always initialize addr if ret == 0 */
+			__u64 uninitialized_var(addr);
+			__u64 uninitialized_var(mtype);
+			if (count < sizeof(addr))
+				return ret ? ret : -EINVAL;
+			_ret = userfaultfd_ctx_read(ctx, no_wait, &mtype, &addr);
+			if (_ret < 0)
+				return ret ? ret : _ret;
+			BUG_ON(mtype != UFFD_PAGEFAULT);
+			if (put_user(addr, (__u64 __user *) buf))
+				return ret ? ret : -EFAULT;
+			_ret = sizeof(addr);
+		} else {
+			struct uffd_v2_msg msg;
+			if (count < sizeof(msg))
+				return ret ? ret : -EINVAL;
+			_ret = userfaultfd_ctx_read(ctx, no_wait, &msg.type, &msg.arg);
+			if (_ret < 0)
+				return ret ? ret : _ret;
+			if (copy_to_user(buf, &msg, sizeof(msg)))
+				return ret ? ret : -EINVAL;
+			_ret = sizeof(msg);
+		}
+
+		ret += _ret;
+		buf += _ret;
+		count -= _ret;
 		/*
 		 * Allow to read more than one fault at time but only
 		 * block if waiting for the very first one.
@@ -981,7 +1002,7 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_api, buf, sizeof(__u64)))
 		goto out;
-	if (uffdio_api.api != UFFD_API) {
+	if (uffdio_api.api != UFFD_API && uffdio_api.api != UFFD_API_V2) {
 		/* careful not to leak info, we only read the first 8 bytes */
 		memset(&uffdio_api, 0, sizeof(uffdio_api));
 		if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
@@ -992,6 +1013,12 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	/* careful not to leak info, we only read the first 8 bytes */
 	uffdio_api.bits = UFFD_API_BITS;
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
+
+	if (uffdio_api.api == UFFD_API_V2) {
+		ctx->features |= UFFD_FEATURE_LONGMSG;
+		uffdio_api.bits |= UFFD_API_V2_BITS;
+	}
+
 	ret = -EFAULT;
 	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
 		goto out;
@@ -1109,6 +1136,7 @@ static struct file *userfaultfd_file_create(int flags)
 
 	ctx->flags = flags;
 	ctx->state = UFFD_STATE_WAIT_API;
+	ctx->features = 0;
 	ctx->mm = current->mm;
 	/* prevent the mm struct to be freed */
 	atomic_inc(&ctx->mm->mm_count);
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index db6e99a..4e169b8 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -9,7 +9,9 @@
 #ifndef _LINUX_USERFAULTFD_H
 #define _LINUX_USERFAULTFD_H
 
-#define UFFD_API ((__u64)0xAA)
+#define UFFD_API 	((__u64)0xAA)
+#define UFFD_API_V2	((__u64)0xAB)
+
 /* FIXME: add "|UFFD_BIT_WP" to UFFD_API_BITS after implementing it */
 #define UFFD_API_BITS (UFFD_BIT_WRITE)
 #define UFFD_API_IOCTLS				\
@@ -147,4 +149,21 @@ struct uffdio_remap {
 	__s64 wake;
 };
 
+struct uffd_v2_msg {
+	__u64	type;
+	__u64	arg;
+};
+
+#define UFFD_PAGEFAULT	0x1
+
+#define UFFD_PAGEFAULT_BIT	(1 << (UFFD_PAGEFAULT - 1))
+#define __UFFD_API_V2_BITS	(UFFD_PAGEFAULT_BIT)
+
+/*
+ * Lower PAGE_SHIFT bits are used to report those supported
+ * by the pagefault message itself. Other bits are used to
+ * report the message types v2 API supports
+ */
+#define UFFD_API_V2_BITS	(__UFFD_API_V2_BITS << 12)
+
 #endif /* _LINUX_USERFAULTFD_H */
-- 
1.8.4.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
