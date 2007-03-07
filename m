Date: Wed, 7 Mar 2007 09:59:44 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 4/6] mm: merge populate and nopage into fault (fixes nonlinear)
Message-ID: <20070307085944.GA17433@wotan.suse.de>
References: <20070221023656.6306.246.sendpatchset@linux.site> <20070221023735.6306.83373.sendpatchset@linux.site> <20070306225101.f393632c.akpm@linux-foundation.org> <20070307070853.GB15877@wotan.suse.de> <20070307081948.GA9563@wotan.suse.de> <20070307082755.GA25733@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070307082755.GA25733@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 07, 2007 at 09:27:55AM +0100, Ingo Molnar wrote:
> 
> * Nick Piggin <npiggin@suse.de> wrote:
> 
> > Then 4,5,6 is the fault/nonlinear rewrite, take it or leave it. I 
> > thought you would have liked the patches...
> 
> btw., if we decide that nonlinear isnt worth the continuing maintainance 
> pain, we could internally implement/emulate sys_remap_file_pages() via a 
> call to mremap() and essentially deprecate it, without breaking the ABI 
> - and remove all the nonlinear code. (This would split fremap areas into 
> separate vmas)

Well I think it has a few possible uses outside the PAE database
workloads. UML for one seem to be interested... as much as I don't
use them, I think nonlinear mappings are kinda cool ;)

After these patches, I don't think there is too much burden. The main
thing left really is just the objrmap stuff, but that is just handled
with a minimal 'dumb' algorithm that doesn't cost much.

Then the core of it is just the file pte handling, which really doesn't
seem to be much problem.

Apart from a handful of trivial if (pte_file()) cases throughout mm/,
our maintainance burden basically now amounts to the following patch.
Even the rmap.c change looks bigger than it is because I split out
the nonlinear unmapping code from try_to_unmap_file. Not too bad, eh? :)

--

 include/asm-powerpc/pgtable.h |   12 ++++
 mm/Kconfig                    |    6 ++
 mm/Makefile                   |    6 +-
 mm/rmap.c                     |  101 +++++++++++++++++++++++++-----------------
 4 files changed, 83 insertions(+), 42 deletions(-)

Index: linux-2.6/include/asm-powerpc/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/pgtable.h
+++ linux-2.6/include/asm-powerpc/pgtable.h
@@ -243,7 +243,12 @@ static inline int pte_write(pte_t pte) {
 static inline int pte_exec(pte_t pte)  { return pte_val(pte) & _PAGE_EXEC;}
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY;}
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED;}
+
+#ifdef CONFIG_NONLINEAR
 static inline int pte_file(pte_t pte) { return pte_val(pte) & _PAGE_FILE;}
+#else
+static inline int pte_file(pte_t pte) { return 0; }
+#endif
 
 static inline void pte_uncache(pte_t pte) { pte_val(pte) |= _PAGE_NO_CACHE; }
 static inline void pte_cache(pte_t pte)   { pte_val(pte) &= ~_PAGE_NO_CACHE; }
@@ -483,9 +488,16 @@ extern void update_mmu_cache(struct vm_a
 #define __swp_entry(type, offset) ((swp_entry_t){((type)<< 1)|((offset)<<8)})
 #define __pte_to_swp_entry(pte)	((swp_entry_t){pte_val(pte) >> PTE_RPN_SHIFT})
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val << PTE_RPN_SHIFT })
+
+#ifdef CONFIG_NONLINEAR
 #define pte_to_pgoff(pte)	(pte_val(pte) >> PTE_RPN_SHIFT)
 #define pgoff_to_pte(off)	((pte_t) {((off) << PTE_RPN_SHIFT)|_PAGE_FILE})
 #define PTE_FILE_MAX_BITS	(BITS_PER_LONG - PTE_RPN_SHIFT)
+#else
+#define pte_to_pgoff(pte)	({BUG(); -1;})
+#define pgoff_to_pte(off)	({BUG(); (pte_t){-1};})
+#define PTE_FILE_MAX_BITS	0
+#endif
 
 /*
  * kern_addr_valid is intended to indicate whether an address is a valid
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -142,6 +142,12 @@ config SPLIT_PTLOCK_CPUS
 #
 # support for page migration
 #
+config NONLINEAR
+	bool "Non linear mappings"
+	def_bool y
+	help
+	  Provides support for the remap_file_pages syscall.
+
 config MIGRATION
 	bool "Page migration"
 	def_bool y
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -3,9 +3,8 @@
 #
 
 mmu-y			:= nommu.o
-mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
-			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o
+mmu-$(CONFIG_MMU)	:= highmem.o madvise.o memory.o mincore.o mlock.o \
+			   mmap.o mprotect.o mremap.o msync.o rmap.o vmalloc.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
@@ -27,5 +26,6 @@ obj-$(CONFIG_SLOB) += slob.o
 obj-$(CONFIG_SLAB) += slab.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
+obj-$(CONFIG_NONLINEAR) += fremap.o
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -756,6 +756,7 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_NONLINEAR
 /*
  * objrmap doesn't work for nonlinear VMAs because the assumption that
  * offset-into-file correlates with offset-into-virtual-addresses does not hold.
@@ -845,53 +846,18 @@ static void try_to_unmap_cluster(unsigne
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
-static int try_to_unmap_anon(struct page *page, int migration)
-{
-	struct anon_vma *anon_vma;
-	struct vm_area_struct *vma;
-	int ret = SWAP_AGAIN;
-
-	anon_vma = page_lock_anon_vma(page);
-	if (!anon_vma)
-		return ret;
-
-	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
-			break;
-	}
-
-	page_unlock_anon_vma(anon_vma);
-	return ret;
-}
-
-/**
- * try_to_unmap_file - unmap file page using the object-based rmap method
- * @page: the page to unmap
- *
- * Find all the mappings of a page using the mapping pointer and the vma chains
- * contained in the address_space struct it points to.
- *
- * This function is only called from try_to_unmap for object-based pages.
+/*
+ * Called with page->mapping->i_mmap_lock held.
  */
-static int try_to_unmap_file(struct page *page, int migration)
+static int try_to_unmap_file_nonlinear(struct page *page, int migration)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 	struct vm_area_struct *vma;
-	struct prio_tree_iter iter;
-	int ret = SWAP_AGAIN;
 	unsigned long cursor;
 	unsigned long max_nl_cursor = 0;
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
-
-	spin_lock(&mapping->i_mmap_lock);
-	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, migration);
-		if (ret == SWAP_FAIL || !page_mapped(page))
-			goto out;
-	}
+	int ret = SWAP_AGAIN;
 
 	if (list_empty(&mapping->i_mmap_nonlinear))
 		goto out;
@@ -956,6 +922,63 @@ static int try_to_unmap_file(struct page
 	 */
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
+
+out:
+	return ret;
+}
+
+#else /* CONFIG_NONLINEAR */
+static int try_to_unmap_file_nonlinear(struct page *page, int migration)
+{
+	return SWAP_AGAIN;
+}
+#endif
+
+static int try_to_unmap_anon(struct page *page, int migration)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	int ret = SWAP_AGAIN;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return ret;
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		ret = try_to_unmap_one(page, vma, migration);
+		if (ret == SWAP_FAIL || !page_mapped(page))
+			break;
+	}
+
+	page_unlock_anon_vma(anon_vma);
+	return ret;
+}
+
+/**
+ * try_to_unmap_file - unmap file page using the object-based rmap method
+ * @page: the page to unmap
+ *
+ * Find all the mappings of a page using the mapping pointer and the vma chains
+ * contained in the address_space struct it points to.
+ *
+ * This function is only called from try_to_unmap for object-based pages.
+ */
+static int try_to_unmap_file(struct page *page, int migration)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	int ret = SWAP_AGAIN;
+
+	spin_lock(&mapping->i_mmap_lock);
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		ret = try_to_unmap_one(page, vma, migration);
+		if (ret == SWAP_FAIL || !page_mapped(page))
+			goto out;
+	}
+
+	ret = try_to_unmap_file_nonlinear(page, migration);
 out:
 	spin_unlock(&mapping->i_mmap_lock);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
