Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 03B106B0071
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 10:06:17 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so57345751wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:06:16 -0700 (PDT)
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id ei3si12041632wjd.20.2015.04.07.07.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 07:06:15 -0700 (PDT)
Received: by wgbdm7 with SMTP id dm7so57344761wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:06:14 -0700 (PDT)
Message-ID: <5523E453.8080101@plexistor.com>
Date: Tue, 07 Apr 2015 17:06:11 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 1/3 v7] mm(v4.1): New pfn_mkwrite same as page_mkwrite for
 VM_PFNMAP
References: <55239645.9000507@plexistor.com> <552397E6.5030506@plexistor.com>
In-Reply-To: <552397E6.5030506@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>
Cc: Stable Tree <stable@vger.kernel.org>


[v5]
Changed comments about pte_same check after the call to
pfn_mkwrite and the return value.

[v4]
Kirill's comments about splitting out a new wp_pfn_shared().
Add Documentation/filesystems/Locking text about pfn_mkwrite.

[v3]
Kirill's comments about use of linear_page_index()

[v2]
Based on linux-next/akpm [3dc4623]. For v4.1 merge window
Incorporated comments from Andrew And Kirill

[v1]
This will allow FS that uses VM_PFNMAP | VM_MIXEDMAP (no page structs)
to get notified when access is a write to a read-only PFN.

This can happen if we mmap() a file then first mmap-read from it
to page-in a read-only PFN, than we mmap-write to the same page.

We need this functionality to fix a DAX bug, where in the scenario
above we fail to set ctime/mtime though we modified the file.
An xfstest is attached to this patchset that shows the failure
and the fix. (A DAX patch will follow)

This functionality is extra important for us, because upon
dirtying of a pmem page we also want to RDMA the page to a
remote cluster node.

We define a new pfn_mkwrite and do not reuse page_mkwrite because
  1 - The name ;-)
  2 - But mainly because it would take a very long and tedious
      audit of all page_mkwrite functions of VM_MIXEDMAP/VM_PFNMAP
      users. To make sure they do not now CRASH. For example current
      DAX code (which this is for) would crash.
      If we would want to reuse page_mkwrite, We will need to first
      patch all users, so to not-crash-on-no-page. Then enable this
      patch. But even if I did that I would not sleep so well at night.
      Adding a new vector is the safest thing to do, and is not that
      expensive. an extra pointer at a static function vector per driver.
      Also the new vector is better for performance, because else we
      Will call all current Kernel vectors, so to:
	check-ha-no-page-do-nothing and return.

No need to call it from do_shared_fault because do_wp_page is called to
change pte permissions anyway.

CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
CC: Jan Kara <jack@suse.cz>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Hugh Dickins <hughd@google.com>
CC: Mel Gorman <mgorman@suse.de>
CC: linux-mm@kvack.org

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 Documentation/filesystems/Locking |  8 ++++++++
 include/linux/mm.h                |  3 +++
 mm/memory.c                       | 43 +++++++++++++++++++++++++++++++++++----
 3 files changed, 50 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index f91926f..8bb8a7e 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -525,6 +525,7 @@ prototypes:
 	void (*close)(struct vm_area_struct*);
 	int (*fault)(struct vm_area_struct*, struct vm_fault *);
 	int (*page_mkwrite)(struct vm_area_struct *, struct vm_fault *);
+	int (*pfn_mkwrite)(struct vm_area_struct *, struct vm_fault *);
 	int (*access)(struct vm_area_struct *, unsigned long, void*, int, int);
 
 locking rules:
@@ -534,6 +535,7 @@ close:		yes
 fault:		yes		can return with page locked
 map_pages:	yes
 page_mkwrite:	yes		can return with page locked
+pfn_mkwrite:	yes
 access:		yes
 
 	->fault() is called when a previously not present pte is about
@@ -560,6 +562,12 @@ the page has been truncated, the filesystem should not look up a new page
 like the ->fault() handler, but simply return with VM_FAULT_NOPAGE, which
 will cause the VM to retry the fault.
 
+	->pfn_mkwrite() is the same as page_mkwrite but when the pte is
+VM_PFNMAP or VM_MIXEDMAP with a page-less entry. Expected return is
+VM_FAULT_NOPAGE. Or one of the VM_FAULT_ERROR types. The default behavior
+after this call is to make the pte read-write, unless pfn_mkwrite returns
+an error.
+
 	->access() is called when get_user_pages() fails in
 access_process_vm(), typically used to debug a process through
 /proc/pid/mem or ptrace.  This function is needed only for
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d584b95..70c47f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -251,6 +251,9 @@ struct vm_operations_struct {
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
+	/* same as page_mkwrite when using VM_PFNMAP|VM_MIXEDMAP */
+	int (*pfn_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
+
 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
 	 */
diff --git a/mm/memory.c b/mm/memory.c
index 59f6268..d839cbc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2181,6 +2181,42 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+/*
+ * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
+ * mapping
+ */
+static int wp_pfn_shared(struct mm_struct *mm,
+			struct vm_area_struct *vma, unsigned long address,
+			pte_t *page_table, spinlock_t *ptl, pte_t orig_pte,
+			pmd_t *pmd)
+{
+	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
+		struct vm_fault vmf = {
+			.page = NULL,
+			.pgoff = linear_page_index(vma, address),
+			.virtual_address = (void __user *)(address & PAGE_MASK),
+			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
+		};
+		int ret;
+
+		pte_unmap_unlock(page_table, ptl);
+		ret = vma->vm_ops->pfn_mkwrite(vma, &vmf);
+		if (ret & VM_FAULT_ERROR)
+			return ret;
+		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		/*
+		 * We might have raced with another page fault while we
+		 * released the pte_offset_map_lock.
+		 */
+		if (!pte_same(*page_table, orig_pte)) {
+			pte_unmap_unlock(page_table, ptl);
+			return 0;
+		}
+	}
+	return wp_page_reuse(mm, vma, address, page_table, ptl, orig_pte,
+			     NULL, 0, 0);
+}
+
 static int wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 			  unsigned long address, pte_t *page_table,
 			  pmd_t *pmd, spinlock_t *ptl, pte_t orig_pte,
@@ -2259,13 +2295,12 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * VM_PFNMAP VMA.
 		 *
 		 * We should not cow pages in a shared writeable mapping.
-		 * Just mark the pages writable as we can't do any dirty
-		 * accounting on raw pfn maps.
+		 * Just mark the pages writable and/or call ops->pfn_mkwrite.
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 				     (VM_WRITE|VM_SHARED))
-			return wp_page_reuse(mm, vma, address, page_table, ptl,
-					     orig_pte, old_page, 0, 0);
+			return wp_pfn_shared(mm, vma, address, page_table, ptl,
+					     orig_pte, pmd);
 
 		pte_unmap_unlock(page_table, ptl);
 		return wp_page_copy(mm, vma, address, page_table, pmd,
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
