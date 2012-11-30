Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A65046B0095
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 10:02:41 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] thp: fix anononymous page accounting in fallback path for COW of HZP
Date: Fri, 30 Nov 2012 17:03:40 +0200
Message-Id: <1354287821-5925-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <50B52E17.8020205@suse.cz>
 <1354287821-5925-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Don't forget to account newly allocated page in fallback path for
copy-on-write of huge zero page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 57f0024..9d6f521 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1164,6 +1164,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	pmd_populate(mm, pmd, pgtable);
 	spin_unlock(&mm->page_table_lock);
 	put_huge_zero_page();
+	inc_mm_counter(mm, MM_ANONPAGES);
 
 	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
