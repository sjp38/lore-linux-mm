Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 290556B0005
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 08:19:52 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b65so33187627wmg.0
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 05:19:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i83si9846501wma.27.2016.07.22.05.19.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 05:19:51 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 02/15] mm: Propagate original vm_fault into do_fault_around()
Date: Fri, 22 Jul 2016 14:19:28 +0200
Message-Id: <1469189981-19000-3-git-send-email-jack@suse.cz>
In-Reply-To: <1469189981-19000-1-git-send-email-jack@suse.cz>
References: <1469189981-19000-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jan Kara <jack@suse.cz>

Propagate vm_fault structure of the original fault into
do_fault_around(). Currently it saves just two arguments of
do_fault_around() but when adding more into struct vm_fault it will be a
bigger win.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 4ee0aa96d78d..651accbe34cc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2950,13 +2950,14 @@ late_initcall(fault_around_debugfs);
  * fault_around_pages() value (and therefore to page order).  This way it's
  * easier to guarantee that we don't cross page table boundaries.
  */
-static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
-		pte_t *pte, pgoff_t pgoff, unsigned int flags)
+static void do_fault_around(struct vm_area_struct *vma, struct vm_fault *vmf,
+		pte_t *pte)
 {
 	unsigned long start_addr, nr_pages, mask;
-	pgoff_t max_pgoff;
-	struct vm_fault vmf;
+	pgoff_t pgoff = vmf->pgoff, max_pgoff;
+	struct vm_fault vmfaround;
 	int off;
+	unsigned long address = (unsigned long)vmf->virtual_address;
 
 	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
@@ -2985,10 +2986,10 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
 		pte++;
 	}
 
-	init_vmf(&vmf, vma, start_addr, pgoff, flags);
-	vmf.pte = pte;
-	vmf.max_pgoff = max_pgoff;
-	vma->vm_ops->map_pages(vma, &vmf);
+	init_vmf(&vmfaround, vma, start_addr, pgoff, vmf->flags);
+	vmfaround.pte = pte;
+	vmfaround.max_pgoff = max_pgoff;
+	vma->vm_ops->map_pages(vma, &vmfaround);
 }
 
 static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -3006,7 +3007,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 */
 	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
-		do_fault_around(vma, address, pte, vmf->pgoff, vmf->flags);
+		do_fault_around(vma, vmf, pte);
 		if (!pte_same(*pte, orig_pte))
 			goto unlock_out;
 		pte_unmap_unlock(pte, ptl);
-- 
2.6.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
