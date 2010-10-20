Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 053CF6B00EE
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 05:27:43 -0400 (EDT)
Date: Wed, 20 Oct 2010 17:27:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101020092739.GA23869@localhost>
References: <AANLkTimVu+5gTDs8przJVP2EbWC=FX-zWW7aH08BtrHC@mail.gmail.com>
 <20101020055717.GA12752@localhost>
 <20101020150346.1832.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101020150346.1832.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Torsten Kaiser <just.for.lkml@googlemail.com>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 03:05:56PM +0800, KOSAKI Motohiro wrote:
> > On Tue, Oct 19, 2010 at 06:06:21PM +0800, Torsten Kaiser wrote:
> > > On Tue, Oct 19, 2010 at 10:43 AM, Torsten Kaiser
> > > <just.for.lkml@googlemail.com> wrote:
> > > > On Tue, Oct 19, 2010 at 1:11 AM, Neil Brown <neilb@suse.de> wrote:
> > > >> Yes, thanks for the report.
> > > >> This is a real bug exactly as you describe.
> > > >>
> > > >> This is how I think I will fix it, though it needs a bit of review and
> > > >> testing before I can be certain.
> > > >> Also I need to check raid10 etc to see if they can suffer too.
> > > >>
> > > >> If you can test it I would really appreciate it.
> > > >
> > > > I did test it, but while it seemed to fix the deadlock, the system
> > > > still got unusable.
> > > > The still running "vmstat 1" showed that the swapout was still
> > > > progressing, but at a rate of ~20k sized bursts every 5 to 20 seconds.
> > > >
> > > > I also tried to additionally add Wu's patch:
> > > > --- linux-next.orig/mm/vmscan.c 2010-10-13 12:35:14.000000000 +0800
> > > > +++ linux-next/mm/vmscan.c A  A  A 2010-10-19 00:13:04.000000000 +0800
> > > > @@ -1163,6 +1163,13 @@ static int too_many_isolated(struct zone
> > > > A  A  A  A  A  A  A  isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> > > > A  A  A  }
> > > >
> > > > + A  A  A  /*
> > > > + A  A  A  A * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so that
> > > > + A  A  A  A * they won't get blocked by normal ones and form circular deadlock.
> > > > + A  A  A  A */
> > > > + A  A  A  if ((sc->gfp_mask & GFP_IOFS) == GFP_IOFS)
> > > > + A  A  A  A  A  A  A  inactive >>= 3;
> > > > +
> > > > A  A  A  return isolated > inactive;
> > > >
> > > > Either it did help somewhat, or I was more lucky on my second try, but
> > > > this time I needed ~5 tries instead of only 2 to get the system mostly
> > > > stuck again. On the testrun with Wu's patch the writeout pattern was
> > > > more stable, a burst of ~80kb each 20 seconds. But I would suspect
> > > > that the size of the burst is rather random.
> > > >
> > > > I do have a complete SysRq+T dump from the first run, I can send that
> > > > to anyone how wants it.
> > > > (It's 190k so I don't want not spam it to the list)
> > > 
> > > Is this call trace from the SysRq+T violation the rule to only
> > > allocate one bio from bio_alloc() until its submitted?
> > > 
> > > [  549.700038] Call Trace:
> > > [  549.700038]  [<ffffffff81566b54>] schedule_timeout+0x144/0x200
> > > [  549.700038]  [<ffffffff81045cd0>] ? process_timeout+0x0/0x10
> > > [  549.700038]  [<ffffffff81565e22>] io_schedule_timeout+0x42/0x60
> > > [  549.700038]  [<ffffffff81083123>] mempool_alloc+0x163/0x1b0
> > > [  549.700038]  [<ffffffff81053560>] ? autoremove_wake_function+0x0/0x40
> > > [  549.700038]  [<ffffffff810ea2b9>] bio_alloc_bioset+0x39/0xf0
> > > [  549.700038]  [<ffffffff810ea38d>] bio_clone+0x1d/0x50
> > > [  549.700038]  [<ffffffff814318ed>] make_request+0x23d/0x850
> > > [  549.700038]  [<ffffffff81082e20>] ? mempool_alloc_slab+0x10/0x20
> > > [  549.700038]  [<ffffffff81045cd0>] ? process_timeout+0x0/0x10
> > > [  549.700038]  [<ffffffff81436e63>] md_make_request+0xc3/0x220
> > > [  549.700038]  [<ffffffff81083099>] ? mempool_alloc+0xd9/0x1b0
> > > [  549.700038]  [<ffffffff811ec153>] generic_make_request+0x1b3/0x370
> > > [  549.700038]  [<ffffffff810ea2d6>] ? bio_alloc_bioset+0x56/0xf0
> > > [  549.700038]  [<ffffffff811ec36a>] submit_bio+0x5a/0xd0
> > > [  549.700038]  [<ffffffff81080cf5>] ? unlock_page+0x25/0x30
> > > [  549.700038]  [<ffffffff810a871e>] swap_writepage+0x7e/0xc0
> > > [  549.700038]  [<ffffffff81090d99>] shmem_writepage+0x1c9/0x240
> > > [  549.700038]  [<ffffffff8108c9cb>] pageout+0x11b/0x270
> > > [  549.700038]  [<ffffffff8108cd78>] shrink_page_list+0x258/0x4d0
> > > [  549.700038]  [<ffffffff8108d9e7>] shrink_inactive_list+0x187/0x310
> > > [  549.700038]  [<ffffffff8102dcb1>] ? __wake_up_common+0x51/0x80
> > > [  549.700038]  [<ffffffff811fc8b2>] ? cpumask_next_and+0x22/0x40
> > > [  549.700038]  [<ffffffff8108e1c0>] shrink_zone+0x3e0/0x470
> > > [  549.700038]  [<ffffffff8108e797>] try_to_free_pages+0x157/0x410
> > > [  549.700038]  [<ffffffff81087c92>] __alloc_pages_nodemask+0x412/0x760
> > > [  549.700038]  [<ffffffff810b27d6>] alloc_pages_current+0x76/0xe0
> > > [  549.700038]  [<ffffffff810b6dad>] new_slab+0x1fd/0x2a0
> > > [  549.700038]  [<ffffffff81045cd0>] ? process_timeout+0x0/0x10
> > > [  549.700038]  [<ffffffff810b8721>] __slab_alloc+0x111/0x540
> > > [  549.700038]  [<ffffffff81059961>] ? prepare_creds+0x21/0xb0
> > > [  549.700038]  [<ffffffff810b92bb>] kmem_cache_alloc+0x9b/0xa0
> > > [  549.700038]  [<ffffffff81059961>] prepare_creds+0x21/0xb0
> > > [  549.700038]  [<ffffffff8104a919>] sys_setresgid+0x29/0x120
> > > [  549.700038]  [<ffffffff8100242b>] system_call_fastpath+0x16/0x1b
> > > [  549.700038]  ffff88011e125ea8 0000000000000046 ffff88011e125e08
> > > ffffffff81073c59
> > > [  549.700038]  0000000000012780 ffff88011ea905b0 ffff88011ea90808
> > > ffff88011e125fd8
> > > [  549.700038]  ffff88011ea90810 ffff88011e124010 0000000000012780
> > > ffff88011e125fd8
> > > 
> > > swap_writepage() uses get_swap_bio() which uses bio_alloc() to get one
> > > bio. That bio is the submitted, but the submit path seems to get into
> > > make_request from raid1.c and that allocates a second bio from
> > > bio_alloc() via bio_clone().
> > > 
> > > I am seeing this pattern (swap_writepage calling
> > > md_make_request/make_request and then getting stuck in mempool_alloc)
> > > more than 5 times in the SysRq+T output...
> > 
> > I bet the root cause is the failure of pool->alloc(__GFP_NORETRY)
> > inside mempool_alloc(), which can be fixed by this patch.
> > 
> > Thanks,
> > Fengguang
> > ---
> > 
> > concurrent direct page reclaim problem
> > 
> >   __GFP_NORETRY page allocations may fail when there are many concurrent page
> >   allocating tasks, but not necessary in real short of memory. The root cause
> >   is, tasks will first run direct page reclaim to free some pages from the LRU
> >   lists and put them to the per-cpu page lists and the buddy system, and then
> >   try to get a free page from there.  However the free pages reclaimed by this
> >   task may be consumed by other tasks when the direct reclaim task is able to
> >   get the free page for itself.
> > 
> >   Let's retry it a bit harder.
> > 
> > --- linux-next.orig/mm/page_alloc.c	2010-10-20 13:44:50.000000000 +0800
> > +++ linux-next/mm/page_alloc.c	2010-10-20 13:50:54.000000000 +0800
> > @@ -1700,7 +1700,7 @@ should_alloc_retry(gfp_t gfp_mask, unsig
> >  				unsigned long pages_reclaimed)
> >  {
> >  	/* Do not loop if specifically requested */
> > -	if (gfp_mask & __GFP_NORETRY)
> > +	if (gfp_mask & __GFP_NORETRY && pages_reclaimed > (1 << (order + 12)))
> >  		return 0;
> >  
> >  	/*
> 
> SLUB usually try high order allocation with __GFP_NORETRY at first. In
> other words, It strongly depend on __GFP_NORETRY don't any retry. I'm
> worry this...

Right. I noticed that too. Hopefully the "limited" retry won't impact
it too much. That said, we do need a better solution than such hacks.

> And, in this case, stucked tasks have PF_MEMALLOC. allocation with PF_MEMALLOC
> failure mean this zone have zero memory purely. So, retrying don't solve anything.

The zone has no free (buddy) memory, but has plenty of reclaimable pages.
The concurrent page reclaimers may steal pages reclaimed by this task
from time to time, but not always. So retry reclaiming will help.

> And I think the root cause is in another.
> 
> bio_clone() use fs_bio_set internally.
> 
> 	struct bio *bio_clone(struct bio *bio, gfp_t gfp_mask)
> 	{
> 	        struct bio *b = bio_alloc_bioset(gfp_mask, bio->bi_max_vecs, fs_bio_set);
> 	...
> 
> and fs_bio_set is initialized very small pool size.
> 
> 	#define BIO_POOL_SIZE 2
> 	static int __init init_bio(void)
> 	{
> 		..
> 	        fs_bio_set = bioset_create(BIO_POOL_SIZE, 0);

Agreed. BIO_POOL_SIZE=2 is too small to be deadlock free.

> So, I think raid1.c need to use their own bioset instead fs_bio_set.
> otherwise, bio pool exshost can happen very easily.

That would fix the deadlock, but not enough for good IO throughput
when multiple CPUs are trying to submit IO. Increasing BIO_POOL_SIZE
to a large value should help fix both the deadlock and IO throughput.

> But I'm not sure. I'm not IO expert.

[add CC to Jens]

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
