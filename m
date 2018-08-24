Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCB656B3041
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:45:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c8-v6so6360840pfn.2
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:45:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w16-v6si6642430ply.462.2018.08.24.08.45.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 08:45:47 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Fix warning in insert_pfn()
Date: Fri, 24 Aug 2018 17:45:42 +0200
Message-Id: <20180824154542.26872-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-ext4@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Dave Jiang <dave.jiang@intel.com>, Jan Kara <jack@suse.cz>

In DAX mode a write pagefault can race with write(2) in the following
way:

CPU0                            CPU1
                                write fault for mapped zero page (hole)
dax_iomap_rw()
  iomap_apply()
    xfs_file_iomap_begin()
      - allocates blocks
    dax_iomap_actor()
      invalidate_inode_pages2_range()
        - invalidates radix tree entries in given range
                                dax_iomap_pte_fault()
                                  grab_mapping_entry()
                                    - no entry found, creates empty
                                  ...
                                  xfs_file_iomap_begin()
                                    - finds already allocated block
                                  ...
                                  vmf_insert_mixed_mkwrite()
                                    - WARNs and does nothing because there
                                      is still zero page mapped in PTE
        unmap_mapping_pages()

This race results in WARN_ON from insert_pfn() and is occasionally
triggered by fstest generic/344. Note that the race is otherwise
harmless as before write(2) on CPU0 is finished, we will invalidate page
tables properly and thus user of mmap will see modified data from
write(2) from that point on. So just restrict the warning only to the
case when the PFN in PTE is not zero page.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 83aef222f11b..e82cd2125d72 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1787,10 +1787,15 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			 * in may not match the PFN we have mapped if the
 			 * mapped PFN is a writeable COW page.  In the mkwrite
 			 * case we are creating a writable PTE for a shared
-			 * mapping and we expect the PFNs to match.
+			 * mapping and we expect the PFNs to match. If they
+			 * don't match, we are likely racing with block
+			 * allocation and mapping invalidation so just skip the
+			 * update.
 			 */
-			if (WARN_ON_ONCE(pte_pfn(*pte) != pfn_t_to_pfn(pfn)))
+			if (pte_pfn(*pte) != pfn_t_to_pfn(pfn)) {
+				WARN_ON_ONCE(!is_zero_pfn(pte_pfn(*pte)));
 				goto out_unlock;
+			}
 			entry = *pte;
 			goto out_mkwrite;
 		} else
-- 
2.16.4
