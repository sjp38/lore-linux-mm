Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 78FB06B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 16:54:41 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so150518986pac.2
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 13:54:41 -0700 (PDT)
Received: from COL004-OMC1S8.hotmail.com (col004-omc1s8.hotmail.com. [65.55.34.18])
        by mx.google.com with ESMTPS id dk5si25991912pbc.22.2015.08.31.13.54.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 31 Aug 2015 13:54:40 -0700 (PDT)
Message-ID: <COL130-W9593F65D7C12B5353FE079B96B0@phx.gbl>
From: Chen Gang <xili_gchen_5257@hotmail.com>
Subject: [PATCH] mm/mmap.c: Only call vma_unlock_anon_vm() when failure
 occurs in expand_upwards() and expand_downwards()
Date: Tue, 1 Sep 2015 04:54:40 +0800
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>
Cc: Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

When failure occurs=2C we need not call khugepaged_enter_vma_merge() or=0A=
validate_mm().=0A=
=0A=
Also simplify do_munmap(): declare 'error' 1 time instead of 2 times in=0A=
sub-blocks.=0A=
=0A=
Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>=0A=
---=0A=
=A0mm/mmap.c | 116 +++++++++++++++++++++++++++++++-------------------------=
------=0A=
=A01 file changed=2C 58 insertions(+)=2C 58 deletions(-)=0A=
=0A=
diff --git a/mm/mmap.c b/mm/mmap.c=0A=
index df6d5f0..d32199a 100644=0A=
--- a/mm/mmap.c=0A=
+++ b/mm/mmap.c=0A=
@@ -2182=2C10 +2182=2C9 @@ int expand_upwards(struct vm_area_struct *vma=2C=
 unsigned long address)=0A=
=A0	if (address < PAGE_ALIGN(address+4))=0A=
=A0		address =3D PAGE_ALIGN(address+4)=3B=0A=
=A0	else {=0A=
-		vma_unlock_anon_vma(vma)=3B=0A=
-		return -ENOMEM=3B=0A=
+		error =3D -ENOMEM=3B=0A=
+		goto err=3B=0A=
=A0	}=0A=
-	error =3D 0=3B=0A=
=A0=0A=
=A0	/* Somebody else might have raced and expanded it already */=0A=
=A0	if (address> vma->vm_end) {=0A=
@@ -2194=2C38 +2193=2C39 @@ int expand_upwards(struct vm_area_struct *vma=
=2C unsigned long address)=0A=
=A0		size =3D address - vma->vm_start=3B=0A=
=A0		grow =3D (address - vma->vm_end)>> PAGE_SHIFT=3B=0A=
=A0=0A=
-		error =3D -ENOMEM=3B=0A=
-		if (vma->vm_pgoff + (size>> PAGE_SHIFT)>=3D vma->vm_pgoff) {=0A=
-			error =3D acct_stack_growth(vma=2C size=2C grow)=3B=0A=
-			if (!error) {=0A=
-				/*=0A=
-				 * vma_gap_update() doesn't support concurrent=0A=
-				 * updates=2C but we only hold a shared mmap_sem=0A=
-				 * lock here=2C so we need to protect against=0A=
-				 * concurrent vma expansions.=0A=
-				 * vma_lock_anon_vma() doesn't help here=2C as=0A=
-				 * we don't guarantee that all growable vmas=0A=
-				 * in a mm share the same root anon vma.=0A=
-				 * So=2C we reuse mm->page_table_lock to guard=0A=
-				 * against concurrent vma expansions.=0A=
-				 */=0A=
-				spin_lock(&vma->vm_mm->page_table_lock)=3B=0A=
-				anon_vma_interval_tree_pre_update_vma(vma)=3B=0A=
-				vma->vm_end =3D address=3B=0A=
-				anon_vma_interval_tree_post_update_vma(vma)=3B=0A=
-				if (vma->vm_next)=0A=
-					vma_gap_update(vma->vm_next)=3B=0A=
-				else=0A=
-					vma->vm_mm->highest_vm_end =3D address=3B=0A=
-				spin_unlock(&vma->vm_mm->page_table_lock)=3B=0A=
-=0A=
-				perf_event_mmap(vma)=3B=0A=
-			}=0A=
+		if (vma->vm_pgoff + (size>> PAGE_SHIFT) < vma->vm_pgoff) {=0A=
+			error =3D -ENOMEM=3B=0A=
+			goto err=3B=0A=
=A0		}=0A=
+		error =3D acct_stack_growth(vma=2C size=2C grow)=3B=0A=
+		if (error)=0A=
+			goto err=3B=0A=
+		/*=0A=
+		 * vma_gap_update() doesn't support concurrent updates=2C but we=0A=
+		 * only hold a shared mmap_sem lock here=2C so we need to protect=0A=
+		 * against concurrent vma expansions. vma_lock_anon_vma()=0A=
+		 * doesn't help here=2C as we don't guarantee that all growable=0A=
+		 * vmas in a mm share the same root anon vma. So=2C we reuse mm->=0A=
+		 * page_table_lock to guard against concurrent vma expansions.=0A=
+		 */=0A=
+		spin_lock(&vma->vm_mm->page_table_lock)=3B=0A=
+		anon_vma_interval_tree_pre_update_vma(vma)=3B=0A=
+		vma->vm_end =3D address=3B=0A=
+		anon_vma_interval_tree_post_update_vma(vma)=3B=0A=
+		if (vma->vm_next)=0A=
+			vma_gap_update(vma->vm_next)=3B=0A=
+		else=0A=
+			vma->vm_mm->highest_vm_end =3D address=3B=0A=
+		spin_unlock(&vma->vm_mm->page_table_lock)=3B=0A=
+=0A=
+		perf_event_mmap(vma)=3B=0A=
=A0	}=0A=
=A0	vma_unlock_anon_vma(vma)=3B=0A=
=A0	khugepaged_enter_vma_merge(vma=2C vma->vm_flags)=3B=0A=
=A0	validate_mm(vma->vm_mm)=3B=0A=
+	return 0=3B=0A=
+err:=0A=
+	vma_unlock_anon_vma(vma)=3B=0A=
=A0	return error=3B=0A=
=A0}=0A=
=A0#endif /* CONFIG_STACK_GROWSUP || CONFIG_IA64 */=0A=
@@ -2265=2C36 +2265=2C37 @@ int expand_downwards(struct vm_area_struct *vma=
=2C=0A=
=A0		size =3D vma->vm_end - address=3B=0A=
=A0		grow =3D (vma->vm_start - address)>> PAGE_SHIFT=3B=0A=
=A0=0A=
-		error =3D -ENOMEM=3B=0A=
-		if (grow <=3D vma->vm_pgoff) {=0A=
-			error =3D acct_stack_growth(vma=2C size=2C grow)=3B=0A=
-			if (!error) {=0A=
-				/*=0A=
-				 * vma_gap_update() doesn't support concurrent=0A=
-				 * updates=2C but we only hold a shared mmap_sem=0A=
-				 * lock here=2C so we need to protect against=0A=
-				 * concurrent vma expansions.=0A=
-				 * vma_lock_anon_vma() doesn't help here=2C as=0A=
-				 * we don't guarantee that all growable vmas=0A=
-				 * in a mm share the same root anon vma.=0A=
-				 * So=2C we reuse mm->page_table_lock to guard=0A=
-				 * against concurrent vma expansions.=0A=
-				 */=0A=
-				spin_lock(&vma->vm_mm->page_table_lock)=3B=0A=
-				anon_vma_interval_tree_pre_update_vma(vma)=3B=0A=
-				vma->vm_start =3D address=3B=0A=
-				vma->vm_pgoff -=3D grow=3B=0A=
-				anon_vma_interval_tree_post_update_vma(vma)=3B=0A=
-				vma_gap_update(vma)=3B=0A=
-				spin_unlock(&vma->vm_mm->page_table_lock)=3B=0A=
-=0A=
-				perf_event_mmap(vma)=3B=0A=
-			}=0A=
+		if (grow> vma->vm_pgoff) {=0A=
+			error =3D -ENOMEM=3B=0A=
+			goto err=3B=0A=
=A0		}=0A=
+		error =3D acct_stack_growth(vma=2C size=2C grow)=3B=0A=
+		if (error)=0A=
+			goto err=3B=0A=
+		/*=0A=
+		 * vma_gap_update() doesn't support concurrent updates=2C but we=0A=
+		 * only hold a shared mmap_sem lock here=2C so we need to protect=0A=
+		 * against concurrent vma expansions. vma_lock_anon_vma()=0A=
+		 * doesn't help here=2C as we don't guarantee that all growable=0A=
+		 * vmas in a mm share the same root anon vma. So=2C we reuse mm->=0A=
+		 * page_table_lock to guard against concurrent vma expansions.=0A=
+		 */=0A=
+		spin_lock(&vma->vm_mm->page_table_lock)=3B=0A=
+		anon_vma_interval_tree_pre_update_vma(vma)=3B=0A=
+		vma->vm_start =3D address=3B=0A=
+		vma->vm_pgoff -=3D grow=3B=0A=
+		anon_vma_interval_tree_post_update_vma(vma)=3B=0A=
+		vma_gap_update(vma)=3B=0A=
+		spin_unlock(&vma->vm_mm->page_table_lock)=3B=0A=
+=0A=
+		perf_event_mmap(vma)=3B=0A=
=A0	}=0A=
=A0	vma_unlock_anon_vma(vma)=3B=0A=
=A0	khugepaged_enter_vma_merge(vma=2C vma->vm_flags)=3B=0A=
=A0	validate_mm(vma->vm_mm)=3B=0A=
+	return 0=3B=0A=
+err:=0A=
+	vma_unlock_anon_vma(vma)=3B=0A=
=A0	return error=3B=0A=
=A0}=0A=
=A0=0A=
@@ -2542=2C6 +2543=2C7 @@ int do_munmap(struct mm_struct *mm=2C unsigned lo=
ng start=2C size_t len)=0A=
=A0{=0A=
=A0	unsigned long end=3B=0A=
=A0	struct vm_area_struct *vma=2C *prev=2C *last=3B=0A=
+	int error=3B=0A=
=A0=0A=
=A0	if ((start & ~PAGE_MASK) || start> TASK_SIZE || len> TASK_SIZE-start)=
=0A=
=A0		return -EINVAL=3B=0A=
@@ -2570=2C8 +2572=2C6 @@ int do_munmap(struct mm_struct *mm=2C unsigned lo=
ng start=2C size_t len)=0A=
=A0	 * places tmp vma above=2C and higher split_vma places tmp vma below.=
=0A=
=A0	 */=0A=
=A0	if (start> vma->vm_start) {=0A=
-		int error=3B=0A=
-=0A=
=A0		/*=0A=
=A0		 * Make sure that map_count on return from munmap() will=0A=
=A0		 * not exceed its limit=3B but let map_count go just above=0A=
@@ -2589=2C7 +2589=2C7 @@ int do_munmap(struct mm_struct *mm=2C unsigned lo=
ng start=2C size_t len)=0A=
=A0	/* Does it split the last one? */=0A=
=A0	last =3D find_vma(mm=2C end)=3B=0A=
=A0	if (last && end> last->vm_start) {=0A=
-		int error =3D __split_vma(mm=2C last=2C end=2C 1)=3B=0A=
+		error =3D __split_vma(mm=2C last=2C end=2C 1)=3B=0A=
=A0		if (error)=0A=
=A0			return error=3B=0A=
=A0	}=0A=
--=A0=0A=
1.9.3=0A=
=0A=
 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
