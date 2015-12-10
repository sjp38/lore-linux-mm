Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 66B116B0268
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:38:04 -0500 (EST)
Received: by pfdd184 with SMTP id d184so39749164pfd.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:38:04 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id da6si16747102pad.156.2015.12.09.18.38.03
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:38:03 -0800 (PST)
Subject: [-mm PATCH v2 05/25] mm, dax: fix livelock,
 allow dax pmd mappings to become writeable
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:37:36 -0800
Message-ID: <20151210023736.30368.76631.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Toshi Kani <toshi.kani@hpe.com>, linux-nvdimm@lists.01.org

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Prior to this change DAX PMD mappings that were made read-only were
never able to be made writable again.  This is because the code in
insert_pfn_pmd() that calls pmd_mkdirty() and pmd_mkwrite() would skip
these calls if the PMD already existed in the page table.

Instead, if we are doing a write always mark the PMD entry as dirty and
writeable.  Without this code we can get into a condition where we mark
the PMD as read-only, and then on a subsequent write fault we get into
an infinite loop of PMD faults where we try unsuccessfully to make the
PMD writeable.

Reported-by: Jeff Moyer <jmoyer@redhat.com>
Reported-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/huge_memory.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index faf39bbf6292..a4bfeb07394b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -967,15 +967,13 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spinlock_t *ptl;
 
 	ptl = pmd_lock(mm, pmd);
-	if (pmd_none(*pmd)) {
-		entry = pmd_mkhuge(pfn_pmd(pfn, prot));
-		if (write) {
-			entry = pmd_mkyoung(pmd_mkdirty(entry));
-			entry = maybe_pmd_mkwrite(entry, vma);
-		}
-		set_pmd_at(mm, addr, pmd, entry);
-		update_mmu_cache_pmd(vma, addr, pmd);
+	entry = pmd_mkhuge(pfn_pmd(pfn, prot));
+	if (write) {
+		entry = pmd_mkyoung(pmd_mkdirty(entry));
+		entry = maybe_pmd_mkwrite(entry, vma);
 	}
+	set_pmd_at(mm, addr, pmd, entry);
+	update_mmu_cache_pmd(vma, addr, pmd);
 	spin_unlock(ptl);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
