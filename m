Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E20346B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 19:40:09 -0500 (EST)
Received: by pwi1 with SMTP id 1so320253pwi.6
        for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:40:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 11 Dec 2009 09:40:07 +0900
Message-ID: <28c262360912101640y4b90db76w61a7a5dab5f8e796@mail.gmail.com>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Hi, Kame.

It looks good than older one. :)

On Thu, Dec 10, 2009 at 4:34 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Now, mm's counter information is updated by atomic_long_xxx() functions i=
f
> USE_SPLIT_PTLOCKS is defined. This causes cache-miss when page faults hap=
pens
> simultaneously in prural cpus. (Almost all process-shared objects is...)
>
> Considering accounting per-mm page usage more, one of problems is cost of
> this counter.
>
> This patch implements per-cpu mm cache. This per-cpu cache is loosely
> synchronized with mm's counter. Current design is..
>
> =C2=A0- prepare per-cpu object curr_mmc. curr_mmc containes pointer to mm=
 and
> =C2=A0 =C2=A0array of counters.
> =C2=A0- At page fault,
> =C2=A0 =C2=A0 * if curr_mmc.mm !=3D NULL, update curr_mmc.mm counter.
> =C2=A0 =C2=A0 * if curr_mmc.mm =3D=3D NULL, fill curr_mmc.mm =3D current-=
>mm and account 1.
> =C2=A0- At schedule()
> =C2=A0 =C2=A0 * if curr_mm.mm !=3D NULL, synchronize and invalidate cache=
d information.
> =C2=A0 =C2=A0 * if curr_mmc.mm =3D=3D NULL, nothing to do.
>
> By this.
> =C2=A0- no atomic ops, which tends to cache-miss, under page table lock.
> =C2=A0- mm->counters are synchronized when schedule() is called.
> =C2=A0- No bad thing to read-side.
>
> Concern:
> =C2=A0- added cost to schedule().
>
> Micro Benchmark:
> =C2=A0measured the number of page faults with 2 threads on 2 sockets.
>
> =C2=A0Before:
> =C2=A0 Performance counter stats for './multi-fault 2' (5 runs):
>
> =C2=A0 =C2=A0 =C2=A0 45122351 =C2=A0page-faults =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0( +- =C2=A0 1.125% )
> =C2=A0 =C2=A0 =C2=A0989608571 =C2=A0cache-references =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 ( +- =C2=A0 1.198% )
> =C2=A0 =C2=A0 =C2=A0205308558 =C2=A0cache-misses =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.159% )
> =C2=A0 29263096648639268 =C2=A0bus-cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.004% )
>
> =C2=A0 60.003427500 =C2=A0seconds time elapsed =C2=A0 ( +- =C2=A0 0.003% =
)
>
> =C2=A0After:
> =C2=A0 =C2=A0Performance counter stats for './multi-fault 2' (5 runs):
>
> =C2=A0 =C2=A0 =C2=A0 46997471 =C2=A0page-faults =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0( +- =C2=A0 0.720% )
> =C2=A0 =C2=A0 1004100076 =C2=A0cache-references =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 ( +- =C2=A0 0.734% )
> =C2=A0 =C2=A0 =C2=A0180959964 =C2=A0cache-misses =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.374% )
> =C2=A0 29263437363580464 =C2=A0bus-cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.002% )
>
> =C2=A0 60.003315683 =C2=A0seconds time elapsed =C2=A0 ( +- =C2=A0 0.004% =
)
>
> =C2=A0 cachemiss/page faults is reduced from 4.55 miss/faults to be 3.85m=
iss/faults
>
> =C2=A0 This microbencmark doesn't do usual behavior (page fault ->madvise=
(DONTNEED)
> =C2=A0 but reducing cache-miss cost sounds good to me even if it's very s=
mall.
>
> Changelog 2009/12/09:
> =C2=A0- loosely update curr_mmc.mm at the 1st page fault.
> =C2=A0- removed hooks in tick.(update_process_times)
> =C2=A0- exported curr_mmc and check curr_mmc.mm directly.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =C2=A0include/linux/mm.h =C2=A0 =C2=A0 =C2=A0 | =C2=A0 37 +++++++++++++++=
+++++++++++++
> =C2=A0include/linux/mm_types.h | =C2=A0 12 +++++++++
> =C2=A0kernel/exit.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=
=A03 +-
> =C2=A0kernel/sched.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A06 =
++++
> =C2=A0mm/memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=
=A0 60 ++++++++++++++++++++++++++++++++++++++++-------
> =C2=A05 files changed, 108 insertions(+), 10 deletions(-)
>
> Index: mmotm-2.6.32-Dec8/include/linux/mm_types.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Dec8.orig/include/linux/mm_types.h
> +++ mmotm-2.6.32-Dec8/include/linux/mm_types.h
> @@ -297,4 +297,16 @@ struct mm_struct {
> =C2=A0/* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
> =C2=A0#define mm_cpumask(mm) (&(mm)->cpu_vm_mask)
>
> +#if USE_SPLIT_PTLOCKS
> +/*
> + * percpu object used for caching thread->mm information.
> + */
> +struct pcp_mm_cache {
> + =C2=A0 =C2=A0 =C2=A0 struct mm_struct *mm;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long counters[NR_MM_COUNTERS];
> +};
> +
> +DECLARE_PER_CPU(struct pcp_mm_cache, curr_mmc);
> +#endif
> +
> =C2=A0#endif /* _LINUX_MM_TYPES_H */
> Index: mmotm-2.6.32-Dec8/include/linux/mm.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Dec8.orig/include/linux/mm.h
> +++ mmotm-2.6.32-Dec8/include/linux/mm.h
> @@ -883,7 +883,16 @@ static inline void set_mm_counter(struct
>
> =C2=A0static inline unsigned long get_mm_counter(struct mm_struct *mm, in=
t member)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 return (unsigned long)atomic_long_read(&(mm)->coun=
ters[member]);
> + =C2=A0 =C2=A0 =C2=A0 long ret;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Because this counter is loosely synchroniz=
ed with percpu cached
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* information, it's possible that value gets=
 to be minus. For user's
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* convenience/sanity, avoid returning minus.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 ret =3D atomic_long_read(&(mm)->counters[member]);
> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(ret < 0))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 return (unsigned long)ret;
> =C2=A0}

Now, your sync point is only task switching time.
So we can't show exact number if many counting of mm happens
in short time.(ie, before context switching).
It isn't matter?

>
> =C2=A0static inline void add_mm_counter(struct mm_struct *mm, int member,=
 long value)
> @@ -900,6 +909,25 @@ static inline void dec_mm_counter(struct
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0atomic_long_dec(&(mm)->counters[member]);
> =C2=A0}
> +extern void __sync_mm_counters(struct mm_struct *mm);
> +/* Called under non-preemptable context, for syncing cached information =
*/
> +static inline void sync_mm_counters_atomic(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mm_struct *mm;
> +
> + =C2=A0 =C2=A0 =C2=A0 mm =3D percpu_read(curr_mmc.mm);
> + =C2=A0 =C2=A0 =C2=A0 if (mm) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __sync_mm_counters(mm)=
;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percpu_write(curr_mmc.=
mm, NULL);
> + =C2=A0 =C2=A0 =C2=A0 }
> +}
> +/* called at thread exit */
> +static inline void exit_mm_counters(void)
> +{
> + =C2=A0 =C2=A0 =C2=A0 preempt_disable();
> + =C2=A0 =C2=A0 =C2=A0 sync_mm_counters_atomic();
> + =C2=A0 =C2=A0 =C2=A0 preempt_enable();
> +}
>
> =C2=A0#else =C2=A0/* !USE_SPLIT_PTLOCKS */
> =C2=A0/*
> @@ -931,6 +959,13 @@ static inline void dec_mm_counter(struct
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm->counters[member]--;
> =C2=A0}
>
> +static inline void sync_mm_counters_atomic(void)
> +{
> +}
> +
> +static inline void exit_mm_counters(void)
> +{
> +}
> =C2=A0#endif /* !USE_SPLIT_PTLOCKS */
>
> =C2=A0#define get_mm_rss(mm) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 \
> Index: mmotm-2.6.32-Dec8/mm/memory.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Dec8.orig/mm/memory.c
> +++ mmotm-2.6.32-Dec8/mm/memory.c
> @@ -121,6 +121,50 @@ static int __init init_zero_pfn(void)
> =C2=A0}
> =C2=A0core_initcall(init_zero_pfn);
>
> +#if USE_SPLIT_PTLOCKS
> +
> +DEFINE_PER_CPU(struct pcp_mm_cache, curr_mmc);
> +
> +void __sync_mm_counters(struct mm_struct *mm)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct pcp_mm_cache *mmc =3D &per_cpu(curr_mmc, sm=
p_processor_id());
> + =C2=A0 =C2=A0 =C2=A0 int i;
> +
> + =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < NR_MM_COUNTERS; i++) {

The cost depends on NR_MM_COUNTER.
Now, it's low but we might add the more counts in pcp_mm_cache.
Then, If we don't change any count in many counts, we don't need to loop
unnecessary. we will remove this with change flag of pcp_mm_cache.
But, change flag cmp/updating overhead is also ugly. So, it would be rather
overkill in now. How about leaving the NOTE ?

/* NOTE :
 * We have to rethink for reducing overhead if we start to
 * add many counts in pcp_mm_cache.
 */

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (mmc->counters[i] !=
=3D 0) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 atomic_long_add(mmc->counters[i], &mm->counters[i]);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 mmc->counters[i] =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 return;
> +}
> +/*
> + * This add_mm_counter_fast() works well only when it's expexted that

expexted =3D> expected :)

> + * mm =3D=3D current->mm. So, use of this function is limited under memo=
ry.c
> + * This add_mm_counter_fast() is called under page table lock.
> + */
> +static void add_mm_counter_fast(struct mm_struct *mm, int member, int va=
l)
> +{
> + =C2=A0 =C2=A0 =C2=A0 struct mm_struct *cached =3D percpu_read(curr_mmc.=
mm);
> +
> + =C2=A0 =C2=A0 =C2=A0 if (likely(cached =3D=3D mm)) { /* fast path */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percpu_add(curr_mmc.co=
unters[member], val);
> + =C2=A0 =C2=A0 =C2=A0 } else if (mm =3D=3D current->mm) { /* 1st page fa=
ult in this period */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percpu_write(curr_mmc.=
mm, mm);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percpu_write(curr_mmc.=
counters[member], val);
> + =C2=A0 =C2=A0 =C2=A0 } else /* page fault via side-path context (get_us=
er_pages()) */
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 add_mm_counter(mm, mem=
ber, val);
> +}
> +
> +#define inc_mm_counter_fast(mm, member) =C2=A0 =C2=A0 =C2=A0 =C2=A0add_m=
m_counter_fast(mm, member, 1)
> +#define dec_mm_counter_fast(mm, member) =C2=A0 =C2=A0 =C2=A0 =C2=A0add_m=
m_counter_fast(mm, member, -1)
> +#else
> +
> +#define inc_mm_counter_fast(mm, member) =C2=A0 =C2=A0 =C2=A0 =C2=A0inc_m=
m_counter(mm, member)
> +#define dec_mm_counter_fast(mm, member) =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_m=
m_counter(mm, member)
> +
> +#endif
> +
> =C2=A0/*
> =C2=A0* If a p?d_bad entry is found while walking page tables, report
> =C2=A0* the error, before resetting entry to p?d_none. =C2=A0Usually (but
> @@ -1541,7 +1585,7 @@ static int insert_page(struct vm_area_st
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Ok, finally just insert the thing.. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0get_page(page);
> - =C2=A0 =C2=A0 =C2=A0 inc_mm_counter(mm, MM_FILEPAGES);
> + =C2=A0 =C2=A0 =C2=A0 inc_mm_counter_fast(mm, MM_FILEPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page_add_file_rmap(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0set_pte_at(mm, addr, pte, mk_pte(page, prot));
>
> @@ -2177,11 +2221,11 @@ gotten:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (likely(pte_same(*page_table, orig_pte))) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (old_page) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (!PageAnon(old_page)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dec_mm_counter(mm, MM_FILEPAGES);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 inc_mm_counter(mm, MM_ANONPAGES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dec_mm_counter_fast(mm, MM_FILEPAGES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 inc_mm_counter_fast(mm, MM_ANONPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 inc_mm_counter(mm, MM_ANONPAGES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 inc_mm_counter_fast(mm, MM_ANONPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0flush_cache_page(v=
ma, address, pte_pfn(orig_pte));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0entry =3D mk_pte(n=
ew_page, vma->vm_page_prot);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0entry =3D maybe_mk=
write(pte_mkdirty(entry), vma);
> @@ -2614,7 +2658,7 @@ static int do_swap_page(struct mm_struct
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * discarded at swap_free().
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
>
> - =C2=A0 =C2=A0 =C2=A0 inc_mm_counter(mm, MM_ANONPAGES);
> + =C2=A0 =C2=A0 =C2=A0 inc_mm_counter_fast(mm, MM_ANONPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pte =3D mk_pte(page, vma->vm_page_prot);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((flags & FAULT_FLAG_WRITE) && reuse_swap_p=
age(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pte =3D maybe_mkwr=
ite(pte_mkdirty(pte), vma);
> @@ -2698,7 +2742,7 @@ static int do_anonymous_page(struct mm_s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!pte_none(*page_table))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto release;
>
> - =C2=A0 =C2=A0 =C2=A0 inc_mm_counter(mm, MM_ANONPAGES);
> + =C2=A0 =C2=A0 =C2=A0 inc_mm_counter_fast(mm, MM_ANONPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page_add_new_anon_rmap(page, vma, address);
> =C2=A0setpte:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0set_pte_at(mm, address, page_table, entry);
> @@ -2852,10 +2896,10 @@ static int __do_fault(struct mm_struct *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (flags & FAULT_=
FLAG_WRITE)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0entry =3D maybe_mkwrite(pte_mkdirty(entry), vma);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (anon) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 inc_mm_counter(mm, MM_ANONPAGES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 inc_mm_counter_fast(mm, MM_ANONPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0page_add_new_anon_rmap(page, vma, address);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 inc_mm_counter(mm, MM_FILEPAGES);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 inc_mm_counter_fast(mm, MM_FILEPAGES);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0page_add_file_rmap(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (flags & FAULT_FLAG_WRITE) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dirty_page =3D page;
> Index: mmotm-2.6.32-Dec8/kernel/sched.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Dec8.orig/kernel/sched.c
> +++ mmotm-2.6.32-Dec8/kernel/sched.c
> @@ -2858,6 +2858,7 @@ context_switch(struct rq *rq, struct tas
> =C2=A0 =C2=A0 =C2=A0 =C2=A0trace_sched_switch(rq, prev, next);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mm =3D next->mm;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0oldmm =3D prev->active_mm;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * For paravirt, this is coupled with an exit =
in switch_to to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * combine the page table reload and the switc=
h backend into
> @@ -5477,6 +5478,11 @@ need_resched_nonpreemptible:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (sched_feat(HRTICK))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hrtick_clear(rq);
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* sync/invaldidate per-cpu cached mm related=
 information
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* before taling rq->lock. (see include/linux=
/mm.h)

taling =3D> taking

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 sync_mm_counters_atomic();

It's my above concern.
before the process schedule out, we could get the wrong info.
It's not realistic problem?


>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_irq(&rq->lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0update_rq_clock(rq);
> Index: mmotm-2.6.32-Dec8/kernel/exit.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Dec8.orig/kernel/exit.c
> +++ mmotm-2.6.32-Dec8/kernel/exit.c
> @@ -942,7 +942,8 @@ NORET_TYPE void do_exit(long code)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_INFO "=
note: %s[%d] exited with preempt_count %d\n",
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0current->comm, task_pid_nr(current),
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0preempt_count());
> -
> + =C2=A0 =C2=A0 =C2=A0 /* synchronize per-cpu cached mm related informati=
on before account */
> + =C2=A0 =C2=A0 =C2=A0 exit_mm_counters();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0acct_update_integrals(tsk);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0group_dead =3D atomic_dec_and_test(&tsk->signa=
l->live);
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
