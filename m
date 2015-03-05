Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 58FE36B008A
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:35 -0500 (EST)
Received: by wibbs8 with SMTP id bs8so8752478wib.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jt9si8706429wid.5.2015.03.05.09.19.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:11 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 15/21] userfaultfd: UFFDIO_COPY and UFFDIO_ZEROPAGE
Date: Thu,  5 Mar 2015 18:17:58 +0100
Message-Id: <1425575884-2574-16-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

These two ioctl allows to either atomically copy or to map zeropages
into the virtual address space. This is used by the thread that opened
the userfaultfd to resolve the userfaults.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 100 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 6b31967..6230f22 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -798,6 +798,100 @@ out:
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
+			   /* don't copy "copy" and "wake" last field */
+			   sizeof(uffdio_copy)-sizeof(__s64)*2))
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
+		ret = wake_userfault(ctx, &range);
+		if (unlikely(put_user(ret, &user_uffdio_copy->wake)))
+			return -EFAULT;
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
+			   /* don't copy "zeropage" and "wake" last field */
+			   sizeof(uffdio_zeropage)-sizeof(__s64)*2))
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
+		ret = wake_userfault(ctx, &range);
+		if (unlikely(put_user(ret, &user_uffdio_zeropage->wake)))
+			return -EFAULT;
+	}
+	ret = range.len == uffdio_zeropage.range.len ? 0 : -EAGAIN;
+out:
+	return ret;
+}
+
 /*
  * userland asks for a certain API version and we return which bits
  * and ioctl commands are implemented in this kernel for such API
@@ -855,6 +949,12 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
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
