Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 30BED90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 20:42:33 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so4269849pab.20
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:32 -0700 (PDT)
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com. [209.85.192.182])
        by mx.google.com with ESMTPS id cq3si5149279pbb.193.2014.10.29.17.42.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 17:42:32 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so4038591pdb.13
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:32 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 3/6] mm: Add a vm_special_mapping .fault method
Date: Wed, 29 Oct 2014 17:42:13 -0700
Message-Id: <c4e198aff7953d25290a8f70910da235f1fd2464.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

Requiring special mappings to give a list of struct pages is
inflexible: it prevents sane use of IO memory in a special mapping,
it's inefficient (it requires arch code to initialize a list of
struct pages, and it requires the mm core to walk the entire list
just to figure out how long it is), and it prevents arch code from
doing anything fancy when a special mapping fault occurs.

Add a .fault method as an alternative to filling in a .pages array.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 include/linux/mm_types.h | 18 +++++++++++++++++-
 mm/mmap.c                | 14 ++++++++++----
 2 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index ad6652fe3671..cc96c63b1002 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -511,12 +511,28 @@ static inline void clear_tlb_flush_pending(struct mm_struct *mm)
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
 
 	/*
+	 * If non-NULL, then this is called to resolve page faults
+	 * on the special mapping.  If used, .pages is not checked.
+	 */
+	int (*fault)(struct vm_special_mapping *sm, struct vm_area_struct *vma,
+		     struct vm_fault *vmf);
+
+	/*
 	 * If non-NULL, this is called when installed and when mremap
 	 * moves the first page of the mapping.
 	 */
diff --git a/mm/mmap.c b/mm/mmap.c
index 8c398b9ee225..d27572e3e4f4 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2950,11 +2950,17 @@ static int special_mapping_fault(struct vm_area_struct *vma,
 	 */
 	pgoff = vmf->pgoff - vma->vm_pgoff;
 
-	if (vma->vm_ops == &legacy_special_mapping_vmops)
+	if (vma->vm_ops == &legacy_special_mapping_vmops) {
 		pages = vma->vm_private_data;
-	else
-		pages = ((struct vm_special_mapping *)vma->vm_private_data)->
-			pages;
+	} else {
+		struct vm_special_mapping *sm = vma->vm_private_data;
+		if (sm->fault) {
+			vmf->pgoff = pgoff;
+			return sm->fault(sm, vma, vmf);
+		} else {
+			pages = sm->pages;
+		}
+	}
 
 	for (; pgoff && *pages; ++pages)
 		pgoff--;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
