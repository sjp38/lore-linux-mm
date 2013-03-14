Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 309186B0088
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:31 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 23/30] thp: prepare zap_huge_pmd() to uncharge file pages
Date: Thu, 14 Mar 2013 19:50:28 +0200
Message-Id: <1363283435-7666-24-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Uncharge pages from correct counter.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a23da8b..34e0385 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1368,10 +1368,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			spin_unlock(&tlb->mm->page_table_lock);
 			put_huge_zero_page();
 		} else {
+			int counter;
 			page = pmd_page(orig_pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			counter = PageAnon(page) ? MM_ANONPAGES : MM_FILEPAGES;
+			add_mm_counter(tlb->mm, counter, -HPAGE_PMD_NR);
 			VM_BUG_ON(!PageHead(page));
 			tlb->mm->nr_ptes--;
 			spin_unlock(&tlb->mm->page_table_lock);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
