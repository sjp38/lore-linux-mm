Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 827A76B0038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 18:26:15 -0400 (EDT)
Received: by oiew67 with SMTP id w67so90838568oie.2
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 15:26:15 -0700 (PDT)
Received: from BLU004-OMC1S16.hotmail.com (blu004-omc1s16.hotmail.com. [65.55.116.27])
        by mx.google.com with ESMTPS id v7si8747409oei.65.2015.08.18.15.26.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Aug 2015 15:26:14 -0700 (PDT)
Message-ID: <BLU436-SMTP37E3EE1A24E7A3EEEDBFA7B9780@phx.gbl>
Date: Wed, 19 Aug 2015 06:27:58 +0800
From: Chen Gang <xili_gchen_5257@hotmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: mmap: Simplify the failure return working flow
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, riel@redhat.com, Michal Hocko <mhocko@suse.cz>, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

__split_vma() doesn't need out_err label, neither need initializing err.

copy_vma() can return NULL directly when kmem_cache_alloc() fails.

Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
---
 mm/mmap.c | 39 +++++++++++++++++++--------------------
 1 file changed, 19 insertions(+), 20 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 8e0366e..35a4376 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2461,7 +2461,7 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	      unsigned long addr, int new_below)
 {
 	struct vm_area_struct *new;
-	int err = -ENOMEM;
+	int err;
 
 	if (is_vm_hugetlb_page(vma) && (addr &
 					~(huge_page_mask(hstate_vma(vma)))))
@@ -2469,7 +2469,7 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	new = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
 	if (!new)
-		goto out_err;
+		return -ENOMEM;
 
 	/* most fields are the same, copy all, and then fixup */
 	*new = *vma;
@@ -2517,7 +2517,6 @@ static int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	mpol_put(vma_policy(new));
  out_free_vma:
 	kmem_cache_free(vm_area_cachep, new);
- out_err:
 	return err;
 }
 
@@ -2958,23 +2957,23 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 		*need_rmap_locks = (new_vma->vm_pgoff <= vma->vm_pgoff);
 	} else {
 		new_vma = kmem_cache_alloc(vm_area_cachep, GFP_KERNEL);
-		if (new_vma) {
-			*new_vma = *vma;
-			new_vma->vm_start = addr;
-			new_vma->vm_end = addr + len;
-			new_vma->vm_pgoff = pgoff;
-			if (vma_dup_policy(vma, new_vma))
-				goto out_free_vma;
-			INIT_LIST_HEAD(&new_vma->anon_vma_chain);
-			if (anon_vma_clone(new_vma, vma))
-				goto out_free_mempol;
-			if (new_vma->vm_file)
-				get_file(new_vma->vm_file);
-			if (new_vma->vm_ops && new_vma->vm_ops->open)
-				new_vma->vm_ops->open(new_vma);
-			vma_link(mm, new_vma, prev, rb_link, rb_parent);
-			*need_rmap_locks = false;
-		}
+		if (!new_vma)
+			return NULL;
+		*new_vma = *vma;
+		new_vma->vm_start = addr;
+		new_vma->vm_end = addr + len;
+		new_vma->vm_pgoff = pgoff;
+		if (vma_dup_policy(vma, new_vma))
+			goto out_free_vma;
+		INIT_LIST_HEAD(&new_vma->anon_vma_chain);
+		if (anon_vma_clone(new_vma, vma))
+			goto out_free_mempol;
+		if (new_vma->vm_file)
+			get_file(new_vma->vm_file);
+		if (new_vma->vm_ops && new_vma->vm_ops->open)
+			new_vma->vm_ops->open(new_vma);
+		vma_link(mm, new_vma, prev, rb_link, rb_parent);
+		*need_rmap_locks = false;
 	}
 	return new_vma;
 
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
