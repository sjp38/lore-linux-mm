Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 139766B0285
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 00:51:57 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i19-v6so9561377pfi.21
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 21:51:57 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p1-v6si18209903pfa.120.2018.11.12.21.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 21:51:55 -0800 (PST)
From: Sasha Levin <sashal@kernel.org>
Subject: [PATCH AUTOSEL 4.14 07/26] mm: Fix warning in insert_pfn()
Date: Tue, 13 Nov 2018 00:51:31 -0500
Message-Id: <20181113055150.78773-7-sashal@kernel.org>
In-Reply-To: <20181113055150.78773-1-sashal@kernel.org>
References: <20181113055150.78773-1-sashal@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Sasha Levin <sashal@kernel.org>, linux-mm@kvack.org

From: Jan Kara <jack@suse.cz>

[ Upstream commit f2c57d91b0d96aa13ccff4e3b178038f17b00658 ]

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

Link: http://lkml.kernel.org/r/20180824154542.26872-1-jack@suse.cz
Signed-off-by: Jan Kara <jack@suse.cz>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/memory.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 93d5d324904b..9c0172a4d9bf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1804,10 +1804,15 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
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
2.17.1
