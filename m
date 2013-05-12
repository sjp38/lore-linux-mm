Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 560446B0074
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:39 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 28/39] thp: prepare zap_huge_pmd() to uncharge file pages
Date: Sun, 12 May 2013 04:23:25 +0300
Message-Id: <1368321816-17719-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Uncharge pages from correct counter.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7ad458d..a88f9b2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1385,10 +1385,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			spin_unlock(&tlb->mm->page_table_lock);
 			put_huge_zero_page();
 		} else {
+			int member;
 			page = pmd_page(orig_pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
+			member = PageAnon(page) ? MM_ANONPAGES : MM_FILEPAGES;
+			add_mm_counter(tlb->mm, member, -HPAGE_PMD_NR);
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
