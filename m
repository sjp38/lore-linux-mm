Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 685126B005C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 20:04:30 -0400 (EDT)
Date: Fri, 1 Jun 2012 02:04:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: AutoNUMA15
Message-ID: <20120601000415.GR21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <20120529133627.GA7637@shutemov.name>
 <20120529154308.GA10790@dhcp-27-244.brq.redhat.com>
 <20120531180834.GP21339@redhat.com>
 <4FC7CE0F.9070706@hp.com>
 <20120531225406.GQ21339@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120531225406.GQ21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: linux-mm@kvack.org

On Fri, Jun 01, 2012 at 12:54:06AM +0200, Andrea Arcangeli wrote:
> I'll push a fix in the origin/autonuma branch as soon as I figure it
> out...

7f9729f89000-7f9729faa000 rw-p 00000000 00:00 0
7f9729faa000-7f9729fea000 rw-s 000c0000 00:15 15364 /dev/mem

addr:00007f9729fc5000 vm_flags:08000875 anon_vma:          (null)
mapping:ffff880430025410 index:b8

The reason for the false positive, was that there are multiple vmas in
the same pmd range, and I was passing the single vma belonging to the
page fault address, for all ptes in that pmd.

The vma is only used for that check, this is why it was harmless.

The vma found during page fault would have been valid for the pmd huge
numa fixup and the pte numa fixup, but not for the less granular pmd
numa fixup (not huge).

This also explains why echo 0 >/sys/kernel/mm/autonuma/knuma_scand/pmd
avoided the warnings.

Can you test the below? I'll push the fix in the origin/autonuma branch.

Thanks!

---
 include/linux/autonuma.h |    4 ++--
 mm/autonuma.c            |   19 +++++++++++++++++--
 mm/memory.c              |    5 ++---
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/linux/autonuma.h b/include/linux/autonuma.h
index b0a8d87..67af86a 100644
--- a/include/linux/autonuma.h
+++ b/include/linux/autonuma.h
@@ -46,8 +46,8 @@ static inline void autonuma_free_page(struct page *page) {}
 
 extern pte_t __pte_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
 			      unsigned long addr, pte_t pte, pte_t *ptep);
-extern void __pmd_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
-			     unsigned long addr, pmd_t *pmd);
+extern void __pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+			     pmd_t *pmd);
 extern void numa_hinting_fault(struct page *page, int numpages);
 
 #endif /* _LINUX_AUTONUMA_H */
diff --git a/mm/autonuma.c b/mm/autonuma.c
index d37647a..ca4c189 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -349,14 +349,16 @@ pte_t __pte_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
 	return pte;
 }
 
-void __pmd_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
+void __pmd_numa_fixup(struct mm_struct *mm,
 		      unsigned long addr, pmd_t *pmdp)
 {
 	pmd_t pmd;
 	pte_t *pte;
 	unsigned long _addr = addr & PMD_MASK;
+	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
+	struct vm_area_struct *vma;
 
 	spin_lock(&mm->page_table_lock);
 	pmd = *pmdp;
@@ -369,12 +371,25 @@ void __pmd_numa_fixup(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!numa)
 		return;
 
+	vma = find_vma(mm, _addr);
+	/* we're in a page fault so some vma must be in the range */
+	BUG_ON(!vma);
+	BUG_ON(vma->vm_start >= _addr + PMD_SIZE);
+	offset = max(_addr, vma->vm_start) & ~PMD_MASK;
+	VM_BUG_ON(offset >= PMD_SIZE);
 	pte = pte_offset_map_lock(mm, pmdp, _addr, &ptl);
-	for (addr = _addr; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
+	pte += offset >> PAGE_SHIFT;
+	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page * page;
 		if (!pte_present(pteval))
 			continue;
+		if (addr >= vma->vm_end) {
+			vma = find_vma(mm, addr);
+			/* there's a pte present so there must be a vma */
+			BUG_ON(!vma);
+			BUG_ON(addr < vma->vm_start);
+		}
 		if (pte_numa(pteval)) {
 			pteval = pte_mknotnuma(pteval);
 			set_pte_at(mm, addr, pte, pteval);
diff --git a/mm/memory.c b/mm/memory.c
index f46cf8a..bbf10c7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3409,11 +3409,10 @@ static inline pte_t pte_numa_fixup(struct mm_struct *mm,
 }
 
 static inline void pmd_numa_fixup(struct mm_struct *mm,
-				  struct vm_area_struct *vma,
 				  unsigned long addr, pmd_t *pmd)
 {
 	if (pmd_numa(*pmd))
-		__pmd_numa_fixup(mm, vma, addr, pmd);
+		__pmd_numa_fixup(mm, addr, pmd);
 }
 
 static inline pmd_t huge_pmd_numa_fixup(struct mm_struct *mm,
@@ -3552,7 +3551,7 @@ retry:
 		}
 	}
 
-	pmd_numa_fixup(mm, vma, address, pmd);
+	pmd_numa_fixup(mm, address, pmd);
 
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
