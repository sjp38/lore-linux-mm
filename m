Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 763B66B0256
	for <linux-mm@kvack.org>; Thu, 10 Dec 2015 22:21:53 -0500 (EST)
Received: by pfv76 with SMTP id 76so5866315pfv.2
        for <linux-mm@kvack.org>; Thu, 10 Dec 2015 19:21:53 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id f79si159752pfj.38.2015.12.10.19.21.52
        for <linux-mm@kvack.org>;
        Thu, 10 Dec 2015 19:21:52 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH 1/6] mm: Add a vm_special_mapping .fault method
Date: Thu, 10 Dec 2015 19:21:42 -0800
Message-Id: <4e911d2752d3b9e52d7496e46b389fc630cdc3a8.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
In-Reply-To: <cover.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>

From: Andy Lutomirski <luto@amacapital.net>

Requiring special mappings to give a list of struct pages is
inflexible: it prevents sane use of IO memory in a special mapping,
it's inefficient (it requires arch code to initialize a list of
struct pages, and it requires the mm core to walk the entire list
just to figure out how long it is), and it prevents arch code from
doing anything fancy when a special mapping fault occurs.

Add a .fault method as an alternative to filling in a .pages array.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 include/linux/mm_types.h | 19 ++++++++++++++++++-
 mm/mmap.c                | 13 +++++++++----
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f8d1492a114f..3d315d373daf 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -568,10 +568,27 @@ static inline void clear_tlb_flush_pending(struct mm_struct *mm)
 }
 #endif
 
+struct vm_fault;
+
 struct vm_special_mapping
 {
-	const char *name;
+	const char *name;	/* The name, e.g. "[vdso]". */
+
+	/*
+	 * If .fault is not provided, this is points to a
+	 * NULL-terminated array of pages that back the special mapping.
+	 *
+	 * This must not be NULL unless .fault is provided.
+	 */
 	struct page **pages;
+
+	/*
+	 * If non-NULL, then this is called to resolve page faults
+	 * on the special mapping.  If used, .pages is not checked.
+	 */
+	int (*fault)(const struct vm_special_mapping *sm,
+		     struct vm_area_struct *vma,
+		     struct vm_fault *vmf);
 };
 
 enum tlb_flush_reason {
diff --git a/mm/mmap.c b/mm/mmap.c
index 2ce04a649f6b..f717453b1a57 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3030,11 +3030,16 @@ static int special_mapping_fault(struct vm_area_struct *vma,
 	pgoff_t pgoff;
 	struct page **pages;
 
-	if (vma->vm_ops == &legacy_special_mapping_vmops)
+	if (vma->vm_ops == &legacy_special_mapping_vmops) {
 		pages = vma->vm_private_data;
-	else
-		pages = ((struct vm_special_mapping *)vma->vm_private_data)->
-			pages;
+	} else {
+		struct vm_special_mapping *sm = vma->vm_private_data;
+
+		if (sm->fault)
+			return sm->fault(sm, vma, vmf);
+
+		pages = sm->pages;
+	}
 
 	for (pgoff = vmf->pgoff; pgoff && *pages; ++pages)
 		pgoff--;
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
