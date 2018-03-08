Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF5E46B0003
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 08:03:54 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p9so2996774pfk.5
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 05:03:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w18-v6sor6380381pll.127.2018.03.08.05.03.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Mar 2018 05:03:53 -0800 (PST)
Date: Thu, 8 Mar 2018 18:35:23 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: Change return type to vm_fault_t
Message-ID: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

Use new return type vm_fault_t for fault handler
in struct vm_operations_struct.

vmf_insert_mixed(), vmf_insert_pfn() and vmf_insert_page()
are newly added inline wrapper functions.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 include/linux/mm.h       | 47 +++++++++++++++++++++++++++++++++++++++++++----
 include/linux/mm_types.h |  2 ++
 2 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..a4d8853 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -379,17 +379,18 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	int (*split)(struct vm_area_struct * area, unsigned long addr);
 	int (*mremap)(struct vm_area_struct * area);
-	int (*fault)(struct vm_fault *vmf);
-	int (*huge_fault)(struct vm_fault *vmf, enum page_entry_size pe_size);
+	vm_fault_t (*fault)(struct vm_fault *vmf);
+	vm_fault_t (*huge_fault)(struct vm_fault *vmf,
+			enum page_entry_size pe_size);
 	void (*map_pages)(struct vm_fault *vmf,
 			pgoff_t start_pgoff, pgoff_t end_pgoff);

 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
-	int (*page_mkwrite)(struct vm_fault *vmf);
+	vm_fault_t (*page_mkwrite)(struct vm_fault *vmf);

 	/* same as page_mkwrite when using VM_PFNMAP|VM_MIXEDMAP */
-	int (*pfn_mkwrite)(struct vm_fault *vmf);
+	vm_fault_t (*pfn_mkwrite)(struct vm_fault *vmf);

 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
@@ -2413,6 +2414,44 @@ int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);

+static inline vm_fault_t vmf_insert_page(struct vm_area_struct *vma,
+				unsigned long addr, struct page *page)
+{
+	int err = vm_insert_page(vma, addr, page);
+
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+
+	return VM_FAULT_NOPAGE;
+}
+
+static inline vm_fault_t vmf_insert_mixed(struct vm_area_struct *vma,
+				unsigned long addr, pfn_t pfn)
+{
+	int err = vm_insert_mixed(vma, addr, pfn);
+
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+
+	return VM_FAULT_NOPAGE;
+}
+
+static inline vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma,
+			unsigned long addr, unsigned long pfn)
+{
+	int err = vm_insert_pfn(vma, addr, pfn);
+
+	if (err == -ENOMEM)
+		return VM_FAULT_OOM;
+	if (err < 0 && err != -EBUSY)
+		return VM_FAULT_SIGBUS;
+
+	return VM_FAULT_NOPAGE;
+}

 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int foll_flags,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd1af6b..2161234 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -22,6 +22,8 @@
 #endif
 #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))

+typedef int vm_fault_t;
+
 struct address_space;
 struct mem_cgroup;
 struct hmm;
--
1.9.1
