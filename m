Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA2F26B029A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 09:49:46 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id b123so21216383itb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 06:49:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m20si2930975ita.87.2016.12.16.06.48.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 06:48:28 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 25/42] userfaultfd: hugetlbfs: reserve count on error in __mcopy_atomic_hugetlb
Date: Fri, 16 Dec 2016 15:48:04 +0100
Message-Id: <20161216144821.5183-26-aarcange@redhat.com>
In-Reply-To: <20161216144821.5183-1-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

From: Mike Kravetz <mike.kravetz@oracle.com>

If __mcopy_atomic_hugetlb exits with an error, put_page will be called
if a huge page was allocated and needs to be freed.  If a reservation
was associated with the huge page, the PagePrivate flag will be set.
Clear PagePrivate before calling put_page/free_huge_page so that the
global reservation count is not incremented.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/userfaultfd.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 0997674..31207b4 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -301,8 +301,23 @@ static __always_inline ssize_t __mcopy_atomic_hugetlb(struct mm_struct *dst_mm,
 out_unlock:
 	up_read(&dst_mm->mmap_sem);
 out:
-	if (page)
+	if (page) {
+		/*
+		 * We encountered an error and are about to free a newly
+		 * allocated huge page.  It is possible that there was a
+		 * reservation associated with the page that has been
+		 * consumed.  See the routine restore_reserve_on_error
+		 * for details.  Unfortunately, we can not call
+		 * restore_reserve_on_error now as it would require holding
+		 * mmap_sem.  Clear the PagePrivate flag so that the global
+		 * reserve count will not be incremented in free_huge_page.
+		 * The reservation map will still indicate the reservation
+		 * was consumed and possibly prevent later page allocation.
+		 * This is better than leaking a global reservation.
+		 */
+		ClearPagePrivate(page);
 		put_page(page);
+	}
 	BUG_ON(copied < 0);
 	BUG_ON(err > 0);
 	BUG_ON(!copied && !err);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
