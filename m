Date: Fri, 7 Mar 2008 16:17:22 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [PATCH] 2/4 move all invalidate_page outside of PT lock (#v9 was
	1/4)
Message-ID: <20080307151722.GD24114@v2.random>
References: <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com> <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com> <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 04, 2008 at 02:35:21PM -0800, Christoph Lameter wrote:
> It is the atomic dead end that we want to avoid. And your patch is exactly 
> that. Both the invalidate_page and the RCU locks us into this.

I preferred to answer with code to avoid any possible misunderstanding
(I through already tried to explain with words and I obviously failed
miserably if you ended up writing such an erratic weird claim like
above ;).

This below simple patch invalidates the "invalidate_page" part, the
next patch will invalidate the RCU part, and btw in a way that doesn't
forbid unregistering the mmu notifiers at runtime (like your brand new
EMM does).

This is incremental with my #v9. I still ask Andrew/Linus to merge the
#v9 patch I posted a few days ago in .25 so KVM/GRU will be 100%
covered in a optimal way on all respects and with maximum flexibility
for future changes of API (to allow for future methods that may take
more than start,end, this was pointed out once by both me and Avi). My
#v9 is zero risk for .25 and it sure worth merging now.

Then in .26 we'll modify the semantics of the API to be blocking
starting with the below patchx. This is a kernel _internal_ API, and
we aren't distributions that have to respect kabi here, but even if we
were, making methods sleepable is a 100% backwards compatible
semantical change, so there's no possible reason to defer the #v9
merging. The changes in .26 will be transparent to any user (even if
they don't need to! even if we turn out to be totally wrong about .26
requiring a minor change of API everything will be perfectly
fine). Nothing of this is visible to userland so we can change it at
any time as we wish.

The reason I keep this incremental (unlike your EMM that does
everything all at the same time mixed in a single patch) is to
decrease the non obviously safe mangling over mm/* during .25. The
below patch is simple, but not as obviously safe as
s/ptep_clear_flush/ptep_clear_flush_notify/.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -134,27 +134,6 @@ static inline void mmu_notifier_mm_init(
 
 
 
-#define ptep_clear_flush_notify(__vma, __address, __ptep)		\
-({									\
-	pte_t __pte;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__pte = ptep_clear_flush(___vma, ___address, __ptep);		\
-	mmu_notifier_invalidate_page(___vma->vm_mm, ___address);	\
-	__pte;								\
-})
-
-#define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-({									\
-	int __young;							\
-	struct vm_area_struct *___vma = __vma;				\
-	unsigned long ___address = __address;				\
-	__young = ptep_clear_flush_young(___vma, ___address, __ptep);	\
-	__young |= mmu_notifier_clear_flush_young(___vma->vm_mm,	\
-						  ___address);		\
-	__young;							\
-})
-
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -186,9 +165,6 @@ static inline void mmu_notifier_mm_init(
 {
 }
 
-#define ptep_clear_flush_young_notify ptep_clear_flush_young
-#define ptep_clear_flush_notify ptep_clear_flush
-
 #endif /* CONFIG_MMU_NOTIFIER */
 
 #endif /* _LINUX_MMU_NOTIFIER_H */
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -194,11 +194,13 @@ __xip_unmap (struct address_space * mapp
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
-			pteval = ptep_clear_flush_notify(vma, address, pte);
+			pteval = ptep_clear_flush(vma, address, pte);
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
 			pte_unmap_unlock(pte, ptl);
+			/* must invalidate_page _before_ freeing the page */
+			mmu_notifier_invalidate_page(mm, address);
 			page_cache_release(page);
 		}
 	}
diff --git a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1626,9 +1626,10 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
+			new_page = NULL;
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
+			page_cache_release(old_page);
 
 			page_mkwrite = 1;
 		}
@@ -1644,6 +1645,7 @@ static int do_wp_page(struct mm_struct *
 		if (ptep_set_access_flags(vma, address, page_table, entry,1))
 			update_mmu_cache(vma, address, entry);
 		ret |= VM_FAULT_WRITE;
+		old_page = new_page = NULL;
 		goto unlock;
 	}
 
@@ -1688,7 +1690,7 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
+		ptep_clear_flush(vma, address, page_table);
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		lru_cache_add_active(new_page);
@@ -1700,12 +1702,18 @@ gotten:
 	} else
 		mem_cgroup_uncharge_page(new_page);
 
-	if (new_page)
+unlock:
+	pte_unmap_unlock(page_table, ptl);
+
+	if (new_page) {
+		if (new_page == old_page)
+			/* cow happened, notify before releasing old_page */
+			mmu_notifier_invalidate_page(mm, address);
 		page_cache_release(new_page);
+	}
 	if (old_page)
 		page_cache_release(old_page);
-unlock:
-	pte_unmap_unlock(page_table, ptl);
+
 	if (dirty_page) {
 		if (vma->vm_file)
 			file_update_time(vma->vm_file);
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -275,7 +275,7 @@ static int page_referenced_one(struct pa
 	unsigned long address;
 	pte_t *pte;
 	spinlock_t *ptl;
-	int referenced = 0;
+	int referenced = 0, clear_flush_young = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
@@ -288,8 +288,11 @@ static int page_referenced_one(struct pa
 	if (vma->vm_flags & VM_LOCKED) {
 		referenced++;
 		*mapcount = 1;	/* break early from loop */
-	} else if (ptep_clear_flush_young_notify(vma, address, pte))
-		referenced++;
+	} else {
+		clear_flush_young = 1;
+		if (ptep_clear_flush_young(vma, address, pte))
+			referenced++;
+	}
 
 	/* Pretend the page is referenced if the task has the
 	   swap token and is in the middle of a page fault. */
@@ -299,6 +302,10 @@ static int page_referenced_one(struct pa
 
 	(*mapcount)--;
 	pte_unmap_unlock(pte, ptl);
+
+	if (clear_flush_young)
+		referenced += mmu_notifier_clear_flush_young(mm, address);
+
 out:
 	return referenced;
 }
@@ -455,7 +462,7 @@ static int page_mkclean_one(struct page 
 		pte_t entry;
 
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		entry = ptep_clear_flush_notify(vma, address, pte);
+		entry = ptep_clear_flush(vma, address, pte);
 		entry = pte_wrprotect(entry);
 		entry = pte_mkclean(entry);
 		set_pte_at(mm, address, pte, entry);
@@ -463,6 +470,10 @@ static int page_mkclean_one(struct page 
 	}
 
 	pte_unmap_unlock(pte, ptl);
+
+	if (ret)
+		mmu_notifier_invalidate_page(mm, address);
+
 out:
 	return ret;
 }
@@ -712,15 +723,14 @@ static int try_to_unmap_one(struct page 
 	 * If it's recently referenced (perhaps page_referenced
 	 * skipped over this mm) then we should reactivate it.
 	 */
-	if (!migration && ((vma->vm_flags & VM_LOCKED) ||
-			(ptep_clear_flush_young_notify(vma, address, pte)))) {
+	if (!migration && (vma->vm_flags & VM_LOCKED)) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
 
 	/* Nuke the page table entry. */
 	flush_cache_page(vma, address, page_to_pfn(page));
-	pteval = ptep_clear_flush_notify(vma, address, pte);
+	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
@@ -775,6 +785,8 @@ static int try_to_unmap_one(struct page 
 
 out_unmap:
 	pte_unmap_unlock(pte, ptl);
+	if (ret != SWAP_FAIL)
+		mmu_notifier_invalidate_page(mm, address);
 out:
 	return ret;
 }
@@ -813,7 +825,7 @@ static void try_to_unmap_cluster(unsigne
 	spinlock_t *ptl;
 	struct page *page;
 	unsigned long address;
-	unsigned long end;
+	unsigned long start, end;
 
 	address = (vma->vm_start + cursor) & CLUSTER_MASK;
 	end = address + CLUSTER_SIZE;
@@ -834,6 +846,8 @@ static void try_to_unmap_cluster(unsigne
 	if (!pmd_present(*pmd))
 		return;
 
+	start = address;
+	mmu_notifier_invalidate_range_begin(mm, start, end);
 	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 
 	/* Update high watermark before we lower rss */
@@ -845,12 +859,12 @@ static void try_to_unmap_cluster(unsigne
 		page = vm_normal_page(vma, address, *pte);
 		BUG_ON(!page || PageAnon(page));
 
-		if (ptep_clear_flush_young_notify(vma, address, pte))
+		if (ptep_clear_flush_young(vma, address, pte))
 			continue;
 
 		/* Nuke the page table entry. */
 		flush_cache_page(vma, address, pte_pfn(*pte));
-		pteval = ptep_clear_flush_notify(vma, address, pte);
+		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
 		if (page->index != linear_page_index(vma, address))
@@ -866,6 +880,7 @@ static void try_to_unmap_cluster(unsigne
 		(*mapcount)--;
 	}
 	pte_unmap_unlock(pte - 1, ptl);
+	mmu_notifier_invalidate_range_end(mm, start, end);
 }
 
 static int try_to_unmap_anon(struct page *page, int migration)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
