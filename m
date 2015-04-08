Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 609146B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 11:56:58 -0400 (EDT)
Received: by wiax7 with SMTP id x7so36297695wia.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 08:56:57 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id l1si20031325wiy.1.2015.04.08.08.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Apr 2015 08:56:56 -0700 (PDT)
Received: by wiaa2 with SMTP id a2so64349236wia.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 08:56:55 -0700 (PDT)
Message-ID: <55254FC4.3050206@plexistor.com>
Date: Wed, 08 Apr 2015 18:56:52 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 1/3 @stable] mm(v4.0): New pfn_mkwrite same as page_mkwrite
 for VM_PFNMAP
References: <55239645.9000507@plexistor.com>
In-Reply-To: <55239645.9000507@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable Tree <stable@vger.kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Eryu Guan <eguan@redhat.com>, Christoph Hellwig <hch@infradead.org>

From: Yigal Korman <yigal@plexistor.com>

[For Stable 4.0.X]
The parallel patch at 4.1-rc1 to this patch is:
  Subject: mm: new pfn_mkwrite same as page_mkwrite for VM_PFNMAP

We need this patch for the 4.0.X stable tree if the patch
  Subject: dax: use pfn_mkwrite to update c/mtime + freeze protection

Was decided to be pulled into stable since it is a dependency
of this patch. The file mm/memory.c was heavily changed in 4.1
hence this here.

[v3]
In the case of !pte_same when we lost the race better
return 0 instead of FAULT_NO_PAGE

[v2]
Fixed according to Kirill's comments

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

Signed-off-by: Yigal Korman <yigal@plexistor.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
CC: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
CC: Matthew Wilcox <matthew.r.wilcox@intel.com>
CC: Jan Kara <jack@suse.cz>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Hugh Dickins <hughd@google.com>
CC: Mel Gorman <mgorman@suse.de>
CC: Konstantin Khlebnikov <koct9i@gmail.com>
CC: linux-mm@kvack.org
CC: Stable Tree <stable@vger.kernel.org>
---
 Documentation/filesystems/Locking |  8 ++++++++
 include/linux/mm.h                |  3 +++
 mm/memory.c                       | 27 ++++++++++++++++++++++++++-
 3 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index f91926f..25f36e6 100644
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
+after this call is to make the pte read-write, unless pfn_mkwrite()
+already touched the pte, in that case it is untouched.
+
 	->access() is called when get_user_pages() fails in
 access_process_vm(), typically used to debug a process through
 /proc/pid/mem or ptrace.  This function is needed only for
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a9392..85ba9c2 100644
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
index 97839f5..6029777 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1982,6 +1982,18 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 	return ret;
 }
 
+static int do_pfn_mkwrite(struct vm_area_struct *vma, unsigned long address)
+{
+	struct vm_fault vmf = {
+		.page = NULL,
+		.pgoff = linear_page_index(vma, address),
+		.virtual_address = (void __user *)(address & PAGE_MASK),
+		.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE,
+	};
+
+	return vma->vm_ops->pfn_mkwrite(vma, &vmf);
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -2025,8 +2037,21 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * accounting on raw pfn maps.
 		 */
 		if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
-				     (VM_WRITE|VM_SHARED))
+				     (VM_WRITE|VM_SHARED)) {
+			if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
+				pte_unmap_unlock(page_table, ptl);
+				ret = do_pfn_mkwrite(vma, address);
+				if (ret & VM_FAULT_ERROR)
+					return ret;
+				page_table = pte_offset_map_lock(mm, pmd,
+								 address, &ptl);
+				if (!pte_same(*page_table, orig_pte)) {
+					ret = 0;
+					goto unlock;
+				}
+			}
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
