Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 27FE68D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 10:57:58 -0500 (EST)
Received: by iwl42 with SMTP id 42so5446922iwl.14
        for <linux-mm@kvack.org>; Mon, 07 Mar 2011 07:57:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299486978.2337.29.camel@sli10-conroe>
References: <1299486978.2337.29.camel@sli10-conroe>
Date: Tue, 8 Mar 2011 00:57:55 +0900
Message-ID: <AANLkTikxoONF16WduKaRKpTFKkZbAR==UA1_a+3qzRV2@mail.gmail.com>
Subject: Re: [PATCH 2/2 v3]mm: batch activate_page() to reduce lock contention
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Mar 7, 2011 at 5:36 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> The zone->lru_lock is heavily contented in workload where activate_page()
> is frequently used. We could do batch activate_page() to reduce the lock
> contention. The batched pages will be added into zone list when the pool
> is full or page reclaim is trying to drain them.
>
> For example, in a 4 socket 64 CPU system, create a sparse file and 64 pro=
cesses,
> processes shared map to the file. Each process read access the whole file=
 and
> then exit. The process exit will do unmap_vmas() and cause a lot of
> activate_page() call. In such workload, we saw about 58% total time reduc=
tion
> with below patch. Other workloads with a lot of activate_page also benefi=
ts a
> lot too.
>
> Andrew Morton suggested activate_page() and putback_lru_pages() should
> follow the same path to active pages, but this is hard to implement (see =
commit
> 7a608572a282a). On the other hand, do we really need putback_lru_pages() =
to
> follow the same path? I tested several FIO/FFSB benchmark (about 20 scrip=
ts for
> each benchmark) in 3 machines here from 2 sockets to 4 sockets. My test d=
oesn't
> show anything significant with/without below patch (there is slight diffe=
rence
> but mostly some noise which we found even without below patch before). Be=
low
> patch basically returns to the same as my first post.
>
> I tested some microbenchmarks:
> case-anon-cow-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.=
58%
> case-anon-cow-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-3.30%
> case-anon-cow-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0-0.51%
> case-anon-cow-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -5.68%
> case-anon-r-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.23%
> case-anon-r-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.81%
> case-anon-r-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-0.71%
> case-anon-r-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 -1.99%
> case-anon-rx-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A02.11%
> case-anon-rx-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 3.46%
> case-anon-w-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 -0.03%
> case-anon-w-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-0.50%
> case-anon-w-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-1.08%
> case-anon-w-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 -0.12%
> case-anon-wx-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0-5.02%
> case-anon-wx-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 -1.43%
> case-fork =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
1.65%
> case-fork-sleep =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 -0.07%
> case-fork-withmem =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.39%
> case-hugetlb =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0-0.59%
> case-lru-file-mmap-read-mt =C2=A0-0.54%
> case-lru-file-mmap-read =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.61%
> case-lru-file-mmap-read-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0-2.24%
> case-lru-file-readonce =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0-0=
.64%
> case-lru-file-readtwice =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -11.69%
> case-lru-memcg =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0-1.35%
> case-mmap-pread-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1.88%
> case-mmap-pread-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0-15.26%
> case-mmap-pread-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.=
89%
> case-mmap-pread-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 -69.72%
> case-mmap-xread-rand-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0.71%
> case-mmap-xread-seq-mt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00.=
38%
>
> The most significent are:
> case-lru-file-readtwice =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 -11.69%
> case-mmap-pread-rand =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0-15.26%
> case-mmap-pread-seq =C2=A0 =C2=A0 =C2=A0 =C2=A0 -69.72%
>
> which use activate_page a lot. =C2=A0others are basically variations beca=
use
> each run has slightly difference.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>
> ---
> =C2=A0mm/swap.c | =C2=A0 45 ++++++++++++++++++++++++++++++++++++++++-----
> =C2=A01 file changed, 40 insertions(+), 5 deletions(-)
>
> Index: linux/mm/swap.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/mm/swap.c =C2=A0 =C2=A0 =C2=A0 =C2=A02011-03-07 10:01:41.0=
00000000 +0800
> +++ linux/mm/swap.c =C2=A0 =C2=A0 2011-03-07 10:09:37.000000000 +0800
> @@ -270,14 +270,10 @@ static void update_page_reclaim_stat(str
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg_reclaim_stat=
->recent_rotated[file]++;
> =C2=A0}
>
> -/*
> - * FIXME: speed this up?
> - */
> -void activate_page(struct page *page)
> +static void __activate_page(struct page *page, void *arg)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zone =3D page_zone(page);
>
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_irq(&zone->lru_lock);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageLRU(page) && !PageActive(page) && !Pag=
eUnevictable(page)) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int file =3D page_=
is_file_cache(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0int lru =3D page_l=
ru_base_type(page);
> @@ -290,8 +286,45 @@ void activate_page(struct page *page)
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0update_page_reclai=
m_stat(zone, page, file, 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> +}
> +
> +#ifdef CONFIG_SMP
> +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);

Why do we have to handle SMP and !SMP?
We have been not separated in case of pagevec using in swap.c.
If you have a special reason, please write it down.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
