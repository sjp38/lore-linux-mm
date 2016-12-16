Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB456B02A0
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:49:58 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o141so21482679itc.1
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:49:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h64si6142860iof.237.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 07/42] userfaultfd: non-cooperative: report all available features to userland
Date: Fri, 16 Dec 2016 15:47:46 +0100
Message-Id: <20161216144821.5183-8-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

This will allow userland to probe all features available in the
kernel. It will however only enable the requested features in the
open userfaultfd context.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index fa6a6bf..fd89b1c 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1252,6 +1252,7 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
 	struct uffdio_api uffdio_api;
 	void __user *buf = (void __user *)arg;
 	int ret;
+	__u64 features;
 
 	ret = -EINVAL;
 	if (ctx->state != UFFD_STATE_WAIT_API)
@@ -1259,21 +1260,23 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
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
