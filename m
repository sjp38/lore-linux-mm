Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9738A6B0258
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:34:04 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so97455315pab.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:04 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l29si77010pfi.75.2015.11.19.14.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:33:56 -0800 (PST)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJMTZrC012940
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:56 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y9nywgawm-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:56 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 9d0d9ee28f0d11e5b9600002c99293a0-495fa230 for <linux-mm@kvack.org>;	Thu, 19
 Nov 2015 14:33:53 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 4/8] userfaultfd: allow userfaultfd register success with writeprotection
Date: Thu, 19 Nov 2015 14:33:49 -0800
Message-ID: <1735e26d3649be909e89d1d3c3e2d27604788d79.1447964595.git.shli@fb.com>
In-Reply-To: <cover.1447964595.git.shli@fb.com>
References: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

The userfaultfd register ioctl currently disables writeprotection.
Enable it.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 fs/userfaultfd.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index eaa5086..12176b5 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -236,6 +236,8 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	 */
 	if (pte_none(*pte))
 		ret = true;
+	if (!pte_write(*pte) && (reason & VM_UFFD_WP))
+		ret = true;
 	pte_unmap(pte);
 
 out:
@@ -736,15 +738,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	vm_flags = 0;
 	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_MISSING)
 		vm_flags |= VM_UFFD_MISSING;
-	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP) {
+	if (uffdio_register.mode & UFFDIO_REGISTER_MODE_WP)
 		vm_flags |= VM_UFFD_WP;
-		/*
-		 * FIXME: remove the below error constraint by
-		 * implementing the wprotect tracking mode.
-		 */
-		ret = -EINVAL;
-		goto out;
-	}
 
 	ret = validate_range(mm, uffdio_register.range.start,
 			     uffdio_register.range.len);
@@ -784,6 +779,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 		ret = -EINVAL;
 		if (cur->vm_ops)
 			goto out_unlock;
+		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_WRITE))
+			goto out_unlock;
 
 		/*
 		 * Check that this vma isn't already owned by a
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
