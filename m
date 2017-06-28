Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id E058A280391
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 14:01:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u126so27894044qka.9
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:01:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si2527528qtd.379.2017.06.28.11.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 11:01:24 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 15/15] mm/migrate: allow migrate_vma() to alloc new page on empty entry v3
Date: Wed, 28 Jun 2017 14:00:47 -0400
Message-Id: <20170628180047.5386-16-jglisse@redhat.com>
In-Reply-To: <20170628180047.5386-1-jglisse@redhat.com>
References: <20170628180047.5386-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This allow caller of migrate_vma() to allocate new page for empty CPU
page table entry. It only support anoymous memory and it won't allow
new page to be instance if userfaultfd is armed.

This is useful to device driver that want to migrate a range of virtual
address and would rather allocate new memory than having to fault later
on.

Changed sinve v2:
  - differentiate between empty CPU page table entry and non empty
  - improve code comments explaining how this works
Changed since v1:
  - 5 level page table fix

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/migrate.h |   9 +++
 mm/migrate.c            | 158 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 161 insertions(+), 6 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index c84541a9610f..c65d0875cdc9 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -205,6 +205,15 @@ static inline unsigned long migrate_pfn(unsigned long pfn)
  * driver should avoid setting MIGRATE_PFN_ERROR unless it is really in an
  * unrecoverable state.
  *
+ * For empty entry inside CPU page table (pte_none() or pmd_none() is true) we
+ * do set MIGRATE_PFN_MIGRATE flag inside the corresponding source array thus
+ * allowing device driver to allocate device memory for those unback virtual
+ * address. For this the device driver simply have to allocate device memory
+ * and properly set the destination entry like for regular migration. Note that
+ * this can still fails and thus inside the device driver must check if the
+ * migration was successful for those entry inside the finalize_and_map()
+ * callback just like for regular migration.
+ *
  * THE alloc_and_copy() CALLBACK MUST NOT CHANGE ANY OF THE SRC ARRAY ENTRIES
  * OR BAD THINGS WILL HAPPEN !
  *
diff --git a/mm/migrate.c b/mm/migrate.c
index c3ff98a4c3dc..643ea61ca9bb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -37,6 +37,7 @@
 #include <linux/hugetlb_cgroup.h>
 #include <linux/gfp.h>
 #include <linux/memremap.h>
+#include <linux/userfaultfd_k.h>
 #include <linux/balloon_compaction.h>
 #include <linux/mmu_notifier.h>
 #include <linux/page_idle.h>
@@ -2102,7 +2103,23 @@ static int migrate_vma_collect_hole(unsigned long start,
 				    struct mm_walk *walk)
 {
 	struct migrate_vma *migrate = walk->private;
-	unsigned long addr, next;
+	unsigned long addr;
+
+	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
+		migrate->cpages++;
+		migrate->dst[migrate->npages] = 0;
+		migrate->src[migrate->npages++] = MIGRATE_PFN_MIGRATE;
+	}
+
+	return 0;
+}
+
+static int migrate_vma_collect_thp(unsigned long start,
+				    unsigned long end,
+				    struct mm_walk *walk)
+{
+	struct migrate_vma *migrate = walk->private;
+	unsigned long addr;
 
 	for (addr = start & PAGE_MASK; addr < end; addr += PAGE_SIZE) {
 		migrate->dst[migrate->npages] = 0;
@@ -2123,10 +2140,14 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 	spinlock_t *ptl;
 	pte_t *ptep;
 
-	if (pmd_none(*pmdp) || pmd_trans_unstable(pmdp)) {
+	if (pmd_none(*pmdp)) {
 		/* FIXME support THP */
 		return migrate_vma_collect_hole(start, end, walk);
 	}
+	if (pmd_trans_unstable(pmdp)) {
+		/* FIXME support THP */
+		return migrate_vma_collect_thp(start, end, walk);
+	}
 
 	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	arch_enter_lazy_mmu_mode();
@@ -2141,7 +2162,9 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
 		pfn = pte_pfn(pte);
 
 		if (pte_none(pte)) {
-			mpfn = pfn = 0;
+			mpfn = MIGRATE_PFN_MIGRATE;
+			migrate->cpages++;
+			pfn = 0;
 			goto next;
 		}
 
@@ -2454,6 +2477,118 @@ static void migrate_vma_unmap(struct migrate_vma *migrate)
 	}
 }
 
+static void migrate_vma_insert_page(struct migrate_vma *migrate,
+				    unsigned long addr,
+				    struct page *page,
+				    unsigned long *src,
+				    unsigned long *dst)
+{
+	struct vm_area_struct *vma = migrate->vma;
+	struct mm_struct *mm = vma->vm_mm;
+	struct mem_cgroup *memcg;
+	spinlock_t *ptl;
+	pgd_t *pgdp;
+	p4d_t *p4dp;
+	pud_t *pudp;
+	pmd_t *pmdp;
+	pte_t *ptep;
+	pte_t entry;
+
+	/* Only allow populating anonymous memory */
+	if (!vma_is_anonymous(vma))
+		goto abort;
+
+	pgdp = pgd_offset(mm, addr);
+	p4dp = p4d_alloc(mm, pgdp, addr);
+	if (!p4dp)
+		goto abort;
+	pudp = pud_alloc(mm, p4dp, addr);
+	if (!pudp)
+		goto abort;
+	pmdp = pmd_alloc(mm, pudp, addr);
+	if (!pmdp)
+		goto abort;
+
+	if (pmd_trans_unstable(pmdp) || pmd_devmap(*pmdp))
+		goto abort;
+
+	/*
+	 * Use pte_alloc() instead of pte_alloc_map().  We can't run
+	 * pte_offset_map() on pmds where a huge pmd might be created
+	 * from a different thread.
+	 *
+	 * pte_alloc_map() is safe to use under down_write(mmap_sem) or when
+	 * parallel threads are excluded by other means.
+	 *
+	 * Here we only have down_read(mmap_sem).
+	 */
+	if (pte_alloc(mm, pmdp, addr))
+		goto abort;
+
+	/* See the comment in pte_alloc_one_map() */
+	if (unlikely(pmd_trans_unstable(pmdp)))
+		goto abort;
+
+	if (unlikely(anon_vma_prepare(vma)))
+		goto abort;
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg, false))
+		goto abort;
+
+	/*
+	 * The memory barrier inside __SetPageUptodate makes sure that
+	 * preceding stores to the page contents become visible before
+	 * the set_pte_at() write.
+	 */
+	__SetPageUptodate(page);
+
+	if (is_zone_device_page(page) && is_device_private_page(page)) {
+		swp_entry_t swp_entry;
+
+		swp_entry = make_device_private_entry(page, vma->vm_flags & VM_WRITE);
+		entry = swp_entry_to_pte(swp_entry);
+	} else {
+		entry = mk_pte(page, vma->vm_page_prot);
+		if (vma->vm_flags & VM_WRITE)
+			entry = pte_mkwrite(pte_mkdirty(entry));
+	}
+
+	ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
+	if (!pte_none(*ptep)) {
+		pte_unmap_unlock(ptep, ptl);
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto abort;
+	}
+
+	/*
+	 * Check for usefaultfd but do not deliver the fault. Instead,
+	 * just back off.
+	 */
+	if (userfaultfd_missing(vma)) {
+		pte_unmap_unlock(ptep, ptl);
+		mem_cgroup_cancel_charge(page, memcg, false);
+		goto abort;
+	}
+
+	inc_mm_counter(mm, MM_ANONPAGES);
+	page_add_new_anon_rmap(page, vma, addr, false);
+	mem_cgroup_commit_charge(page, memcg, false, false);
+	if (!is_zone_device_page(page))
+		lru_cache_add_active_or_unevictable(page, vma);
+	set_pte_at(mm, addr, ptep, entry);
+
+	/* Take a reference on the page */
+	get_page(page);
+
+	/* No need to invalidate - it was non-present before */
+	update_mmu_cache(vma, addr, ptep);
+	pte_unmap_unlock(ptep, ptl);
+	*src = MIGRATE_PFN_MIGRATE;
+	return;
+
+abort:
+	*src &= ~MIGRATE_PFN_MIGRATE;
+}
+
 /*
  * migrate_vma_pages() - migrate meta-data from src page to dst page
  * @migrate: migrate struct containing all migration information
@@ -2474,10 +2609,15 @@ static void migrate_vma_pages(struct migrate_vma *migrate)
 		struct address_space *mapping;
 		int r;
 
-		if (!page || !newpage)
+		if (!newpage) {
+			migrate->src[i] &= ~MIGRATE_PFN_MIGRATE;
 			continue;
-		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE))
+		} else if (!page && (migrate->src[i] & MIGRATE_PFN_MIGRATE)) {
+			migrate_vma_insert_page(migrate, addr, newpage,
+						&migrate->src[i],
+						&migrate->dst[i]);
 			continue;
+		}
 
 		mapping = page_mapping(page);
 
@@ -2527,8 +2667,14 @@ static void migrate_vma_finalize(struct migrate_vma *migrate)
 		struct page *newpage = migrate_pfn_to_page(migrate->dst[i]);
 		struct page *page = migrate_pfn_to_page(migrate->src[i]);
 
-		if (!page)
+		if (!page) {
+			if (newpage) {
+				unlock_page(newpage);
+				put_page(newpage);
+			}
 			continue;
+		}
+
 		if (!(migrate->src[i] & MIGRATE_PFN_MIGRATE) || !newpage) {
 			if (newpage) {
 				unlock_page(newpage);
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
