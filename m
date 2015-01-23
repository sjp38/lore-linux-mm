Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3D0E26B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 03:03:47 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so7141664pac.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 00:03:45 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ji2si1102706pbb.23.2015.01.23.00.03.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 00:03:45 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH -mm 14/13] mm: pagewalk: fix misbehavior of walk_page_range
 for vma(VM_PFNMAP) (Re: [PATCH -mm v7 02/13] pagewalk: improve vma handling)
Date: Fri, 23 Jan 2015 08:02:15 +0000
Message-ID: <20150123080204.GA2583@hori1.linux.bs1.fc.nec.co.jp>
References: <1415343692-6314-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1415343692-6314-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150122152205.39b7f8f451824b556c1a3f70@linux-foundation.org>
In-Reply-To: <20150122152205.39b7f8f451824b556c1a3f70@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <296B6BB5AA2BF14C9218EEF6C01931AB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shiraz Hashim <shashim@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Andrew,

On Thu, Jan 22, 2015 at 03:22:05PM -0800, Andrew Morton wrote:
> On Fri, 7 Nov 2014 07:01:55 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.=
com> wrote:
>=20
> > Current implementation of page table walker has a fundamental problem
> > in vma handling, which started when we tried to handle vma(VM_HUGETLB).
> > Because it's done in pgd loop, considering vma boundary makes code
> > complicated and bug-prone.
> >=20
> > >From the users viewpoint, some user checks some vma-related condition =
to
> > determine whether the user really does page walk over the vma.
> >=20
> > In order to solve these, this patch moves vma check outside pgd loop an=
d
> > introduce a new callback ->test_walk().
>=20
> I had to revert
> mm-pagewalk-call-pte_hole-for-vm_pfnmap-during-walk_page_range.patch.patc=
h
> to apply this.  Could you please work out how to reapply it after your
> patch?

I revised Shiraz's patch on top of this series.
My testing confirmed that both of the overrunning problem and "storing data
in wrong index" problem are solved with it.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 23 Jan 2015 16:58:12 +0900
Subject: [PATCH] mm: pagewalk: fix misbehavior of walk_page_range for
 vma(VM_PFNMAP)

walk_page_range() silently skips vma having VM_PFNMAP set, which leads to
undesirable behaviour at client end (who called walk_page_range).  For
example for pagemap_read(), when no callbacks are called against VM_PFNMAP
vma, pagemap_read() may prepare pagemap data for next virtual address range
at wrong index. That could confuse and/or break userspace applications.

This patch avoid this misbehavior caused by vma(VM_PFNMAP) like follows:
- for pagemap_read() which has its own ->pte_hole(), call the ->pte_hole()
  over vma(VM_PFNMAP),
- for clear_refs and queue_pages which have their own ->tests_walk,
  just return 1 and skip vma(VM_PFNMAP). This is no problem because
  these are not interested in hole regions,
- for other callers, just skip the vma(VM_PFNMAP) as a default behavior.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>
---
 fs/proc/task_mmu.c |  3 +++
 mm/mempolicy.c     |  3 +++
 mm/pagewalk.c      | 21 +++++++++++++--------
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index dcee0ad53fae..91753dd283f0 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -844,6 +844,9 @@ static int clear_refs_test_walk(unsigned long start, un=
signed long end,
 	struct clear_refs_private *cp =3D walk->private;
 	struct vm_area_struct *vma =3D walk->vma;
=20
+	if (vma->vm_flags & VM_PFNMAP)
+		return 1;
+
 	/*
 	 * Writing 1 to /proc/pid/clear_refs affects all pages.
 	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 326474de80bd..66e7141c2bfd 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -591,6 +591,9 @@ static int queue_pages_test_walk(unsigned long start, u=
nsigned long end,
 	unsigned long endvma =3D vma->vm_end;
 	unsigned long flags =3D qp->flags;
=20
+	if (vma->vm_flags & VM_PFNMAP)
+		return 1;
+
 	if (endvma > end)
 		endvma =3D end;
 	if (vma->vm_start > start)
diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 4c9a653ba563..75c1f2878519 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -35,7 +35,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr,=
 unsigned long end,
 	do {
 again:
 		next =3D pmd_addr_end(addr, end);
-		if (pmd_none(*pmd)) {
+		if (pmd_none(*pmd) || !walk->vma) {
 			if (walk->pte_hole)
 				err =3D walk->pte_hole(addr, next, walk);
 			if (err)
@@ -165,9 +165,6 @@ static int walk_hugetlb_range(unsigned long addr, unsig=
ned long end,
  * or skip it via the returned value. Return 0 if we do walk over the
  * current vma, and return 1 if we skip the vma. Negative values means
  * error, where we abort the current walk.
- *
- * Default check (only VM_PFNMAP check for now) is used when the caller
- * doesn't define test_walk() callback.
  */
 static int walk_page_test(unsigned long start, unsigned long end,
 			struct mm_walk *walk)
@@ -178,11 +175,19 @@ static int walk_page_test(unsigned long start, unsign=
ed long end,
 		return walk->test_walk(start, end, walk);
=20
 	/*
-	 * Do not walk over vma(VM_PFNMAP), because we have no valid struct
-	 * page backing a VM_PFNMAP range. See also commit a9ff785e4437.
+	 * vma(VM_PFNMAP) doesn't have any valid struct pages behind VM_PFNMAP
+	 * range, so we don't walk over it as we do for normal vmas. However,
+	 * Some callers are interested in handling hole range and they don't
+	 * want to just ignore any single address range. Such users certainly
+	 * define their ->pte_hole() callbacks, so let's delegate them to handle
+	 * vma(VM_PFNMAP).
 	 */
-	if (vma->vm_flags & VM_PFNMAP)
-		return 1;
+	if (vma->vm_flags & VM_PFNMAP) {
+		int err =3D 1;
+		if (walk->pte_hole)
+			err =3D walk->pte_hole(start, end, walk);
+		return err ? err : 1;
+	}
 	return 0;
 }
=20
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
