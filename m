Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F6618D0039
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 23:19:03 -0500 (EST)
Date: Thu, 24 Feb 2011 05:18:51 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110224041851.GF31195@random.random>
References: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
 <1298425922-23630-9-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298425922-23630-9-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

Incremental fix for your patch 8 (I doubt it was intentional).

===
Subject: thp: move THP_SPLIT from __split_huge_page_pmd to inner split_huge_page

From: Andrea Arcangeli <aarcange@redhat.com>

Provide more accurate stats by accounting every split_huge_page not only the
ones coming from pmd manipulations.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1393,6 +1393,7 @@ int split_huge_page(struct page *page)
 
 	BUG_ON(!PageSwapBacked(page));
 	__split_huge_page(page, anon_vma);
+	count_vm_event(THP_SPLIT);
 
 	BUG_ON(PageCompound(page));
 out_unlock:
@@ -2287,9 +2288,6 @@ void __split_huge_page_pmd(struct mm_str
 		spin_unlock(&mm->page_table_lock);
 		return;
 	}
-
-	count_vm_event(THP_SPLIT);
-
 	page = pmd_page(*pmd);
 	VM_BUG_ON(!page_count(page));
 	get_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
