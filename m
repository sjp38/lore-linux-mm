Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE3936B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 15:50:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q87so137859034pfk.15
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 12:50:19 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id i15si1450914pll.664.2017.07.24.12.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 12:50:18 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id 123so1971390pgj.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 12:50:18 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH] mm: Prevent racy access to tlb_flush_pending
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20170717180246.62277-1-namit@vmware.com>
Date: Mon, 24 Jul 2017 12:50:14 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <542D4404-6F77-41A7-8B60-2402ED854269@gmail.com>
References: <20170717180246.62277-1-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>, Nadav Amit <namit@vmware.com>

Nadav Amit <namit@vmware.com> wrote:

> Setting and clearing mm->tlb_flush_pending can be performed by =
multiple
> threads, since mmap_sem may only be acquired for read in =
task_numa_work.
> If this happens, tlb_flush_pending may be cleared while one of the
> threads still changes PTEs and batches TLB flushes.
>=20
> As a result, TLB flushes can be skipped because the indication of
> pending TLB flushes is lost, for instance due to race between
> migration and change_protection_range (just as in the scenario that
> caused the introduction of tlb_flush_pending).
>=20
> The feasibility of such a scenario was confirmed by adding assertion =
to
> check tlb_flush_pending is not set by two threads, adding artificial
> latency in change_protection_range() and using sysctl to reduce
> kernel.numa_balancing_scan_delay_ms.
>=20
> Fixes: 20841405940e ("mm: fix TLB flush race between migration, and
> change_protection_range")
>=20
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
> include/linux/mm_types.h | 8 ++++----
> kernel/fork.c            | 2 +-
> mm/debug.c               | 2 +-
> 3 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 45cdb27791a3..36f4ec589544 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -493,7 +493,7 @@ struct mm_struct {
> 	 * can move process memory needs to flush the TLB when moving a
> 	 * PROT_NONE or PROT_NUMA mapped page.
> 	 */
> -	bool tlb_flush_pending;
> +	atomic_t tlb_flush_pending;
> #endif
> 	struct uprobes_state uprobes_state;
> #ifdef CONFIG_HUGETLB_PAGE
> @@ -528,11 +528,11 @@ static inline cpumask_t *mm_cpumask(struct =
mm_struct *mm)
> static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
> {
> 	barrier();
> -	return mm->tlb_flush_pending;
> +	return atomic_read(&mm->tlb_flush_pending) > 0;
> }
> static inline void set_tlb_flush_pending(struct mm_struct *mm)
> {
> -	mm->tlb_flush_pending =3D true;
> +	atomic_inc(&mm->tlb_flush_pending);
>=20
> 	/*
> 	 * Guarantee that the tlb_flush_pending store does not leak into =
the
> @@ -544,7 +544,7 @@ static inline void set_tlb_flush_pending(struct =
mm_struct *mm)
> static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> {
> 	barrier();
> -	mm->tlb_flush_pending =3D false;
> +	atomic_dec(&mm->tlb_flush_pending);
> }
> #else
> static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
> diff --git a/kernel/fork.c b/kernel/fork.c
> index e53770d2bf95..5a7ecfbb7420 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -809,7 +809,7 @@ static struct mm_struct *mm_init(struct mm_struct =
*mm, struct task_struct *p,
> 	mm_init_aio(mm);
> 	mm_init_owner(mm, p);
> 	mmu_notifier_mm_init(mm);
> -	clear_tlb_flush_pending(mm);
> +	atomic_set(&mm->tlb_flush_pending, 0);
> #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> 	mm->pmd_huge_pte =3D NULL;
> #endif
> diff --git a/mm/debug.c b/mm/debug.c
> index db1cd26d8752..d70103bb4731 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -159,7 +159,7 @@ void dump_mm(const struct mm_struct *mm)
> 		mm->numa_next_scan, mm->numa_scan_offset, =
mm->numa_scan_seq,
> #endif
> #if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> -		mm->tlb_flush_pending,
> +		atomic_read(&mm->tlb_flush_pending),
> #endif
> 		mm->def_flags, &mm->def_flags
> 	);
> --=20
> 2.11.0

Andrew, are there any reservations regarding this patch (excluding those =
of
Andy=E2=80=99s which I think I addressed)?

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
