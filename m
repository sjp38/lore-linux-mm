Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id BBA556B025D
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 00:09:32 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so172352781pac.3
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 21:09:32 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id uv3si7128363pac.101.2015.11.29.21.09.32
        for <linux-mm@kvack.org>;
        Sun, 29 Nov 2015 21:09:32 -0800 (PST)
Subject: [RFC PATCH 5/5] dax: re-enable dax pmd mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 29 Nov 2015 21:09:00 -0800
Message-ID: <20151130050900.18366.73673.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
References: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: toshi.kani@hp.com, linux-nvdimm@lists.01.org

Now that the get_user_pages() path knows how to handle dax-pmd mappings,
remove the protections that disabled dax-pmd support.

Test-case from github.com/pmem/ndctl:

    make TESTS=lib/test-dax.sh check

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/Kconfig |    3 ++-
 fs/dax.c   |    8 ++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 6ce72d8d1ee1..ad8f4aa4161c 100644
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
index a429a00628c5..6662de3c0bc7 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -573,7 +573,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	sector_t block;
 	int result = 0;
 
-	/* dax pmd mappings are broken wrt gup and fork */
+	/* dax pmd mappings require pfn_t_devmap() */
 	if (!IS_ENABLED(CONFIG_FS_DAX_PMD))
 		return VM_FAULT_FALLBACK;
 
@@ -692,11 +692,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 			goto fallback;
 		}
 
-		/*
-		 * TODO: teach vmf_insert_pfn_pmd() to support
-		 * 'pte_special' for pmds
-		 */
-		if (pfn_t_has_page(dax.pfn)) {
+		if (!pfn_t_devmap(dax.pfn)) {
 			dax_unmap_atomic(bdev, &dax);
 			reason = "pfn not in memmap";
 			goto fallback;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
