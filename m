Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DC5FF6B05ED
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:02 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s18so24511145qks.4
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w34si10863191qtd.181.2017.08.02.09.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:02 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/6] userfaultfd: call userfaultfd_unmap_prep only if __split_vma succeeds
Date: Wed,  2 Aug 2017 18:51:43 +0200
Message-Id: <20170802165145.22628-5-aarcange@redhat.com>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

A __split_vma is not a worthy event to report, and it's definitely not
a unmap so it would be incorrect to report unmap for the whole region
to the userfaultfd manager if a __split_vma fails.

So only call userfaultfd_unmap_prep after the __vma_splitting is over
and do_munmap cannot fail anymore.

Also add unlikely because it's better to optimize for the vast
majority of apps that aren't using userfaultfd in a non cooperative
way. Ideally we should also find a way to eliminate the branch
entirely if CONFIG_USERFAULTFD=n, but it would complicate things so
stick to unlikely for now.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index f19efcf75418..9b0161f1adf3 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2639,13 +2639,6 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	if (vma->vm_start >= end)
 		return 0;
 
-	if (uf) {
-		int error = userfaultfd_unmap_prep(vma, start, end, uf);
-
-		if (error)
-			return error;
-	}
-
 	/*
 	 * If we need to split any vma, do it now to save pain later.
 	 *
@@ -2679,6 +2672,21 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 	}
 	vma = prev ? prev->vm_next : mm->mmap;
 
+	if (unlikely(uf)) {
+		/*
+		 * If userfaultfd_unmap_prep returns an error the vmas
+		 * will remain splitted, but userland will get a
+		 * highly unexpected error anyway. This is no
+		 * different than the case where the first of the two
+		 * __split_vma fails, but we don't undo the first
+		 * split, despite we could. This is unlikely enough
+		 * failure that it's not worth optimizing it for.
+		 */
+		int error = userfaultfd_unmap_prep(vma, start, end, uf);
+		if (error)
+			return error;
+	}
+
 	/*
 	 * unlock any mlock()ed ranges before detaching vmas
 	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
