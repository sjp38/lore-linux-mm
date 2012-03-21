Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 76DCA6B0083
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 02:57:05 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so872729bkw.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 23:57:04 -0700 (PDT)
Subject: [PATCH 12/16] mm/mips: use vm_flags_t for vma flags
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 21 Mar 2012 10:57:02 +0400
Message-ID: <20120321065702.13852.81639.stgit@zurg>
In-Reply-To: <20120321065140.13852.52315.stgit@zurg>
References: <20120321065140.13852.52315.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: linux-mips@linux-mips.org
---
 arch/mips/mm/c-r3k.c  |    2 +-
 arch/mips/mm/c-r4k.c  |    6 +++---
 arch/mips/mm/c-tx39.c |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/mips/mm/c-r3k.c b/arch/mips/mm/c-r3k.c
index 0765583..0ae0684 100644
--- a/arch/mips/mm/c-r3k.c
+++ b/arch/mips/mm/c-r3k.c
@@ -239,7 +239,7 @@ static void r3k_flush_cache_page(struct vm_area_struct *vma,
 				 unsigned long addr, unsigned long pfn)
 {
 	unsigned long kaddr = KSEG0ADDR(pfn << PAGE_SHIFT);
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgdp;
 	pud_t *pudp;
diff --git a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
index c97087d..94b2b89 100644
--- a/arch/mips/mm/c-r4k.c
+++ b/arch/mips/mm/c-r4k.c
@@ -394,7 +394,7 @@ static void r4k__flush_cache_vunmap(void)
 static inline void local_r4k_flush_cache_range(void * args)
 {
 	struct vm_area_struct *vma = args;
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 
 	if (!(has_valid_asid(vma->vm_mm)))
 		return;
@@ -407,7 +407,7 @@ static inline void local_r4k_flush_cache_range(void * args)
 static void r4k_flush_cache_range(struct vm_area_struct *vma,
 	unsigned long start, unsigned long end)
 {
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 
 	if (cpu_has_dc_aliases || (exec && !cpu_has_ic_fills_f_dc))
 		r4k_on_each_cpu(local_r4k_flush_cache_range, vma);
@@ -457,7 +457,7 @@ static inline void local_r4k_flush_cache_page(void *args)
 	struct vm_area_struct *vma = fcp_args->vma;
 	unsigned long addr = fcp_args->addr;
 	struct page *page = pfn_to_page(fcp_args->pfn);
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 	struct mm_struct *mm = vma->vm_mm;
 	int map_coherent = 0;
 	pgd_t *pgdp;
diff --git a/arch/mips/mm/c-tx39.c b/arch/mips/mm/c-tx39.c
index a43c197c..1227670 100644
--- a/arch/mips/mm/c-tx39.c
+++ b/arch/mips/mm/c-tx39.c
@@ -169,7 +169,7 @@ static void tx39_flush_cache_range(struct vm_area_struct *vma,
 
 static void tx39_flush_cache_page(struct vm_area_struct *vma, unsigned long page, unsigned long pfn)
 {
-	int exec = vma->vm_flags & VM_EXEC;
+	int exec = (vma->vm_flags & VM_EXEC) != VM_NONE;
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgdp;
 	pud_t *pudp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
