Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2ABC8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:36:58 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 135so3209147itk.5
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:36:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d78sor5328741itc.28.2019.01.11.16.36.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 16:36:57 -0800 (PST)
From: Blake Caldwell <blake.caldwell@colorado.edu>
Subject: [PATCH 4/4] userfaultfd: change the direction for UFFDIO_REMAP to out
Date: Sat, 12 Jan 2019 00:36:29 +0000
Message-Id: <ab1b6be85254e111935104cf4a2293ab2fa4a8d6.1547251023.git.blake.caldwell@colorado.edu>
In-Reply-To: <cover.1547251023.git.blake.caldwell@colorado.edu>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
In-Reply-To: <cover.1547251023.git.blake.caldwell@colorado.edu>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: blake.caldwell@colorado.edu
Cc: rppt@linux.vnet.ibm.com, xemul@virtuozzo.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, aarcange@redhat.com

Moving a page out of a userfaultfd registered region and into a userland
anonymous vma is needed by the use case of uncooperatively limiting the
resident size of the userfaultfd region. Reverse the direction of the
original userfaultfd_remap() to the out direction. Now after memory has
been removed, subsequent accesses will generate uffdio page fault events.

Signed-off-by: Blake Caldwell <blake.caldwell@colorado.edu>
---
 Documentation/admin-guide/mm/userfaultfd.rst | 10 ++++++++++
 fs/userfaultfd.c                             |  6 +++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/Documentation/admin-guide/mm/userfaultfd.rst b/Documentation/admin-guide/mm/userfaultfd.rst
index 5048cf6..714af49 100644
--- a/Documentation/admin-guide/mm/userfaultfd.rst
+++ b/Documentation/admin-guide/mm/userfaultfd.rst
@@ -108,6 +108,16 @@ UFFDIO_COPY. They're atomic as in guaranteeing that nothing can see an
 half copied page since it'll keep userfaulting until the copy has
 finished.
 
+To move pages out of a userfault registered region and into a user vma
+the UFFDIO_REMAP ioctl can be used. This is only possible for the
+"OUT" direction. For the "IN" direction, UFFDIO_COPY is preferred
+since UFFDIO_REMAP requires a TLB flush on the source range at a
+greater penalty than copying the page. With
+UFFDIO_REGISTER_MODE_MISSING set, subsequent accesses to the same
+region will generate a page fault event. This allows non-cooperative
+removal of memory in a userfaultfd registered vma, effectively
+limiting the amount of resident memory in such a region.
+
 QEMU/KVM
 ========
 
diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cf68cdb..8099da2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1808,10 +1808,10 @@ static int userfaultfd_remap(struct userfaultfd_ctx *ctx,
 			   sizeof(uffdio_remap)-sizeof(__s64)))
 		goto out;
 
-	ret = validate_range(ctx->mm, uffdio_remap.dst, uffdio_remap.len);
+	ret = validate_range(current->mm, uffdio_remap.dst, uffdio_remap.len);
 	if (ret)
 		goto out;
-	ret = validate_range(current->mm, uffdio_remap.src, uffdio_remap.len);
+	ret = validate_range(ctx->mm, uffdio_remap.src, uffdio_remap.len);
 	if (ret)
 		goto out;
 	ret = -EINVAL;
@@ -1819,7 +1819,7 @@ static int userfaultfd_remap(struct userfaultfd_ctx *ctx,
 				  UFFDIO_REMAP_MODE_DONTWAKE))
 		goto out;
 
-	ret = remap_pages(ctx->mm, current->mm,
+	ret = remap_pages(current->mm, ctx->mm,
 			  uffdio_remap.dst, uffdio_remap.src,
 			  uffdio_remap.len, uffdio_remap.mode);
 	if (unlikely(put_user(ret, &user_uffdio_remap->remap)))
-- 
1.8.3.1
