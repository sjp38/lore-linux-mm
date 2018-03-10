Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA6576B000C
	for <linux-mm@kvack.org>; Sat, 10 Mar 2018 11:22:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v2so5055423pgv.23
        for <linux-mm@kvack.org>; Sat, 10 Mar 2018 08:22:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor204263pge.300.2018.03.10.08.22.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Mar 2018 08:22:20 -0800 (PST)
Date: Sat, 10 Mar 2018 21:53:52 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v2] mm: Change return type to vm_fault_t
Message-ID: <20180310162351.GA7422@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

The plan for these patches is to introduce the typedef, initially
just as documentation ("These functions should return a VM_FAULT_ status").
We'll trickle the patches to individual drivers/filesystems in through
the maintainers, as far as possible. Then we'll change the typedef
to an unsigned int and break the compilation of any unconverted
drivers/filesystems.

vmf_insert_page(), vmf_insert_mixed() and vmf_insert_pfn() are three
newly added functions. The various drivers/filesystems where return value
of fault(), huge_fault(), page_mkwrite() and pfn_mkwrite() get converted,
will need them. These functions will return correct VM_FAULT_ code based
on err value.

We've had bugs before where drivers returned -EFOO.  And we have this
silly inefficiency where vm_insert_xxx() return an errno which (afaict)
every driver then converts into a VM_FAULT code. In many cases drivers
failed to return correct VM_FAULT code value despite of vm_insert_xxx()
fails. We have indentified and clean up all those existing bugs and silly
inefficiencies in driver/filesystems by adding these three new inline
wrappers. As mentioned above, we will trickle those patches to individual
drivers/filesystems in through maintainers after these three wrapper
functions are merged.

Eventually we can convert vm_insert_xxx() into vmf_insert_xxx() and
remove these inline wrappers, but these are a good intermediate step.

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
