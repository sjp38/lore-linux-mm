Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E62478D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 23:44:45 -0500 (EST)
Subject: Re: [PATCH 2/2 v3]mm: batch activate_page() to reduce lock
 contention
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <AANLkTikxoONF16WduKaRKpTFKkZbAR==UA1_a+3qzRV2@mail.gmail.com>
References: <1299486978.2337.29.camel@sli10-conroe>
	 <AANLkTikxoONF16WduKaRKpTFKkZbAR==UA1_a+3qzRV2@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 08 Mar 2011 12:44:13 +0800
Message-ID: <1299559453.2337.30.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 2011-03-07 at 23:57 +0800, Minchan Kim wrote:
> On Mon, Mar 7, 2011 at 5:36 PM, Shaohua Li <shaohua.li@intel.com> wrote:
> > The zone->lru_lock is heavily contented in workload where activate_page()
> > is frequently used. We could do batch activate_page() to reduce the lock
> > contention. The batched pages will be added into zone list when the pool
> > is full or page reclaim is trying to drain them.
> >
> > For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> > processes shared map to the file. Each process read access the whole file and
> > then exit. The process exit will do unmap_vmas() and cause a lot of
> > activate_page() call. In such workload, we saw about 58% total time reduction
> > with below patch. Other workloads with a lot of activate_page also benefits a
> > lot too.
> >
> > Andrew Morton suggested activate_page() and putback_lru_pages() should
> > follow the same path to active pages, but this is hard to implement (see commit
> > 7a608572a282a). On the other hand, do we really need putback_lru_pages() to
> > follow the same path? I tested several FIO/FFSB benchmark (about 20 scripts for
> > each benchmark) in 3 machines here from 2 sockets to 4 sockets. My test doesn't
> > show anything significant with/without below patch (there is slight difference
> > but mostly some noise which we found even without below patch before). Below
> > patch basically returns to the same as my first post.
> >
> > I tested some microbenchmarks:
> > case-anon-cow-rand-mt               0.58%
> > case-anon-cow-rand          -3.30%
> > case-anon-cow-seq-mt                -0.51%
> > case-anon-cow-seq           -5.68%
> > case-anon-r-rand-mt         0.23%
> > case-anon-r-rand            0.81%
> > case-anon-r-seq-mt          -0.71%
> > case-anon-r-seq                     -1.99%
> > case-anon-rx-rand-mt                2.11%
> > case-anon-rx-seq-mt         3.46%
> > case-anon-w-rand-mt         -0.03%
> > case-anon-w-rand            -0.50%
> > case-anon-w-seq-mt          -1.08%
> > case-anon-w-seq                     -0.12%
> > case-anon-wx-rand-mt                -5.02%
> > case-anon-wx-seq-mt         -1.43%
> > case-fork                   1.65%
> > case-fork-sleep                     -0.07%
> > case-fork-withmem           1.39%
> > case-hugetlb                        -0.59%
> > case-lru-file-mmap-read-mt  -0.54%
> > case-lru-file-mmap-read             0.61%
> > case-lru-file-mmap-read-rand        -2.24%
> > case-lru-file-readonce              -0.64%
> > case-lru-file-readtwice             -11.69%
> > case-lru-memcg                      -1.35%
> > case-mmap-pread-rand-mt             1.88%
> > case-mmap-pread-rand                -15.26%
> > case-mmap-pread-seq-mt              0.89%
> > case-mmap-pread-seq         -69.72%
> > case-mmap-xread-rand-mt             0.71%
> > case-mmap-xread-seq-mt              0.38%
> >
> > The most significent are:
> > case-lru-file-readtwice             -11.69%
> > case-mmap-pread-rand                -15.26%
> > case-mmap-pread-seq         -69.72%
> >
> > which use activate_page a lot.  others are basically variations because
> > each run has slightly difference.
> >
> > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> >
> > ---
> >  mm/swap.c |   45 ++++++++++++++++++++++++++++++++++++++++-----
> >  1 file changed, 40 insertions(+), 5 deletions(-)
> >
> > Index: linux/mm/swap.c
> > ===================================================================
> > --- linux.orig/mm/swap.c        2011-03-07 10:01:41.000000000 +0800
> > +++ linux/mm/swap.c     2011-03-07 10:09:37.000000000 +0800
> > @@ -270,14 +270,10 @@ static void update_page_reclaim_stat(str
> >                memcg_reclaim_stat->recent_rotated[file]++;
> >  }
> >
> > -/*
> > - * FIXME: speed this up?
> > - */
> > -void activate_page(struct page *page)
> > +static void __activate_page(struct page *page, void *arg)
> >  {
> >        struct zone *zone = page_zone(page);
> >
> > -       spin_lock_irq(&zone->lru_lock);
> >        if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> >                int file = page_is_file_cache(page);
> >                int lru = page_lru_base_type(page);
> > @@ -290,8 +286,45 @@ void activate_page(struct page *page)
> >
> >                update_page_reclaim_stat(zone, page, file, 1);
> >        }
> > +}
> > +
> > +#ifdef CONFIG_SMP
> > +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
> 
> Why do we have to handle SMP and !SMP?
> We have been not separated in case of pagevec using in swap.c.
> If you have a special reason, please write it down.
this is to reduce memory footprint as suggested by akpm.

Thanks,
Shaohua


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
