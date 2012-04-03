Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 7C70F6B004A
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 20:44:40 -0400 (EDT)
From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: [x86 PAT PATCH 1/2] x86, pat: remove the dependency on 'vm_pgoff' in track/untrack pfn vma routines
Date: Mon,  2 Apr 2012 17:46:08 -0700
Message-Id: <1333413969-30761-2-git-send-email-suresh.b.siddha@intel.com>
In-Reply-To: <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>
References: <20120331170947.7773.46399.stgit@zurg>
 <1333413969-30761-1-git-send-email-suresh.b.siddha@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Suresh Siddha <suresh.b.siddha@intel.com>, Andi Kleen <andi@firstfloor.org>, Pallipadi Venkatesh <venki@google.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Konstantin Khlebnikov <khlebnikov@openvz.org>

'pfn' argument for track_pfn_vma_new() can be used for reserving the attribute
for the pfn range. No need to depend on 'vm_pgoff'

Similarly, untrack_pfn_vma() can depend on the 'pfn' argument if it
is non-zero or can use follow_phys() to get the starting value of the pfn
range.

Also the non zero 'size' argument can be used instead of recomputing
it from vma.

This cleanup also prepares the ground for the track/untrack pfn vma routines
to take over the ownership of setting PAT specific vm_flag in the 'vma'.

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
+		return reserve_pfn_range(pfn, size, prot, 0);
 
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
+	paddr = (resource_size_t)pfn;
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
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
