Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 302EC90008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 20:42:36 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id p10so3998612pdj.19
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:35 -0700 (PDT)
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com. [209.85.220.44])
        by mx.google.com with ESMTPS id wv1si5141161pab.224.2014.10.29.17.42.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Oct 2014 17:42:35 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so4277737pad.31
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:42:34 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Subject: [RFC 4/6] mm: Add vm_insert_pfn_prot
Date: Wed, 29 Oct 2014 17:42:14 -0700
Message-Id: <844c23f06c7ce48c1cccb71af1c63c07ff9e65b6.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
In-Reply-To: <cover.1414629045.git.luto@amacapital.net>
References: <cover.1414629045.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>

The x86 vvar mapping contains pages with differing cacheability
flags.  This is currently only supported using (io_)remap_pfn_range,
but those functions can't be used inside page faults.

Add vm_insert_pfn_prot to support varying cacheability within the
same non-COW VMA in a more sane manner.

x86 needs this to avoid a CRIU-breaking and memory-wasting explosion
of VMAs when supporting userspace access to the HPET.

Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 25 +++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 66bc9a37ae17..8f1fa43cf615 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1960,6 +1960,8 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index adeac306610f..f80cea300729 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1598,8 +1598,29 @@ out:
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn)
 {
+	return vm_insert_pfn_prot(vma, addr, pfn, vma->vm_page_prot);
+}
+EXPORT_SYMBOL(vm_insert_pfn);
+
+/**
+ * vm_insert_pfn_prot - insert single pfn into user vma with specified pgprot
+ * @vma: user vma to map to
+ * @addr: target user address of this page
+ * @pfn: source kernel pfn
+ * @pgprot: pgprot flags for the inserted page
+ *
+ * This is exactly like vm_insert_pfn, except that it allows drivers to
+ * to override pgprot on a per-page basis.
+ *
+ * This only makes sense for IO mappings, and it makes no sense for
+ * cow mappings.  In general, using multiple vmas is preferable;
+ * vm_insert_pfn_prot should only be used if using multiple VMAs is
+ * impractical.
+ */
+int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pgprot_t pgprot)
+{
 	int ret;
-	pgprot_t pgprot = vma->vm_page_prot;
 	/*
 	 * Technically, architectures with pte_special can avoid all these
 	 * restrictions (same for remap_pfn_range).  However we would like
@@ -1621,7 +1642,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	return ret;
 }
-EXPORT_SYMBOL(vm_insert_pfn);
+EXPORT_SYMBOL(vm_insert_pfn_prot);
 
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn)
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
