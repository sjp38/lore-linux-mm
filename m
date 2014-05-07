Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DEEC26B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 04:55:49 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so783645pde.41
        for <linux-mm@kvack.org>; Wed, 07 May 2014 01:55:49 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ho7si13429340pad.315.2014.05.07.01.55.47
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 01:55:48 -0700 (PDT)
Date: Wed, 7 May 2014 17:57:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: remove global tb_lock by using lock-free CAS
Message-ID: <20140507085743.GA31680@bbox>
References: <000001cf6816$d538c370$7faa4a50$%yang@samsung.com>
 <20140505152014.GA8551@cerebellum.variantweb.net>
 <1399312844.2570.28.camel@buesod1.americas.hpqcorp.net>
 <20140505134615.04cb627bb2784cabcb844655@linux-foundation.org>
 <1399328550.2646.5.camel@buesod1.americas.hpqcorp.net>
 <000001cf69c9$5776f330$0664d990$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cf69c9$5776f330$0664d990$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Davidlohr Bueso' <davidlohr@hp.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Seth Jennings' <sjennings@variantweb.net>, 'Nitin Gupta' <ngupta@vflare.org>, 'Sergey Senozhatsky' <sergey.senozhatsky@gmail.com>, 'Bob Liu' <bob.liu@oracle.com>, 'Dan Streetman' <ddstreet@ieee.org>, weijie.yang.kh@gmail.com, heesub.shin@samsung.com, 'linux-kernel' <linux-kernel@vger.kernel.org>, 'Linux-MM' <linux-mm@kvack.org>

On Wed, May 07, 2014 at 03:51:35PM +0800, Weijie Yang wrote:
> On Tue, May 6, 2014 at 6:22 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > On Mon, 2014-05-05 at 13:46 -0700, Andrew Morton wrote:
> >> On Mon, 05 May 2014 11:00:44 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:
> >>
> >> > > > @@ -339,12 +338,14 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
> >> > > >         unsigned long handle;
> >> > > >         u16 size;
> >> > > >
> >> > > > -       read_lock(&meta->tb_lock);
> >> > > > +       while(atomic_cmpxchg(&meta->table[index].state, IDLE, ACCESS) != IDLE)
> >> > > > +               cpu_relax();
> >> > > > +
> >> > >
> >> > > So... this might be dumb question, but this looks like a spinlock
> >> > > implementation.
> >> > >
> >> > > What advantage does this have over a standard spinlock?
> >> >
> >> > I was wondering the same thing. Furthermore by doing this you'll loose
> >> > the benefits of sharing the lock... your numbers do indicate that it is
> >> > for the better. Also, note that hopefully rwlock_t will soon be updated
> >> > to be fair and perform up to par with spinlocks, something which is long
> >> > overdue. So you could reduce the critical region by implementing the
> >> > same granularity, just don't implement your own locking schemes, like
> >> > this.
> 
> Actually, the main reason I use a CAS rather than a standard lock here is
> that I want to minimize the meta table memory overhead. A tiny reason is
> my fuzzy memory that CAS is more efficient than spinlock (please correct me
> if I am wrong).
> 
> Anyway, I changed the CAS to spinlock and rwlock, re-test them:
> 
>       Test       lock-free	   spinlock     rwlock
> ------------------------------------------------------
>  Initial write   1424141.62   1426372.84   1423019.21
>        Rewrite   1652504.81   1623307.14   1653682.04
>           Read  11404668.35  11242885.05  10938125.00
>        Re-read  11555483.75   11253906.6  10837773.50
>   Reverse Read   8394478.17   8277250.34   7768057.39
>    Stride read   9372229.95   9010498.53   8692871.77
>    Random read   9187221.90   8988080.55   8661184.60
> Mixed workload   5843370.85   5414729.54   5451055.03
>   Random write   1608947.04   1572276.64   1588866.51
>         Pwrite   1311055.32   1302463.04   1302001.06
>          Pread   4652056.11   4555802.18   4469672.34

I'd like to clear it out.
The spinlock and rwlock you mentioned is per-meta entry lock like state
you added or global lock for meta? If it's latter, rwlock means base?

> 
> And I cann't say which one is the best, they have the similar performance.

Most popular use of zram is the in-memory swap for small embedded system
so I don't want to increase memory footprint without good reason although
it makes synthetic benchmark. Alhought it's 1M for 1G, it isn't small if we
consider compression ratio and real free memory after boot(But data I have
an interest is mixed workload enhancement. It would be important for heavy
memory pressure for latency so it attractives me a lot. Anyway, I need number
for back up the justification with real swap usecase rather than zram-blk.
Recently, I have considered per-process reclaim  based on zram so maybe I will
have a test for that).
But recently, I have received private mail from some server folks to use
zram-blk, not zram-swap so in case of that, such enhancement would be
desirable so my point is I'm not saying the drop of the patch and let's
find proper solution to meet both and gather more data.

> 
> Wait, iozone will create temporary files for every test thread, so there is no
> possibility that these threads access the same table[index] concurrenctly.
> So, I use fio to test the raw zram block device.
> To enhance the possibility of access the same table[index] conflictly, I set zram
> with a small disksize(10M) and let thread run with large loop count.
> 
> On the same test machine, the fio test command is:
> fio --bs=32k --randrepeat=1 --randseed=100 --refill_buffers
> --scramble_buffers=1 --direct=1 --loops=3000 --numjobs=4
> --filename=/dev/zram0 --name=seq-write --rw=write --stonewall
> --name=seq-read --rw=read --stonewall --name=seq-readwrite
> --rw=rw --stonewall --name=rand-readwrite --rw=randrw --stonewall
> 
>     Test      base    lock-free   spinlock   rwlock
> ------------------------------------------------------
> seq-write   935109.2   999580.5   998134.8   994384.6
>  seq-read  5598064.6  6444011.5  6243184.6  6197514.2
>    seq-rw  1403963.0  1635673.0  1633823.0  1635972.2
>   rand-rw  1389864.4  1612520.4  1613403.6  1612129.8

What's the difference between base and rwlock?
Base means global rwlock while rwlock means per-meta entry rwlock?


> 
> This result(KB/s, average of 5 tests) shows the performance improvement
> on base version, however, I cann't say which method is the best.
> 
> >>
> >> It sounds like seqlocks will match this access pattern pretty well?
> >
> > Indeed. And after a closer look, except for zram_slot_free_notify(),
> > that lock is always shared. So, unless fine graining it implies taking
> > the lock exclusively like in this patch (if so, that needs to be
> > explicitly documented in the changelog), we would ideally continue to
> > share it. That _should_ provide nicer performance numbers when using the
> > correct lock.
> >
> 
> Andrew mentioned seqlocks, however, I think it is hard the use seqlocks here
> after I recheck the codes. No matter use it as a meta global lock or a
> table[index] lock. The main reason is the writer will free the handle rather than
> just change some value.
> If I misunderstand you, please let me know.
> 
> Now, I am in a delimma. For minimizing the memory overhead, I like to use CAS.
> However, it is not a standard way.
> 
> Any complaint or suggestions are welcomed.
> 
> Regards,
> 
> >
> >
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
