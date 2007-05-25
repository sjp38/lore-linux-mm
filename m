Date: Fri, 25 May 2007 16:57:02 +0100
Subject: [PATCH] Update page->order at an appropriate time when tracking PAGE_OWNER
Message-ID: <20070525155701.GA763@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alexn@telia.com, akpm@linux-foundation.org
Cc: haveblue@us.ibm.com, kamezawa.hiroyu@jp.fujitu.com, clameter@sgi.com, apw@shadowen.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

PAGE_OWNER tracks free pages by setting page->order to -1. However, it is set
during __free_pages() which is not the only free path as __pagevec_free()
and free_compound_page() do not go through __free_pages(). This leads to a
situation where free pages are visible in /proc/page_owner which is confusing
and might be interpreted as a memory leak.

This patch sets page->owner when PageBuddy is set. It also prints
a warning to the kernel log if a free page is found that does
not appear free to PAGE_OWNER. This should be considered a fix to
page-owner-tracking-leak-detector.patch.

This only applies to -mm as PAGE_OWNER is not in mainline.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---
 fs/proc/proc_misc.c |    8 ++++++++
 mm/page_alloc.c     |    6 +++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-005_migrate_nocontext/fs/proc/proc_misc.c linux-2.6.22-rc2-mm1-010_fix_pageowner/fs/proc/proc_misc.c
--- linux-2.6.22-rc2-mm1-005_migrate_nocontext/fs/proc/proc_misc.c	2007-05-25 10:24:24.000000000 +0100
+++ linux-2.6.22-rc2-mm1-010_fix_pageowner/fs/proc/proc_misc.c	2007-05-25 14:26:26.000000000 +0100
@@ -769,8 +769,16 @@ read_page_owner(struct file *file, char 
 		if (!pfn_valid(pfn))
 			continue;
 		page = pfn_to_page(pfn);
+
+		/* Catch situations where free pages have a bad ->order  */
+		if (page->order >= 0 && PageBuddy(page))
+			printk(KERN_WARNING
+				"PageOwner info inaccurate for PFN %lu\n",
+				pfn);
+
 		if (page->order >= 0)
 			break;
+
 		next_idx++;
 	}
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/page_alloc.c linux-2.6.22-rc2-mm1-010_fix_pageowner/mm/page_alloc.c
--- linux-2.6.22-rc2-mm1-005_migrate_nocontext/mm/page_alloc.c	2007-05-25 10:24:24.000000000 +0100
+++ linux-2.6.22-rc2-mm1-010_fix_pageowner/mm/page_alloc.c	2007-05-25 11:19:29.000000000 +0100
@@ -324,6 +324,9 @@ static inline void set_page_order(struct
 {
 	set_page_private(page, order);
 	__SetPageBuddy(page);
+#ifdef CONFIG_PAGE_OWNER
+		page->order = -1;
+#endif
 }
 
 static inline void rmv_page_order(struct page *page)
@@ -1745,9 +1748,6 @@ fastcall void __free_pages(struct page *
 			free_hot_page(page);
 		else
 			__free_pages_ok(page, order);
-#ifdef CONFIG_PAGE_OWNER
-		page->order = -1;
-#endif
 	}
 }
 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
