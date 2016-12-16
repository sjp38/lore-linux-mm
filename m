Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id DED536B0267
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:48:26 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 136so91837706iou.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:48:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 78si2933384ith.107.2016.12.16.06.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:26 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 14/42] userfaultfd: non-cooperative: avoid MADV_DONTNEED race condition
Date: Fri, 16 Dec 2016 15:47:53 +0100
Message-Id: <20161216144821.5183-15-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

MADV_DONTNEED must be notified to userland before the pages are
zapped. This allows userland to immediately stop adding pages to the
userfaultfd ranges before the pages are actually zapped or there could
be non-zeropage leftovers as result of concurrent UFFDIO_COPY run in
between zap_page_range and madvise_userfault_dontneed (both
MADV_DONTNEED and UFFDIO_COPY runs under the mmap_sem for reading, so
they can run concurrently).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 06ffb5a..ca75b8a 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -477,8 +477,8 @@ static long madvise_dontneed(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
 		return -EINVAL;
 
-	zap_page_range(vma, start, end - start, NULL);
 	madvise_userfault_dontneed(vma, prev, start, end);
+	zap_page_range(vma, start, end - start, NULL);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
