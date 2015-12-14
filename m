Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC096B0254
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:31:26 -0500 (EST)
Received: by padhk6 with SMTP id hk6so67660387pad.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:31:25 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id mj8si10027604pab.50.2015.12.14.10.31.25
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 10:31:25 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 1/6] mm: Add a vm_special_mapping .fault method
Date: Mon, 14 Dec 2015 10:31:13 -0800
Message-Id: <ef4d53a91e2691c2a96404441703cd7195f5d35b.1450117783.git.luto@kernel.org>
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
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

Looks-OK-to: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---

Notes:
    Chages from v1:
     - Fixed "struct vm_special_mapping" code layout (akpm)
     - s/is// (akpm)

 include/linux/mm_types.h | 22 +++++++++++++++++++---
 mm/mmap.c                | 13 +++++++++----
 2 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index f8d1492a114f..c88e48a3c155 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -568,10 +568,26 @@ static inline void clear_tlb_flush_pending(struct mm_struct *mm)
 }
 #endif
 
-struct vm_special_mapping
-{
-	const char *name;
+struct vm_fault;
+
+struct vm_special_mapping {
+	const char *name;	/* The name, e.g. "[vdso]". */
+
+	/*
+	 * If .fault is not provided, this points to a
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
