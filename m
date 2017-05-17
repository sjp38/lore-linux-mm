Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC4506B0038
	for <linux-mm@kvack.org>; Wed, 17 May 2017 13:16:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c6so13599498pfj.5
        for <linux-mm@kvack.org>; Wed, 17 May 2017 10:16:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d9si2621669pgn.218.2017.05.17.10.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 May 2017 10:16:56 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/2] mm: avoid spurious 'bad pmd' warning messages
Date: Wed, 17 May 2017 11:16:38 -0600
Message-Id: <20170517171639.14501-1-ross.zwisler@linux.intel.com>
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

Reorder these checks so that pmd_devmap() is checked first, avoiding the
error messages.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Fixes: commit 7267ec008b5c ("mm: postpone page table allocation until we have page to map")
Cc: stable@vger.kernel.org
---
 mm/memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6ff5d72..1ee269d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3061,7 +3061,7 @@ static int pte_alloc_one_map(struct vm_fault *vmf)
 	 * through an atomic read in C, which is what pmd_trans_unstable()
 	 * provides.
 	 */
-	if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
+	if (pmd_devmap(*vmf->pmd) || pmd_trans_unstable(vmf->pmd))
 		return VM_FAULT_NOPAGE;
 
 	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
@@ -3690,7 +3690,7 @@ static int handle_pte_fault(struct vm_fault *vmf)
 		vmf->pte = NULL;
 	} else {
 		/* See comment in pte_alloc_one_map() */
-		if (pmd_trans_unstable(vmf->pmd) || pmd_devmap(*vmf->pmd))
+		if (pmd_devmap(*vmf->pmd) || pmd_trans_unstable(vmf->pmd))
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
