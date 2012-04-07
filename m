Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 20F5A6B004D
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 15:01:03 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so3469210bkw.14
        for <linux-mm@kvack.org>; Sat, 07 Apr 2012 12:01:02 -0700 (PDT)
Subject: [PATCH v2 01/10] x86,
 pat: remove the dependency on 'vm_pgoff' in track/untrack pfn vma
 routines
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 07 Apr 2012 23:00:58 +0400
Message-ID: <20120407190058.9726.15634.stgit@zurg>
In-Reply-To: <20120407185546.9726.62260.stgit@zurg>
References: <20120407185546.9726.62260.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Venkatesh Pallipadi <venki@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>

From: Suresh Siddha <suresh.b.siddha@intel.com>

'pfn' argument for track_pfn_vma_new() can be used for reserving the attribute
for the pfn range. No need to depend on 'vm_pgoff'

Similarly, untrack_pfn_vma() can depend on the 'pfn' argument if it
is non-zero or can use follow_phys() to get the starting value of the pfn
range.

Also the non zero 'size' argument can be used instead of recomputing
it from vma.

This cleanup also prepares the ground for the track/untrack pfn vma routines
to take over the ownership of setting PAT specific vm_flag in the 'vma'.

[khlebnikov@openvz.org: Clear pfn to paddr conversion]

Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Venkatesh Pallipadi <venki@google.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Ingo Molnar <mingo@redhat.com>
---
 arch/x86/mm/pat.c |   33 +++++++++++++++++++--------------
 1 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index f6ff57b..86d6590 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -692,21 +692,18 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
 int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
 			unsigned long pfn, unsigned long size)
 {
+	resource_size_t paddr = (resource_size_t)pfn << PAGE_SHIFT;
 	unsigned long flags;
-	resource_size_t paddr;
-	unsigned long vma_size = vma->vm_end - vma->vm_start;
 
-	if (is_linear_pfn_mapping(vma)) {
-		/* reserve the whole chunk starting from vm_pgoff */
-		paddr = (resource_size_t)vma->vm_pgoff << PAGE_SHIFT;
-		return reserve_pfn_range(paddr, vma_size, prot, 0);
-	}
+	/* reserve the whole chunk starting from paddr */
+	if (is_linear_pfn_mapping(vma))
+		return reserve_pfn_range(paddr, size, prot, 0);
 
 	if (!pat_enabled)
 		return 0;
 
 	/* for vm_insert_pfn and friends, we set prot based on lookup */
-	flags = lookup_memtype(pfn << PAGE_SHIFT);
+	flags = lookup_memtype(paddr);
 	*prot = __pgprot((pgprot_val(vma->vm_page_prot) & (~_PAGE_CACHE_MASK)) |
 			 flags);
 
@@ -716,20 +713,28 @@ int track_pfn_vma_new(struct vm_area_struct *vma, pgprot_t *prot,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
