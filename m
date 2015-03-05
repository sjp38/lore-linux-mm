Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id B154B6B0082
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:19:25 -0500 (EST)
Received: by qgaj5 with SMTP id j5so6305217qga.12
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:19:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v5si6525417qci.35.2015.03.05.09.19.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 09:19:07 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 20/21] userfaultfd: UFFDIO_REMAP
Date: Thu,  5 Mar 2015 18:18:03 +0100
Message-Id: <1425575884-2574-21-git-send-email-aarcange@redhat.com>
In-Reply-To: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
References: <1425575884-2574-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Android Kernel Team <kernel-team@android.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

This remap ioctl allows to atomically move a page in or out of an
userfaultfd address space. It's more expensive than "copy" (and of
course more expensive than "zerofill") as it requires a TLB flush on
the source range for each ioctl, which is an expensive operation on
SMP. Especially if copying only a few pages at time, copying without
TLB flush is faster.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 51 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 6230f22..b4c7f25 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -892,6 +892,54 @@ out:
 	return ret;
 }
 
+static int userfaultfd_remap(struct userfaultfd_ctx *ctx,
+			     unsigned long arg)
+{
+	__s64 ret;
+	struct uffdio_remap uffdio_remap;
+	struct uffdio_remap __user *user_uffdio_remap;
+	struct userfaultfd_wake_range range;
+
+	user_uffdio_remap = (struct uffdio_remap __user *) arg;
+
+	ret = -EFAULT;
+	if (copy_from_user(&uffdio_remap, user_uffdio_remap,
+			   /* don't copy "remap" and "wake" last field */
+			   sizeof(uffdio_remap)-sizeof(__s64)*2))
+		goto out;
+
+	ret = validate_range(ctx->mm, uffdio_remap.dst, uffdio_remap.len);
+	if (ret)
+		goto out;
+	ret = validate_range(current->mm, uffdio_remap.src, uffdio_remap.len);
+	if (ret)
+		goto out;
+	ret = -EINVAL;
+	if (uffdio_remap.mode & ~(UFFDIO_REMAP_MODE_ALLOW_SRC_HOLES|
+				  UFFDIO_REMAP_MODE_DONTWAKE))
+		goto out;
+
+	ret = remap_pages(ctx->mm, current->mm,
+			  uffdio_remap.dst, uffdio_remap.src,
+			  uffdio_remap.len, uffdio_remap.mode);
+	if (unlikely(put_user(ret, &user_uffdio_remap->remap)))
+		return -EFAULT;
+	if (ret < 0)
+		goto out;
+	/* len == 0 would wake all */
+	BUG_ON(!ret);
+	range.len = ret;
+	if (!(uffdio_remap.mode & UFFDIO_REMAP_MODE_DONTWAKE)) {
+		range.start = uffdio_remap.dst;
+		ret = wake_userfault(ctx, &range);
+		if (unlikely(put_user(ret, &user_uffdio_remap->wake)))
+			return -EFAULT;
+	}
+	ret = range.len == uffdio_remap.len ? 0 : -EAGAIN;
+out:
+	return ret;
+}
+
 /*
  * userland asks for a certain API version and we return which bits
  * and ioctl commands are implemented in this kernel for such API
@@ -955,6 +1003,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	case UFFDIO_ZEROPAGE:
 		ret = userfaultfd_zeropage(ctx, arg);
 		break;
+	case UFFDIO_REMAP:
+		ret = userfaultfd_remap(ctx, arg);
+		break;
 	}
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
