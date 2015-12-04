Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 495806B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 10:17:07 -0500 (EST)
Received: by wmww144 with SMTP id w144so65911249wmw.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 07:17:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si6366808wmg.102.2015.12.04.07.17.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 04 Dec 2015 07:17:05 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 3/3] mm, debug: move bad flags printing to bad_page()
Date: Fri,  4 Dec 2015 16:16:35 +0100
Message-Id: <1449242195-16374-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1449242195-16374-1-git-send-email-vbabka@suse.cz>
References: <87io4hi06n.fsf@rasmusvillemoes.dk>
 <1449242195-16374-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Rasmus Villemoes <linux@rasmusvillemoes.dk>

Since bad_page() is the only user of the badflags parameter of
dump_page_badflags(), we can move the code to bad_page() and simplify a bit.

The dump_page_badflags() function is renamed to __dump_page() and can still be
called separately from dump_page() for temporary debug prints where page_owner
info is not desired.

The only user-visible change is that page->mem_cgroup is printed before the bad
flags.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
---
 include/linux/mmdebug.h |  3 +--
 mm/debug.c              | 14 +++-----------
 mm/page_alloc.c         | 10 +++++++---
 3 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 2c8286cf162e..9b0dc2161f7a 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -14,8 +14,7 @@ extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
 extern void dump_page(struct page *page, const char *reason);
-extern void dump_page_badflags(struct page *page, const char *reason,
-			       unsigned long badflags);
+extern void __dump_page(struct page *page, const char *reason);
 void dump_vma(const struct vm_area_struct *vma);
 void dump_mm(const struct mm_struct *mm);
 
diff --git a/mm/debug.c b/mm/debug.c
index c42bb4c13c2d..d36aa66e9779 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -109,25 +109,17 @@ const struct trace_print_flags gfpflag_names[] = {
 	{0, NULL},
 };
 
-void dump_page_badflags(struct page *page, const char *reason,
-		unsigned long badflags)
+void __dump_page(struct page *page, const char *reason)
 {
-	unsigned long printflags = page->flags;
-
 	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx\n",
 		  page, atomic_read(&page->_count), page_mapcount(page),
 		  page->mapping, page->index);
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
 
-	pr_emerg("flags: %#lx(%pgp)\n", printflags, &printflags);
+	pr_emerg("flags: %#lx(%pgp)\n", page->flags, &page->flags);
 
 	if (reason)
 		pr_alert("page dumped because: %s\n", reason);
-	if (page->flags & badflags) {
-		printflags = page->flags & badflags;
-		pr_alert("bad because of flags: %#lx(%pgp)\n", printflags,
-								&printflags);
-	}
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
 		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
@@ -136,7 +128,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 
 void dump_page(struct page *page, const char *reason)
 {
-	dump_page_badflags(page, reason, 0);
+	__dump_page(page, reason);
 	dump_page_owner(page);
 }
 EXPORT_SYMBOL(dump_page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bd94c7465dea..2388496a7c6c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -435,7 +435,7 @@ static void bad_page(struct page *page, const char *reason,
 			goto out;
 		}
 		if (nr_unshown) {
-			printk(KERN_ALERT
+			pr_alert(
 			      "BUG: Bad page state: %lu messages suppressed\n",
 				nr_unshown);
 			nr_unshown = 0;
@@ -445,9 +445,13 @@ static void bad_page(struct page *page, const char *reason,
 	if (nr_shown++ == 0)
 		resume = jiffies + 60 * HZ;
 
-	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
+	pr_alert("BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
-	dump_page_badflags(page, reason, bad_flags);
+	__dump_page(page, reason);
+	bad_flags &= page->flags;
+	if (bad_flags)
+		pr_alert("bad because of flags: %#lx(%pgp)\n",
+						bad_flags, &bad_flags);
 	dump_page_owner(page);
 
 	print_modules();
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
