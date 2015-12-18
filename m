Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 78F606B0007
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:03:41 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p187so54389514wmp.1
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:03:41 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si10702754wmf.17.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 06/14] mm, debug: replace dump_flags() with the new printk formats
Date: Fri, 18 Dec 2015 10:03:18 +0100
Message-Id: <1450429406-7081-7-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

With the new printk format strings for flags, we can get rid of dump_flags()
in mm/debug.c.

This also fixes dump_vma() which used dump_flags() for printing vma flags.
However dump_flags() did a page-flags specific filtering of bits higher than
NR_PAGEFLAGS in order to remove the zone id part. For dump_vma() this resulted
in removing several VM_* flags from the symbolic translation.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
---
 mm/debug.c | 60 ++++++++++++++----------------------------------------------
 1 file changed, 14 insertions(+), 46 deletions(-)

diff --git a/mm/debug.c b/mm/debug.c
index 79621a5ce46f..5ea57bc49ef6 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -28,36 +28,6 @@ const struct trace_print_flags vmaflag_names[] = {
 	{0, NULL}
 };
 
-static void dump_flags(unsigned long flags,
-			const struct trace_print_flags *names, int count)
-{
-	const char *delim = "";
-	unsigned long mask;
-	int i;
-
-	pr_emerg("flags: %#lx(", flags);
-
-	/* remove zone id */
-	flags &= (1UL << NR_PAGEFLAGS) - 1;
-
-	for (i = 0; i < count && flags; i++) {
-
-		mask = names[i].mask;
-		if ((flags & mask) != mask)
-			continue;
-
-		flags &= ~mask;
-		pr_cont("%s%s", delim, names[i].name);
-		delim = "|";
-	}
-
-	/* check for left over flags */
-	if (flags)
-		pr_cont("%s%#lx", delim, flags);
-
-	pr_cont(")\n");
-}
-
 void dump_page_badflags(struct page *page, const char *reason,
 		unsigned long badflags)
 {
@@ -68,15 +38,15 @@ void dump_page_badflags(struct page *page, const char *reason,
 		pr_cont(" compound_mapcount: %d", compound_mapcount(page));
 	pr_cont("\n");
 	BUILD_BUG_ON(ARRAY_SIZE(pageflag_names) != __NR_PAGEFLAGS + 1);
-	dump_flags(page->flags, pageflag_names,
-					ARRAY_SIZE(pageflag_names) - 1);
+	pr_emerg("flags: %#lx(%pgp)\n", page->flags, &page->flags);
+
 	if (reason)
 		pr_alert("page dumped because: %s\n", reason);
-	if (page->flags & badflags) {
-		pr_alert("bad because of flags:\n");
-		dump_flags(page->flags & badflags, pageflag_names,
-					ARRAY_SIZE(pageflag_names) - 1);
-	}
+
+	badflags &= page->flags;
+	if (badflags)
+		pr_alert("bad because of flags: %#lx(%pgp)\n", badflags,
+								&badflags);
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
 		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
@@ -96,13 +66,14 @@ void dump_vma(const struct vm_area_struct *vma)
 	pr_emerg("vma %p start %p end %p\n"
 		"next %p prev %p mm %p\n"
 		"prot %lx anon_vma %p vm_ops %p\n"
-		"pgoff %lx file %p private_data %p\n",
+		"pgoff %lx file %p private_data %p\n"
+		"flags: %#lx(%pgv)\n",
 		vma, (void *)vma->vm_start, (void *)vma->vm_end, vma->vm_next,
 		vma->vm_prev, vma->vm_mm,
 		(unsigned long)pgprot_val(vma->vm_page_prot),
 		vma->anon_vma, vma->vm_ops, vma->vm_pgoff,
-		vma->vm_file, vma->vm_private_data);
-	dump_flags(vma->vm_flags, vmaflag_names, ARRAY_SIZE(vmaflag_names) - 1);
+		vma->vm_file, vma->vm_private_data,
+		vma->vm_flags, &vma->vm_flags);
 }
 EXPORT_SYMBOL(dump_vma);
 
@@ -136,7 +107,7 @@ void dump_mm(const struct mm_struct *mm)
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 		"tlb_flush_pending %d\n"
 #endif
-		"%s",	/* This is here to hold the comma */
+		"def_flags: %#lx(%pgv)\n",
 
 		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
 #ifdef CONFIG_MMU
@@ -170,11 +141,8 @@ void dump_mm(const struct mm_struct *mm)
 #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
 		mm->tlb_flush_pending,
 #endif
-		""		/* This is here to not have a comma! */
-		);
-
-		dump_flags(mm->def_flags, vmaflag_names,
-				ARRAY_SIZE(vmaflag_names) - 1);
+		mm->def_flags, &mm->def_flags
+	);
 }
 
 #endif		/* CONFIG_DEBUG_VM */
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
