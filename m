Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id CB4EA6B009E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:32:01 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so41064418qgf.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:32:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m64si538225qkh.92.2015.05.14.10.31.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:46 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 13/23] userfaultfd: change the read API to return a uffd_msg
Date: Thu, 14 May 2015 19:31:10 +0200
Message-Id: <1431624680-20153-14-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

I had requests to return the full address (not the page aligned one)
to userland.

It's not entirely clear how the page offset could be relevant because
userfaults aren't like SIGBUS that can sigjump to a different place
and it actually skip resolving the fault depending on a page
offset. There's currently no real way to skip the fault especially
because after a UFFDIO_COPY|ZEROPAGE, the fault is optimized to be
retried within the kernel without having to return to userland first
(not even self modifying code replacing the .text that touched the
faulting address would prevent the fault to be repeated). Userland
cannot skip repeating the fault even more so if the fault was
triggered by a KVM secondary page fault or any get_user_pages or any
copy-user inside some syscall which will return to kernel code. The
second time FAULT_FLAG_RETRY_NOWAIT won't be set leading to a SIGBUS
being raised because the userfault can't wait if it cannot release the
mmap_map first (and FAULT_FLAG_RETRY_NOWAIT is required for that).

Still returning userland a proper structure during the read() on the
uffd, can allow to use the current UFFD_API for the future
non-cooperative extensions too and it looks cleaner as well. Once we
get additional fields there's no point to return the fault address
page aligned anymore to reuse the bits below PAGE_SHIFT.

The only downside is that the read() syscall will read 32bytes instead
of 8bytes but that's not going to be measurable overhead.

The total number of new events that can be extended or of new future
bits for already shipped events, is limited to 64 by the features
field of the uffdio_api structure. If more will be needed a bump of
UFFD_API will be required.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 Documentation/vm/userfaultfd.txt | 12 +++---
 fs/userfaultfd.c                 | 79 +++++++++++++++++++++++-----------------
 include/uapi/linux/userfaultfd.h | 64 ++++++++++++++++++++++++--------
 3 files changed, 102 insertions(+), 53 deletions(-)

diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.txt
index c2f5145..3557edd 100644
--- a/Documentation/vm/userfaultfd.txt
+++ b/Documentation/vm/userfaultfd.txt
@@ -46,11 +46,13 @@ is a corner case that would currently return -EBUSY).
 When first opened the userfaultfd must be enabled invoking the
 UFFDIO_API ioctl specifying a uffdio_api.api value set to UFFD_API (or
 a later API version) which will specify the read/POLLIN protocol
-userland intends to speak on the UFFD. The UFFDIO_API ioctl if
-successful (i.e. if the requested uffdio_api.api is spoken also by the
-running kernel), will return into uffdio_api.features and
-uffdio_api.ioctls two 64bit bitmasks of respectively the activated
-feature of the read(2) protocol and the generic ioctl available.
+userland intends to speak on the UFFD and the uffdio_api.features
+userland needs to be enabled. The UFFDIO_API ioctl if successful
+(i.e. if the requested uffdio_api.api is spoken also by the running
+kernel and the requested features are going to be enabled) will return
+into uffdio_api.features and uffdio_api.ioctls two 64bit bitmasks of
+respectively all the available features of the read(2) protocol and
+the generic ioctl available.
 
 Once the userfaultfd has been enabled the UFFDIO_REGISTER ioctl should
 be invoked (if present in the returned uffdio_api.ioctls bitmask) to
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 9085365..b45cefe 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -50,7 +50,7 @@ struct userfaultfd_ctx {
 };
 
 struct userfaultfd_wait_queue {
-	unsigned long address;
+	struct uffd_msg msg;
 	wait_queue_t wq;
 	bool pending;
 	struct userfaultfd_ctx *ctx;
@@ -77,7 +77,8 @@ static int userfaultfd_wake_function(wait_queue_t *wq, unsigned mode,
 	/* len == 0 means wake all */
 	start = range->start;
 	len = range->len;
-	if (len && (start > uwq->address || start + len <= uwq->address))
+	if (len && (start > uwq->msg.arg.pagefault.address ||
+		    start + len <= uwq->msg.arg.pagefault.address))
 		goto out;
 	ret = wake_up_state(wq->private, mode);
 	if (ret)
@@ -122,28 +123,43 @@ static void userfaultfd_ctx_put(struct userfaultfd_ctx *ctx)
 	}
 }
 
-static inline unsigned long userfault_address(unsigned long address,
-					      unsigned int flags,
-					      unsigned long reason)
+static inline void msg_init(struct uffd_msg *msg)
 {
-	BUILD_BUG_ON(PAGE_SHIFT < UFFD_BITS);
-	address &= PAGE_MASK;
+	BUILD_BUG_ON(sizeof(struct uffd_msg) != 32);
+	/*
+	 * Must use memset to zero out the paddings or kernel data is
+	 * leaked to userland.
+	 */
+	memset(msg, 0, sizeof(struct uffd_msg));
+}
+
+static inline struct uffd_msg userfault_msg(unsigned long address,
+					    unsigned int flags,
+					    unsigned long reason)
+{
+	struct uffd_msg msg;
+	msg_init(&msg);
+	msg.event = UFFD_EVENT_PAGEFAULT;
+	msg.arg.pagefault.address = address;
 	if (flags & FAULT_FLAG_WRITE)
 		/*
-		 * Encode "write" fault information in the LSB of the
-		 * address read by userland, without depending on
-		 * FAULT_FLAG_WRITE kernel internal value.
+		 * If UFFD_FEATURE_PAGEFAULT_FLAG_WRITE was set in the
+		 * uffdio_api.features and UFFD_PAGEFAULT_FLAG_WRITE
+		 * was not set in a UFFD_EVENT_PAGEFAULT, it means it
+		 * was a read fault, otherwise if set it means it's
+		 * a write fault.
 		 */
-		address |= UFFD_BIT_WRITE;
+		msg.arg.pagefault.flags |= UFFD_PAGEFAULT_FLAG_WRITE;
 	if (reason & VM_UFFD_WP)
 		/*
-		 * Encode "reason" fault information as bit number 1
-		 * in the address read by userland. If bit number 1 is
-		 * clear it means the reason is a VM_FAULT_MISSING
-		 * fault.
+		 * If UFFD_FEATURE_PAGEFAULT_FLAG_WP was set in the
+		 * uffdio_api.features and UFFD_PAGEFAULT_FLAG_WP was
+		 * not set in a UFFD_EVENT_PAGEFAULT, it means it was
+		 * a missing fault, otherwise if set it means it's a
+		 * write protect fault.
 		 */
-		address |= UFFD_BIT_WP;
-	return address;
+		msg.arg.pagefault.flags |= UFFD_PAGEFAULT_FLAG_WP;
+	return msg;
 }
 
 /*
@@ -229,7 +245,7 @@ int handle_userfault(struct vm_area_struct *vma, unsigned long address,
 
 	init_waitqueue_func_entry(&uwq.wq, userfaultfd_wake_function);
 	uwq.wq.private = current;
-	uwq.address = userfault_address(address, flags, reason);
+	uwq.msg = userfault_msg(address, flags, reason);
 	uwq.pending = true;
 	uwq.ctx = ctx;
 
@@ -385,7 +401,7 @@ static unsigned int userfaultfd_poll(struct file *file, poll_table *wait)
 }
 
 static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
-				    __u64 *addr)
+				    struct uffd_msg *msg)
 {
 	ssize_t ret;
 	DECLARE_WAITQUEUE(wait, current);
@@ -403,8 +419,8 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			 * disappear from under us.
 			 */
 			uwq->pending = false;
-			/* careful to always initialize addr if ret == 0 */
-			*addr = uwq->address;
+			/* careful to always initialize msg if ret == 0 */
+			*msg = uwq->msg;
 			spin_unlock(&ctx->fault_wqh.lock);
 			ret = 0;
 			break;
@@ -434,8 +450,7 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
 	ssize_t _ret, ret = 0;
-	/* careful to always initialize addr if ret == 0 */
-	__u64 uninitialized_var(addr);
+	struct uffd_msg msg;
 	int no_wait = file->f_flags & O_NONBLOCK;
 
 	if (ctx->state == UFFD_STATE_WAIT_API)
@@ -443,16 +458,16 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 	BUG_ON(ctx->state != UFFD_STATE_RUNNING);
 
 	for (;;) {
-		if (count < sizeof(addr))
+		if (count < sizeof(msg))
 			return ret ? ret : -EINVAL;
-		_ret = userfaultfd_ctx_read(ctx, no_wait, &addr);
+		_ret = userfaultfd_ctx_read(ctx, no_wait, &msg);
 		if (_ret < 0)
 			return ret ? ret : _ret;
-		if (put_user(addr, (__u64 __user *) buf))
+		if (copy_to_user((__u64 __user *) buf, &msg, sizeof(msg)))
 			return ret ? ret : -EFAULT;
-		ret += sizeof(addr);
-		buf += sizeof(addr);
-		count -= sizeof(addr);
+		ret += sizeof(msg);
+		buf += sizeof(msg);
+		count -= sizeof(msg);
 		/*
 		 * Allow to read more than one fault at time but only
 		 * block if waiting for the very first one.
@@ -845,17 +860,15 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	if (ctx->state != UFFD_STATE_WAIT_API)
 		goto out;
 	ret = -EFAULT;
-	if (copy_from_user(&uffdio_api, buf, sizeof(__u64)))
+	if (copy_from_user(&uffdio_api, buf, sizeof(uffdio_api)))
 		goto out;
-	if (uffdio_api.api != UFFD_API) {
-		/* careful not to leak info, we only read the first 8 bytes */
+	if (uffdio_api.api != UFFD_API || uffdio_api.features) {
 		memset(&uffdio_api, 0, sizeof(uffdio_api));
 		if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
 			goto out;
 		ret = -EINVAL;
 		goto out;
 	}
-	/* careful not to leak info, we only read the first 8 bytes */
 	uffdio_api.features = UFFD_API_FEATURES;
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
 	ret = -EFAULT;
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 03f21cb..8e42bc3 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -10,8 +10,12 @@
 #define _LINUX_USERFAULTFD_H
 
 #define UFFD_API ((__u64)0xAA)
-/* FIXME: add "|UFFD_FEATURE_WP" to UFFD_API_FEATURES after implementing it */
-#define UFFD_API_FEATURES (UFFD_FEATURE_WRITE_BIT)
+/*
+ * After implementing the respective features it will become:
+ * #define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP | \
+ *			      UFFD_FEATURE_EVENT_FORK)
+ */
+#define UFFD_API_FEATURES (0)
 #define UFFD_API_IOCTLS				\
 	((__u64)1 << _UFFDIO_REGISTER |		\
 	 (__u64)1 << _UFFDIO_UNREGISTER |	\
@@ -43,26 +47,56 @@
 #define UFFDIO_WAKE		_IOR(UFFDIO, _UFFDIO_WAKE,	\
 				     struct uffdio_range)
 
-/*
- * Valid bits below PAGE_SHIFT in the userfault address read through
- * the read() syscall.
- */
-#define UFFD_BIT_WRITE	(1<<0)	/* this was a write fault, MISSING or WP */
-#define UFFD_BIT_WP	(1<<1)	/* handle_userfault() reason VM_UFFD_WP */
-#define UFFD_BITS	2	/* two above bits used for UFFD_BIT_* mask */
+/* read() structure */
+struct uffd_msg {
+	__u8	event;
+
+	union {
+		struct {
+			__u32	flags;
+			__u64	address;
+		} pagefault;
+
+		struct {
+			/* unused reserved fields */
+			__u64	reserved1;
+			__u64	reserved2;
+			__u64	reserved3;
+		} reserved;
+	} arg;
+};
 
 /*
- * Features reported in uffdio_api.features field
+ * Start at 0x12 and not at 0 to be more strict against bugs.
  */
-#define UFFD_FEATURE_WRITE_BIT	(1<<0) /* Corresponds to UFFD_BIT_WRITE */
-#define UFFD_FEATURE_WP_BIT	(1<<1) /* Corresponds to UFFD_BIT_WP */
+#define UFFD_EVENT_PAGEFAULT	0x12
+#if 0 /* not available yet */
+#define UFFD_EVENT_FORK		0x13
+#endif
+
+/* flags for UFFD_EVENT_PAGEFAULT */
+#define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
+#define UFFD_PAGEFAULT_FLAG_WP		(1<<1)	/* If reason is VM_UFFD_WP */
 
 struct uffdio_api {
-	/* userland asks for an API number */
+	/* userland asks for an API number and the features to enable */
 	__u64 api;
-
-	/* kernel answers below with the available features for the API */
+	/*
+	 * Kernel answers below with the all available features for
+	 * the API, this notifies userland of which events and/or
+	 * which flags for each event are enabled in the current
+	 * kernel.
+	 *
+	 * Note: UFFD_EVENT_PAGEFAULT and UFFD_PAGEFAULT_FLAG_WRITE
+	 * are to be considered implicitly always enabled in all kernels as
+	 * long as the uffdio_api.api requested matches UFFD_API.
+	 */
+#if 0 /* not available yet */
+#define UFFD_FEATURE_PAGEFAULT_FLAG_WP		(1<<0)
+#define UFFD_FEATURE_EVENT_FORK			(1<<1)
+#endif
 	__u64 features;
+
 	__u64 ioctls;
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
