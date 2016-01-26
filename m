Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC856B0009
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:51:33 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id b14so128660858wmb.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:51:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v18si1597685wju.157.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 14/14] mm, debug: move bad flags printing to bad_page()
Date: Tue, 26 Jan 2016 13:45:53 +0100
Message-Id: <1453812353-26744-15-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

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
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmdebug.h |  3 +--
 mm/debug.c              | 10 +++-------
 mm/page_alloc.c         | 10 +++++++---
 3 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 93fff2971fd4..3fb9bc65d61d 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -15,8 +15,7 @@ extern const struct trace_print_flags vmaflag_names[];
 extern const struct trace_print_flags gfpflag_names[];
 
 extern void dump_page(struct page *page, const char *reason);
-extern void dump_page_badflags(struct page *page, const char *reason,
-			       unsigned long badflags);
+extern void __dump_page(struct page *page, const char *reason);
 void dump_vma(const struct vm_area_struct *vma);
 void dump_mm(const struct mm_struct *mm);
 
diff --git a/mm/debug.c b/mm/debug.c
index 61b1f1bb328e..df7247b0b532 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -40,8 +40,7 @@ const struct trace_print_flags vmaflag_names[] = {
 	{0, NULL}
 };
 
-void dump_page_badflags(struct page *page, const char *reason,
-		unsigned long badflags)
+void __dump_page(struct page *page, const char *reason)
 {
 	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
 		  page, atomic_read(&page->_count), page_mapcount(page),
@@ -50,15 +49,12 @@ void dump_page_badflags(struct page *page, const char *reason,
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
+
 	pr_emerg("flags: %#lx(%pGp)\n", page->flags, &page->flags);
 
 	if (reason)
 		pr_alert("page dumped because: %s\n", reason);
 
-	badflags &= page->flags;
-	if (badflags)
-		pr_alert("bad because of flags: %#lx(%pGp)\n", badflags,
-								&badflags);
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
 		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
@@ -67,7 +63,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 
 void dump_page(struct page *page, const char *reason)
 {
-	dump_page_badflags(page, reason, 0);
+	__dump_page(page, reason);
 	dump_page_owner(page);
 }
 EXPORT_SYMBOL(dump_page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e8b3cb78b5cf..35f47f830b52 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -430,7 +430,7 @@ static void bad_page(struct page *page, const char *reason,
 			goto out;
 		}
 		if (nr_unshown) {
-			printk(KERN_ALERT
+			pr_alert(
 			      "BUG: Bad page state: %lu messages suppressed\n",
 				nr_unshown);
 			nr_unshown = 0;
@@ -440,9 +440,13 @@ static void bad_page(struct page *page, const char *reason,
 	if (nr_shown++ == 0)
 		resume = jiffies + 60 * HZ;
 
-	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
+	pr_alert("BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
-	dump_page_badflags(page, reason, bad_flags);
+	__dump_page(page, reason);
+	bad_flags &= page->flags;
+	if (bad_flags)
+		pr_alert("bad because of flags: %#lx(%pGp)\n",
+						bad_flags, &bad_flags);
 	dump_page_owner(page);
 
 	print_modules();
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
