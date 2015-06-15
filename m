Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id A70BD6B006E
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:22:18 -0400 (EDT)
Received: by qgf75 with SMTP id 75so29123383qgf.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:22:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si13322754qge.80.2015.06.15.10.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 10:22:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/7] userfaultfd: require UFFDIO_API before other ioctls
Date: Mon, 15 Jun 2015 19:22:05 +0200
Message-Id: <1434388931-24487-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
References: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

UFFDIO_API was already forced before read/poll could work. This
makes the code more strict to force it also for all other ioctls.

All users would already have been required to call UFFDIO_API before
invoking other ioctls but this makes it more explicit.

This will ensure we can change all ioctls (all but UFFDIO_API/struct
uffdio_api) with a bump of uffdio_api.api.

There's no actual plan or need to change the API or the ioctl, the
current API already should cover fine even the non cooperative usage,
but this is just for the longer term future just in case.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 5f11678..b69d236 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1115,6 +1115,12 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	int ret = -EINVAL;
 	struct userfaultfd_ctx *ctx = file->private_data;
 
+	if (cmd != UFFDIO_API) {
+		if (ctx->state == UFFD_STATE_WAIT_API)
+			return -EINVAL;
+		BUG_ON(ctx->state != UFFD_STATE_RUNNING);
+	}
+
 	switch(cmd) {
 	case UFFDIO_API:
 		ret = userfaultfd_api(ctx, arg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
