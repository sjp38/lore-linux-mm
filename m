Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 907636B02DC
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 15:40:56 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id g193so23325986qke.2
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 12:40:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v80si1913119qkv.258.2016.11.02.12.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 12:34:10 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 07/33] userfaultfd: non-cooperative: report all available features to userland
Date: Wed,  2 Nov 2016 20:33:39 +0100
Message-Id: <1478115245-32090-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
References: <1478115245-32090-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert"@v2.random, " <dgilbert@redhat.com>,  Mike Kravetz <mike.kravetz@oracle.com>,  Shaohua Li <shli@fb.com>,  Pavel Emelyanov <xemul@parallels.com>"@v2.random

This will allow userland to probe all features available in the
kernel. It will however only enable the requested features in the
open userfaultfd context.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 76205b3..b164c40 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1250,6 +1250,7 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	struct uffdio_api uffdio_api;
 	void __user *buf = (void __user *)arg;
 	int ret;
+	__u64 features;
 
 	ret = -EINVAL;
 	if (ctx->state != UFFD_STATE_WAIT_API)
@@ -1257,21 +1258,23 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	ret = -EFAULT;
 	if (copy_from_user(&uffdio_api, buf, sizeof(uffdio_api)))
 		goto out;
-	if (uffdio_api.api != UFFD_API ||
-	    (uffdio_api.features & ~UFFD_API_FEATURES)) {
+	features = uffdio_api.features;
+	if (uffdio_api.api != UFFD_API || (features & ~UFFD_API_FEATURES)) {
 		memset(&uffdio_api, 0, sizeof(uffdio_api));
 		if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
 			goto out;
 		ret = -EINVAL;
 		goto out;
 	}
-	uffdio_api.features &= UFFD_API_FEATURES;
+	/* report all available features and ioctls to userland */
+	uffdio_api.features = UFFD_API_FEATURES;
 	uffdio_api.ioctls = UFFD_API_IOCTLS;
 	ret = -EFAULT;
 	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
 		goto out;
 	ctx->state = UFFD_STATE_RUNNING;
-	ctx->features = uffd_ctx_features(uffdio_api.features);
+	/* only enable the requested features for this uffd context */
+	ctx->features = uffd_ctx_features(features);
 	ret = 0;
 out:
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
