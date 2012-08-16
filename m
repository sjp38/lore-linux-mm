Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 258BB6B0072
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 11:16:29 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v3 6/7] mm: make clear_huge_page cache clear only around the fault address
Date: Thu, 16 Aug 2012 18:15:53 +0300
Message-Id: <1345130154-9602-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1345130154-9602-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1345130154-9602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

Clearing a 2MB huge page will typically blow away several levels
of CPU caches. To avoid this only cache clear the 4K area
around the fault address and use a cache avoiding clears
for the rest of the 2MB area.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c |   34 +++++++++++++++++++++++++++++-----
 1 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index dfc179b..d4626b9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3969,18 +3969,34 @@ EXPORT_SYMBOL(might_fault);
 #endif
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
+
+#ifndef ARCH_HAS_USER_NOCACHE
+#define ARCH_HAS_USER_NOCACHE 0
+#endif
+
+#if ARCH_HAS_USER_NOCACHE == 0
+#define clear_user_highpage_nocache clear_user_highpage
+#endif
+
 static void clear_gigantic_page(struct page *page,
-				unsigned long addr,
-				unsigned int pages_per_huge_page)
+		unsigned long haddr, unsigned long fault_address,
+		unsigned int pages_per_huge_page)
 {
 	int i;
 	struct page *p = page;
+	unsigned long vaddr;
+	int target = (fault_address - haddr) >> PAGE_SHIFT;
 
 	might_sleep();
+	vaddr = haddr;
 	for (i = 0; i < pages_per_huge_page;
 	     i++, p = mem_map_next(p, page, i)) {
 		cond_resched();
-		clear_user_highpage(p, addr + i * PAGE_SIZE);
+		vaddr = haddr + i*PAGE_SIZE;
+		if (!ARCH_HAS_USER_NOCACHE  || i == target)
+			clear_user_highpage(p, vaddr);
+		else
+			clear_user_highpage_nocache(p, vaddr);
 	}
 }
 void clear_huge_page(struct page *page,
@@ -3988,16 +4004,24 @@ void clear_huge_page(struct page *page,
 		     unsigned int pages_per_huge_page)
 {
 	int i;
+	unsigned long vaddr;
+	int target = (fault_address - haddr) >> PAGE_SHIFT;
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
-		clear_gigantic_page(page, haddr, pages_per_huge_page);
+		clear_gigantic_page(page, haddr, fault_address,
+				pages_per_huge_page);
 		return;
 	}
 
 	might_sleep();
+	vaddr = haddr;
 	for (i = 0; i < pages_per_huge_page; i++) {
 		cond_resched();
-		clear_user_highpage(page + i, haddr + i * PAGE_SIZE);
+		vaddr = haddr + i*PAGE_SIZE;
+		if (!ARCH_HAS_USER_NOCACHE || i == target)
+			clear_user_highpage(page + i, vaddr);
+		else
+			clear_user_highpage_nocache(page + i, vaddr);
 	}
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
