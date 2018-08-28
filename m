Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2276B46EC
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o16-v6so1266578pgv.21
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w135-v6si1276302pff.8.2018.08.28.07.57.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:44 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 10/10] mm: Convert insert_pfn to vm_fault_t
Date: Tue, 28 Aug 2018 07:57:28 -0700
Message-Id: <20180828145728.11873-11-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All callers convert its errno into a vm_fault_t, so convert it to
return a vm_fault_t directly.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/memory.c | 24 +++++-------------------
 1 file changed, 5 insertions(+), 19 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9fef202b4ea7..368b65390762 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1767,19 +1767,16 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
-static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
+static vm_fault_t insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int retval;
 	pte_t *pte, entry;
 	spinlock_t *ptl;
 
-	retval = -ENOMEM;
 	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
-		goto out;
-	retval = -EBUSY;
+		return VM_FAULT_OOM;
 	if (!pte_none(*pte)) {
 		if (mkwrite) {
 			/*
@@ -1812,11 +1809,9 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
-	retval = 0;
 out_unlock:
 	pte_unmap_unlock(pte, ptl);
-out:
-	return retval;
+	return VM_FAULT_NOPAGE;
 }
 
 /**
@@ -1840,8 +1835,6 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot)
 {
-	int err;
-
 	/*
 	 * Technically, architectures with pte_special can avoid all these
 	 * restrictions (same for remap_pfn_range).  However we would like
@@ -1862,15 +1855,8 @@ vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 
 	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
 
-	err = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
+	return insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
 			false);
-
-	if (err == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (err < 0 && err != -EBUSY)
-		return VM_FAULT_SIGBUS;
-
-	return VM_FAULT_NOPAGE;
 }
 EXPORT_SYMBOL(vmf_insert_pfn_prot);
 
@@ -1950,7 +1936,7 @@ static vm_fault_t __vm_insert_mixed(struct vm_area_struct *vma,
 		page = pfn_to_page(pfn_t_to_pfn(pfn));
 		err = insert_page(vma, addr, page, pgprot);
 	} else {
-		err = insert_pfn(vma, addr, pfn, pgprot, mkwrite);
+		return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
 	}
 
 	if (err == -ENOMEM)
-- 
2.18.0
