Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C34E282F6A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:39:54 -0500 (EST)
Received: by pfnn128 with SMTP id n128so39810111pfn.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:39:54 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id l77si16802545pfi.91.2015.12.09.18.39.54
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 18:39:54 -0800 (PST)
Subject: [-mm PATCH v2 25/25] dax: re-enable dax pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 09 Dec 2015 18:39:27 -0800
Message-ID: <20151210023927.30368.66143.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
References: <20151210023708.30368.92962.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

Now that the get_user_pages() path knows how to handle dax-pmd mappings,
remove the protections that disabled dax-pmd support.

Tests available from github.com/pmem/ndctl:

    make TESTS="lib/test-dax.sh lib/test-mmap.sh" check

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/Kconfig |    3 ++-
 fs/dax.c   |    8 ++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 7a6ff07c183f..922893f8ab4a 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -50,7 +50,8 @@ config FS_DAX_PMD
 	bool
 	default FS_DAX
 	depends on FS_DAX
-	depends on BROKEN
+	depends on ZONE_DEVICE
+	depends on TRANSPARENT_HUGEPAGE
 
 endif # BLOCK
 
diff --git a/fs/dax.c b/fs/dax.c
index a8b82a75dfa8..dd11e15a7940 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -581,7 +581,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	sector_t block;
 	int result = 0;
 
-	/* dax pmd mappings are broken wrt gup and fork */
+	/* dax pmd mappings require pfn_t_devmap() */
 	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
 		return VM_FAULT_FALLBACK;
 
@@ -706,11 +706,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto fallback;
 		}
 
-		/*
-		 * TODO: teach vmf_insert_pfn_pmd() to support
-		 * 'pte_special' for pmds
-		 */
-		if (pfn_t_has_page(dax.pfn)) {
+		if (!pfn_t_devmap(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
 			dax_pmd_dbg(bdev, address, "pfn not in memmap");
 			goto fallback;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
