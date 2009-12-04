Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0C1626B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 19:49:19 -0500 (EST)
Received: by pwi9 with SMTP id 9so1899983pwi.6
        for <linux-mm@kvack.org>; Thu, 03 Dec 2009 16:49:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091204091821.340ddcd5.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091203102851.daeb940c.kamezawa.hiroyu@jp.fujitsu.com>
	 <4B17D506.7030701@gmail.com>
	 <20091204091821.340ddcd5.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 4 Dec 2009 09:49:17 +0900
Message-ID: <28c262360912031649o42c9af52r35369fa820ec14f9@mail.gmail.com>
Subject: Re: [RFC][mmotm][PATCH] percpu mm struct counter cache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, Dec 4, 2009 at 9:18 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 04 Dec 2009 00:11:02 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> Hi, Kame.
>>
>> KAMEZAWA Hiroyuki wrote:
>> > Christophs's mm_counter+percpu implemtation has scalability at updates=
 but
>> > read-side had some problems. Inspired by that, I tried to write percpu=
-cache
>> > counter + synchronization method. My own tiny benchmark shows somethin=
g good
>> > but this patch's hooks may summon other troubles...
>> >
>> > Now, I start from sharing codes here. Any comments are welcome.
>> > (Especially, moving hooks to somewhere better is my concern.)
>> > My test proram will be posted in reply to this mail.
>> >
>> > Regards,
>> > -Kame
>> > =3D=3D
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > This patch is for implemanting light-weight per-mm statistics.
>> > Now, when split-pagetable-lock is used, statistics per mm struct
>> > is maintainer by atomic_long_t value. This costs one atomic_inc()
>> > under page_table_lock and if multi-thread program runs and shares
>> > mm_struct, this tend to cause cache-miss+atomic_ops.
>>
>> Both cases are (page_table_lock + atomic inc) cost?
>>
>> AFAIK,
>> If we don't use split lock, we get the just spinlock of page_table_lock.
> yes.
>
>> If we use split lock, we get the just atomic_op cost + page->ptl lock.
> yes. now.
>
>> In case of split lock, ptl lock contention for rss accounting is little,=
 I think.
>>
>> If I am wrong, could you write down changelog more clearly?
>>
> AFAIK, you're right.
>
>
>>
>> >
>> > This patch adds per-cpu mm statistics cache and sync it in periodicall=
y.
>> > Cached Information are synchronized into mm_struct at
>> > =C2=A0 - tick
>> > =C2=A0 - context_switch.
>> > =C2=A0 if there is difference.
>>
>> Should we sync mm statistics periodically?
>> Couldn't we sync statistics when we need it?
>> ex) get_mm_counter.
>> I am not sure it's possible. :)
>
> For this counter, read-side cost is important.
> My reply to Christoph's per-cpu-mm-counter, which gathers information at
> get_mm_counter.
> http://marc.info/?l=3Dlinux-mm&m=3D125747002917101&w=3D2
>
> Making read-side of this counter slower means making ps or top slower.
> IMO, ps or top is too slow now and making them more slow is very bad.

Also, we don't want to make regression in no-split-ptl lock system.
Now, tick update cost is zero in no-split-ptl-lock system.
but task switching is a little increased since compare instruction.
As you know, task-switching is rather costly function.
I mind additional overhead in so-split-ptl lock system.
I think we can remove the overhead completely.

>
>>
>> >
>> > Tiny test progam on x86-64/4core/2socket machine shows (small) improve=
ments.
>> > This test program measures # of page faults on cpu =C2=A00 and 4.
>> > (Using all 8cpus, most of time is used for spinlock and you can't see
>> > =C2=A0benefits of this patch..)
>> >
>> > [Before Patch]
>> > Performance counter stats for './multi-fault 2' (5 runs):
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A044282223 =C2=A0page-faults =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0( +- =C2=A0 0.912% )
>> > =C2=A0 =C2=A0 =C2=A01015540330 =C2=A0cache-references =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 1.701% )
>> > =C2=A0 =C2=A0 =C2=A0 210497140 =C2=A0cache-misses =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.731% )
>> > =C2=A029262804803383988 =C2=A0bus-cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.003% )
>> >
>> > =C2=A0 =C2=A060.003401467 =C2=A0seconds time elapsed =C2=A0 ( +- =C2=
=A0 0.004% )
>> >
>> > =C2=A04.75 miss/faults
>> > =C2=A0660825108.1564714580837551899777 bus-cycles/faults
>> >
>> > [After Patch]
>> > Performance counter stats for './multi-fault 2' (5 runs):
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A045543398 =C2=A0page-faults =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0( +- =C2=A0 0.499% )
>> > =C2=A0 =C2=A0 =C2=A01031865896 =C2=A0cache-references =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 2.720% )
>> > =C2=A0 =C2=A0 =C2=A0 184901499 =C2=A0cache-misses =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.626% )
>> > =C2=A029261889737265056 =C2=A0bus-cycles =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 ( +- =C2=A0 0.002% )
>> >
>> > =C2=A0 =C2=A060.001218501 =C2=A0seconds time elapsed =C2=A0 ( +- =C2=
=A0 0.000% )
>> >
>> > =C2=A04.05 miss/faults
>> > =C2=A0642505632.5 bus-cycles/faults
>> >
>> > Note: to enable split-pagetable-lock, you have to disable SPINLOCK_DEB=
UG.
>> >
>> > This patch moves mm_counter definitions to mm.h+memory.c from sched.h.
>> > So, total patch size seems to be big.
>>
>> What's your goal/benefit?
>> You cut down atomic operations with (cache and sync) method?
>>
>> Please, write down the your goal/benefit. :)
>>
> Sorry.

No problem. :)

>
> My goal is adding more counters like swap_usage or lowmem_rss_usage,
> etc. Adding them means I'll add more cache-misses.
> Once we can add cache-hit+no-atomic-ops counter, adding statistics will b=
e
> much easier.

Yeb. It would be better to add this in changelog.

> And considering relaxinug mmap_sem as my speculative-page-fault patch,
> this mm_counter will be another heavy cache-miss point.
>
>
>> >
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
>> > +/*
>> > + * The mm counters are not protected by its page_table_lock,
>> > + * so must be incremented atomically.
>> > + */
>> > +void set_mm_counter(struct mm_struct *mm, int member, long value)
>> > +{
>> > + =C2=A0 atomic_long_set(&mm->counters[member], value);
>> > +}
>> > +
>> > +unsigned long get_mm_counter(struct mm_struct *mm, int member)
>> > +{
>> > + =C2=A0 long ret =3D atomic_long_read(&mm->counters[member]);
>>
>> Which case do we get the minus 'ret'?
>>
> When a process is heavily swapped out and no "sync" happens,
> we can get minus. And file-map,fault,munmap in short time can
> make this minus.

Yes. please, add this description by comment.

> And In this patch, dec_mm_counter() is not used so much.
> But I'll add ones at adding swap_usage counter.
>
>
>
>
>> > + =C2=A0 if (ret < 0)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>> > + =C2=A0 return ret;
>> > +}
>> > +
>> > +void add_mm_counter(struct mm_struct *mm, int member, long value)
>> > +{
>> > + =C2=A0 atomic_long_add(value, &mm->counters[member]);
>> > +}
>> > +
>> > +/*
>> > + * Always called under pte_lock....irq off, mm !=3D curr_mmc.mm if ca=
lled
>> > + * by get_user_pages() etc.
>> > + */
>> > +static void
>> > +add_mm_counter_fast(struct mm_struct *mm, int member, long val)
>> > +{
>> > + =C2=A0 if (likely(percpu_read(curr_mmc.mm) =3D=3D mm))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 percpu_add(curr_mmc.counters[memb=
er], val);
>> > + =C2=A0 else
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 add_mm_counter(mm, member, val);
>> > +}
>> > +
>> > +/* Called by not-preemptable context */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 non-preemptible
>> > +void sync_tsk_mm_counters(void)
>> > +{
>> > + =C2=A0 struct pcp_mm_cache *cache =3D &per_cpu(curr_mmc, smp_process=
or_id());
>> > + =C2=A0 int i;
>> > +
>> > + =C2=A0 if (!cache->mm)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> > +
>> > + =C2=A0 for (i =3D 0; i < NR_MM_STATS; i++) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!cache->counters[i])
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 conti=
nue;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 add_mm_counter(cache->mm, i, cach=
e->counters[i]);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cache->counters[i] =3D 0;
>> > + =C2=A0 }
>> > +}
>> > +
>> > +void prepare_mm_switch(struct task_struct *prev, struct task_struct *=
next)
>> > +{
>> > + =C2=A0 if (prev->mm =3D=3D next->mm)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return;
>> > + =C2=A0 /* If task is exited, sync is already done and prev->mm is NU=
LL */
>> > + =C2=A0 if (prev->mm)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sync_tsk_mm_counters();
>> > + =C2=A0 percpu_write(curr_mmc.mm, next->mm);
>> > +}
>>
>> Further optimization.
>> In case of (A-> kernel thread -> A), we don't need sync only if
>> we update statistics when we need it as i suggested.
>>
> Hmm. I'll check following can work or not.
> =3D=3D
> =C2=A0 =C2=A0 =C2=A0 if (next->mm =3D=3D &init_mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 if (prev->mm =3D=3D &init_mm) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (percpu_read(cu=
rr_mmc.mm) =3D=3D next->mm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =3D=3D
if next->mm is NULL, it's kernel thread.
You can use this rule.

As I suggested, I want to remove this compare overhead in non-split-ptl sys=
tem.


>> > +
>> > +#else =C2=A0/* !USE_SPLIT_PTLOCKS */
>> > +/*
>> > + * The mm counters are protected by its page_table_lock,
>> > + * so can be incremented directly.
>> > + */
>> > +void set_mm_counter(struct mm_struct *mm, int member, long value)
>> > +{
>> > + =C2=A0 mm->counters[member] =3D value;
>> > +}
>> > +
>> > +unsigned long get_mm_counter(struct mm_struct *mm, int member)
>> > +{
>> > + =C2=A0 return mm->counters[member];
..
<snip>
..
>> > =C2=A0 =C2=A0 pte_unmap_unlock(pte - 1, ptl);
>> > Index: mmotm-2.6.32-Nov24/mm/swapfile.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.32-Nov24.orig/mm/swapfile.c
>> > +++ mmotm-2.6.32-Nov24/mm/swapfile.c
>> > @@ -839,7 +839,7 @@ static int unuse_pte(struct vm_area_stru
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out;
>> > =C2=A0 =C2=A0 }
>> >
>> > - =C2=A0 inc_mm_counter(vma->vm_mm, anon_rss);
>> > + =C2=A0 add_mm_counter(vma->vm_mm, MM_ANONPAGES, 1);
>>
>> Why can't we use inc_mm_counter_fast in here?
>>
> This vma->vm_mm isn't current->mm in many case, I think.

I missed point. Thanks.

>
>
>> > =C2=A0 =C2=A0 get_page(page);
>> > =C2=A0 =C2=A0 set_pte_at(vma->vm_mm, addr, pte,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0pte_mkold(mk_pt=
e(page, vma->vm_page_prot)));
>> > Index: mmotm-2.6.32-Nov24/kernel/timer.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-2.6.32-Nov24.orig/kernel/timer.c
>> > +++ mmotm-2.6.32-Nov24/kernel/timer.c
>> > @@ -1200,6 +1200,8 @@ void update_process_times(int user_tick)
>> > =C2=A0 =C2=A0 account_process_tick(p, user_tick);
>> > =C2=A0 =C2=A0 run_local_timers();
..
<snip>
..
 =C2=A0 =C2=A0 /*
>> > =C2=A0 =C2=A0 =C2=A0* For paravirt, this is coupled with an exit in sw=
itch_to to
>> > =C2=A0 =C2=A0 =C2=A0* combine the page table reload and the switch bac=
kend into
>> >
>>
>> I think code is not bad but I don't know how effective this patch is in =
practice.
> Maybe the benefit of this patch itself is not clear at this point.
> I'll post with "more counters" patch as swap_usage, lowmem_rss usage coun=
ter in the
> next time. Adding more counters without atomic_ops will seems attractive.

I agree.

>> Thanks for good effort. Kame. :)
>>
>
> Thank you for review.
> -Kame
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
