Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 743F36B0035
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 10:42:29 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/3] sparc: gup_pte_range() support THP based tail recounting
Date: Mon, 17 Oct 2011 16:41:56 +0200
Message-Id: <1318862517-7042-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1318862517-7042-1-git-send-email-aarcange@redhat.com>
References: <1316793432.9084.47.camel@twins>
 <1318862517-7042-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Up to this point the code assumed old refcounting for hugepages
(pre-thp). This updates the code directly to the thp mapcount tail
page refcounting.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/sparc/mm/gup.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index a986b5d..afcebac 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -12,6 +12,17 @@
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
 
+static inline void get_huge_page_tail(struct page *page)
+{
+	/*
+	 * __split_huge_page_refcount() cannot run
+	 * from under us.
+	 */
+	VM_BUG_ON(page_mapcount(page) < 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	atomic_inc(&page->_mapcount);
+}
+
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -56,6 +67,8 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 			put_page(head);
 			return 0;
 		}
+		if (head != page)
+			get_huge_page_tail(page);
 
 		pages[*nr] = page;
 		(*nr)++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
