Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 11BAC6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 09:38:43 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so39218333wib.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:38:42 -0700 (PDT)
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id r9si4372205wjz.175.2015.03.25.06.38.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 06:38:41 -0700 (PDT)
Received: by wgra20 with SMTP id a20so27747852wgr.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 06:38:40 -0700 (PDT)
Message-ID: <5512BA5D.8070609@plexistor.com>
Date: Wed, 25 Mar 2015 15:38:37 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm: New pfn_mkwrite same as page_mkwrite for VM_PFNMAP
References: <5512B961.8070409@plexistor.com>
In-Reply-To: <5512B961.8070409@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>

From: Yigal Korman <yigal@plexistor.com>

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

CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
CC: Jan Kara <jack@suse.cz>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Hugh Dickins <hughd@google.com>
CC: Mel Gorman <mgorman@suse.de>
CC: linux-mm@kvack.org

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 28 +++++++++++++++++++++++++++-
 2 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..1cd820c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -250,6 +250,8 @@ struct vm_operations_struct {
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
 	int (*page_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
+	/* same as page_mkwrite when using VM_PFNMAP|VM_MIXEDMAP */
+	int (*pfn_mkwrite)(struct vm_area_struct *vma, struct vm_fault *vmf);
 
 	/* called by access_process_vm when get_user_pages() fails, typically
 	 * for use by special VMAs that can switch between memory and hardware
diff --git a/mm/memory.c b/mm/memory.c
index 8068893..8d640d1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1982,6 +1982,23 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	return ret;
 }
 
+static int do_pfn_mkwrite(struct vm_area_struct *vma, unsigned long address)
+{
+	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
+		struct vm_fault vmf = {
+			.page = 0,
+			.pgoff = (((address & PAGE_MASK) - vma->vm_start)
+						>> PAGE_SHIFT) + vma->vm_pgoff,
+			.virtual_address = (void __user *)(address & PAGE_MASK),
+			.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
+		};
+
+		return vma->vm_ops->pfn_mkwrite(vma, &vmf);
+	}
+
+	return 0;
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2025,8 +2042,17 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * accounting on raw pfn maps.
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
-				     (VM_WRITE|VM_SHARED))
+				     (VM_WRITE|VM_SHARED)) {
+			pte_unmap_unlock(page_table, ptl);
+			ret = do_pfn_mkwrite(vma, address);
+			if (ret & VM_FAULT_ERROR)
+				return ret;
+			page_table = pte_offset_map_lock(mm, pmd, address,
+							 &ptl);
+			if (!pte_same(*page_table, orig_pte))
+				goto unlock;
 			goto reuse;
+		}
 		goto gotten;
 	}
 
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
