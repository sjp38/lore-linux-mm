Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id BE2BF6B0253
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 06:50:13 -0400 (EDT)
Received: by qkbp125 with SMTP id p125so159589340qkb.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 03:50:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o72si1691905qkh.20.2015.07.08.03.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 03:50:12 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/5] userfaultfd: require UFFDIO_API before other ioctls
Date: Wed,  8 Jul 2015 12:50:04 +0200
Message-Id: <1436352608-8455-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
References: <1436352608-8455-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Pavel Emelyanov <xemul@parallels.com>, Dave Hansen <dave.hansen@intel.com>

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
 fs/userfaultfd.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89067cf..901d52a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -577,7 +577,6 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 
 	if (ctx->state == UFFD_STATE_WAIT_API)
 		return -EINVAL;
-	BUG_ON(ctx->state != UFFD_STATE_RUNNING);
 
 	for (;;) {
 		if (count < sizeof(msg))
@@ -1115,6 +1114,9 @@ static long userfaultfd_ioctl(struct file *file, unsigned cmd,
 	int ret = -EINVAL;
 	struct userfaultfd_ctx *ctx = file->private_data;
 
+	if (cmd != UFFDIO_API && ctx->state == UFFD_STATE_WAIT_API)
+		return -EINVAL;
+
 	switch(cmd) {
 	case UFFDIO_API:
 		ret = userfaultfd_api(ctx, arg);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
