Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8CC6B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:57:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c10so143093161pfg.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:57:57 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s64si8910598pgb.336.2017.05.22.14.57.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:57:56 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 1/2] mm: avoid spurious 'bad pmd' warning messages
Date: Mon, 22 May 2017 15:57:48 -0600
Message-Id: <20170522215749.23516-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pawel Lebioda <pawel.lebioda@intel.com>, Dave Jiang <dave.jiang@intel.com>, Xiong Zhou <xzhou@redhat.com>, Eryu Guan <eguan@redhat.com>, stable@vger.kernel.org

When the pmd_devmap() checks were added by:

commit 5c7fb56e5e3f ("mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd")

to add better support for DAX huge pages, they were all added to the end of
if() statements after existing pmd_trans_huge() checks.  So, things like:

-       if (pmd_trans_huge(*pmd))
+       if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd))

When further checks were added after pmd_trans_unstable() checks by:

commit 7267ec008b5c ("mm: postpone page table allocation until we have page
to map")

they were also added at the end of the conditional:

+       if (pmd_trans_unstable(fe->pmd) || pmd_devmap(*fe->pmd))

This ordering is fine for pmd_trans_huge(), but doesn't work for
pmd_trans_unstable().  This is because DAX huge pages trip the bad_pmd()
check inside of pmd_none_or_trans_huge_or_clear_bad() (called by
pmd_trans_unstable()), which prints out a warning and returns 1.  So, we do
end up doing the right thing, but only after spamming dmesg with suspicious
looking messages:

mm/pgtable-generic.c:39: bad pmd ffff8808daa49b88(84000001006000a5)

Reorder these checks in a helper so that pmd_devmap() is checked first,
avoiding the error messages, and add a comment explaining why the ordering
is important.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Fixes: commit 7267ec008b5c ("mm: postpone page table allocation until we have page to map")
Cc: stable@vger.kernel.org
---

Changes from v1:
 - Break the checks out into the new pmd_devmap_trans_unstable() helper and
   add a comment about the ordering (Dave).  I ended up keeping this helper
   in mm/memory.c because I didn't see an obvious header where it would
   live happily.  pmd_devmap() is either defined in
   arch/x86/include/asm/pgtable.h or in include/linux/mm.h depending on
   __HAVE_ARCH_PTE_DEVMAP and CONFIG_TRANSPARENT_HUGEPAGE, and
   pmd_trans_unstable() is defined in include/asm-generic/pgtable.h.

 - Add a comment explaining why pte_alloc_one_map() doesn't suffer from races.
   This was the result of a conversation with Dave Hansen.
---
 mm/memory.c | 40 ++++++++++++++++++++++++++++++----------
 1 file changed, 30 insertions(+), 10 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6ff5d72..2e65df1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3029,6 +3029,17 @@ static int __do_fault(struct vm_fault *vmf)
 	return ret;
 }
 
+/*
+ * The ordering of these checks is important for pmds with _PAGE_DEVMAP set.
+ * If we check pmd_trans_unstable() first we will trip the bad_pmd() check
+ * inside of pmd_none_or_trans_huge_or_clear_bad(). This will end up correctly
+ * returning 1 but not before it spams dmesg with the pmd_clear_bad() output.
+ */
+static int pmd_devmap_trans_unstable(pmd_t *pmd)
+{
+	return pmd_devmap(*pmd) || pmd_trans_unstable(pmd);
+}
+
 static int pte_alloc_one_map(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -3052,18 +3063,27 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
 map_pte:
 	/*
 	 * If a huge pmd materialized under us just retry later.  Use
-	 * pmd_trans_unstable() instead of pmd_trans_huge() to ensure the pmd
-	 * didn't become pmd_trans_huge under us and then back to pmd_none, as
-	 * a result of MADV_DONTNEED running immediately after a huge pmd fault
-	 * in a different thread of this mm, in turn leading to a misleading
-	 * pmd_trans_huge() retval.  All we have to ensure is that it is a
-	 * regular pmd that we can walk with pte_offset_map() and we can do that
-	 * through an atomic read in C, which is what pmd_trans_unstable()
-	 * provides.
+	 * pmd_trans_unstable() via pmd_devmap_trans_unstable() instead of
+	 * pmd_trans_huge() to ensure the pmd didn't become pmd_trans_huge
+	 * under us and then back to pmd_none, as a result of MADV_DONTNEED
+	 * running immediately after a huge pmd fault in a different thread of
+	 * this mm, in turn leading to a misleading pmd_trans_huge() retval.
+	 * All we have to ensure is that it is a regular pmd that we can walk
+	 * with pte_offset_map() and we can do that through an atomic read in
+	 * C, which is what pmd_trans_unstable() provides.
 	 */
-	if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
+	if (pmd_devmap_trans_unstable(vmf->pmd))
 		return VM_FAULT_NOPAGE;
 
+	/*
+	 * At this point we know that our vmf->pmd points to a page of ptes
+	 * and it cannot become pmd_none(), pmd_devmap() or pmd_trans_huge()
+	 * for the duration of the fault.  If a racing MADV_DONTNEED runs and
+	 * we zap the ptes pointed to by our vmf->pmd, the vmf->ptl will still
+	 * be valid and we will re-check to make sure the vmf->pte isn't
+	 * pte_none() under vmf->ptl protection when we return to
+	 * alloc_set_pte().
+	 */
 	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
 			&vmf->ptl);
 	return 0;
@@ -3690,7 +3710,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 		vmf->pte = NULL;
 	} else {
 		/* See comment in pte_alloc_one_map() */
-		if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
+		if (pmd_devmap_trans_unstable(vmf->pmd))
 			return 0;
 		/*
 		 * A regular pmd is established and it can't morph into a huge
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
