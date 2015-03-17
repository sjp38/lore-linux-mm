Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D14E26B006C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 19:35:43 -0400 (EDT)
Received: by pdnc3 with SMTP id c3so23866514pdn.0
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 16:35:43 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id bq8si32193326pdb.214.2015.03.17.16.35.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 16:35:43 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so23819049pdb.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 16:35:42 -0700 (PDT)
From: Derek <denc716@gmail.com>
Subject: [PATCH 2/2] clean up goto just return ERR_PTR
Date: Tue, 17 Mar 2015 16:35:33 -0700
Message-Id: <1426635333-30257-2-git-send-email-denc716@gmail.com>
In-Reply-To: <1426635333-30257-1-git-send-email-denc716@gmail.com>
References: <1426635333-30257-1-git-send-email-denc716@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>
Cc: Derek Che <crquan@ymail.com>

As suggested by Kirill the "goto"s in vma_to_resize aren't
neccessary, just change them to explicit return.

Signed-off-by: Derek Che <crquan@ymail.com>
Suggested-by: "Kirill A. Shutemov" <kirill@shutemov.name>
Acked-by: David Rientjes <rientjes@google.com>

---
 mm/mremap.c | 25 ++++++++-----------------
 1 file changed, 8 insertions(+), 17 deletions(-)

diff --git a/mm/mremap.c b/mm/mremap.c
index 5da81cb..afa3ab7 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -339,25 +339,25 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 	struct vm_area_struct *vma = find_vma(mm, addr);
 
 	if (!vma || vma->vm_start > addr)
-		goto Efault;
+		return ERR_PTR(-EFAULT);
 
 	if (is_vm_hugetlb_page(vma))
-		goto Einval;
+		return ERR_PTR(-EINVAL);
 
 	/* We can't remap across vm area boundaries */
 	if (old_len > vma->vm_end - addr)
-		goto Efault;
+		return ERR_PTR(-EFAULT);
 
 	/* Need to be careful about a growing mapping */
 	if (new_len > old_len) {
 		unsigned long pgoff;
 
 		if (vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
-			goto Efault;
+			return ERR_PTR(-EFAULT);
 		pgoff = (addr - vma->vm_start) >> PAGE_SHIFT;
 		pgoff += vma->vm_pgoff;
 		if (pgoff + (new_len >> PAGE_SHIFT) < pgoff)
-			goto Einval;
+			return ERR_PTR(-EINVAL);
 	}
 
 	if (vma->vm_flags & VM_LOCKED) {
@@ -366,29 +366,20 @@ static struct vm_area_struct *vma_to_resize(unsigned long addr,
 		lock_limit = rlimit(RLIMIT_MEMLOCK);
 		locked += new_len - old_len;
 		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
-			goto Eagain;
+			return ERR_PTR(-EAGAIN);
 	}
 
 	if (!may_expand_vm(mm, (new_len - old_len) >> PAGE_SHIFT))
-		goto Enomem;
+		return ERR_PTR(-ENOMEM);
 
 	if (vma->vm_flags & VM_ACCOUNT) {
 		unsigned long charged = (new_len - old_len) >> PAGE_SHIFT;
 		if (security_vm_enough_memory_mm(mm, charged))
-			goto Enomem;
+			return ERR_PTR(-ENOMEM);
 		*p = charged;
 	}
 
 	return vma;
-
-Efault:	/* very odd choice for most of the cases, but... */
-	return ERR_PTR(-EFAULT);
-Einval:
-	return ERR_PTR(-EINVAL);
-Enomem:
-	return ERR_PTR(-ENOMEM);
-Eagain:
-	return ERR_PTR(-EAGAIN);
 }
 
 static unsigned long mremap_to(unsigned long addr, unsigned long old_len,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
