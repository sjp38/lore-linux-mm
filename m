Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E9108600309
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 11:37:47 -0500 (EST)
Subject: Re: [RFC] high system time & lock contention running large mixed
	workload
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
References: <20091125133752.2683c3e4@bree.surriel.com>
	 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
	 <20091201102645.5C0A.A69D9226@jp.fujitsu.com>
Content-Type: multipart/mixed; boundary="=-PgS2TVA1s1fkKlAMWv6Z"
Date: Tue, 01 Dec 2009 11:41:02 -0500
Message-Id: <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>


--=-PgS2TVA1s1fkKlAMWv6Z
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2009-12-01 at 21:23 +0900, KOSAKI Motohiro wrote:
> (cc to some related person)

> 
> At first look,
> 
>    - We have to fix this issue certenally.
>    - But your patch is a bit risky. 
> 
> Your patch treat trylock(pte-lock) failure as no accessced. but
> generally lock contention imply to have contention peer. iow, the page
> have reference bit typically. then, next shrink_inactive_list() move it
> active list again. that's suboptimal result.
> 
> However, we can't treat lock-contention as page-is-referenced simply. if it does,
> the system easily go into OOM.
> 
> So, 
> 	if (priority < DEF_PRIORITY - 2)
> 		page_referenced()
> 	else
> 		page_refenced_trylock()
> 
> is better?
> On typical workload, almost vmscan only use DEF_PRIORITY. then,
> if priority==DEF_PRIORITY situation don't cause heavy lock contention,
> the system don't need to mind the contention. anyway we can't avoid
> contention if the system have heavy memory pressure.
> 


Agreed.  The attached updated patch only does a trylock in the
page_referenced() call from shrink_inactive_list() and only for
anonymous pages when the priority is either 10, 11 or
12(DEF_PRIORITY-2).  I have never seen a problem like this with active
pagecache pages and it does not alter the existing shrink_page_list
behavior.  What do you think about this???





--=-PgS2TVA1s1fkKlAMWv6Z
Content-Disposition: attachment; filename=pageout.diff
Content-Type: text/x-patch; name=pageout.diff; charset=utf-8
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index cb0ba70..d7eaeca 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -80,7 +80,7 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
+			struct mem_cgroup *cnt, unsigned long *vm_flags, int try);
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
+				  int try)
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
index dd43373..d8afe1a 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -270,7 +270,7 @@ unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
  * On success returns with pte mapped and locked.
  */
 pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp, int sync)
+			  unsigned long address, spinlock_t **ptlp, int sync, int try)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -298,7 +298,13 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
 	}
 
 	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	if (try) {
+		if (!spin_trylock(ptl)) {
+			pte_unmap(pte);
+			return NULL;
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
+			       int try)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -352,7 +359,7 @@ static int page_referenced_one(struct page *page,
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 0);
+	pte = page_check_address(page, mm, address, &ptl, 0, try);
 	if (!pte)
 		goto out;
 
@@ -396,7 +403,8 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long *vm_flags,
+				int try)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -417,7 +425,7 @@ static int page_referenced_anon(struct page *page,
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags, try);
 		if (!mapcount)
 			break;
 	}
@@ -482,7 +490,7 @@ static int page_referenced_file(struct page *page,
 		if (mem_cont && !mm_match_cgroup(vma->vm_mm, mem_cont))
 			continue;
 		referenced += page_referenced_one(page, vma,
-						  &mapcount, vm_flags);
+						  &mapcount, vm_flags, 0);
 		if (!mapcount)
 			break;
 	}
@@ -504,7 +512,8 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+		    unsigned long *vm_flags,
+		    int try)
 {
 	int referenced = 0;
 
@@ -515,7 +524,7 @@ int page_referenced(struct page *page,
 	if (page_mapped(page) && page->mapping) {
 		if (PageAnon(page))
 			referenced += page_referenced_anon(page, mem_cont,
-								vm_flags);
+								vm_flags, try);
 		else if (is_locked)
 			referenced += page_referenced_file(page, mem_cont,
 								vm_flags);
@@ -547,7 +556,7 @@ static int page_mkclean_one(struct page *page, struct vm_area_struct *vma)
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl, 1);
+	pte = page_check_address(page, mm, address, &ptl, 1, 0);
 	if (!pte)
 		goto out;
 
@@ -774,7 +783,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
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

--=-PgS2TVA1s1fkKlAMWv6Z--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
