Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CED9A6B0572
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 15:21:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l2so15219153pgu.2
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 12:21:47 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id d12si16045567pgn.909.2017.08.01.12.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 12:21:46 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id 83so3876888pgb.4
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 12:21:46 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 4/4] mm: fix KSM data corruption
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <1501566977-20293-5-git-send-email-minchan@kernel.org>
Date: Tue, 1 Aug 2017 12:21:41 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <FB5683EF-3972-46F0-BD14-F64B08D5E3AA@gmail.com>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-5-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, kernel-team <kernel-team@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>

Minchan Kim <minchan@kernel.org> wrote:

> Nadav reported KSM can corrupt the user data by the TLB batching =
race[1].
> That means data user written can be lost.
>=20
> Quote from Nadav Amit
> "
> For this race we need 4 CPUs:
>=20
> CPU0: Caches a writable and dirty PTE entry, and uses the stale value =
for
> write later.
>=20
> CPU1: Runs madvise_free on the range that includes the PTE. It would =
clear
> the dirty-bit. It batches TLB flushes.
>=20
> CPU2: Writes 4 to /proc/PID/clear_refs , clearing the PTEs soft-dirty. =
We
> care about the fact that it clears the PTE write-bit, and of course, =
batches
> TLB flushes.
>=20
> CPU3: Runs KSM. Our purpose is to pass the following test in
> write_protect_page():
>=20
> 	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
> 	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)))
>=20
> Since it will avoid TLB flush. And we want to do it while the PTE is =
stale.
> Later, and before replacing the page, we would be able to change the =
page.
>=20
> Note that all the operations the CPU1-3 perform canhappen in parallel =
since
> they only acquire mmap_sem for read.
>=20
> We start with two identical pages. Everything below regards the same
> page/PTE.
>=20
> CPU0		CPU1		CPU2		CPU3
> ----		----		----		----
> Write the same
> value on page
>=20
> [cache PTE as
> dirty in TLB]
>=20
> 		MADV_FREE
> 		pte_mkclean()
>=20
> 				4 > clear_refs
> 				pte_wrprotect()
>=20
> 						write_protect_page()
> 						[ success, no flush ]
>=20
> 						pages_indentical()
> 						[ ok ]
>=20
> Write to page
> different value
>=20
> [Ok, using stale
> PTE]
>=20
> 						replace_page()
>=20
> Later, CPU1, CPU2 and CPU3 would flush the TLB, but that is too late. =
CPU0
> already wrote on the page, but KSM ignored this write, and it got =
lost.
> "
>=20
> In above scenario, MADV_FREE is fixed by changing TLB batching API
> including [set|clear]_tlb_flush_pending. Remained thing is soft-dirty =
part.
>=20
> This patch changes soft-dirty uses TLB batching API instead of =
flush_tlb_mm
> and KSM checks pending TLB flush by using mm_tlb_flush_pending so that
> it will flush TLB to avoid data lost if there are other parallel =
threads
> pending TLB flush.
>=20
> [1] =
http://lkml.kernel.org/r/BD3A0EBE-ECF4-41D4-87FA-C755EA9AB6BD@gmail.com
>=20
> Note:
> I failed to reproduce this problem through Nadav's test program which
> need to tune timing in my system speed so didn't confirm it work.
> Nadav, Could you test this patch on your test machine?
>=20
> Thanks!
>=20
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
> fs/proc/task_mmu.c | 4 +++-
> mm/ksm.c           | 3 ++-
> 2 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 9782dedeead7..58ef3a6abbc0 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1018,6 +1018,7 @@ static ssize_t clear_refs_write(struct file =
*file, const char __user *buf,
> 	enum clear_refs_types type;
> 	int itype;
> 	int rv;
> +	struct mmu_gather tlb;
>=20
> 	memset(buffer, 0, sizeof(buffer));
> 	if (count > sizeof(buffer) - 1)
> @@ -1062,6 +1063,7 @@ static ssize_t clear_refs_write(struct file =
*file, const char __user *buf,
> 		}
>=20
> 		down_read(&mm->mmap_sem);
> +		tlb_gather_mmu(&tlb, mm, 0, -1);
> 		if (type =3D=3D CLEAR_REFS_SOFT_DIRTY) {
> 			for (vma =3D mm->mmap; vma; vma =3D =
vma->vm_next) {
> 				if (!(vma->vm_flags & VM_SOFTDIRTY))
> @@ -1083,7 +1085,7 @@ static ssize_t clear_refs_write(struct file =
*file, const char __user *buf,
> 		walk_page_range(0, mm->highest_vm_end, =
&clear_refs_walk);
> 		if (type =3D=3D CLEAR_REFS_SOFT_DIRTY)
> 			mmu_notifier_invalidate_range_end(mm, 0, -1);
> -		flush_tlb_mm(mm);
> +		tlb_finish_mmu(&tlb, 0, -1);
> 		up_read(&mm->mmap_sem);
> out_mm:
> 		mmput(mm);
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 0c927e36a639..15dd7415f7b3 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1038,7 +1038,8 @@ static int write_protect_page(struct =
vm_area_struct *vma, struct page *page,
> 		goto out_unlock;
>=20
> 	if (pte_write(*pvmw.pte) || pte_dirty(*pvmw.pte) ||
> -	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte))) {
> +	    (pte_protnone(*pvmw.pte) && pte_savedwrite(*pvmw.pte)) ||
> +						=
mm_tlb_flush_pending(mm)) {
> 		pte_t entry;
>=20
> 		swapped =3D PageSwapCache(page);
> --=20
> 2.7.4

I tested the patch-set, and my PoC does not fail anymore.

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
