Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 931A76B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 13:31:27 -0500 (EST)
Received: by pfnn128 with SMTP id n128so109535056pfn.0
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:31:27 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id 85si18561889pfn.11.2015.12.14.10.31.26
        for <linux-mm@kvack.org>;
        Mon, 14 Dec 2015 10:31:26 -0800 (PST)
From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 2/6] mm: Add vm_insert_pfn_prot
Date: Mon, 14 Dec 2015 10:31:14 -0800
Message-Id: <946cc8ead6807b4026b88785156797e42e0d652a.1450117783.git.luto@kernel.org>
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
In-Reply-To: <cover.1450117783.git.luto@kernel.org>
References: <cover.1450117783.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>

The x86 vvar vma conntains pages with differing cacheability
flags.  x86 currently implements this by manually inserting all the ptes
using (io_)remap_pfn_range when the vma is set up.

x86 wants to move to using .fault with VM_FAULT_NOPAGE to set up the
mappings as needed.  The correct API to use to insert a pfn in
.fault is vm_insert_pfn, but vm_insert_pfn can't override the vma's
cache mode, and the HPET page in particular needs to be uncached
despite the fact that the rest of the VMA is cached.

Add vm_insert_pfn_prot to support varying cacheability within the
same non-COW VMA in a more sane manner.

x86 could alternatively use multiple VMAs, but that's messy, would
break CRIU, and would create unnecessary VMAs that would waste
memory.

Acked-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---

Notes:
    Changes from v1:
     - Improve the changelog (akpm)

 include/linux/mm.h |  2 ++
 mm/memory.c        | 25 +++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 00bad7793788..87ef1d7730ba 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2080,6 +2080,8 @@ int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
+int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
+			unsigned long pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
diff --git a/mm/memory.c b/mm/memory.c
index c387430f06c3..a29f0b90fc56 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1564,8 +1564,29 @@ out:
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
@@ -1587,7 +1608,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	return ret;
 }
-EXPORT_SYMBOL(vm_insert_pfn);
+EXPORT_SYMBOL(vm_insert_pfn_prot);
 
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn)
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
