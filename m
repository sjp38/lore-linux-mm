Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFF86B7CAA
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 17:51:00 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id w24so903490otk.22
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 14:51:00 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l14si640637oie.139.2018.12.06.14.50.58
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 14:50:58 -0800 (PST)
From: Steve Capper <steve.capper@arm.com>
Subject: [PATCH V5 1/7] mm: mmap: Allow for "high" userspace addresses
Date: Thu,  6 Dec 2018 22:50:36 +0000
Message-Id: <20181206225042.11548-2-steve.capper@arm.com>
In-Reply-To: <20181206225042.11548-1-steve.capper@arm.com>
References: <20181206225042.11548-1-steve.capper@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org
Cc: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, suzuki.poulose@arm.com, jcm@redhat.com, Steve Capper <steve.capper@arm.com>, Andrew Morton <akpm@linux-foundation.org>

This patch adds support for "high" userspace addresses that are
optionally supported on the system and have to be requested via a hint
mechanism ("high" addr parameter to mmap).

Architectures such as powerpc and x86 achieve this by making changes to
their architectural versions of arch_get_unmapped_* functions. However,
on arm64 we use the generic versions of these functions.

Rather than duplicate the generic arch_get_unmapped_* implementations
for arm64, this patch instead introduces two architectural helper macros
and applies them to arch_get_unmapped_*:
 arch_get_mmap_end(addr) - get mmap upper limit depending on addr hint
 arch_get_mmap_base(addr, base) - get mmap_base depending on addr hint

If these macros are not defined in architectural code then they default
to (TASK_SIZE) and (base) so should not introduce any behavioural
changes to architectures that do not define them.

Signed-off-by: Steve Capper <steve.capper@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>

---

Changed in V4, added Catalin's reviewed by

Changed in V3, commit log cleared up, explanation given for why core
code change over just architectural change
---
 mm/mmap.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6c04292e16a7..7bb64381e77c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2066,6 +2066,15 @@ unsigned long unmapped_area_topdown(struct vm_unmapped_area_info *info)
 	return gap_end;
 }
 
+
+#ifndef arch_get_mmap_end
+#define arch_get_mmap_end(addr)	(TASK_SIZE)
+#endif
+
+#ifndef arch_get_mmap_base
+#define arch_get_mmap_base(addr, base) (base)
+#endif
+
 /* Get an address range which is currently unmapped.
  * For shmat() with addr=0.
  *
@@ -2085,8 +2094,9 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
 	struct vm_unmapped_area_info info;
+	const unsigned long mmap_end = arch_get_mmap_end(addr);
 
-	if (len > TASK_SIZE - mmap_min_addr)
+	if (len > mmap_end - mmap_min_addr)
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED)
@@ -2095,7 +2105,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma_prev(mm, addr, &prev);
-		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
+		if (mmap_end - len >= addr && addr >= mmap_min_addr &&
 		    (!vma || addr + len <= vm_start_gap(vma)) &&
 		    (!prev || addr >= vm_end_gap(prev)))
 			return addr;
@@ -2104,7 +2114,7 @@ arch_get_unmapped_area(struct file *filp, unsigned long addr,
 	info.flags = 0;
 	info.length = len;
 	info.low_limit = mm->mmap_base;
-	info.high_limit = TASK_SIZE;
+	info.high_limit = mmap_end;
 	info.align_mask = 0;
 	return vm_unmapped_area(&info);
 }
@@ -2124,9 +2134,10 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	struct mm_struct *mm = current->mm;
 	unsigned long addr = addr0;
 	struct vm_unmapped_area_info info;
+	const unsigned long mmap_end = arch_get_mmap_end(addr);
 
 	/* requested length too big for entire address space */
-	if (len > TASK_SIZE - mmap_min_addr)
+	if (len > mmap_end - mmap_min_addr)
 		return -ENOMEM;
 
 	if (flags & MAP_FIXED)
@@ -2136,7 +2147,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	if (addr) {
 		addr = PAGE_ALIGN(addr);
 		vma = find_vma_prev(mm, addr, &prev);
-		if (TASK_SIZE - len >= addr && addr >= mmap_min_addr &&
+		if (mmap_end - len >= addr && addr >= mmap_min_addr &&
 				(!vma || addr + len <= vm_start_gap(vma)) &&
 				(!prev || addr >= vm_end_gap(prev)))
 			return addr;
@@ -2145,7 +2156,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 	info.flags = VM_UNMAPPED_AREA_TOPDOWN;
 	info.length = len;
 	info.low_limit = max(PAGE_SIZE, mmap_min_addr);
-	info.high_limit = mm->mmap_base;
+	info.high_limit = arch_get_mmap_base(addr, mm->mmap_base);
 	info.align_mask = 0;
 	addr = vm_unmapped_area(&info);
 
@@ -2159,7 +2170,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
 		VM_BUG_ON(addr != -ENOMEM);
 		info.flags = 0;
 		info.low_limit = TASK_UNMAPPED_BASE;
-		info.high_limit = TASK_SIZE;
+		info.high_limit = mmap_end;
 		addr = vm_unmapped_area(&info);
 	}
 
-- 
2.19.2
