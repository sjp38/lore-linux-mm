Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 325916B0256
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 15:37:44 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so18974716qkb.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 12:37:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 138si5443808qhs.81.2015.08.13.12.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 12:37:43 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 01/15] fork: pass the dst vma to copy_page_range() and its sub-functions.
Date: Thu, 13 Aug 2015 15:37:17 -0400
Message-Id: <1439494651-1255-2-git-send-email-jglisse@redhat.com>
In-Reply-To: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
References: <1439494651-1255-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

For HMM we will need to resort to the old way of allocating new page
for anonymous memory when that anonymous memory have been migrated
to device memory.

This does not impact any process that do not use HMM through some
device driver. Only process that migrate anonymous memory to device
memory with HMM will have to copy migrated page on fork.

We do not expect this to be a common or advised thing to do so we
resort to the simpler solution of allocating new page. If this kind
of usage turns out to be important we will revisit way to achieve
COW even for remote memory.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/mm.h |  5 +++--
 kernel/fork.c      |  2 +-
 mm/memory.c        | 33 +++++++++++++++++++++------------
 3 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b5bf210..580fe65 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1124,8 +1124,9 @@ int walk_page_range(unsigned long addr, unsigned long end,
 int walk_page_vma(struct vm_area_struct *vma, struct mm_walk *walk);
 void free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 		unsigned long end, unsigned long floor, unsigned long ceiling);
-int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma);
+int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		    struct vm_area_struct *dst_vma,
+		    struct vm_area_struct *vma);
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
diff --git a/kernel/fork.c b/kernel/fork.c
index bf2dcb6..2d32a4b 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -497,7 +497,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		rb_parent = &tmp->vm_rb;
 
 		mm->map_count++;
-		retval = copy_page_range(mm, oldmm, mpnt);
+		retval = copy_page_range(mm, oldmm, tmp, mpnt);
 
 		if (tmp->vm_ops && tmp->vm_ops->open)
 			tmp->vm_ops->open(tmp);
diff --git a/mm/memory.c b/mm/memory.c
index d784e35..71b5c35 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -885,8 +885,10 @@ out_set_pte:
 }
 
 static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		   pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
-		   unsigned long addr, unsigned long end)
+			  pmd_t *dst_pmd, pmd_t *src_pmd,
+			  struct vm_area_struct *dst_vma,
+			  struct vm_area_struct *vma,
+			  unsigned long addr, unsigned long end)
 {
 	pte_t *orig_src_pte, *orig_dst_pte;
 	pte_t *src_pte, *dst_pte;
@@ -947,9 +949,12 @@ again:
 	return 0;
 }
 
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
+static inline int copy_pmd_range(struct mm_struct *dst_mm,
+				 struct mm_struct *src_mm,
+				 pud_t *dst_pud, pud_t *src_pud,
+				 struct vm_area_struct *dst_vma,
+				 struct vm_area_struct *vma,
+				 unsigned long addr, unsigned long end)
 {
 	pmd_t *src_pmd, *dst_pmd;
 	unsigned long next;
@@ -974,15 +979,18 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 		if (pmd_none_or_clear_bad(src_pmd))
 			continue;
 		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
+				   dst_vma, vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
+static inline int copy_pud_range(struct mm_struct *dst_mm,
+				 struct mm_struct *src_mm,
+				 pgd_t *dst_pgd, pgd_t *src_pgd,
+				 struct vm_area_struct *dst_vma,
+				 struct vm_area_struct *vma,
+				 unsigned long addr, unsigned long end)
 {
 	pud_t *src_pud, *dst_pud;
 	unsigned long next;
@@ -996,14 +1004,15 @@ static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src
 		if (pud_none_or_clear_bad(src_pud))
 			continue;
 		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
+				   dst_vma, vma, addr, next))
 			return -ENOMEM;
 	} while (dst_pud++, src_pud++, addr = next, addr != end);
 	return 0;
 }
 
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		struct vm_area_struct *vma)
+		    struct vm_area_struct *dst_vma,
+		    struct vm_area_struct *vma)
 {
 	pgd_t *src_pgd, *dst_pgd;
 	unsigned long next;
@@ -1057,7 +1066,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		if (pgd_none_or_clear_bad(src_pgd))
 			continue;
 		if (unlikely(copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-					    vma, addr, next))) {
+					    dst_vma, vma, addr, next))) {
 			ret = -ENOMEM;
 			break;
 		}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
