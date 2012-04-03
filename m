Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 751CB6B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 19:29:36 -0400 (EDT)
Subject: Re: [x86 PAT PATCH 1/2] x86, pat: remove the dependency on
 'vm_pgoff' in track/untrack pfn vma routines
From: Suresh Siddha <suresh.b.siddha@intel.com>
Reply-To: Suresh Siddha <suresh.b.siddha@intel.com>
Date: Tue, 03 Apr 2012 16:31:21 -0700
In-Reply-To: <4F7A8C94.3040708@openvz.org>
References: <20120331170947.7773.46399.stgit@zurg>
	 <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>
	 <1333413969-30761-2-git-send-email-suresh.b.siddha@intel.com>
	 <4F7A8C94.3040708@openvz.org>
Content-Type: multipart/mixed; boundary="=-lYqONymdFNRNg8Efn52R"
Message-ID: <1333495881.12400.19.camel@sbsiddha-desk.sc.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>


--=-lYqONymdFNRNg8Efn52R
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2012-04-03 at 09:37 +0400, Konstantin Khlebnikov wrote:
> Suresh Siddha wrote:
> > 'pfn' argument for track_pfn_vma_new() can be used for reserving the attribute
> > for the pfn range. No need to depend on 'vm_pgoff'
> >
> > Similarly, untrack_pfn_vma() can depend on the 'pfn' argument if it
> > is non-zero or can use follow_phys() to get the starting value of the pfn
> > range.
> >
> > Also the non zero 'size' argument can be used instead of recomputing
> > it from vma.
> >
> > This cleanup also prepares the ground for the track/untrack pfn vma routines
> > to take over the ownership of setting PAT specific vm_flag in the 'vma'.
> >
> > Signed-off-by: Suresh Siddha<suresh.b.siddha@intel.com>
> > Cc: Venkatesh Pallipadi<venki@google.com>
> > Cc: Konstantin Khlebnikov<khlebnikov@openvz.org>
> > ---
> >   arch/x86/mm/pat.c |   30 +++++++++++++++++-------------
> >   1 files changed, 17 insertions(+), 13 deletions(-)
> >
> > diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
> > index f6ff57b..617f42b 100644
> > --- a/arch/x86/mm/pat.c
> > +++ b/arch/x86/mm/pat.c
> > @@ -693,14 +693,10 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
> >   			unsigned long pfn, unsigned long size)
> >   {
> >   	unsigned long flags;
> > -	resource_size_t paddr;
> > -	unsigned long vma_size = vma->vm_end - vma->vm_start;
> >
> > -	if (is_linear_pfn_mapping(vma)) {
> > -		/* reserve the whole chunk starting from vm_pgoff */
> > -		paddr = (resource_size_t)vma->vm_pgoff<<  PAGE_SHIFT;
> > -		return reserve_pfn_range(paddr, vma_size, prot, 0);
> > -	}
> > +	/* reserve the whole chunk starting from pfn */
> > +	if (is_linear_pfn_mapping(vma))
> > +		return reserve_pfn_range(pfn, size, prot, 0);
> 
> you mix here pfn and paddr: old code passes paddr as first argument of reserve_pfn_range().

oops. That was my oversight. I updated the two patches to address this.
Also I cleared VM_PAT flag as part of the untrack_pfn_vma(), so that the
use cases (like the i915 case) which just evict the pfn's (by using
unmap_mapping_range) with out actually removing the vma will do the
free_pfn_range() only when it is required.

Attached (to this e-mail) are the -v2 versions of the PAT patches. I
tested these on my SNB laptop.

thanks,
suresh

--=-lYqONymdFNRNg8Efn52R
Content-Disposition: attachment;
	filename*0=0001-x86-pat-remove-the-dependency-on-vm_pgoff-in-track-u.pat;
	filename*1=ch
Content-Type: text/x-patch;
	name="0001-x86-pat-remove-the-dependency-on-vm_pgoff-in-track-u.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: x86, pat: remove the dependency on 'vm_pgoff' in track/untrack pfn vma routines

'pfn' argument for track_pfn_vma_new() can be used for reserving the attribute
for the pfn range. No need to depend on 'vm_pgoff'

Similarly, untrack_pfn_vma() can depend on the 'pfn' argument if it
is non-zero or can use follow_phys() to get the starting value of the pfn
range.

Also the non zero 'size' argument can be used instead of recomputing
it from vma.

This cleanup also prepares the ground for the track/untrack pfn vma routines
to take over the ownership of setting PAT specific vm_flag in the 'vma'.

-v2: fixed the first argument for reserve_pfn_range()

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Venkatesh Pallipadi <venki@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 arch/x86/mm/pat.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index f6ff57b..617f42b 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -693,14 +693,10 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
 			unsigned long pfn, unsigned long size)
 {
 	unsigned long flags;
-	resource_size_t paddr;
-	unsigned long vma_size = vma->vm_end - vma->vm_start;
 
-	if (is_linear_pfn_mapping(vma)) {
-		/* reserve the whole chunk starting from vm_pgoff */
-		paddr = (resource_size_t)vma->vm_pgoff << PAGE_SHIFT;
-		return reserve_pfn_range(paddr, vma_size, prot, 0);
-	}
+	/* reserve the whole chunk starting from pfn */
+	if (is_linear_pfn_mapping(vma))
+		return reserve_pfn_range(pfn << PAGE_SHIFT, size, prot, 0);
 
 	if (!pat_enabled)
 		return 0;
@@ -716,20 +712,28 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
 /*
  * untrack_pfn_vma is called while unmapping a pfnmap for a region.
  * untrack can be called for a specific region indicated by pfn and size or
- * can be for the entire vma (in which case size can be zero).
+ * can be for the entire vma (in which case pfn, size are zero).
  */
 void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
 			unsigned long size)
 {
 	resource_size_t paddr;
-	unsigned long vma_size = vma->vm_end - vma->vm_start;
+	unsigned long prot;
 
-	if (is_linear_pfn_mapping(vma)) {
-		/* free the whole chunk starting from vm_pgoff */
-		paddr = (resource_size_t)vma->vm_pgoff << PAGE_SHIFT;
-		free_pfn_range(paddr, vma_size);
+	if (!is_linear_pfn_mapping(vma))
 		return;
+
+	/* free the chunk starting from pfn or the whole chunk */
+	paddr = (resource_size_t)pfn << PAGE_SHIFT;
+	if (!paddr && !size) {
+		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr)) {
+			WARN_ON_ONCE(1);
+			return;
+		}
+
+		size = vma->vm_end - vma->vm_start;
 	}
+	free_pfn_range(paddr, size);
 }
 
 pgprot_t pgprot_writecombine(pgprot_t prot)

--=-lYqONymdFNRNg8Efn52R
Content-Disposition: attachment;
	filename="0002-mm-x86-PAT-rework-linear-pfn-mmap-tracking.patch"
Content-Type: text/x-patch; name="0002-mm-x86-PAT-rework-linear-pfn-mmap-tracking.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: mm, x86, PAT: rework linear pfn-mmap tracking

This patch replaces generic vma-flag VM_PFN_AT_MMAP with x86-only VM_PAT.

We can toss mapping address from remap_pfn_range() into track_pfn_vma_new(),
and collect all PAT-related logic together in arch/x86/.

This patch also restores orignal frustration-free is_cow_mapping() check in
remap_pfn_range(), as it was before commit v2.6.28-rc8-88-g3c8bb73
("x86: PAT: store vm_pgoff for all linear_over_vma_region mappings - v3")

is_linear_pfn_mapping() checks can be removed from mm/huge_memory.c,
because it already handled by VM_PFNMAP in VM_NO_THP bit-mask.

-v2: Reset the VM_PAT flag as part of untrack_pfn_vma()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Venkatesh Pallipadi <venki@google.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Ingo Molnar <mingo@redhat.com>
---
 arch/x86/mm/pat.c             |   17 ++++++++++++-----
 include/asm-generic/pgtable.h |    4 ++--
 include/linux/mm.h            |   15 +--------------
 mm/huge_memory.c              |    7 +++----
 mm/memory.c                   |   15 ++++++++-------
 5 files changed, 26 insertions(+), 32 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 24c3f95..516404c 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -665,7 +665,7 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
 	unsigned long vma_size = vma->vm_end - vma->vm_start;
 	pgprot_t pgprot;
 
-	if (is_linear_pfn_mapping(vma)) {
+	if (vma->vm_flags & VM_PAT) {
 		/*
 		 * reserve the whole chunk covered by vma. We need the
 		 * starting address and protection from pte.
@@ -690,13 +690,19 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
  * single reserve_pfn_range call.
  */
 int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
-			unsigned long pfn, unsigned long size)
+		      unsigned long pfn, unsigned long addr, unsigned long size)
 {
 	unsigned long flags;
 
 	/* reserve the whole chunk starting from pfn */
-	if (is_linear_pfn_mapping(vma))
-		return reserve_pfn_range(pfn << PAGE_SHIFT, size, prot, 0);
+	if (addr == vma->vm_start && size == (vma->vm_end - vma->vm_start)) {
+		int ret;
+
+		ret = reserve_pfn_range(pfn << PAGE_SHIFT, size, prot, 0);
+		if (!ret)
+			vma->vm_flags |= VM_PAT;
+		return ret;
+	}
 
 	if (!pat_enabled)
 		return 0;
@@ -720,7 +726,7 @@ void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
 	resource_size_t paddr;
 	unsigned long prot;
 
-	if (!is_linear_pfn_mapping(vma))
+	if (!(vma->vm_flags & VM_PAT))
 		return;
 
 	/* free the chunk starting from pfn or the whole chunk */
@@ -734,6 +740,7 @@ void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
 		size = vma->vm_end - vma->vm_start;
 	}
 	free_pfn_range(paddr, size);
+	vma->vm_flags &= ~VM_PAT;
 }
 
 pgprot_t pgprot_writecombine(pgprot_t prot)
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 125c54e..688a2a5 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -389,7 +389,7 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
  * for physical range indicated by pfn and size.
  */
 static inline int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
-					unsigned long pfn, unsigned long size)
+		unsigned long pfn, unsigned long addr, unsigned long size)
 {
 	return 0;
 }
@@ -420,7 +420,7 @@ static inline void untrack_pfn_vma(struct vm_area_struct *vma,
 }
 #else
 extern int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
-				unsigned long pfn, unsigned long size);
+		unsigned long pfn, unsigned long addr, unsigned long size);
 extern int track_pfn_vma_copy(struct vm_area_struct *vma);
 extern void untrack_pfn_vma(struct vm_area_struct *vma, unsigned long pfn,
 				unsigned long size);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d8738a4..b8e5fe5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -117,7 +117,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
-#define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
+#define VM_PAT		0x40000000	/* PAT reserves whole VMA at once (x86) */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
 
 /* Bits set in the VMA until the stack is in its final location */
@@ -158,19 +158,6 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 
-/*
- * This interface is used by x86 PAT code to identify a pfn mapping that is
- * linear over entire vma. This is to optimize PAT code that deals with
- * marking the physical region with a particular prot. This is not for generic
- * mm use. Note also that this check will not work if the pfn mapping is
- * linear for a vma starting at physical address 0. In which case PAT code
- * falls back to slow path of reserving physical range page by page.
- */
-static inline int is_linear_pfn_mapping(struct vm_area_struct *vma)
-{
-	return !!(vma->vm_flags & VM_PFN_AT_MMAP);
-}
-
 static inline int is_pfn_mapping(struct vm_area_struct *vma)
 {
 	return !!(vma->vm_flags & VM_PFNMAP);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f0e5306..cf827da 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1650,7 +1650,7 @@ int khugepaged_enter_vma_merge(struct vm_area_struct *vma)
 	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
 	 * true too, verify it here.
 	 */
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 	hend = vma->vm_end & HPAGE_PMD_MASK;
 	if (hstart < hend)
@@ -1908,7 +1908,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * If is_pfn_mapping() is true is_learn_pfn_mapping() must be
 	 * true too, verify it here.
 	 */
-	VM_BUG_ON(is_linear_pfn_mapping(vma) || vma->vm_flags & VM_NO_THP);
+	VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -2150,8 +2150,7 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 		 * If is_pfn_mapping() is true is_learn_pfn_mapping()
 		 * must be true too, verify it here.
 		 */
-		VM_BUG_ON(is_linear_pfn_mapping(vma) ||
-			  vma->vm_flags & VM_NO_THP);
+		VM_BUG_ON(vma->vm_flags & VM_NO_THP);
 
 		hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
 		hend = vma->vm_end & HPAGE_PMD_MASK;
diff --git a/mm/memory.c b/mm/memory.c
index 6105f47..e6e4dfd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2145,7 +2145,7 @@ int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 
 	if (addr < vma->vm_start || addr >= vma->vm_end)
 		return -EFAULT;
-	if (track_pfn_vma_new(vma, &pgprot, pfn, PAGE_SIZE))
+	if (track_pfn_vma_new(vma, &pgprot, pfn, addr, PAGE_SIZE))
 		return -EINVAL;
 
 	ret = insert_pfn(vma, addr, pfn, pgprot);
@@ -2285,23 +2285,24 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
 	 * There's a horrible special case to handle copy-on-write
 	 * behaviour that some programs depend on. We mark the "original"
 	 * un-COW'ed pages by matching them up with "vma->vm_pgoff".
+	 * See vm_normal_page() for details.
 	 */
-	if (addr == vma->vm_start && end == vma->vm_end) {
+
+	if (is_cow_mapping(vma->vm_flags)) {
+		if (addr != vma->vm_start || end != vma->vm_end)
+			return -EINVAL;
 		vma->vm_pgoff = pfn;
-		vma->vm_flags |= VM_PFN_AT_MMAP;
-	} else if (is_cow_mapping(vma->vm_flags))
-		return -EINVAL;
+	}
 
 	vma->vm_flags |= VM_IO | VM_RESERVED | VM_PFNMAP;
 
-	err = track_pfn_vma_new(vma, &prot, pfn, PAGE_ALIGN(size));
+	err = track_pfn_vma_new(vma, &prot, pfn, addr, PAGE_ALIGN(size));
 	if (err) {
 		/*
 		 * To indicate that track_pfn related cleanup is not
 		 * needed from higher level routine calling unmap_vmas
 		 */
 		vma->vm_flags &= ~(VM_IO | VM_RESERVED | VM_PFNMAP);
-		vma->vm_flags &= ~VM_PFN_AT_MMAP;
 		return -EINVAL;
 	}
 

--=-lYqONymdFNRNg8Efn52R--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
