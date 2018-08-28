Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03A336B46E9
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:45 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3-v6so1276711pgc.8
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l63-v6si1182249plb.106.2018.08.28.07.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:44 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 09/10] mm: Convert __vm_insert_mixed to vm_fault_t
Date: Tue, 28 Aug 2018 07:57:27 -0700
Message-Id: <20180828145728.11873-10-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Both of its callers currently convert its errno return into a
vm_fault_t, so move the conversion into __vm_insert_mixed.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/memory.c | 36 +++++++++++++++---------------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 9e97926fee19..9fef202b4ea7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1915,20 +1915,21 @@ static bool vm_mixed_ok(struct vm_area_struct *vma, pfn_t pfn)
 	return false;
 }
 
-static int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn, bool mkwrite)
+static vm_fault_t __vm_insert_mixed(struct vm_area_struct *vma,
+		unsigned long addr, pfn_t pfn, bool mkwrite)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
+	int err;
 
 	BUG_ON(!vm_mixed_ok(vma, pfn));
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
-		return -EFAULT;
+		return VM_FAULT_SIGBUS;
 
 	track_pfn_insert(vma, &pgprot, pfn);
 
 	if (!pfn_modify_allowed(pfn_t_to_pfn(pfn), pgprot))
-		return -EACCES;
+		return VM_FAULT_SIGBUS;
 
 	/*
 	 * If we don't have pte special, then we have to use the pfn_valid()
@@ -1947,15 +1948,10 @@ static int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		 * result in pfn_t_has_page() == false.
 		 */
 		page = pfn_to_page(pfn_t_to_pfn(pfn));
-		return insert_page(vma, addr, page, pgprot);
+		err = insert_page(vma, addr, page, pgprot);
+	} else {
+		err = insert_pfn(vma, addr, pfn, pgprot, mkwrite);
 	}
-	return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
-}
-
-vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-		pfn_t pfn)
-{
-	int err = __vm_insert_mixed(vma, addr, pfn, false);
 
 	if (err == -ENOMEM)
 		return VM_FAULT_OOM;
@@ -1964,6 +1960,12 @@ vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 
 	return VM_FAULT_NOPAGE;
 }
+
+vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+		pfn_t pfn)
+{
+	return __vm_insert_mixed(vma, addr, pfn, false);
+}
 EXPORT_SYMBOL(vmf_insert_mixed);
 
 /*
@@ -1971,18 +1973,10 @@ EXPORT_SYMBOL(vmf_insert_mixed);
  *  different entry in the mean time, we treat that as success as we assume
  *  the same entry was actually inserted.
  */
-
 vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
 		unsigned long addr, pfn_t pfn)
 {
-	int err;
-
-	err =  __vm_insert_mixed(vma, addr, pfn, true);
-	if (err == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (err < 0 && err != -EBUSY)
-		return VM_FAULT_SIGBUS;
-	return VM_FAULT_NOPAGE;
+	return __vm_insert_mixed(vma, addr, pfn, true);
 }
 EXPORT_SYMBOL(vmf_insert_mixed_mkwrite);
 
-- 
2.18.0
