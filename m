Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 70A9C6B0258
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:36:46 -0500 (EST)
Received: by wmvv187 with SMTP id v187so207145987wmv.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:36:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l7si26329731wmf.85.2015.11.24.04.36.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 04:36:43 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/9] mm, debug: fix wrongly filtered flags in dump_vma()
Date: Tue, 24 Nov 2015 13:36:13 +0100
Message-Id: <1448368581-6923-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

The dump_vma() function uses dump_flags() for printing the flags as symbolic
names. That function however does a page-flags specific filtering of bits
higher than NR_PAGEFLAGS in order to remove the zone id part. For dump_vma()
this results in removing several VM_* flags from the symbolic translation.

Fix this by refactoring dump_flags() to dump_flag_names(), which only prints
the symbolic names in parentheses. Printing the raw flag value with a prefix,
and any filtering is left to the caller. In addition to fixing the bug, this
allows better flexibility, which will be useful to print gfp_flags by a later
patch.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/debug.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 8362765..d9718fc 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -46,17 +46,14 @@ static const struct trace_print_flags pageflag_names[] = {
 #endif
 };
 
-static void dump_flags(unsigned long flags,
+static void dump_flag_names(unsigned long flags,
 			const struct trace_print_flags *names, int count)
 {
 	const char *delim = "";
 	unsigned long mask;
 	int i;
 
-	pr_emerg("flags: %#lx(", flags);
-
-	/* remove zone id */
-	flags &= (1UL << NR_PAGEFLAGS) - 1;
+	pr_cont("(");
 
 	for (i = 0; i < count && flags; i++) {
 
@@ -79,6 +76,8 @@ static void dump_flags(unsigned long flags,
 void dump_page_badflags(struct page *page, const char *reason,
 		unsigned long badflags)
 {
+	unsigned long printflags = page->flags;
+
 	pr_emerg("page:%p count:%d mapcount:%d mapping:%p index:%#lx",
 		  page, atomic_read(&page->_count), page_mapcount(page),
 		  page->mapping, page->index);
@@ -86,13 +85,19 @@ void dump_page_badflags(struct page *page, const char *reason,
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS);
-	dump_flags(page->flags, pageflag_names, ARRAY_SIZE(pageflag_names));
+
+	pr_emerg("flags: %#lx", printflags);
+	/* remove zone id */
+	printflags &= (1UL << NR_PAGEFLAGS) - 1;
+	dump_flag_names(printflags, pageflag_names, ARRAY_SIZE(pageflag_names));
+
 	if (reason)
 		pr_alert("page dumped because: %s\n", reason);
 	if (page->flags & badflags) {
-		pr_alert("bad because of flags:\n");
-		dump_flags(page->flags & badflags,
-				pageflag_names, ARRAY_SIZE(pageflag_names));
+		printflags = page->flags & badflags;
+		pr_alert("bad because of flags: %#lx:", printflags);
+		dump_flag_names(printflags, pageflag_names,
+						ARRAY_SIZE(pageflag_names));
 	}
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
@@ -162,7 +167,9 @@ void dump_vma(const struct vm_area_struct *vma)
 		(unsigned long)pgprot_val(vma->vm_page_prot),
 		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
 		vma->vm_file, vma->vm_private_data);
-	dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));
+	pr_emerg("flags: %#lx", vma->vm_flags);
+	dump_flag_names(vma->vm_flags, vmaflags_names,
+						ARRAY_SIZE(vmaflags_names));
 }
 EXPORT_SYMBOL(dump_vma);
 
@@ -233,8 +240,9 @@ void dump_mm(const struct mm_struct *mm)
 		""		/* This is here to not have a comma! */
 		);
 
-		dump_flags(mm->def_flags, vmaflags_names,
-				ARRAY_SIZE(vmaflags_names));
+	pr_emerg("def_flags: %#lx(", mm->def_flags);
+	dump_flag_names(mm->def_flags, vmaflags_names,
+					ARRAY_SIZE(vmaflags_names));
 }
 
 #endif		/* CONFIG_DEBUG_VM */
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
