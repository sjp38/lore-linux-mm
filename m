Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AFC246B0292
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:22:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d13so6024488pgf.12
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:22:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u143si356967pgb.341.2017.06.14.10.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 10:22:20 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 1/3] mm: add vm_insert_mixed_mkwrite()
Date: Wed, 14 Jun 2017 11:22:09 -0600
Message-Id: <20170614172211.19820-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20170614172211.19820-1-ross.zwisler@linux.intel.com>
References: <20170614172211.19820-1-ross.zwisler@linux.intel.com>
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
 include/linux/mm.h |  2 ++
 mm/memory.c        | 49 +++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b892e95..0ea79e6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2296,6 +2296,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			pfn_t pfn);
+int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index 2e65df1..38d7c4f 100644
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
 
@@ -1736,7 +1742,8 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 
 	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
 
-	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
+	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
+			false);
 
 	return ret;
 }
@@ -1772,10 +1779,44 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		page = pfn_to_page(pfn_t_to_pfn(pfn));
 		return insert_page(vma, addr, page, pgprot);
 	}
-	return insert_pfn(vma, addr, pfn, pgprot);
+	return insert_pfn(vma, addr, pfn, pgprot, false);
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
+int vm_insert_mixed_mkwrite(struct vm_area_struct *vma, unsigned long addr,
+			pfn_t pfn)
+{
+	pgprot_t pgprot = vma->vm_page_prot;
+
+	BUG_ON(!(vma->vm_flags & VM_MIXEDMAP));
+
+	if (addr < vma->vm_start || addr >= vma->vm_end)
+		return -EFAULT;
+
+	track_pfn_insert(vma, &pgprot, pfn);
+
+	/*
+	 * If we don't have pte special, then we have to use the pfn_valid()
+	 * based VM_MIXEDMAP scheme (see vm_normal_page), and thus we *must*
+	 * refcount the page if pfn_valid is true (hence insert_page rather
+	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
+	 * without pte special, it would there be refcounted as a normal page.
+	 */
+	if (!HAVE_PTE_SPECIAL && !pfn_t_devmap(pfn) && pfn_t_valid(pfn)) {
+		struct page *page;
+
+		/*
+		 * At this point we are committed to insert_page()
+		 * regardless of whether the caller specified flags that
+		 * result in pfn_t_has_page() == false.
+		 */
+		page = pfn_to_page(pfn_t_to_pfn(pfn));
+		return insert_page(vma, addr, page, pgprot);
+	}
+	return insert_pfn(vma, addr, pfn, pgprot, true);
+}
+EXPORT_SYMBOL(vm_insert_mixed_mkwrite);
+
 /*
  * maps a range of physical memory into the requested pages. the old
  * mappings are removed. any references to nonexistent pages results
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
