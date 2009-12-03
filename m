Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5E643600762
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 17:11:38 -0500 (EST)
Subject: Re: [RFC] high system time & lock contention running large mixed
	workload
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <4B15CEE0.2030503@redhat.com>
References: <20091125133752.2683c3e4@bree.surriel.com>
	 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
	 <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
	 <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>
	 <4B15CEE0.2030503@redhat.com>
Content-Type: multipart/mixed; boundary="=-PtPyi9IWv63FBket5joZ"
Date: Thu, 03 Dec 2009 17:14:56 -0500
Message-Id: <1259878496.2345.57.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>


--=-PtPyi9IWv63FBket5joZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2009-12-01 at 21:20 -0500, Rik van Riel wrote:

> This is reasonable, except for the fact that pages that are moved
> to the inactive list without having the referenced bit cleared are
> guaranteed to be moved back to the active list.
> 
> You'll be better off without that excess list movement, by simply
> moving pages directly back onto the active list if the trylock
> fails.
> 


The attached patch addresses this issue by changing page_check_address()
to return -1 if the spin_trylock() fails and page_referenced_one() to
return 1 in that path so the page gets moved back to the active list.

Also, BTW, check this out: an 8-CPU/16GB system running AIM 7 Compute
has 196491 isolated_anon pages.  This means that ~6140 processes are
somewhere down in try_to_free_pages() since we only isolate 32 pages at
a time, this is out of 9000 processes...


---------------------------------------------------------------------
active_anon:2140361 inactive_anon:453356 isolated_anon:196491
 active_file:3438 inactive_file:1100 isolated_file:0
 unevictable:2802 dirty:153 writeback:0 unstable:0
 free:578920 slab_reclaimable:49214 slab_unreclaimable:93268
 mapped:1105 shmem:0 pagetables:139100 bounce:0

Node 0 Normal free:1647892kB min:12500kB low:15624kB high:18748kB 
active_anon:7835452kB inactive_anon:785764kB active_file:13672kB 
inactive_file:4352kB unevictable:11208kB isolated(anon):785964kB 
isolated(file):0kB present:12410880kB mlocked:11208kB dirty:604kB 
writeback:0kB mapped:4344kB shmem:0kB slab_reclaimable:177792kB 
slab_unreclaimable:368676kB kernel_stack:73256kB pagetables:489972kB 
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0

202895 total pagecache pages
197629 pages in swap cache
Swap cache stats: add 6954838, delete 6757209, find 1251447/2095005
Free swap  = 65881196kB
Total swap = 67354616kB
3997696 pages RAM
207046 pages reserved
1688629 pages shared
3016248 pages non-shared


--=-PtPyi9IWv63FBket5joZ
Content-Disposition: attachment; filename=page_referenced.patch
Content-Type: text/x-patch; name=page_referenced.patch; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index cb0ba70..03a10f7 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -80,7 +80,7 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
+			struct mem_cgroup *cnt, unsigned long *vm_flags, int trylock);
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
 	TTU_MIGRATION = 1,		/* migration mode */
@@ -99,7 +99,7 @@ int try_to_unmap(struct page *, enum ttu_flags flags);
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
 pte_t *page_check_address(struct page *, struct mm_struct *,
-				unsigned long, spinlock_t **, int);
+				unsigned long, spinlock_t **, int, int);
 
 /*
  * Used by swapoff to help locate where page is expected in vma.
@@ -135,7 +135,8 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma);
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *cnt,
-				  unsigned long *vm_flags)
+				  unsigned long *vm_flags,
+				  int trylock)
 {
 	*vm_flags = 0;
 	return TestClearPageReferenced(page);
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
index dd43373..e066833 100644
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
+		return 1;
 
 	/*
 	 * Don't want to elevate referenced for mlocked page that gets this far,
@@ -396,7 +405,8 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				int trylock)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -417,7 +427,7 @@ static int page_referenced_anon(struct page *page,
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags, trylock);
 		if (!mapcount)
 			break;
 	}
@@ -482,7 +492,7 @@ static int page_referenced_file(struct page *page,
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags, 0);
 		if (!mapcount)
 			break;
 	}
@@ -497,6 +507,7 @@ static int page_referenced_file(struct page *page,
  * @is_locked: caller holds lock on the page
  * @mem_cont: target memory controller
  * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ * @trylock: use spin_trylock to prevent high lock contention.
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -504,7 +515,8 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int trylock)
 {
 	int referenced = 0;
 
@@ -515,7 +527,7 @@ int page_referenced(struct page *page,
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
 			referenced += page_referenced_anon(page, mem_cont,
-								vm_flags);
+						     		vm_flags, trylock);
 		else if (is_locked)
 			referenced += page_referenced_file(page, mem_cont,
 								vm_flags);
@@ -547,7 +559,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 1);
+	pte = page_check_address(page, mm, address, &ptl, 1, 0);
 	if (!pte)
 		goto out;
 
@@ -774,7 +786,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
+	pte = page_check_address(page, mm, address, &ptl, 0, 0);
 	if (!pte)
 		goto out;
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 777af57..fff63a0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -643,7 +643,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		}
 
 		referenced = page_referenced(page, 1,
-						sc->mem_cgroup, &vm_flags);
+						sc->mem_cgroup, &vm_flags, 0);
 		/*
 		 * In active use or really unfreeable?  Activate it.
 		 * If page which have PG_mlocked lost isoltation race,
@@ -1355,7 +1355,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags,
+						priority<DEF_PRIORITY-2?0:1)) {
 			nr_rotated++;
 			/*
 			 * Identify referenced, file-backed active pages and

--=-PtPyi9IWv63FBket5joZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
