Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2D9FA6B003D
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 16:24:21 -0500 (EST)
Subject: Re: [RFC] high system time & lock contention running large mixed
	workload
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <4B1857ED.30304@redhat.com>
References: <20091125133752.2683c3e4@bree.surriel.com>
	 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
	 <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
	 <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>
	 <4B15CEE0.2030503@redhat.com>
	 <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
	 <4B1857ED.30304@redhat.com>
Content-Type: multipart/mixed; boundary="=-aaFOjjHa7REDHnjwFPUm"
Date: Fri, 04 Dec 2009 16:26:52 -0500
Message-Id: <1259962013.3221.8.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>


--=-aaFOjjHa7REDHnjwFPUm
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2009-12-03 at 19:29 -0500, Rik van Riel wrote:
> On 12/03/2009 05:14 PM, Larry Woodman wrote:
> 
> > The attached patch addresses this issue by changing page_check_address()
> > to return -1 if the spin_trylock() fails and page_referenced_one() to
> > return 1 in that path so the page gets moved back to the active list.
> 
> Your patch forgot to add the code to vmscan.c to actually move
> the page back to the active list.

Right

> 
> Also, please use an enum for the page_referenced return
> values, so the code in vmscan.c can use symbolic names.
> 
> enum page_reference {
> 	NOT_REFERENCED,
> 	REFERENCED,
> 	LOCK_CONTENDED,
> };
> 

Here it is:




--=-aaFOjjHa7REDHnjwFPUm
Content-Disposition: attachment; filename=page_referenced.patch
Content-Type: text/x-patch; name=page_referenced.patch; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index cb0ba70..2b931c8 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -76,11 +76,17 @@ static inline void page_dup_rmap(struct page *page)
 	atomic_inc(&page->_mapcount);
 }
 
+enum page_referenced {
+	NOT_REFERENCED,
+	REFERENCED,
+	LOCK_CONTENDED,
+};
+
 /*
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
+			struct mem_cgroup *cnt, unsigned long *vm_flags, int trylock);
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
 	TTU_MIGRATION = 1,		/* migration mode */
@@ -99,7 +105,7 @@ int try_to_unmap(struct page *, enum ttu_flags flags);
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
 pte_t *page_check_address(struct page *, struct mm_struct *,
-				unsigned long, spinlock_t **, int);
+				unsigned long, spinlock_t **, int, int);
 
 /*
  * Used by swapoff to help locate where page is expected in vma.
@@ -135,10 +141,11 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *cnt,
-				  unsigned long *vm_flags)
+				  unsigned long *vm_flags,
+				  int trylock)
 {
 	*vm_flags = 0;
-	return TestClearPageReferenced(page);
+	return (TestClearPageReferenced(page)?REFERENCED:NOT_REFERENCED);
 }
 
 #define try_to_unmap(page, refs) SWAP_FAIL
diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index 1888b2d..35be29d 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -188,7 +188,7 @@ retry:
 		address = vma->vm_start +
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
-		pte = page_check_address(page, mm, address, &ptl, 1);
+		pte = page_check_address(page, mm, address, &ptl, 1, 0);
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
diff --git a/mm/ksm.c b/mm/ksm.c
index 5575f86..8abb14b 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -623,7 +623,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 	if (addr == -EFAULT)
 		goto out;
 
-	ptep = page_check_address(page, mm, addr, &ptl, 0);
+	ptep = page_check_address(page, mm, addr, &ptl, 0, 0);
 	if (!ptep)
 		goto out;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index dd43373..2b15a18 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -270,7 +270,7 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
  * On success returns with pte mapped and locked.
  */
 pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp, int sync)
+			  unsigned long address, spinlock_t **ptlp, int sync, int trylock)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -298,7 +298,13 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 	}
 
 	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	if (trylock) {
+		if (!spin_trylock(ptl)) {
+			pte_unmap(pte);
+			return (pte_t *)-1;
+		}
+	} else
+		spin_lock(ptl);
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;
@@ -325,7 +331,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 	address = vma_address(page, vma);
 	if (address == -EFAULT)		/* out of vma range */
 		return 0;
-	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1);
+	pte = page_check_address(page, vma->vm_mm, address, &ptl, 1, 0);
 	if (!pte)			/* the page is not in this mm */
 		return 0;
 	pte_unmap_unlock(pte, ptl);
@@ -340,7 +346,8 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
 static int page_referenced_one(struct page *page,
 			       struct vm_area_struct *vma,
 			       unsigned int *mapcount,
-			       unsigned long *vm_flags)
+			       unsigned long *vm_flags,
+			       int trylock)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -352,9 +359,11 @@ static int page_referenced_one(struct page *page,
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
+	pte = page_check_address(page, mm, address, &ptl, 0, trylock);
 	if (!pte)
 		goto out;
+	else if (pte == (pte_t *)-1)
+		return LOCK_CONTENDED;
 
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
@@ -391,21 +400,24 @@ out_unmap:
 out:
 	if (referenced)
 		*vm_flags |= vma->vm_flags;
-	return referenced;
+	return (referenced?REFERENCED:NOT_REFERENCED);
 }
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				int trylock)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
 	int referenced = 0;
+	int locked = 0;
+	int ret;
 
 	anon_vma = page_lock_anon_vma(page);
 	if (!anon_vma)
-		return referenced;
+		return NOT_REFERENCED;
 
 	mapcount = page_mapcount(page);
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
@@ -416,14 +428,19 @@ static int page_referenced_anon(struct page *page,
 		 */
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
-		referenced += page_referenced_one(page, vma,
-						  &mapcount, vm_flags);
+		ret = page_referenced_one(page, vma,
+						  &mapcount, vm_flags, trylock);
+		if (ret == LOCK_CONTENDED)
+			locked++;
+		else if (ret == REFERENCED)
+			referenced++;
+		
 		if (!mapcount)
 			break;
 	}
 
 	page_unlock_anon_vma(anon_vma);
-	return referenced;
+	return (locked?LOCK_CONTENDED:referenced?REFERENCED:NOT_REFERENCED);
 }
 
 /**
@@ -482,13 +499,13 @@ static int page_referenced_file(struct page *page,
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags, 0);
 		if (!mapcount)
 			break;
 	}
 
 	spin_unlock(&mapping->i_mmap_lock);
-	return referenced;
+	return (referenced?REFERENCED:NOT_REFERENCED);
 }
 
 /**
@@ -497,6 +514,7 @@ static int page_referenced_file(struct page *page,
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @trylock: use spin_trylock to prevent high lock contention.
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -504,9 +522,11 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int trylock)
 {
 	int referenced = 0;
+	int ret = NOT_REFERENCED;
 
 	if (TestClearPageReferenced(page))
 		referenced++;
@@ -514,25 +534,28 @@ int page_referenced(struct page *page,
 	*vm_flags = 0;
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
-			referenced += page_referenced_anon(page, mem_cont,
-								vm_flags);
+			ret = page_referenced_anon(page, mem_cont,
+						     		vm_flags, trylock);
 		else if (is_locked)
-			referenced += page_referenced_file(page, mem_cont,
+			ret = page_referenced_file(page, mem_cont,
 								vm_flags);
 		else if (!trylock_page(page))
 			referenced++;
 		else {
-			if (page->mapping)
-				referenced += page_referenced_file(page,
+			if (page->mapping) {
+				ret = page_referenced_file(page,
 							mem_cont, vm_flags);
+			}
 			unlock_page(page);
 		}
 	}
 
+	if (ret == REFERENCED)
+		referenced++;
 	if (page_test_and_clear_young(page))
 		referenced++;
 
-	return referenced;
+	return (ret == LOCK_CONTENDED?LOCK_CONTENDED:(referenced?REFERENCED:NOT_REFERENCED));
 }
 
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
@@ -547,7 +570,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 1);
+	pte = page_check_address(page, mm, address, &ptl, 1, 0);
 	if (!pte)
 		goto out;
 
@@ -774,7 +797,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
+	pte = page_check_address(page, mm, address, &ptl, 0, 0);
 	if (!pte)
 		goto out;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 777af57..5543278 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -643,14 +643,14 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		referenced = page_referenced(page, 1,
-						sc->mem_cgroup, &vm_flags);
+						sc->mem_cgroup, &vm_flags, 0);
 		/*
 		 * In active use or really unfreeable?  Activate it.
 		 * If page which have PG_mlocked lost isoltation race,
 		 * try_to_unmap moves it to unevictable list
 		 */
 		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page)
+					(referenced == REFERENCED) && page_mapping_inuse(page)
 					&& !(vm_flags & VM_LOCKED))
 			goto activate_locked;
 
@@ -686,7 +686,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
+			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && (referenced == REFERENCED))
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
@@ -1320,6 +1320,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	struct page *page;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 	unsigned long nr_rotated = 0;
+	int referenced;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1354,21 +1355,27 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		}
 
 		/* page_referenced clears PageReferenced */
-		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
-			nr_rotated++;
-			/*
-			 * Identify referenced, file-backed active pages and
-			 * give them one more trip around the active list. So
-			 * that executable code get better chances to stay in
-			 * memory under moderate memory pressure.  Anon pages
-			 * are not likely to be evicted by use-once streaming
-			 * IO, plus JVM can create lots of anon VM_EXEC pages,
-			 * so we ignore them here.
-			 */
-			if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
-				list_add(&page->lru, &l_active);
-				continue;
+		if (page_mapping_inuse(page)) { 
+		   
+			referenced = page_referenced(page, 0, sc->mem_cgroup,
+						&vm_flags, priority<DEF_PRIORITY-2?0:1);
+
+			if (referenced != NOT_REFERENCED) {
+				nr_rotated++;
+				/*
+				 * Identify referenced, file-backed active pages and
+				 * give them one more trip around the active list. So
+				 * that executable code get better chances to stay in
+				 * memory under moderate memory pressure.  Anon pages
+				 * are not likely to be evicted by use-once streaming
+				 * IO, plus JVM can create lots of anon VM_EXEC pages,
+				 * so we ignore them here.
+				 */
+				if (((vm_flags & VM_EXEC) && page_is_file_cache(page)) ||
+				     (referenced == LOCK_CONTENDED)) {
+					list_add(&page->lru, &l_active);
+					continue;
+				}
 			}
 		}
 

--=-aaFOjjHa7REDHnjwFPUm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
