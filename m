Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EABB76B0338
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 16:49:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s74so7996105pfe.10
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 13:49:28 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h91si2588710pld.196.2017.06.07.13.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jun 2017 13:49:28 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/3] mm: add vm_insert_mixed_mkwrite()
Date: Wed,  7 Jun 2017 14:48:57 -0600
Message-Id: <20170607204859.13104-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

To be able to use the common 4k zero page in DAX we need to have our PTE
fault path look more like our PMD fault path where a PTE entry can be
marked as dirty and writeable as it is first inserted, rather than waiting
for a follow-up dax_pfn_mkwrite() => finish_mkwrite_fault() call.

Right now we can rely on having a dax_pfn_mkwrite() call because we can
distinguish between these two cases in do_wp_page():

	case 1: 4k zero page => writable DAX storage
	case 2: read-only DAX storage => writeable DAX storage

This distinction is made by via vm_normal_page().  vm_normal_page() returns
false for the common 4k zero page, though, just as it does for DAX ptes.
Instead of special casing the DAX + 4k zero page case, we will simplify our
DAX PTE page fault sequence so that it matches our DAX PMD sequence, and
get rid of dax_pfn_mkwrite() completely.

This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
will do the work that was previously done by wp_page_reuse() as part of the
dax_pfn_mkwrite() call path.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/mm.h |  9 +++++++--
 mm/memory.c        | 21 ++++++++++++++-------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b892e95..11e323a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2294,10 +2294,15 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn);
+int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn, bool mkwrite);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
+static inline int vm_insert_mixed(struct vm_area_struct *vma,
+		unsigned long addr, pfn_t pfn)
+{
+	return vm_insert_mixed_mkwrite(vma, addr, pfn, false);
+}
 
 struct page *follow_page_mask(struct vm_area_struct *vma,
 			      unsigned long address, unsigned int foll_flags,
diff --git a/mm/memory.c b/mm/memory.c
index 2e65df1..8d0eef6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1646,7 +1646,7 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 EXPORT_SYMBOL(vm_insert_page);
 
 static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn, pgprot_t prot)
+			pfn_t pfn, pgprot_t prot, bool mkwrite)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int retval;
@@ -1658,7 +1658,7 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
-	if (!pte_none(*pte))
+	if (!pte_none(*pte) && !mkwrite)
 		goto out_unlock;
 
 	/* Ok, finally just insert the thing.. */
@@ -1666,6 +1666,12 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
 	else
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
+
+	if (mkwrite) {
+		entry = pte_mkyoung(entry);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	}
+
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
@@ -1736,14 +1742,15 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 
 	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
 
-	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
+	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
+			false);
 
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn_prot);
 
-int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn)
+int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn, bool mkwrite)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 
@@ -1772,9 +1779,9 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		page = pfn_to_page(pfn_t_to_pfn(pfn));
 		return insert_page(vma, addr, page, pgprot);
 	}
-	return insert_pfn(vma, addr, pfn, pgprot);
+	return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
 }
-EXPORT_SYMBOL(vm_insert_mixed);
+EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
 
 /*
  * maps a range of physical memory into the requested pages. the old
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
