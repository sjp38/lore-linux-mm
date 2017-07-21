Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46CF06B02B4
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 18:40:05 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so69128789pfe.11
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 15:40:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s27si3462068pfi.496.2017.07.21.15.40.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 15:40:04 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 1/5] mm: add mkwrite param to vm_insert_mixed()
Date: Fri, 21 Jul 2017 16:39:51 -0600
Message-Id: <20170721223956.29485-2-ross.zwisler@linux.intel.com>
In-Reply-To: <20170721223956.29485-1-ross.zwisler@linux.intel.com>
References: <20170721223956.29485-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie <airlied@linux.ie>, Ingo Molnar <mingo@redhat.com>, Inki Dae <inki.dae@samsung.com>, Jan Kara <jack@suse.cz>, Jonathan Corbet <corbet@lwn.net>, Joonyoung Shim <jy0922.shim@samsung.com>, Krzysztof Kozlowski <krzk@kernel.org>, Kukjin Kim <kgene@kernel.org>, Kyungmin Park <kyungmin.park@samsung.com>, Matthew Wilcox <mawilcox@microsoft.com>, Patrik Jakobsson <patrik.r.jakobsson@gmail.com>, Rob Clark <robdclark@gmail.com>, Seung-Woo Kim <sw0312.kim@samsung.com>, Steven Rostedt <rostedt@goodmis.org>, Tomi Valkeinen <tomi.valkeinen@ti.com>, dri-devel@lists.freedesktop.org, freedreno@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org, linux-arm-msm@vger.kernel.org, linux-doc@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-samsung-soc@vger.kernel.org, linux-xfs@vger.kernel.org

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
get rid of the dax_pfn_mkwrite() helper.  We will instead use
dax_iomap_fault() to handle write-protection faults.

This means that insert_pfn() needs to follow the lead of insert_pfn_pmd()
and allow us to pass in a 'mkwrite' flag.  If 'mkwrite' is set insert_pfn()
will do the work that was previously done by wp_page_reuse() as part of the
dax_pfn_mkwrite() call path.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 drivers/dax/device.c                    |  2 +-
 drivers/gpu/drm/exynos/exynos_drm_gem.c |  3 ++-
 drivers/gpu/drm/gma500/framebuffer.c    |  2 +-
 drivers/gpu/drm/msm/msm_gem.c           |  3 ++-
 drivers/gpu/drm/omapdrm/omap_gem.c      |  6 ++++--
 drivers/gpu/drm/ttm/ttm_bo_vm.c         |  2 +-
 fs/dax.c                                |  2 +-
 include/linux/mm.h                      |  2 +-
 mm/memory.c                             | 27 +++++++++++++++++++++------
 9 files changed, 34 insertions(+), 15 deletions(-)

diff --git a/drivers/dax/device.c b/drivers/dax/device.c
index e9f3b3e..3973521 100644
--- a/drivers/dax/device.c
+++ b/drivers/dax/device.c
@@ -273,7 +273,7 @@ static int __dev_dax_pte_fault(struct dev_dax *dev_dax, struct vm_fault *vmf)
 
 	pfn = phys_to_pfn_t(phys, dax_region->pfn_flags);
 
-	rc = vm_insert_mixed(vmf->vma, vmf->address, pfn);
+	rc = vm_insert_mixed(vmf->vma, vmf->address, pfn, false);
 
 	if (rc == -ENOMEM)
 		return VM_FAULT_OOM;
diff --git a/drivers/gpu/drm/exynos/exynos_drm_gem.c b/drivers/gpu/drm/exynos/exynos_drm_gem.c
index c23479b..bfa6648 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_gem.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_gem.c
@@ -466,7 +466,8 @@ int exynos_drm_gem_fault(struct vm_fault *vmf)
 	}
 
 	pfn = page_to_pfn(exynos_gem->pages[page_offset]);
-	ret = vm_insert_mixed(vma, vmf->address, __pfn_to_pfn_t(pfn, PFN_DEV));
+	ret = vm_insert_mixed(vma, vmf->address, __pfn_to_pfn_t(pfn, PFN_DEV),
+			false);
 
 out:
 	switch (ret) {
diff --git a/drivers/gpu/drm/gma500/framebuffer.c b/drivers/gpu/drm/gma500/framebuffer.c
index 7da70b6..6dd865f 100644
--- a/drivers/gpu/drm/gma500/framebuffer.c
+++ b/drivers/gpu/drm/gma500/framebuffer.c
@@ -134,7 +134,7 @@ static int psbfb_vm_fault(struct vm_fault *vmf)
 		pfn = (phys_addr >> PAGE_SHIFT);
 
 		ret = vm_insert_mixed(vma, address,
-				__pfn_to_pfn_t(pfn, PFN_DEV));
+				__pfn_to_pfn_t(pfn, PFN_DEV), false);
 		if (unlikely((ret == -EBUSY) || (ret != 0 && i > 0)))
 			break;
 		else if (unlikely(ret != 0)) {
diff --git a/drivers/gpu/drm/msm/msm_gem.c b/drivers/gpu/drm/msm/msm_gem.c
index 65f3554..c187fd1 100644
--- a/drivers/gpu/drm/msm/msm_gem.c
+++ b/drivers/gpu/drm/msm/msm_gem.c
@@ -249,7 +249,8 @@ int msm_gem_fault(struct vm_fault *vmf)
 	VERB("Inserting %p pfn %lx, pa %lx", (void *)vmf->address,
 			pfn, pfn << PAGE_SHIFT);
 
-	ret = vm_insert_mixed(vma, vmf->address, __pfn_to_pfn_t(pfn, PFN_DEV));
+	ret = vm_insert_mixed(vma, vmf->address, __pfn_to_pfn_t(pfn, PFN_DEV),
+			false);
 
 out_unlock:
 	mutex_unlock(&msm_obj->lock);
diff --git a/drivers/gpu/drm/omapdrm/omap_gem.c b/drivers/gpu/drm/omapdrm/omap_gem.c
index 5c5c86d..26eebcd 100644
--- a/drivers/gpu/drm/omapdrm/omap_gem.c
+++ b/drivers/gpu/drm/omapdrm/omap_gem.c
@@ -393,7 +393,8 @@ static int fault_1d(struct drm_gem_object *obj,
 	VERB("Inserting %p pfn %lx, pa %lx", (void *)vmf->address,
 			pfn, pfn << PAGE_SHIFT);
 
-	return vm_insert_mixed(vma, vmf->address, __pfn_to_pfn_t(pfn, PFN_DEV));
+	return vm_insert_mixed(vma, vmf->address, __pfn_to_pfn_t(pfn, PFN_DEV),
+			false);
 }
 
 /* Special handling for the case of faulting in 2d tiled buffers */
@@ -486,7 +487,8 @@ static int fault_2d(struct drm_gem_object *obj,
 			pfn, pfn << PAGE_SHIFT);
 
 	for (i = n; i > 0; i--) {
-		vm_insert_mixed(vma, vaddr, __pfn_to_pfn_t(pfn, PFN_DEV));
+		vm_insert_mixed(vma, vaddr, __pfn_to_pfn_t(pfn, PFN_DEV),
+				false);
 		pfn += priv->usergart[fmt].stride_pfn;
 		vaddr += PAGE_SIZE * m;
 	}
diff --git a/drivers/gpu/drm/ttm/ttm_bo_vm.c b/drivers/gpu/drm/ttm/ttm_bo_vm.c
index b442d12..e85bfa7 100644
--- a/drivers/gpu/drm/ttm/ttm_bo_vm.c
+++ b/drivers/gpu/drm/ttm/ttm_bo_vm.c
@@ -248,7 +248,7 @@ static int ttm_bo_vm_fault(struct vm_fault *vmf)
 
 		if (vma->vm_flags & VM_MIXEDMAP)
 			ret = vm_insert_mixed(&cvma, address,
-					__pfn_to_pfn_t(pfn, PFN_DEV));
+					__pfn_to_pfn_t(pfn, PFN_DEV), false);
 		else
 			ret = vm_insert_pfn(&cvma, address, pfn);
 
diff --git a/fs/dax.c b/fs/dax.c
index 306c2b6..c844a51 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -899,7 +899,7 @@ static int dax_insert_mapping(struct address_space *mapping,
 	*entryp = ret;
 
 	trace_dax_insert_mapping(mapping->host, vmf, ret);
-	return vm_insert_mixed(vma, vaddr, pfn);
+	return vm_insert_mixed(vma, vaddr, pfn, false);
 }
 
 /**
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5..3eabc40 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2292,7 +2292,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn, pgprot_t pgprot);
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn);
+			pfn_t pfn, bool mkwrite);
 int vm_iomap_memory(struct vm_area_struct *vma, phys_addr_t start, unsigned long len);
 
 
diff --git a/mm/memory.c b/mm/memory.c
index 0e517be..d351911 100644
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
@@ -1658,14 +1658,28 @@ static int insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
-	if (!pte_none(*pte))
-		goto out_unlock;
+	if (!pte_none(*pte)) {
+		if (mkwrite) {
+			if (WARN_ON_ONCE(pte_pfn(*pte) != pfn_t_to_pfn(pfn)))
+				goto out_unlock;
+			entry = *pte;
+			goto out_mkwrite;
+		} else
+			goto out_unlock;
+	}
 
 	/* Ok, finally just insert the thing.. */
 	if (pfn_t_devmap(pfn))
 		entry = pte_mkdevmap(pfn_t_pte(pfn, prot));
 	else
 		entry = pte_mkspecial(pfn_t_pte(pfn, prot));
+
+out_mkwrite:
+	if (mkwrite) {
+		entry = pte_mkyoung(entry);
+		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	}
+
 	set_pte_at(mm, addr, pte, entry);
 	update_mmu_cache(vma, addr, pte); /* XXX: why not for insert_page? */
 
@@ -1736,14 +1750,15 @@ int vm_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
 
 	track_pfn_insert(vma, &pgprot, __pfn_to_pfn_t(pfn, PFN_DEV));
 
-	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot);
+	ret = insert_pfn(vma, addr, __pfn_to_pfn_t(pfn, PFN_DEV), pgprot,
+			false);
 
 	return ret;
 }
 EXPORT_SYMBOL(vm_insert_pfn_prot);
 
 int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
-			pfn_t pfn)
+			pfn_t pfn, bool mkwrite)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
 
@@ -1772,7 +1787,7 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 		page = pfn_to_page(pfn_t_to_pfn(pfn));
 		return insert_page(vma, addr, page, pgprot);
 	}
-	return insert_pfn(vma, addr, pfn, pgprot);
+	return insert_pfn(vma, addr, pfn, pgprot, mkwrite);
 }
 EXPORT_SYMBOL(vm_insert_mixed);
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
