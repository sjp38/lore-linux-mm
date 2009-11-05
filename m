Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CDA876B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 10:11:34 -0500 (EST)
Received: by pwj4 with SMTP id 4so45513pwj.6
        for <linux-mm@kvack.org>; Thu, 05 Nov 2009 07:11:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 6 Nov 2009 00:11:32 +0900
Message-ID: <28c262360911050711k47a63896xe4915157664cb822@mail.gmail.com>
Subject: Re: [PATCH] show per-process swap usage via procfs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, cl@linux-foundation.org, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Wed, Nov 4, 2009 at 3:24 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Passed several tests and one bug was fixed since RFC version.
> This patch is against mmotm.
> =3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, anon_rss and file_rss is counted as RSS and exported via /proc.
> RSS usage is important information but one more information which
> is often asked by users is "usage of swap".(user support team said.)
>
> This patch counts swap entry usage per process and show it via
> /proc/<pid>/status. I think status file is robust against new entry.
> Then, it is the first candidate..
>
> =A0After this, /proc/<pid>/status includes following line
> =A0<snip>
> =A0VmPeak: =A0 315360 kB
> =A0VmSize: =A0 315360 kB
> =A0VmLck: =A0 =A0 =A0 =A0 0 kB
> =A0VmHWM: =A0 =A0180452 kB
> =A0VmRSS: =A0 =A0180452 kB
> =A0VmData: =A0 311624 kB
> =A0VmStk: =A0 =A0 =A0 =A084 kB
> =A0VmExe: =A0 =A0 =A0 =A0 4 kB
> =A0VmLib: =A0 =A0 =A01568 kB
> =A0VmPTE: =A0 =A0 =A0 640 kB
> =A0VmSwap: =A0 131240 kB <=3D=3D=3D new information
>
> Note:
> =A0Because this patch catches swap_pte on page table, this will
> =A0not catch shmem's swapout. It's already accounted in per-shmem
> =A0inode and we don't need to do more.
>
> Changelog: 2009/11/03
> =A0- clean up.
> =A0- fixed initialization bug at fork (init_mm())
>
> Acked-by: Acked-by; David Rientjes <rientjes@google.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0fs/proc/task_mmu.c =A0 =A0 =A0 | =A0 =A09 ++++++---
> =A0include/linux/mm_types.h | =A0 =A01 +
> =A0kernel/fork.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0mm/memory.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 30 +++++++++++++++++++++-=
--------
> =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0mm/swapfile.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A06 files changed, 31 insertions(+), 12 deletions(-)
>
> Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
> +++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
> @@ -228,6 +228,7 @@ struct mm_struct {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0mm_counter_t _file_rss;
> =A0 =A0 =A0 =A0mm_counter_t _anon_rss;
> + =A0 =A0 =A0 mm_counter_t _swap_usage;
>
> =A0 =A0 =A0 =A0unsigned long hiwater_rss; =A0 =A0 =A0/* High-watermark of=
 RSS usage */
> =A0 =A0 =A0 =A0unsigned long hiwater_vm; =A0 =A0 =A0 /* High-water virtua=
l memory usage */
> Index: mmotm-2.6.32-Nov2/mm/memory.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/mm/memory.c
> +++ mmotm-2.6.32-Nov2/mm/memory.c
> @@ -376,12 +376,15 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int an=
on_rss)
> +static inline void
> +add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss, int swap_us=
age)
> =A0{
> =A0 =A0 =A0 =A0if (file_rss)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_mm_counter(mm, file_rss, file_rss);
> =A0 =A0 =A0 =A0if (anon_rss)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_mm_counter(mm, anon_rss, anon_rss);
> + =A0 =A0 =A0 if (swap_usage)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_mm_counter(mm, swap_usage, swap_usage);
> =A0}
>
> =A0/*
> @@ -597,7 +600,9 @@ copy_one_pte(struct mm_struct *dst_mm, s
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 &src_mm->mmlist);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unloc=
k(&mmlist_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_write_migration_entr=
y(entry) &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!is_migration_entry(ent=
ry))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rss[2]++;

First thought I come to is that we believe !is_migration_entry(entry) equal
swap entry?
We began supporting HWPOISON.
HWPOISON would be rare event so some less exact swap accouting may
be allowed, I think.  Is this enough to jusitfy that?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (is_write_migration=
_entry(entry) &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0is_cow_mapping(vm_flags)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * COW map=
pings require pages in both parent
> @@ -648,11 +653,11 @@ static int copy_pte_range(struct mm_stru
> =A0 =A0 =A0 =A0pte_t *src_pte, *dst_pte;
> =A0 =A0 =A0 =A0spinlock_t *src_ptl, *dst_ptl;
> =A0 =A0 =A0 =A0int progress =3D 0;
> - =A0 =A0 =A0 int rss[2];
> + =A0 =A0 =A0 int rss[3];
> =A0 =A0 =A0 =A0swp_entry_t entry =3D (swp_entry_t){0};
>
> =A0again:
> - =A0 =A0 =A0 rss[1] =3D rss[0] =3D 0;
> + =A0 =A0 =A0 rss[2] =3D rss[1] =3D rss[0] =3D 0;
> =A0 =A0 =A0 =A0dst_pte =3D pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst=
_ptl);
> =A0 =A0 =A0 =A0if (!dst_pte)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOMEM;
> @@ -688,7 +693,7 @@ again:
> =A0 =A0 =A0 =A0arch_leave_lazy_mmu_mode();
> =A0 =A0 =A0 =A0spin_unlock(src_ptl);
> =A0 =A0 =A0 =A0pte_unmap_nested(orig_src_pte);
> - =A0 =A0 =A0 add_mm_rss(dst_mm, rss[0], rss[1]);
> + =A0 =A0 =A0 add_mm_rss(dst_mm, rss[0], rss[1], rss[2]);
> =A0 =A0 =A0 =A0pte_unmap_unlock(orig_dst_pte, dst_ptl);
> =A0 =A0 =A0 =A0cond_resched();
>
> @@ -818,6 +823,7 @@ static unsigned long zap_pte_range(struc
> =A0 =A0 =A0 =A0spinlock_t *ptl;
> =A0 =A0 =A0 =A0int file_rss =3D 0;
> =A0 =A0 =A0 =A0int anon_rss =3D 0;
> + =A0 =A0 =A0 int swap_usage =3D 0;
>
> =A0 =A0 =A0 =A0pte =3D pte_offset_map_lock(mm, pmd, addr, &ptl);
> =A0 =A0 =A0 =A0arch_enter_lazy_mmu_mode();
> @@ -887,13 +893,18 @@ static unsigned long zap_pte_range(struc
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pte_file(ptent)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(!(vma->vm_fla=
gs & VM_NONLINEAR)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0print_bad_=
pte(vma, addr, ptent, NULL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unlikely(!free_swap_and_cache(pte_to_s=
wp_entry(ptent))))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_bad_pte(vma, addr, pt=
ent, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 swp_entry_t ent =3D pte_to_=
swp_entry(ptent);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!is_migration_entry(ent=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 swap_usage-=
-;

ditto

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!free_swap_and=
_cache(ent)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 print_bad_p=
te(vma, addr, ptent, NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pte_clear_not_present_full(mm, addr, pte, =
tlb->fullmm);
> =A0 =A0 =A0 =A0} while (pte++, addr +=3D PAGE_SIZE, (addr !=3D end && *za=
p_work > 0));
>
> - =A0 =A0 =A0 add_mm_rss(mm, file_rss, anon_rss);
> + =A0 =A0 =A0 add_mm_rss(mm, file_rss, anon_rss, swap_usage);
> =A0 =A0 =A0 =A0arch_leave_lazy_mmu_mode();
> =A0 =A0 =A0 =A0pte_unmap_unlock(pte - 1, ptl);
>
> @@ -2595,6 +2606,7 @@ static int do_swap_page(struct mm_struct
> =A0 =A0 =A0 =A0 */
>
> =A0 =A0 =A0 =A0inc_mm_counter(mm, anon_rss);
> + =A0 =A0 =A0 dec_mm_counter(mm, swap_usage);
> =A0 =A0 =A0 =A0pte =3D mk_pte(page, vma->vm_page_prot);
> =A0 =A0 =A0 =A0if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pte =3D maybe_mkwrite(pte_mkdirty(pte), vm=
a);
> Index: mmotm-2.6.32-Nov2/mm/swapfile.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/mm/swapfile.c
> +++ mmotm-2.6.32-Nov2/mm/swapfile.c
> @@ -837,6 +837,7 @@ static int unuse_pte(struct vm_area_stru
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0inc_mm_counter(vma->vm_mm, anon_rss);
> + =A0 =A0 =A0 dec_mm_counter(vma->vm_mm, swap_usage);
> =A0 =A0 =A0 =A0get_page(page);
> =A0 =A0 =A0 =A0set_pte_at(vma->vm_mm, addr, pte,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pte_mkold(mk_pte(page, vma->vm_page_p=
rot)));
> Index: mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/fs/proc/task_mmu.c
> +++ mmotm-2.6.32-Nov2/fs/proc/task_mmu.c
> @@ -17,7 +17,7 @@
> =A0void task_mem(struct seq_file *m, struct mm_struct *mm)
> =A0{
> =A0 =A0 =A0 =A0unsigned long data, text, lib;
> - =A0 =A0 =A0 unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
> + =A0 =A0 =A0 unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss,=
 swap;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Note: to minimize their overhead, mm maintains hiwater_=
vm and
> @@ -36,6 +36,7 @@ void task_mem(struct seq_file *m, struct
> =A0 =A0 =A0 =A0data =3D mm->total_vm - mm->shared_vm - mm->stack_vm;
> =A0 =A0 =A0 =A0text =3D (PAGE_ALIGN(mm->end_code) - (mm->start_code & PAG=
E_MASK)) >> 10;
> =A0 =A0 =A0 =A0lib =3D (mm->exec_vm << (PAGE_SHIFT-10)) - text;
> + =A0 =A0 =A0 swap =3D get_mm_counter(mm, swap_usage);
> =A0 =A0 =A0 =A0seq_printf(m,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"VmPeak:\t%8lu kB\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"VmSize:\t%8lu kB\n"
> @@ -46,7 +47,8 @@ void task_mem(struct seq_file *m, struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"VmStk:\t%8lu kB\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"VmExe:\t%8lu kB\n"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"VmLib:\t%8lu kB\n"
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 "VmPTE:\t%8lu kB\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "VmPTE:\t%8lu kB\n"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "VmSwap:\t%8lu kB\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hiwater_vm << (PAGE_SHIFT-10),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(total_vm - mm->reserved_vm) << (PAGE_SHIF=
T-10),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mm->locked_vm << (PAGE_SHIFT-10),
> @@ -54,7 +56,8 @@ void task_mem(struct seq_file *m, struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_rss << (PAGE_SHIFT-10),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data << (PAGE_SHIFT-10),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mm->stack_vm << (PAGE_SHIFT-10), text, lib=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 (PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >>=
 10);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >>=
 10,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 swap << (PAGE_SHIFT - 10));
> =A0}
>
> =A0unsigned long task_vsize(struct mm_struct *mm)
> Index: mmotm-2.6.32-Nov2/mm/rmap.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/mm/rmap.c
> +++ mmotm-2.6.32-Nov2/mm/rmap.c
> @@ -834,6 +834,7 @@ static int try_to_unmap_one(struct page
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unloc=
k(&mmlist_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dec_mm_counter(mm, anon_rs=
s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inc_mm_counter(mm, swap_usa=
ge);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (PAGE_MIGRATION) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Store the pfn of the pa=
ge in a special migration
> Index: mmotm-2.6.32-Nov2/kernel/fork.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/kernel/fork.c
> +++ mmotm-2.6.32-Nov2/kernel/fork.c
> @@ -454,6 +454,7 @@ static struct mm_struct * mm_init(struct
> =A0 =A0 =A0 =A0mm->nr_ptes =3D 0;
> =A0 =A0 =A0 =A0set_mm_counter(mm, file_rss, 0);
> =A0 =A0 =A0 =A0set_mm_counter(mm, anon_rss, 0);
> + =A0 =A0 =A0 set_mm_counter(mm, swap_usage, 0);
> =A0 =A0 =A0 =A0spin_lock_init(&mm->page_table_lock);
> =A0 =A0 =A0 =A0mm->free_area_cache =3D TASK_UNMAPPED_BASE;
> =A0 =A0 =A0 =A0mm->cached_hole_size =3D ~0UL;
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

That's good.
>From now on, we can chagne scanning of pte to find swap pte
in smaps_pte_rangem, too. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
