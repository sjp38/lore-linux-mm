Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 327C06B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:55:15 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 25 Jul 2013 09:50:43 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 438DE2190066
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 09:59:20 +0100 (BST)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6P8sxAl50004038
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 08:54:59 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6P8t9oU025872
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 02:55:10 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/2] mm: add support for discard of unused ptes
Date: Thu, 25 Jul 2013 10:54:20 +0200
Message-Id: <1374742461-29160-2-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1374742461-29160-1-git-send-email-schwidefsky@de.ibm.com>
References: <1374742461-29160-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Konstantin Weitz <konstantin.weitz@gmail.com>

From: Konstantin Weitz <konstantin.weitz@gmail.com>

In a virtualized environment and given an appropriate interface the guest
can mark pages as unused while they are free (for the s390 implementation
see git commit 45e576b1c3d00206 "guest page hinting light"). For the host
the unused state is a property of the pte.

This patch adds the primitive 'pte_unused' and code to the host swap out
handler so that pages marked as unused by all mappers are not swapped out
but discarded instead, thus saving one IO for swap out and potentially
another one for swap in.

[ Martin Schwidefsky: patch reordering and simplification ]

Signed-off-by: Konstantin Weitz <konstantin.weitz@gmail.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 include/asm-generic/pgtable.h |   13 +++++++++++++
 mm/rmap.c                     |   10 ++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 2f47ade..ec540c5 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -193,6 +193,19 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
 }
 #endif
 
+#ifndef __HAVE_ARCH_PTE_UNUSED
+/*
+ * Some architectures provide facilities to virtualization guests
+ * so that they can flag allocated pages as unused. This allows the
+ * host to transparently reclaim unused pages. This function returns
+ * whether the pte's page is unused.
+ */
+static inline int pte_unused(pte_t pte)
+{
+	return 0;
+}
+#endif
+
 #ifndef __HAVE_ARCH_PMD_SAME
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
diff --git a/mm/rmap.c b/mm/rmap.c
index cd356df..2291f25 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1234,6 +1234,16 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		}
 		set_pte_at(mm, address, pte,
 			   swp_entry_to_pte(make_hwpoison_entry(page)));
+	} else if (pte_unused(pteval)) {
+		/*
+		 * The guest indicated that the page content is of no
+		 * interest anymore. Simply discard the pte, vmscan
+		 * will take care of the rest.
+		 */
+		if (PageAnon(page))
+			dec_mm_counter(mm, MM_ANONPAGES);
+		else
+			dec_mm_counter(mm, MM_FILEPAGES);
 	} else if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
