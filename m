Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 9FAF66B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 13:12:34 -0500 (EST)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [RFC] mm: Limit pgd range freeing to TASK_SIZE
Date: Tue, 28 Feb 2012 18:12:01 +0000
Message-Id: <1330452721-26947-1-git-send-email-catalin.marinas@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>

ARM processors with LPAE enabled use 3 levels of page tables, with an
entry in the top one (pgd/pud) covering 1GB of virtual space. Because of
the relocation limitations on ARM, the loadable modules are mapped 16MB
below PAGE_OFFSET, making the corresponding 1GB pgd/pud shared between
kernel modules and user space. During fault processing, pmd entries
corresponding to modules are populated to point to the init_mm pte
tables.

Since free_pgtables() is called with ceiling =3D=3D 0, free_pgd_range() (an=
d
subsequently called functions) also clears the pgd/pud entry that is
shared between user space and kernel modules. If a module interrupt
routine is invoked during this window, the kernel gets a translation
fault and becomes confused.

There is proposed fix for ARM (within the arch/arm/ code) but it
wouldn't be needed if the pgd range freeing is capped at TASK_SIZE. The
concern is that there are architectures with vmas beyond TASK_SIZE, so
the aim of this RFC is to ask whether those architectures rely on
free_pgtables() to free any page tables beyond TASK_SIZE.

Alternatively, we can define something like LAST_USER_ADDRESS,
defaulting to 0 for most architectures.

Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
---
 fs/exec.c |    4 ++--
 mm/mmap.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 92ce83a..f2d66ab 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -626,7 +626,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, =
unsigned long shift)
 =09=09 * when the old and new regions overlap clear from new_end.
 =09=09 */
 =09=09free_pgd_range(&tlb, new_end, old_end, new_end,
-=09=09=09vma->vm_next ? vma->vm_next->vm_start : 0);
+=09=09=09vma->vm_next ? vma->vm_next->vm_start : TASK_SIZE);
 =09} else {
 =09=09/*
 =09=09 * otherwise, clean from old_start; this is done to not touch
@@ -635,7 +635,7 @@ static int shift_arg_pages(struct vm_area_struct *vma, =
unsigned long shift)
 =09=09 * for the others its just a little faster.
 =09=09 */
 =09=09free_pgd_range(&tlb, old_start, old_end, new_end,
-=09=09=09vma->vm_next ? vma->vm_next->vm_start : 0);
+=09=09=09vma->vm_next ? vma->vm_next->vm_start : TASK_SIZE);
 =09}
 =09tlb_finish_mmu(&tlb, new_end, old_end);
=20
diff --git a/mm/mmap.c b/mm/mmap.c
index 3f758c7..5e5c8a8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1866,7 +1866,7 @@ static void unmap_region(struct mm_struct *mm,
 =09unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
 =09vm_unacct_memory(nr_accounted);
 =09free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
-=09=09=09=09 next ? next->vm_start : 0);
+=09=09=09=09 next ? next->vm_start : TASK_SIZE);
 =09tlb_finish_mmu(&tlb, start, end);
 }
=20
@@ -2241,7 +2241,7 @@ void exit_mmap(struct mm_struct *mm)
 =09end =3D unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
 =09vm_unacct_memory(nr_accounted);
=20
-=09free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
+=09free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, TASK_SIZE);
 =09tlb_finish_mmu(&tlb, 0, end);
=20
 =09/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
