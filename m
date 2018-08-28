Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68C496B46E8
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 10:57:44 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e15-v6so1084453pfi.5
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:57:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l14-v6si1198591pfd.250.2018.08.28.07.57.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 07:57:43 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 08/10] mm: Inline vm_insert_pfn_prot into caller
Date: Tue, 28 Aug 2018 07:57:26 -0700
Message-Id: <20180828145728.11873-9-willy@infradead.org>
In-Reply-To: <20180828145728.11873-1-willy@infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

vm_insert_pfn_prot() is only called from vmf_insert_pfn_prot(),
so inline it and convert some of the errnos into vm_fault codes earlier.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/memory.c | 55 +++++++++++++++++++++++------------------------------
 1 file changed, 24 insertions(+), 31 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d5ccbadd81c1..9e97926fee19 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1819,36 +1819,6 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	return retval;
 }
 
-static int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
-			unsigned long pfn, pgprot_t pgprot)
-{
-	int ret;
-	/*
-	 * Technically, architectures with pte_special can avoid all these
-	 * restrictions (same for remap_pfn_range).  However we would like
-	 * consistency in testing and feature parity among all, so we should
-	 * try to keep these invariants in place for everybody.
-	 */
-	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
-	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
-						(VM_PFNMAP|VM_MIXEDMAP));
-	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
-	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
-
-	if (addr < vma->vm_start || addr >= vma->vm_end)
-		return -EFAULT;
-
-	if (!pfn_modify_allowed(pfn, pgprot))
-		return -EACCES;
-
-	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
-
-	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
-			false);
-
-	return ret;
-}
-
 /**
  * vmf_insert_pfn_prot - insert single pfn into user vma with specified pgprot
  * @vma: user vma to map to
@@ -1870,7 +1840,30 @@ static int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot)
 {
-	int err = vm_insert_pfn_prot(vma, addr, pfn, pgprot);
+	int err;
+
+	/*
+	 * Technically, architectures with pte_special can avoid all these
+	 * restrictions (same for remap_pfn_range).  However we would like
+	 * consistency in testing and feature parity among all, so we should
+	 * try to keep these invariants in place for everybody.
+	 */
+	BUG_ON(!(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
+	BUG_ON((vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)) ==
+						(VM_PFNMAP|VM_MIXEDMAP));
+	BUG_ON((vma->vm_flags & VM_PFNMAP) && is_cow_mapping(vma->vm_flags));
+	BUG_ON((vma->vm_flags & VM_MIXEDMAP) && pfn_valid(pfn));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return VM_FAULT_SIGBUS;
+
+	if (!pfn_modify_allowed(pfn, pgprot))
+		return VM_FAULT_SIGBUS;
+
+	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
+
+	err = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
+			false);
 
 	if (err == -ENOMEM)
 		return VM_FAULT_OOM;
-- 
2.18.0
