Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0656B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:49:14 -0500 (EST)
Received: by mail-qk0-f182.google.com with SMTP id x1so71691907qkc.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:49:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d21si35127266qkb.86.2016.02.23.10.49.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 10:49:13 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] mm: thp: fix SMP race condition between THP page fault and MADV_DONTNEED
Date: Tue, 23 Feb 2016 19:49:10 +0100
Message-Id: <1456253350-3959-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1456253350-3959-1-git-send-email-aarcange@redhat.com>
References: <20160223154950.GA22449@node.shutemov.name>
 <1456253350-3959-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>
Cc: linux-mm@kvack.org

pmd_trans_unstable()/pmd_none_or_trans_huge_or_clear_bad() were
introduced to locklessy (but atomically) detect when a pmd is a
regular (stable) pmd or when the pmd is unstable and can infinitely
transition from pmd_none() and pmd_trans_huge() from under us, while
only holding the mmap_sem for reading (for writing not).

While holding the mmap_sem only for reading, MADV_DONTNEED can run
from under us and so before we can assume the pmd to be a regular
stable pmd we need to compare it against pmd_none() and
pmd_trans_huge() in an atomic way, with pmd_trans_unstable(). The old
pmd_trans_huge() left a tiny window for a race.

Useful applications are unlikely to notice the difference as doing
MADV_DONTNEED concurrently with a page fault would lead to undefined
behavior.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reported-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 635451a..50347ed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3404,8 +3404,19 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (unlikely(pmd_none(*pmd)) &&
 	    unlikely(__pte_alloc(mm, vma, pmd, address)))
 		return VM_FAULT_OOM;
-	/* if an huge pmd materialized from under us just retry later */
-	if (unlikely(pmd_trans_huge(*pmd) || pmd_devmap(*pmd)))
+	/*
+	 * If an huge pmd materialized from under us just retry later.
+	 * Use pmd_trans_unstable() instead of pmd_trans_huge() to
+	 * ensure the pmd didn't become pmd_trans_huge from under us
+	 * and then back to pmd_none, as result of MADV_DONTNEED
+	 * running immediately after a huge pmd fault of a different
+	 * thread of this mm, in turn leading to a misleading
+	 * pmd_trans_huge() retval. All we have to ensure is that it
+	 * is a regular pmd that we can walk with pte_offset_map() and
+	 * we can do that through an atomic read in C, which is what
+	 * pmd_trans_unstable() is provided for.
+	 */
+	if (unlikely(pmd_trans_unstable(pmd) || pmd_devmap(*pmd)))
 		return 0;
 	/*
 	 * A regular pmd is established and it can't morph into a huge pmd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
