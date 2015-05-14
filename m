Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0E44A6B00A5
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:32:12 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so49359277wgb.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:32:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fb7si1140190wid.20.2015.05.14.10.31.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:50 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 23/23] userfaultfd: UFFDIO_COPY and UFFDIO_ZEROPAGE
Date: Thu, 14 May 2015 19:31:20 +0200
Message-Id: <1431624680-20153-24-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

These two ioctl allows to either atomically copy or to map zeropages
into the virtual address space. This is used by the thread that opened
the userfaultfd to resolve the userfaults.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 96 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 6772c22..65704cb 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -942,6 +942,96 @@ out:
 	return ret;
 }
 
+static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
+			    unsigned long arg)
+{
+	__s64 ret;
+	struct uffdio_copy uffdio_copy;
+	struct uffdio_copy __user *user_uffdio_copy;
+	struct userfaultfd_wake_range range;
+
+	user_uffdio_copy = (struct uffdio_copy __user *) arg;
+
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_copy, user_uffdio_copy,
+			   /* don't copy "copy" last field */
+			   sizeof(uffdio_copy)-sizeof(__s64)))
+		goto out;
+
+	ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
+	if (ret)
+		goto out;
+	/*
+	 * double check for wraparound just in case. copy_from_user()
+	 * will later check uffdio_copy.src + uffdio_copy.len to fit
+	 * in the userland range.
+	 */
+	ret = -EINVAL;
+	if (uffdio_copy.src + uffdio_copy.len <= uffdio_copy.src)
+		goto out;
+	if (uffdio_copy.mode & ~UFFDIO_COPY_MODE_DONTWAKE)
+		goto out;
+
+	ret = mcopy_atomic(ctx->mm, uffdio_copy.dst, uffdio_copy.src,
+			   uffdio_copy.len);
+	if (unlikely(put_user(ret, &user_uffdio_copy->copy)))
+		return -EFAULT;
+	if (ret < 0)
+		goto out;
+	BUG_ON(!ret);
+	/* len == 0 would wake all */
+	range.len = ret;
+	if (!(uffdio_copy.mode & UFFDIO_COPY_MODE_DONTWAKE)) {
+		range.start = uffdio_copy.dst;
+		wake_userfault(ctx, &range);
+	}
+	ret = range.len == uffdio_copy.len ? 0 : -EAGAIN;
+out:
+	return ret;
+}
+
+static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
+				unsigned long arg)
+{
+	__s64 ret;
+	struct uffdio_zeropage uffdio_zeropage;
+	struct uffdio_zeropage __user *user_uffdio_zeropage;
+	struct userfaultfd_wake_range range;
+
+	user_uffdio_zeropage = (struct uffdio_zeropage __user *) arg;
+
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_zeropage, user_uffdio_zeropage,
+			   /* don't copy "zeropage" last field */
+			   sizeof(uffdio_zeropage)-sizeof(__s64)))
+		goto out;
+
+	ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
+			     uffdio_zeropage.range.len);
+	if (ret)
+		goto out;
+	ret = -EINVAL;
+	if (uffdio_zeropage.mode & ~UFFDIO_ZEROPAGE_MODE_DONTWAKE)
+		goto out;
+
+	ret = mfill_zeropage(ctx->mm, uffdio_zeropage.range.start,
+			     uffdio_zeropage.range.len);
+	if (unlikely(put_user(ret, &user_uffdio_zeropage->zeropage)))
+		return -EFAULT;
+	if (ret < 0)
+		goto out;
+	/* len == 0 would wake all */
+	BUG_ON(!ret);
+	range.len = ret;
+	if (!(uffdio_zeropage.mode & UFFDIO_ZEROPAGE_MODE_DONTWAKE)) {
+		range.start = uffdio_zeropage.range.start;
+		wake_userfault(ctx, &range);
+	}
+	ret = range.len == uffdio_zeropage.range.len ? 0 : -EAGAIN;
+out:
+	return ret;
+}
+
 /*
  * userland asks for a certain API version and we return which bits
  * and ioctl commands are implemented in this kernel for such API
@@ -997,6 +1087,12 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	case UFFDIO_WAKE:
 		ret = userfaultfd_wake(ctx, arg);
 		break;
+	case UFFDIO_COPY:
+		ret = userfaultfd_copy(ctx, arg);
+		break;
+	case UFFDIO_ZEROPAGE:
+		ret = userfaultfd_zeropage(ctx, arg);
+		break;
 	}
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
