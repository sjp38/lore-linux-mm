Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 55EC36B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 22:35:53 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so5604402pad.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 19:35:53 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id k13si1227383pbq.238.2015.10.12.19.35.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 12 Oct 2015 19:35:52 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2] thp: use is_zero_pfn only after pte_present check
Date: Tue, 13 Oct 2015 11:38:38 +0900
Message-Id: <1444703918-16597-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, stable@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Use is_zero_pfn on pteval only after pte_present check on pteval
(It might be better idea to introduce is_zero_pte where checks
pte_present first). Otherwise, it could work with swap or
migration entry and if pte_pfn's result is equal to zero_pfn
by chance, we lose user's data in __collapse_huge_page_copy.
So if you're luck, the application is segfaulted and finally you
could see below message when the application is exit.

BUG: Bad rss-counter state mm:ffff88007f099300 idx:2 val:3

Cc: <stable@vger.kernel.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
Hello Greg,

This patch should go to -stable but when you will apply it
after merging of linus tree, it will be surely conflicted due
to userfaultfd part.

I want to know how to handle it.

Thanks.

 mm/huge_memory.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4b06b8db9df2..bbac913f96bc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2206,7 +2206,8 @@ static int __collapse_huge_page_isolate(struct vm_area_struct *vma,
 	for (_pte = pte; _pte < pte+HPAGE_PMD_NR;
 	     _pte++, address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
-		if (pte_none(pteval) || is_zero_pfn(pte_pfn(pteval))) {
+		if (pte_none(pteval) || (pte_present(pteval) &&
+				is_zero_pfn(pte_pfn(pteval)))) {
 			if (!userfaultfd_armed(vma) &&
 			    ++none_or_zero <= khugepaged_max_ptes_none)
 				continue;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
