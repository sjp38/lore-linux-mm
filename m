Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 01CC56B0253
	for <linux-mm@kvack.org>; Sun, 11 Oct 2015 21:51:34 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so81388507pab.2
        for <linux-mm@kvack.org>; Sun, 11 Oct 2015 18:51:33 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id ks7si22084803pab.9.2015.10.11.18.51.32
        for <linux-mm@kvack.org>;
        Sun, 11 Oct 2015 18:51:33 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] thp: use is_zero_pfn after pte_present check
Date: Mon, 12 Oct 2015 10:54:16 +0900
Message-Id: <1444614856-18543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Use is_zero_pfn on pteval only after pte_present check on pteval
(It might be better idea to introduce is_zero_pte where checks
pte_present first). Otherwise, it could work with swap or
migration entry and if pte_pfn's result is equal to zero_pfn
by chance, we lose user's data in __collapse_huge_page_copy.
So if you're luck, the application is segfaulted and finally you
could see below message when the application is exit.

BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3

Signed-off-by: Minchan Kim <minchan@kernel.org>
---

I found this bug with MADV_FREE hard test. Sometime, I saw
"Bad rss-counter" message with MM_SWAPENTS but it's really
rare, once a day if I was luck or once in five days if I was
unlucky so I am doing test still and just pass a few days but
I hope it will fix the issue.

 mm/huge_memory.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8db9df2..349590aa4533 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2665,15 +2665,25 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
 	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
-		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
+		if (pte_none(pteval)) {
 			if (!userfaultfd_armed(vma) &&
 			    ++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
 			else
 				goto out_unmap;
 		}
+
 		if (!pte_present(pteval))
 			goto out_unmap;
+
+		if (is_zero_pfn(pte_pfn(pteval))) {
+			if (!userfaultfd_armed(vma) &&
+			    ++none_or_zero <= khugepaged_max_ptes_none)
+				continue;
+			else
+				goto out_unmap;
+		}
+
 		if (pte_write(pteval))
 			writable = true;
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
