Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DC6938D003B
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 22:12:39 -0400 (EDT)
Received: by iwl42 with SMTP id 42so208467iwl.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 19:12:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1300154014.2337.74.camel@sli10-conroe>
References: <1299735019.2337.63.camel@sli10-conroe>
	<20110314144540.GC11699@barrios-desktop>
	<1300154014.2337.74.camel@sli10-conroe>
Date: Tue, 15 Mar 2011 11:12:37 +0900
Message-ID: <AANLkTin2h0YFe70vYj7cExAJbbPS+oDjvfunfGPNZfB1@mail.gmail.com>
Subject: Re: [PATCH 2/2 v4]mm: batch activate_page() to reduce lock contention
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 15, 2011 at 10:53 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> On Mon, 2011-03-14 at 22:45 +0800, Minchan Kim wrote:
>> On Thu, Mar 10, 2011 at 01:30:19PM +0800, Shaohua Li wrote:
>> > The zone->lru_lock is heavily contented in workload where activate_pag=
e()
>> > is frequently used. We could do batch activate_page() to reduce the lo=
ck
>> > contention. The batched pages will be added into zone list when the po=
ol
>> > is full or page reclaim is trying to drain them.
>> >
>> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 =
processes,
>> > processes shared map to the file. Each process read access the whole f=
ile and
>> > then exit. The process exit will do unmap_vmas() and cause a lot of
>> > activate_page() call. In such workload, we saw about 58% total time re=
duction
>> > with below patch. Other workloads with a lot of activate_page also ben=
efits a
>> > lot too.
>> >
>> > Andrew Morton suggested activate_page() and putback_lru_pages() should
>> > follow the same path to active pages, but this is hard to implement (s=
ee commit
>> > 7a608572a282a). On the other hand, do we really need putback_lru_pages=
() to
>> > follow the same path? I tested several FIO/FFSB benchmark (about 20 sc=
ripts for
>> > each benchmark) in 3 machines here from 2 sockets to 4 sockets. My tes=
t doesn't
>> > show anything significant with/without below patch (there is slight di=
fference
>> > but mostly some noise which we found even without below patch before).=
 Below
>> > patch basically returns to the same as my first post.
>> >
>> > I tested some microbenchmarks:
>> > case-anon-cow-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 0.58%
>> > case-anon-cow-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-3.30%
>> > case-anon-cow-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0-0.51%
>> > case-anon-cow-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -5.68%
>> > case-anon-r-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.23%
>> > case-anon-r-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.81%
>> > case-anon-r-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-0.71%
>> > case-anon-r-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 -1.99%
>> > case-anon-rx-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A02.11%
>> > case-anon-rx-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 3.46%
>> > case-anon-w-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 -0.03%
>> > case-anon-w-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-0.50%
>> > case-anon-w-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-1.08%
>> > case-anon-w-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 -0.12%
>> > case-anon-wx-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0-5.02%
>> > case-anon-wx-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 -1.43%
>> > case-fork =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 1.65%
>> > case-fork-sleep =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 -0.07%
>> > case-fork-withmem =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.39%
>> > case-hugetlb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0-0.59%
>> > case-lru-file-mmap-read-mt =C2=A0-0.54%
>> > case-lru-file-mmap-read =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.61=
%
>> > case-lru-file-mmap-read-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0-2.24%
>> > case-lru-file-readonce =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0-0.64%
>> > case-lru-file-readtwice =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -11.=
69%
>> > case-lru-memcg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0-1.35%
>> > case-mmap-pread-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.88=
%
>> > case-mmap-pread-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0-15.26%
>> > case-mmap-pread-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00.89%
>> > case-mmap-pread-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 -69.72%
>> > case-mmap-xread-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.71=
%
>> > case-mmap-xread-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00.38%
>> >
>> > The most significent are:
>> > case-lru-file-readtwice =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -11.=
69%
>> > case-mmap-pread-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0-15.26%
>> > case-mmap-pread-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 -69.72%
>> >
>> > which use activate_page a lot. =C2=A0others are basically variations b=
ecause
>> > each run has slightly difference.
>> >
>> > In UP case, 'size mm/swap.o'
>> > before the two patches:
>> > =C2=A0 =C2=A0text =C2=A0 =C2=A0data =C2=A0 =C2=A0 bss =C2=A0 =C2=A0 de=
c =C2=A0 =C2=A0 hex filename
>> > =C2=A0 =C2=A06466 =C2=A0 =C2=A0 896 =C2=A0 =C2=A0 =C2=A0 4 =C2=A0 =C2=
=A07366 =C2=A0 =C2=A01cc6 mm/swap.o
>> > after the two patches:
>> > =C2=A0 =C2=A0text =C2=A0 =C2=A0data =C2=A0 =C2=A0 bss =C2=A0 =C2=A0 de=
c =C2=A0 =C2=A0 hex filename
>> > =C2=A0 =C2=A06343 =C2=A0 =C2=A0 896 =C2=A0 =C2=A0 =C2=A0 4 =C2=A0 =C2=
=A07243 =C2=A0 =C2=A01c4b mm/swap.o
>> >
>> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>> >
>> > ---
>> > =C2=A0mm/swap.c | =C2=A0 45 ++++++++++++++++++++++++++++++++++++++++--=
---
>> > =C2=A01 file changed, 40 insertions(+), 5 deletions(-)
>> >
>> > Index: linux/mm/swap.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- linux.orig/mm/swap.c =C2=A0 =C2=A02011-03-09 12:56:09.000000000 +0=
800
>> > +++ linux/mm/swap.c 2011-03-09 12:56:46.000000000 +0800
>> > @@ -272,14 +272,10 @@ static void update_page_reclaim_stat(str
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcg_reclaim_stat->recent_r=
otated[file]++;
>> > =C2=A0}
>> >
>> > -/*
>> > - * FIXME: speed this up?
>> > - */
>> > -void activate_page(struct page *page)
>> > +static void __activate_page(struct page *page, void *arg)
>> > =C2=A0{
>> > =C2=A0 =C2=A0 struct zone *zone =3D page_zone(page);
>> >
>> > - =C2=A0 spin_lock_irq(&zone->lru_lock);
>> > =C2=A0 =C2=A0 if (PageLRU(page) && !PageActive(page) && !PageUnevictab=
le(page)) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int file =3D page_is_file_ca=
che(page);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int lru =3D page_lru_base_ty=
pe(page);
>> > @@ -292,8 +288,45 @@ void activate_page(struct page *page)
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 update_page_reclaim_stat(zon=
e, page, file, 1);
>> > =C2=A0 =C2=A0 }
>> > +}
>> > +
>> > +#ifdef CONFIG_SMP
>> > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>> > +
>> > +static void activate_page_drain(int cpu)
>> > +{
>> > + =C2=A0 struct pagevec *pvec =3D &per_cpu(activate_page_pvecs, cpu);
>> > +
>> > + =C2=A0 if (pagevec_count(pvec))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pagevec_lru_move_fn(pvec, __activ=
ate_page, NULL);
>> > +}
>> > +
>> > +void activate_page(struct page *page)
>> > +{
>> > + =C2=A0 if (PageLRU(page) && !PageActive(page) && !PageUnevictable(pa=
ge)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct pagevec *pvec =3D &get_cpu=
_var(activate_page_pvecs);
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page_cache_get(page);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!pagevec_add(pvec, page))
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pagev=
ec_lru_move_fn(pvec, __activate_page, NULL);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_cpu_var(activate_page_pvecs);
>> > + =C2=A0 }
>> > +}
>> > +
>> > +#else
>> > +static inline void activate_page_drain(int cpu)
>> > +{
>> > +}
>> > +
>> > +void activate_page(struct page *page)
>> > +{
>> > + =C2=A0 struct zone *zone =3D page_zone(page);
>> > +
>> > + =C2=A0 spin_lock_irq(&zone->lru_lock);
>> > + =C2=A0 __activate_page(page, NULL);
>> > =C2=A0 =C2=A0 spin_unlock_irq(&zone->lru_lock);
>> > =C2=A0}
>> > +#endif
>>
>> Why do we need CONFIG_SMP in only activate_page_pvecs?
>> The per-cpu of activate_page_pvecs consumes lots of memory in UP?
>> I don't think so. But if it consumes lots of memory, it's a problem
>> of per-cpu.
> No, not too much memory.
>
>> I can't understand why we should hanlde activate_page_pvecs specially.
>> Please, enlighten me.
> Not it's special. akpm asked me to do it this time. Reducing little
> memory is still worthy anyway, so that's it. We can do it for other
> pvecs too, in separate patch.

Understandable but I don't like code separation by CONFIG_SMP for just
little bit enhance of memory usage. In future, whenever we use percpu,
do we have to implement each functions for both SMP and non-SMP?
Is it desirable?
Andrew, Is it really valuable?

If everybody agree, I don't oppose such way.
But now I vote code cleanness than reduce memory footprint.

>
> Thanks,
> Shaohua
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
