Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 45E546B0032
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 21:48:51 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so7053754pab.28
        for <linux-mm@kvack.org>; Mon, 22 Dec 2014 18:48:51 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id yl3si13226072pac.62.2014.12.22.18.48.48
        for <linux-mm@kvack.org>;
        Mon, 22 Dec 2014 18:48:49 -0800 (PST)
Date: Tue, 23 Dec 2014 11:50:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/6] zsmalloc support compaction
Message-ID: <20141223025029.GB30174@bbox>
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
 <20141217231930.GA13582@cerebellum.variantweb.net>
 <20141219004648.GB1538@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141219004648.GB1538@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com

On Fri, Dec 19, 2014 at 09:46:48AM +0900, Minchan Kim wrote:
> Hey Seth,
> 
> On Wed, Dec 17, 2014 at 05:19:30PM -0600, Seth Jennings wrote:
> > On Tue, Dec 02, 2014 at 11:49:41AM +0900, Minchan Kim wrote:
> > > Recently, there was issue about zsmalloc fragmentation and
> > > I got a report from Juno that new fork failed although there
> > > are plenty of free pages in the system.
> > > His investigation revealed zram is one of the culprit to make
> > > heavy fragmentation so there was no more contiguous 16K page
> > > for pgd to fork in the ARM.
> > > 
> > > This patchset implement *basic* zsmalloc compaction support
> > > and zram utilizes it so admin can do
> > > 	"echo 1 > /sys/block/zram0/compact"
> > > 
> > > Actually, ideal is that mm migrate code is aware of zram pages and
> > > migrate them out automatically without admin's manual opeartion
> > > when system is out of contiguous page. Howver, we need more thinking
> > > before adding more hooks to migrate.c. Even though we implement it,
> > > we need manual trigger mode, too so I hope we could enhance
> > > zram migration stuff based on this primitive functions in future.
> > > 
> > > I just tested it on only x86 so need more testing on other arches.
> > > Additionally, I should have a number for zsmalloc regression
> > > caused by indirect layering. Unfortunately, I don't have any
> > > ARM test machine on my desk. I will get it soon and test it.
> > > Anyway, before further work, I'd like to hear opinion.
> > > 
> > > Pathset is based on v3.18-rc6-mmotm-2014-11-26-15-45.
> > 
> > Hey Minchan, sorry it has taken a while for me to look at this.
> 
> It's better than forever silence. Thanks, Seth.
> 
> > 
> > I have prototyped this for zbud to and I see you face some of the same
> > issues, some of them much worse for zsmalloc like large number of
> > objects to move to reclaim a page (with zbud, the max is 1).
> > 
> > I see you are using zsmalloc itself for allocating the handles.  Why not
> > kmalloc()?  Then you wouldn't need to track the handle_class stuff and
> > adjust the class sizes (just in the interest of changing only what is
> > need to achieve the functionality).
> 
> 1. kmalloc minimum size : 8 byte but 4byte is enough to keep the handle
> 2. handle can pin lots of slab pages in memory
> 3. it's inaccurate for accouting memory usage of zsmalloc
> 4. Creating handle class in zsmalloc is simple.
> 
> > 
> > I used kmalloc() but that is not without issue as the handles can be
> > allocated from many slabs and any slab that contains a handle can't be
> > freed, basically resulting in the handles themselves needing to be
> > compacted, which they can't be because the user handle is a pointer to
> > them.
> 
> Sure.

One thing for good with slab is that it could remove unnecessary operations
to translate handle to handle's position(page, idx) so that it would be
faster although we waste 50% on 32 bit machine. Okay, I will check it.

Thanks, Seth.


> 
> > 
> > One way to fix this, but it would be some amount of work, is to have the
> > user (zswap/zbud) provide the space for the handle to zbud/zsmalloc.
>               zram?
> > The zswap/zbud layer knows the size of the device (i.e. handle space)
>             zram?
> > and could allocate a statically sized vmalloc area for holding handles
> > so they don't get spread all over memory.  I haven't fully explored this
> > idea yet.
> 
> Hmm, I don't think it's a good idea.
> 
> Don't make an assumption that user of allocator know the size in advance.
> In addition, you want to populate all of pages to keep handle in vmalloc
> area statiscally? It wouldn't be huge but it depends on the user's setup
> of disksize. More question: How do you search empty slot for new handle?
> At last, we need caching logic and small allocator for that.
> IMHO, it has cons than pros compared current my approach.
> 
> > 
> > It is pretty limiting having the user trigger the compaction. Can we
> 
> Yeb, As I said, we need more policy but in this step, I want to introduce
> primitive functions to enhance our policy as next step.
> 
> > have a work item that periodically does some amount of compaction?
> 
> I'm not sure periodic cleanup is good idea. I'd like to pass the decision
> to the user, rather than allocator itself. It's enough for allocator
> to expose current status to the user.
> 
> 
> > Maybe also have something analogous to direct reclaim that, when
> > zs_malloc fails to secure a new page, it will try to compact to get one?
> > I understand this is a first step.  Maybe too much.
> 
> Yeb, I want to separate enhance as another patchset.
> 
> > 
> > Also worth pointing out that the fullness groups are very coarse.
> > Combining the objects from a ZS_ALMOST_EMPTY zspage and ZS_ALMOST_FULL
> > zspage, might not result in very tight packing.  In the worst case, the
> > destination zspage would be slightly over 1/4 full (see
> > fullness_threshold_frac)
> 
> Good point. Actually, I had noticed that.
> after all of ALMOST_EMPTY zspages are done to migrate, we might peek
> out ZS_ALMOST_FULL zspages to consider.
> 
> > 
> > It also seems that you start with the smallest size classes first.
> > Seems like if we start with the biggest first, we move fewer objects and
> > reclaim more pages.
> 
> Good idea. I will respin.
> Thanks for the comment!
> 
> > 
> > It does add a lot of code :-/  Not sure if there is any way around that
> > though if we want this functionality for zsmalloc.
> > 
> > Seth
> > 
> > > 
> > > Thanks.
> > > 
> > > Minchan Kim (6):
> > >   zsmalloc: expand size class to support sizeof(unsigned long)
> > >   zsmalloc: add indrection layer to decouple handle from object
> > >   zsmalloc: implement reverse mapping
> > >   zsmalloc: encode alloced mark in handle object
> > >   zsmalloc: support compaction
> > >   zram: support compaction
> > > 
> > >  drivers/block/zram/zram_drv.c |  24 ++
> > >  drivers/block/zram/zram_drv.h |   1 +
> > >  include/linux/zsmalloc.h      |   1 +
> > >  mm/zsmalloc.c                 | 596 +++++++++++++++++++++++++++++++++++++-----
> > >  4 files changed, 552 insertions(+), 70 deletions(-)
> > > 
> > > -- 
> > > 2.0.0
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> -- 
> Kind regards,
> Minchan Kim
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
