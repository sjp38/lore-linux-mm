Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id D44106B006E
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:03:31 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v2 3/6] THP: Pass real, not rounded, address to clear_huge_page
Date: Thu,  9 Aug 2012 18:03:00 +0300
Message-Id: <1344524583-1096-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 70737ec..ecd93f8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -633,7 +633,8 @@ static inline pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
-					unsigned long haddr, pmd_t *pmd,
+					unsigned long haddr,
+					unsigned long address, pmd_t *pmd,
 					struct page *page)
 {
 	pgtable_t pgtable;
@@ -643,7 +644,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	if (unlikely(!pgtable))
 		return VM_FAULT_OOM;
 
-	clear_huge_page(page, haddr, HPAGE_PMD_NR);
+	clear_huge_page(page, address, HPAGE_PMD_NR);
 	__SetPageUptodate(page);
 
 	spin_lock(&mm->page_table_lock);
@@ -720,8 +721,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			put_page(page);
 			goto out;
 		}
-		if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd,
-							  page))) {
+		if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr,
+						address, pmd, page))) {
 			mem_cgroup_uncharge_page(page);
 			put_page(page);
 			goto out;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
