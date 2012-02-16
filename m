Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 6C2196B00EB
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 09:32:55 -0500 (EST)
From: =?UTF-8?q?Rados=C5=82aw=20Smogura?= <mail@smogura.eu>
Subject: [PATCH 08/18] Generic routines for defragmenting pagecache.
Date: Thu, 16 Feb 2012 15:31:35 +0100
Message-Id: <1329402705-25454-8-git-send-email-mail@smogura.eu>
In-Reply-To: <1329402705-25454-1-git-send-email-mail@smogura.eu>
References: <1329402705-25454-1-git-send-email-mail@smogura.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Yongqiang Yang <xiaoqiangnk@gmail.com>, mail@smogura.eu, linux-ext4@vger.kernel.org

Those are generic rountines with support for SHMFS (TMPFS).

Signed-off-by: RadosA?aw Smogura <mail@smogura.eu>
---
 include/linux/defrag-pagecache.h |   62 +++++
 include/linux/fs.h               |   23 ++
 mm/Makefile                      |    1 +
 mm/defrag-pagecache.c            |  489 ++++++++++++++++++++++++++++++++++++++
 4 files changed, 575 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/defrag-pagecache.h
 create mode 100644 mm/defrag-pagecache.c

diff --git a/include/linux/defrag-pagecache.h b/include/linux/defrag-pagecache.h
new file mode 100644
index 0000000..46793de
--- /dev/null
+++ b/include/linux/defrag-pagecache.h
@@ -0,0 +1,62 @@
+/*
+ * linux/include/linux/defrag-pagecache.h
+ *
+ * Defragments pagecache into compound pages
+ *
+ * (c) 2011 RadosA?aw Smogura
+ */
+
+#ifndef DEFRAG_PAGECACHE_H
+#define DEFRAG_PAGECACHE_H
+#include <linux/fs.h>
+
+/* XXX Split this file into two public and protected - comments below
+ * Protected will contain
+ * declaration of generic and helper methods for file systems developers,
+ * public just general structures and controls.
+ */
+struct file;
+struct inode;
+struct defrag_pagecache_ctl;
+struct address_space;
+
+typedef struct page *defrag_generic_get_page(
+	const struct defrag_pagecache_ctl *ctl, struct inode *inode,
+	pgoff_t pageIndex);
+
+/** Passes additional information and controls to page defragmentation. */
+struct defrag_pagecache_ctl {
+	/** If yes defragmentation will try to fill page caches. */
+	char fillPages:1;
+
+	/** If filling of page fails, defragmentation will fail too. Setting
+	 * this requires {@link #fillPages} will be setted.
+	 */
+	char requireFillPages:1;
+
+	/** If yes defragmentation will try to force in many aspects, this may
+	 * cause, operation to run longer, but with greater probability of
+	 * success. */
+	char force:1;
+};
+
+/** Defragments page cache of specified file and migrates it's to huge pages.
+ *
+ * @param f
+ * @param offset
+ * @param size
+ * @return
+ */
+extern int defragPageCache(struct file *f, unsigned long offset,
+	unsigned long size, const struct defrag_pagecache_ctl *defragCtl);
+
+/** Tries to fix to huge page mappings, buy walking through given Trnapsarent
+ * Huge Page */
+extern int thpFixMappings(struct page *hugePage);
+
+extern int defrag_generic_shm(struct file *file, struct address_space *mapping,
+			   loff_t pos,
+			   struct page **pagep,
+			   struct defrag_pagecache_ctl *ctl);
+#endif	/* DEFRAG_PAGECACHE_H */
+
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 386da09..bfd9122 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -11,6 +11,10 @@
 #include <linux/blk_types.h>
 #include <linux/types.h>
 
+#ifdef CONFIG_HUGEPAGECACHE
+#include <linux/defrag-pagecache.h>
+#endif
+
 /*
  * It's silly to have NR_OPEN bigger than NR_FILE, but you can change
  * the file limit at runtime and only root can increase the per-process
@@ -602,6 +606,25 @@ struct address_space_operations {
 				loff_t pos, unsigned len, unsigned copied,
 				struct page *page, void *fsdata);
 
+#ifdef CONFIG_HUGEPAGECACHE
+	/** Used to defrag (migrate) pages at position {@code pos}
+	 * to huge pages. Having this not {@code NULL} will indicate that
+	 * address space, generally, supports huge pages (transaprent
+	 * huge page may be established).
+	 * <br/>
+	 * It's like migrate pages, but different :)
+	 *
+	 * @param pagep on success will be setted to established huge page
+	 *
+	 * @returns TODO What to return?
+	 *	    {@code 0} on success, value less then {@code 0} on error
+	 */
+	int (*defragpage) (struct file *, struct address_space *mapping,
+				loff_t pos,
+				struct page **pagep,
+				const struct defrag_pagecache_ctl *ctl);
+#endif
+
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	sector_t (*bmap)(struct address_space *, sector_t);
 	void (*invalidatepage) (struct page *, unsigned long);
diff --git a/mm/Makefile b/mm/Makefile
index 50ec00e..75389c8 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -51,3 +51,4 @@ obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
+obj-$(CONFIG_HUGEPAGECACHE) += defrag-pagecache.o
\ No newline at end of file
diff --git a/mm/defrag-pagecache.c b/mm/defrag-pagecache.c
new file mode 100644
index 0000000..5a14fe8
--- /dev/null
+++ b/mm/defrag-pagecache.c
@@ -0,0 +1,489 @@
+/*
+ * linux/mm/defrag-pagecache.c
+ *
+ * Defragments pagecache into compound pages
+ *
+ * (c) 2011 RadosA?aw Smogura
+ */
+#include <linux/export.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <asm/pgtable.h>
+#include <linux/migrate.h>
+#include <linux/defrag-pagecache.h>
+#include <linux/pagemap.h>
+#include <linux/swap.h>
+#include <linux/rmap.h>
+#include <linux/page-flags.h>
+#include <linux/shmem_fs.h>
+#include <asm/tlbflush.h>
+#include "internal.h"
+/*#include <linux/pgtable_helper.h>*/
+
+struct migration_private {
+	loff_t startIndex;
+	pgoff_t nextIndex;
+	pgoff_t pagesToMigrateCount;
+
+	struct page *hugePage;
+	struct inode *inode;
+
+	const struct defrag_pagecache_ctl *defragCtl;
+
+	int stop;
+	int result;
+	int stoppedCompoundFound;
+
+	/** Callback method used to obtain next page. */
+	defrag_generic_get_page *getNextPage;
+};
+
+static const struct defrag_pagecache_ctl defaultDefragCtl = {
+	.fillPages = 0,
+	.requireFillPages = 0,
+	.force = 0
+};
+
+#define HUGEPAGE_ALLOC_GFP (GFP_HIGHUSER | __GFP_COMP \
+		| __GFP_REPEAT | __GFP_NOWARN | __GFP_WAIT)
+
+static int defrageOneHugePage(struct file *file, loff_t offset,
+	struct page **pagep,
+	const struct defrag_pagecache_ctl *defragCtl,
+	defrag_generic_get_page *getPage);
+
+int defragPageCache(struct file *f, unsigned long offset, unsigned long size,
+	const struct defrag_pagecache_ctl *defragCtl)
+{
+	/* Calculate requested huge page order.
+	 * XXX Is below caluclation mutliplatform?
+	 */
+	const int hugePageOrder = (PMD_SHIFT - PAGE_SHIFT);
+	const int chunkSize = 1 << hugePageOrder;
+	unsigned long offsetIdx = offset;
+	unsigned long chunksToProceed;
+
+	struct inode *inode = f->f_path.dentry->d_inode;
+
+	const struct address_space_operations *aops =
+		inode->i_mapping->a_ops;
+
+	/* TODO: Use hugepage state or something better instead of hardcoded...
+	 *       value. */
+	if ((offset != ((offset >> hugePageOrder) << hugePageOrder) ||
+		size != ((size >> hugePageOrder) << hugePageOrder))
+		/* && (size != (1 << hugePageOrder))*/) {
+		/* Start and length must be huge page "aligned". */
+		return -EINVAL;
+	}
+
+	offsetIdx = offset;
+	chunksToProceed = size >> hugePageOrder;
+	for (; chunksToProceed; chunksToProceed--, offsetIdx += chunkSize) {
+		struct page *pagep;
+		int result = aops->defragpage(f, inode->i_mapping, offsetIdx,
+			&pagep,
+			defragCtl);
+		if (result)
+			return result;
+	}
+
+	return 0;
+}
+
+/** Callback for getting page for tmpfs.
+ * Tmpfs uses {@link shmem_read_mapping_page_gfp} function to read
+ * page from page cache.
+ */
+struct page *shmem_defrag_get_page(const struct defrag_pagecache_ctl *ctl,
+	struct inode *inode, pgoff_t pageIndex)
+{
+
+	return shmem_read_mapping_page_gfp(
+				inode->i_mapping, pageIndex,
+				mapping_gfp_mask(inode->i_mapping));
+}
+
+static void defrag_generic_mig_result(struct page *oldPage,
+	struct page *newPage, struct migration_ctl *ctl, int result)
+{
+	struct migration_private *prv =
+		(struct migration_private *) ctl->privateData;
+
+	if (!result) {
+		/* Update index only on success; on fail, index will be used to
+		 * clean up. */
+		prv->nextIndex++;
+
+		if (!PageTail(newPage))
+			putback_lru_page(newPage);
+		else
+			put_page(newPage);
+	} else {
+		prv->stop = 1;
+	}
+
+	/* XXX No isolated zone status update! */
+	putback_lru_page(oldPage);
+	put_page(oldPage);
+/*
+	unlock_page(oldPage);
+*/
+
+	prv->result = result;
+}
+
+static struct page *defrag_generic_mig_page_new(struct page *oldPage,
+	struct migration_ctl *ctl)
+{
+	struct migration_private *prv =
+		(struct migration_private *) ctl->privateData;
+
+	return prv->hugePage + prv->nextIndex;
+}
+
+static struct page *defrag_generic_mig_page_next(struct migration_ctl *ctl,
+	page_mode *mode)
+{
+	struct migration_private *prv =
+		(struct migration_private *) ctl->privateData;
+	const struct defrag_pagecache_ctl *defragCtl;
+
+	/** Hold current page cache page, we are going to migrate. */
+	struct page *filePage;
+
+	struct inode *inode;
+
+	pgoff_t pageIndex;
+
+	if (!(prv->nextIndex < prv->pagesToMigrateCount))
+		return NULL;
+
+	if (prv->result || prv->stop)
+		return NULL;
+
+	inode = prv->inode;
+	pageIndex = prv->startIndex + prv->nextIndex;
+	defragCtl = prv->defragCtl;
+
+repeat_find:
+	filePage = find_lock_page(inode->i_mapping, pageIndex);
+
+	if (filePage)
+		if (PageUptodate(filePage))
+				goto skip_fill_pages;
+
+	/* Try to upread page, if this was intention of caller,
+	 * we don't need to check if page is writeback, migrate pages do it. */
+	if (!defragCtl->fillPages) {
+		prv->result = 0;
+		prv->stop = 1;
+		return NULL;
+	}
+
+	filePage = prv->getNextPage(prv->defragCtl, inode, pageIndex);
+
+	if (IS_ERR(filePage)) {
+		prv->result = PTR_ERR(filePage);
+		prv->stop = 1;
+		return NULL;
+	}
+
+	lock_page(filePage);
+	/* Validate page */
+	if (!filePage->mapping
+			|| filePage->index != pageIndex
+			|| !PageUptodate(filePage)) {
+		unlock_page(filePage);
+		goto repeat_find;
+	}
+
+skip_fill_pages:
+	if (/* ??? !defragCtl->fillPages && */ PageCompound(filePage)) {
+		/* Heare I think about giving support that in page
+		 * cache may exists huge page but not uptodate whole.
+		 *
+		 * Currently this idea is suspended, due to many
+		 * complications.
+		 */
+		prv->stoppedCompoundFound = 1;
+		goto out_unlock_and_stop;
+	}
+
+	/* Prepare page for isolation, check if it can be isolated. */
+	if (!PageLRU(filePage)) {
+		if (defragCtl->force) {
+			/* Isolation requires page in LRU, we may need to drain
+			 * it if not present. */
+			lru_add_drain();
+			if (!PageLRU(filePage)) {
+				lru_add_drain_all();
+				if (!PageLRU(filePage)) {
+					prv->result = -EBUSY;
+					goto out_unlock_and_stop;
+				}
+			}
+		} else {
+			prv->result = -EBUSY;
+			goto out_unlock_and_stop;
+		}
+	}
+
+	/* Isolate pages. */
+	if (isolate_lru_page(filePage)) {
+		prv->result = -EBUSY;
+		goto putback_page_and_stop;
+	}
+
+	*mode = PAGE_LOCKED;
+	return filePage;
+
+putback_page_and_stop:
+	putback_lru_page(filePage);
+
+out_unlock_and_stop:
+	unlock_page(filePage);
+	put_page(filePage);
+
+	return NULL;
+
+}
+
+int defrag_generic_shm(struct file *file, struct address_space *mapping,
+			   loff_t pos,
+			   struct page **pagep,
+			   struct defrag_pagecache_ctl *ctl)
+{
+	return defrageOneHugePage(file, pos, pagep, ctl, shmem_defrag_get_page);
+}
+EXPORT_SYMBOL(defrag_generic_shm);
+
+int defrag_generic_pagecache(struct file *file,
+			struct address_space *mapping,
+			loff_t pos,
+			struct page **pagep,
+			struct defrag_pagecache_ctl *ctl)
+{
+	/* As we do not support generic page cache defragmentaion, yet. */
+	BUG();
+	return 0;
+}
+/** Internal method for defragmenting one chunk of page cache.
+ *
+ * <br/>
+ * This is in some
+ * way common logic to operate on page cache. It's highly probably that this
+ * method will be exposed as "generic" to add support for transparent
+ * huge pages for page cache.
+ */
+static int defrageOneHugePage(struct file *file, loff_t offset,
+	struct page **pagep,
+	const struct defrag_pagecache_ctl *defragCtl,
+	defrag_generic_get_page *getPage)
+{
+	const int hugePageOrder = (PMD_SHIFT - PAGE_SHIFT);
+
+	/** Huge page we migrate to. */
+	struct page *hugePage;
+
+	/** Private migration data. */
+	struct migration_private migrationPrv;
+
+	struct migration_ctl migration_ctl;
+
+	struct inode *inode = file->f_path.dentry->d_inode;
+
+	const int size = 1 << hugePageOrder;
+
+	/** Helpers */
+	pgoff_t i;
+
+	/* Over here we callback based migration. */
+	/* READ.
+	 *
+	 * This code is in develop stage, and following problems must be
+	 * resolved:
+	 * - page is read from page cache, but lock is droped, in meantime
+	 *   page may be no longer up to date, or may be removed from
+	 *   page cache. This will be resolved by changing migrat function
+	 */
+	/* Allocate one huge page. */
+	hugePage = alloc_pages(HUGEPAGE_ALLOC_GFP, hugePageOrder);
+	if (!hugePage)
+		return -ENOMEM;
+
+	migrationPrv.nextIndex = 0;
+	migrationPrv.pagesToMigrateCount = size;
+	migrationPrv.hugePage = hugePage;
+	migrationPrv.stop = 0;
+	migrationPrv.result = 0;
+	migrationPrv.stoppedCompoundFound = 0;
+	migrationPrv.getNextPage = getPage;
+	migrationPrv.startIndex = offset;
+	migrationPrv.inode = inode;
+	migrationPrv.defragCtl =
+		(const struct defrag_pagecache_ctl *) defragCtl;
+	/* Elevate page counts */
+	for (i = 1; i < size; i++) {
+		struct page *p = hugePage + i;
+		/* Elevate page counters. */
+		get_page(p);
+	}
+
+	migration_ctl.getNextPage = defrag_generic_mig_page_next;
+	migration_ctl.getNewPage = defrag_generic_mig_page_new;
+	migration_ctl.notifyResult = defrag_generic_mig_result;
+	migration_ctl.privateData = (unsigned long) &migrationPrv;
+
+	/* Aquire compund lock. */
+	compound_lock(hugePage);
+
+	/* Migrate pages. Currently page migrate will auto put back pages,
+	 * and may fail and repeat, we need array of pages, to match
+	 * each subpage. This behaviour isn't good.
+	 */
+	migrate_pages_cb(&migration_ctl, true,
+		MIGRATE_SYNC | MIGRATE_SRC_GETTED);
+	if (migrationPrv.nextIndex < migrationPrv.pagesToMigrateCount) {
+		/* XXX Simulate various bugs, at least do it hardcoded. */
+		/* XXX Everything here is BUG, because need to opcode spliting
+		 */
+		if (migrationPrv.stoppedCompoundFound) {
+			/* If any page has been migrated it's a BUG */
+			BUG_ON(migrationPrv.nextIndex);
+			goto compound_unlock_end;
+		}
+		/* Not all pages has been migrated, split target page. */
+		/* Downgrade counts of tail pages - may cause deadlock. */
+		VM_BUG_ON(1);
+	} else {
+		goto compound_unlock_end;
+	}
+
+compound_unlock_end:
+	compound_unlock(hugePage);
+/*
+	put_page(hugePage);
+*/
+
+	/* All file pages are unlocked, and should be freed. Huge should be on
+	 * Unevictable list.
+	 */
+	return migrationPrv.result;
+}
+
+static int thpFixMappingsRmapWalk(struct page *page, struct vm_area_struct *vma,
+	unsigned long addr, void *prvData) {
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd, _pmd;
+	pte_t *pte;
+
+	int i;
+
+/*
+	printk(KERN_INFO "Starting address is %lx", addr);
+*/
+	if (vma->vm_flags & VM_NONLINEAR || (addr & ~HPAGE_PMD_MASK)) {
+		/* Skip nonlinear VMAs, and not aligned addresses*/
+		return SWAP_AGAIN;
+	}
+
+	/* We will set pmd only if all tail pages meets following requirements:
+	 * - all pages are up to data
+	 * - all pages have same protection bits
+	 * - ???
+	 */
+	pgd = pgd_offset(vma->vm_mm, addr);
+	if (!pgd_present(*pgd))
+		return SWAP_AGAIN;
+
+	pud = pud_offset(pgd, addr);
+	if (!pud_present(*pud))
+		return SWAP_AGAIN;
+
+	pmd = pmd_offset(pud, addr);
+	if (!pmd_present(*pmd))
+		return SWAP_AGAIN;
+
+	pte = (pte_t *) pmd;
+	if (pte_huge(*pte))
+		return SWAP_AGAIN;
+
+
+	/*printk(KERN_INFO "Checking head flags"); */
+	pte = pte_offset_map(pmd, addr);
+	if (!pte_present(*pte)) {
+		/* printk(KERN_INFO "Pte not present."); */
+		pte_unmap(pte);
+		return SWAP_AGAIN;
+	}
+
+	for (i = 1; i < HPAGE_PMD_NR; i++) {
+		struct page *tail_page;
+
+		addr += PAGE_SIZE;
+
+		pte = pte_offset_map(pmd, addr);
+		if (!pte_present(*pte)) {
+			/*
+			 * printk(KERN_INFO "No %d pte returning.", i);
+			 */
+			pte_unmap(pte);
+			return SWAP_AGAIN;
+		}
+
+		tail_page = pte_page(*pte);
+		if (!tail_page) {
+			/* printk(KERN_INFO "Page +%d not present.", i); */
+			goto unmap_out;
+		}
+
+		/* We check index, howver we do not allow not linear mapping :)
+		 */
+		/* smp_mb(); */
+		int i1 = tail_page->mapping == page->mapping;
+		int i2 = tail_page->index == (page->index + i);
+		if (i1 && i2) {
+			/*
+			printk(KERN_INFO "Page +%d present mappings and"
+				" indices ok", i);
+			*/
+		} else {
+			printk(KERN_INFO "Page +%d has good mapping %d, and"
+				" good index %d (%d, %d).",
+				i,
+				i1,
+				i2,
+				tail_page->index,
+				page->index);
+			goto unmap_out;
+		}
+		pte_unmap(pte);
+	}
+	pmd_clear(pmd);
+	_pmd = pmd_mkhuge(pmd_modify(*pmd, vma->vm_page_prot));
+
+	set_pmd_at(vma->vm_mm, addr, pmd, _pmd);
+	/* Everything is ok. */
+
+	/* TODO Do not flush all :) */
+	flush_tlb_mm(vma->vm_mm);
+	printk(KERN_INFO "Replaced by pmd");
+	return SWAP_AGAIN;
+unmap_out:
+	pte_unmap(pte);
+
+	return SWAP_AGAIN;
+}
+
+int thpFixMappings(struct page *hugePage)
+{
+	BUG_ON(PageAnon(hugePage));
+	/* lock_page(hugePage); */
+	BUG_ON(!PageTransHuge(hugePage));
+	rmap_walk(hugePage, thpFixMappingsRmapWalk, NULL);
+	/* unlock_page(hugePage); */
+
+	return 0;
+}
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
