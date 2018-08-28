Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE2816B46E1
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:39 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id g9-v6so1270313pgc.16
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si1160193plk.379.2018.08.28.07.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:38 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 02/10] mm: Remove vm_insert_mixed
Date: Tue, 28 Aug 2018 07:57:20 -0700
Message-Id: <20180828145728.11873-3-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

All callers are now converted to vmf_insert_mixed() so convert
vmf_insert_mixed() from being a compatibility wrapper into the real
function.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 include/linux/mm.h | 15 +--------------
 mm/memory.c        | 14 ++++++++++----
 2 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a61ebe8ad4ca..ce1b24376d72 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2482,7 +2482,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
 vm_fault_t vmf_insert_mixed_mkwrite(struct vm_area_struct *vma,
 		unsigned long addr, pfn_t pfn);
@@ -2501,19 +2501,6 @@ static inline vm_fault_t vmf_insert_page(struct vm_area_struct *vma,
 	return VM_FAULT_NOPAGE;
 }
 
-static inline vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma,
-				unsigned long addr, pfn_t pfn)
-{
-	int err = vm_insert_mixed(vma, addr, pfn);
-
-	if (err == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (err < 0 && err != -EBUSY)
-		return VM_FAULT_SIGBUS;
-
-	return VM_FAULT_NOPAGE;
-}
-
 static inline vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma,
 			unsigned long addr, unsigned long pfn)
 {
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..f0b123a94426 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1940,13 +1940,19 @@ static int __vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
 }
 
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn)
+vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
+		pfn_t pfn)
 {
-	return __vm_insert_mixed(vma, addr, pfn, false);
+	int err = __vm_insert_mixed(vma, addr, pfn, false);
 
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+
+	return VM_FAULT_NOPAGE;
 }
-EXPORT_SYMBOL(vm_insert_mixed);
+EXPORT_SYMBOL(vmf_insert_mixed);
 
 /*
  *  If the insertion of PTE failed because someone else already added a
-- 
2.18.0
