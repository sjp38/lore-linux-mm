Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDBA6B025F
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 14:14:23 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id p10so8730060pgr.6
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:14:23 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id y21si384683pfd.406.2017.07.19.11.14.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 11:14:21 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c23so551920pfe.5
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 11:14:21 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: TLB batching breaks MADV_DONTNEED
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170719082316.ceuzf3wt34e6jy3s@suse.de>
Date: Wed, 19 Jul 2017 11:14:17 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <196BA5A2-A4EA-43A0-8961-B5CF262CA745@gmail.com>
References: <B672524C-1D52-4215-89CB-9FF3477600C9@gmail.com>
 <20170719082316.ceuzf3wt34e6jy3s@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>

Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Jul 18, 2017 at 10:05:23PM -0700, Nadav Amit wrote:
>> Something seems to be really wrong with all these TLB flush batching
>> mechanisms that are all around kernel. Here is another example, which =
was
>> not addressed by the recently submitted patches.
>>=20
>> Consider what happens when two MADV_DONTNEED run concurrently. =
According to
>> the man page "After a successful MADV_DONTNEED operation ??? =
subsequent
>> accesses of pages in the range will succeed, but will result in ???
>> zero-fill-on-demand pages for anonymous private mappings.???
>>=20
>> However, the test below, which does MADV_DONTNEED in two threads, =
reads ???8???
>> and not ???0??? when reading the memory following MADV_DONTNEED. It =
happens
>> since one of the threads clears the PTE, but defers the TLB flush for =
some
>> time (until it finishes changing 16k PTEs). The main thread sees the =
PTE
>> already non-present and does not flush the TLB.
>>=20
>> I think there is a need for a batching scheme that considers whether
>> mmap_sem is taken for write/read/nothing and the change to the PTE.
>> Unfortunately, I do not have the time to do it right now.
>>=20
>> Am I missing something? Thoughts?
>=20
> You're right that in this case, there will be a short window when the =
old
> anonymous data is still available. Non-anonymous doesn't matter in =
this case
> as the if the data is unmapped but available from a stale TLB entry, =
all it
> means is that there is a delay in refetching the data from backing =
storage.
>=20
> Technically, DONTNEED is not required to zero-fill the data but in the
> case of Linux, it actually does matter because the stale entry is
> pointing to page that will be freed shortly. If a caller returns and
> uses a stale TLB entry to "reinitialise" the region then the writes =
may
> be lost.

And although I didn=E2=80=99t check, it may have some implications on =
userfaultfd
which is often used with MADV_DONTNEED.

> This is independent of the reclaim batching of flushes and specific to
> how madvise uses zap_page_range.
>=20
> The most straight-forward but overkill solution would be to take =
mmap_sem
> for write for madvise. That would have wide-ranging consequences and =
likely
> to be rejected.
>=20
> A more reasonable solution would be to always flush the TLB range =
being
> madvised when the VMA is a private anonymous mapping to guarantee that
> a zero-fill-on-demand region exists. Other mappings do not need =
special
> protection as a parallel access will either use a stale TLB (no =
permission
> change so no problem) or refault the data. Special casing based on
> mmap_sem does not make much sense but is also unnecessary.
>=20
> Something like this completely untested patch that would point in the
> general direction if a case can be found where this should be fixed. =
It
> could be optimised to only flush the local TLB but it's probably not =
worth
> the complexity.
>=20
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 9976852f1e1c..78bbe09e549e 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -497,6 +497,18 @@ static long madvise_dontneed_single_vma(struct =
vm_area_struct *vma,
> 					unsigned long start, unsigned =
long end)
> {
> 	zap_page_range(vma, start, end - start);
> +
> +	/*
> +	 * A parallel madvise operation could have unmapped PTEs and =
deferred
> +	 * a flush before this madvise returns. Guarantee the TLB is =
flushed
> +	 * so that an immediate read after madvise will return zero's =
for
> +	 * private anonymous mappings. File-backed shared mappings do =
not
> +	 * matter as they will either use a stale TLB entry or refault =
the
> +	 * data in the event of a race.
> +	 */
> +	if (vma_is_anonymous(vma))
> +		flush_tlb_range(vma, start, end);
> +=09
> 	return 0;
> }

It will work but would in this case but would very often result in a
redundant TLB flush. I also think that we still don=E2=80=99t understand =
the extent
of the problem, based on the issues that keep coming out. In this case =
it
may be better to be defensive and not to try to avoid flushes too
aggressively (e.g., on non-anonymous VMAs).

Here is what I have in mind (not tested). Based on whether mmap_sem is
acquired for write, exclusiveness is determined. If exclusiveness is not
maintained, a TLB flush is required. If I could use the owner field of =
rwsem
(when available), this can simplify the check whether the code is run
exclusively.

Having said that, I still think that the whole batching scheme need to =
be
unified and rethought of.

-- >8 --
Subject: [PATCH] mm: Add missing TLB flushes when zapping

From: Nadav Amit <namit@vmware.com>
---
 arch/s390/mm/gmap.c       |  2 +-
 arch/x86/mm/mpx.c         |  2 +-
 drivers/android/binder.c  |  2 +-
 include/asm-generic/tlb.h |  2 +-
 include/linux/mm.h        |  2 +-
 mm/madvise.c              |  2 +-
 mm/memory.c               | 25 ++++++++++++++++++++++++-
 7 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/arch/s390/mm/gmap.c b/arch/s390/mm/gmap.c
index 4fb3d3cdb370..f11d78d74f64 100644
--- a/arch/s390/mm/gmap.c
+++ b/arch/s390/mm/gmap.c
@@ -690,7 +690,7 @@ void gmap_discard(struct gmap *gmap, unsigned long =
from, unsigned long to)
 		/* Find vma in the parent mm */
 		vma =3D find_vma(gmap->mm, vmaddr);
 		size =3D min(to - gaddr, PMD_SIZE - (gaddr & =
~PMD_MASK));
-		zap_page_range(vma, vmaddr, size);
+		zap_page_range(vma, vmaddr, size, false);
 	}
 	up_read(&gmap->mm->mmap_sem);
 }
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 1c34b767c84c..e0b0caa09199 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -789,7 +789,7 @@ static noinline int zap_bt_entries_mapping(struct =
mm_struct *mm,
 			return -EINVAL;
=20
 		len =3D min(vma->vm_end, end) - addr;
-		zap_page_range(vma, addr, len);
+		zap_page_range(vma, addr, len, true);
 		trace_mpx_unmap_zap(addr, addr+len);
=20
 		vma =3D vma->vm_next;
diff --git a/drivers/android/binder.c b/drivers/android/binder.c
index aae4d8d4be36..7e3fdd0e6e21 100644
--- a/drivers/android/binder.c
+++ b/drivers/android/binder.c
@@ -658,7 +658,7 @@ static int binder_update_page_range(struct =
binder_proc *proc, int allocate,
 		page =3D &proc->pages[(page_addr - proc->buffer) / =
PAGE_SIZE];
 		if (vma)
 			zap_page_range(vma, (uintptr_t)page_addr +
-				proc->user_buffer_offset, PAGE_SIZE);
+				proc->user_buffer_offset, PAGE_SIZE, =
true);
 err_vm_insert_page_failed:
 		unmap_kernel_range((unsigned long)page_addr, PAGE_SIZE);
 err_map_kernel_failed:
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 9cd77edd642d..83ca2764f61a 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -121,7 +121,7 @@ extern bool __tlb_remove_page_size(struct mmu_gather =
*tlb, struct page *page,
=20
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address,
-				      unsigned int range_size)
+				      unsigned long range_size)
 {
 	tlb->start =3D min(tlb->start, address);
 	tlb->end =3D max(tlb->end, address + range_size);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5e8569..bcd6b4138bec 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1203,7 +1203,7 @@ struct page *vm_normal_page_pmd(struct =
vm_area_struct *vma, unsigned long addr,
 int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size);
 void zap_page_range(struct vm_area_struct *vma, unsigned long address,
-		unsigned long size);
+		unsigned long size, bool exclusive);
 void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct =
*start_vma,
 		unsigned long start, unsigned long end);
=20
diff --git a/mm/madvise.c b/mm/madvise.c
index 9976852f1e1c..956f273fac2f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -496,7 +496,7 @@ static int madvise_free_single_vma(struct =
vm_area_struct *vma,
 static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
 					unsigned long start, unsigned =
long end)
 {
-	zap_page_range(vma, start, end - start);
+	zap_page_range(vma, start, end - start, false);
 	return 0;
 }
=20
diff --git a/mm/memory.c b/mm/memory.c
index 0e517be91a89..becb8752a422 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1469,11 +1469,12 @@ void unmap_vmas(struct mmu_gather *tlb,
  * @vma: vm_area_struct holding the applicable pages
  * @start: starting address of pages to zap
  * @size: number of bytes to zap
+ * @exclusive: whether mmap_sem is acquired for write
  *
  * Caller must protect the VMA list
  */
 void zap_page_range(struct vm_area_struct *vma, unsigned long start,
-		unsigned long size)
+		unsigned long size, bool exclusive)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	struct mmu_gather tlb;
@@ -1486,6 +1487,20 @@ void zap_page_range(struct vm_area_struct *vma, =
unsigned long start,
 	for ( ; vma && vma->vm_start < end; vma =3D vma->vm_next)
 		unmap_single_vma(&tlb, vma, start, end, NULL);
 	mmu_notifier_invalidate_range_end(mm, start, end);
+
+	/*
+	 * If mmap_sem is not acquired for write, a TLB flush of the =
entire
+	 * range is needed, since zap_page_range may run while another =
thread
+	 * unmaps PTEs and defers TLB flushes to batch them. As a =
result, this
+	 * thread may not see present PTEs in zap_pte_range and would =
not ask to
+	 * flush them, although they were not flushed before.  This =
scenario can
+	 * happen, for example, when two threads use MADV_DONTNEED of
+	 * overlapping memory ranges concurrently. To avoid problems, if
+	 * mmap_sem is not held exclusively, we should flush the entire =
range.
+	 */
+	if (!exclusive)
+		__tlb_adjust_range(&tlb, start, size);
+
 	tlb_finish_mmu(&tlb, start, end);
 }
=20
@@ -1511,6 +1526,14 @@ static void zap_page_range_single(struct =
vm_area_struct *vma, unsigned long addr
 	mmu_notifier_invalidate_range_start(mm, address, end);
 	unmap_single_vma(&tlb, vma, address, end, details);
 	mmu_notifier_invalidate_range_end(mm, address, end);
+
+	/*
+	 * This code may race with other PTE unmapping (see comment in
+	 * zap_page_range). Always flush the TLB since we do not know if
+	 * mmap_sem is acquired for write.
+	 */
+	__tlb_adjust_range(&tlb, address, size);
+
 	tlb_finish_mmu(&tlb, address, end);
 }
=20
--=20
2.11.0

=20=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
