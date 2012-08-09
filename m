Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2B85E6B0062
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:03:30 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v2 2/6] mm: make clear_huge_page tolerate non aligned address
Date: Thu,  9 Aug 2012 18:02:59 +0300
Message-Id: <1344524583-1096-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

hugetlb does not necessarily pass in an aligned address, so the
low level address computation is wrong.

This will fix architectures that actually use the address for flushing
the cleared address (very few, like xtensa/sparc/...?)

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5736170..b47199a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3987,16 +3987,17 @@ void clear_huge_page(struct page *page,
 		     unsigned long addr, unsigned int pages_per_huge_page)
 {
 	int i;
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
 
 	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
-		clear_gigantic_page(page, addr, pages_per_huge_page);
+		clear_gigantic_page(page, haddr, pages_per_huge_page);
 		return;
 	}
 
 	might_sleep();
 	for (i = 0; i < pages_per_huge_page; i++) {
 		cond_resched();
-		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		clear_user_highpage(page + i, haddr + i * PAGE_SIZE);
 	}
 }
 
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
