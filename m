Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id CC7DC6B0038
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 21:20:50 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7650660pad.28
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 18:20:50 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id d7si26286929pdf.132.2014.09.15.18.20.47
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 18:20:49 -0700 (PDT)
Date: Tue, 16 Sep 2014 10:21:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/3] zram: add swap_get_free hint
Message-ID: <20140916012100.GE10912@bbox>
References: <1409794786-10951-1-git-send-email-minchan@kernel.org>
 <1409794786-10951-4-git-send-email-minchan@kernel.org>
 <54080606.3050106@samsung.com>
 <20140904235952.GA32561@bbox>
 <CALZtONB=YCWiWQNPjrfr6W4gPNNj10tH-d_sWV916sBwHefPPQ@mail.gmail.com>
 <20140915005704.GG2160@bbox>
 <CALZtONCb=gT27qhXz3qu=OEzA=djvFvoT_=x=X1bZmtpMzYjhA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONCb=gT27qhXz3qu=OEzA=djvFvoT_=x=X1bZmtpMzYjhA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Heesub Shin <heesub.shin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>

On Mon, Sep 15, 2014 at 12:00:33PM -0400, Dan Streetman wrote:
> On Sun, Sep 14, 2014 at 8:57 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Sat, Sep 13, 2014 at 03:39:13PM -0400, Dan Streetman wrote:
> >> On Thu, Sep 4, 2014 at 7:59 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > Hi Heesub,
> >> >
> >> > On Thu, Sep 04, 2014 at 03:26:14PM +0900, Heesub Shin wrote:
> >> >> Hello Minchan,
> >> >>
> >> >> First of all, I agree with the overall purpose of your patch set.
> >> >
> >> > Thank you.
> >> >
> >> >>
> >> >> On 09/04/2014 10:39 AM, Minchan Kim wrote:
> >> >> >This patch implement SWAP_GET_FREE handler in zram so that VM can
> >> >> >know how many zram has freeable space.
> >> >> >VM can use it to stop anonymous reclaiming once zram is full.
> >> >> >
> >> >> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> >> >---
> >> >> >  drivers/block/zram/zram_drv.c | 18 ++++++++++++++++++
> >> >> >  1 file changed, 18 insertions(+)
> >> >> >
> >> >> >diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> >> >> >index 88661d62e46a..8e22b20aa2db 100644
> >> >> >--- a/drivers/block/zram/zram_drv.c
> >> >> >+++ b/drivers/block/zram/zram_drv.c
> >> >> >@@ -951,6 +951,22 @@ static int zram_slot_free_notify(struct block_device *bdev,
> >> >> >     return 0;
> >> >> >  }
> >> >> >
> >> >> >+static int zram_get_free_pages(struct block_device *bdev, long *free)
> >> >> >+{
> >> >> >+    struct zram *zram;
> >> >> >+    struct zram_meta *meta;
> >> >> >+
> >> >> >+    zram = bdev->bd_disk->private_data;
> >> >> >+    meta = zram->meta;
> >> >> >+
> >> >> >+    if (!zram->limit_pages)
> >> >> >+            return 1;
> >> >> >+
> >> >> >+    *free = zram->limit_pages - zs_get_total_pages(meta->mem_pool);
> >> >>
> >> >> Even if 'free' is zero here, there may be free spaces available to
> >> >> store more compressed pages into the zs_pool. I mean calculation
> >> >> above is not quite accurate and wastes memory, but have no better
> >> >> idea for now.
> >> >
> >> > Yeb, good point.
> >> >
> >> > Actually, I thought about that but in this patchset, I wanted to
> >> > go with conservative approach which is a safe guard to prevent
> >> > system hang which is terrible than early OOM kill.
> >> >
> >> > Whole point of this patchset is to add a facility to VM and VM
> >> > collaborates with zram via the interface to avoid worst case
> >> > (ie, system hang) and logic to throttle could be enhanced by
> >> > several approaches in future but I agree my logic was too simple
> >> > and conservative.
> >> >
> >> > We could improve it with [anti|de]fragmentation in future but
> >> > at the moment, below simple heuristic is not too bad for first
> >> > step. :)
> >> >
> >> >
> >> > ---
> >> >  drivers/block/zram/zram_drv.c | 15 ++++++++++-----
> >> >  drivers/block/zram/zram_drv.h |  1 +
> >> >  2 files changed, 11 insertions(+), 5 deletions(-)
> >> >
> >> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> >> > index 8e22b20aa2db..af9dfe6a7d2b 100644
> >> > --- a/drivers/block/zram/zram_drv.c
> >> > +++ b/drivers/block/zram/zram_drv.c
> >> > @@ -410,6 +410,7 @@ static bool zram_free_page(struct zram *zram, size_t index)
> >> >         atomic64_sub(zram_get_obj_size(meta, index),
> >> >                         &zram->stats.compr_data_size);
> >> >         atomic64_dec(&zram->stats.pages_stored);
> >> > +       atomic_set(&zram->alloc_fail, 0);
> >> >
> >> >         meta->table[index].handle = 0;
> >> >         zram_set_obj_size(meta, index, 0);
> >> > @@ -600,10 +601,12 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >> >         alloced_pages = zs_get_total_pages(meta->mem_pool);
> >> >         if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> >> >                 zs_free(meta->mem_pool, handle);
> >> > +               atomic_inc(&zram->alloc_fail);
> >> >                 ret = -ENOMEM;
> >> >                 goto out;
> >> >         }
> >>
> >> This isn't going to work well at all with swap.  There will be,
> >> minimum, 32 failures to write a swap page before GET_FREE finally
> >> indicates it's full, and even then a single free during those 32
> >> failures will restart the counter, so it could be dozens or hundreds
> >> (or more) swap write failures before the zram device is marked as
> >> full.  And then, a single zram free will move it back to non-full and
> >> start the write failures over again.
> >>
> >> I think it would be better to just check for actual fullness (i.e.
> >> alloced_pages > limit_pages) at the start of write, and fail if so.
> >> That will allow a single write to succeed when it crosses into
> >> fullness, and the if GET_FREE is changed to a simple IS_FULL and uses
> >> the same check (alloced_pages > limit_pages), then swap shouldn't see
> >> any write failures (or very few), and zram will stay full until enough
> >> pages are freed that it really does move under limit_pages.
> >
> > The alloced_pages > limit_pages doesn't mean zram is full so with your
> > approach, it could kick OOM earlier which is not what we want.
> > Because our product uses zram to delay app killing by low memory killer.
> 
> With zram, the meaning of "full" isn't as obvious as other fixed-size
> storage devices.  Obviously, "full" usually means "no more room to
> store anything", while "not full" means "there is room to store
> anything, up to the remaining free size".  With zram, its zsmalloc
> pool size might be over the specified limit, but there will still be
> room to store *some* things - but not *anything*.  Only compressed
> pages that happen to fit inside a class with at least one zspage that
> isn't full.
> 
> Clearly, we shouldn't wait to declare zram "full" only once zsmalloc
> is 100% full in all its classes.
> 
> What about waiting until there is N number of write failures, like
> this patch?  That doesn't seem very fair to the writer, since each
> write failure will cause them to do extra work (first, in selecting
> what to write, and then in recovering from the failed write).
> However, it will probably squeeze some writes into some of those empty
> spaces in already-allocated zspages.
> 
> And declaring zram "full" immediately once the zsmalloc pool size
> increases past the specified limit?  Since zsmalloc's classes almost
> certainly contain some fragmentation, that will waste all the empty
> spaces that could still store more compressed pages.  But, this is the
> limit at which you cannot guarantee all writes to be able to store a
> compressed page - any zsmalloc classes without a partially empty
> zspage will have to increase zsmalloc's size, therefore failing the
> write.
> 
> Neither definition of "full" is optimal.  Since in this case we're
> talking about swap, I think forcing swap write failures to happen,
> which with direct reclaim could (I believe) stop everything while the
> write failures continue, should be avoided as much as possible.  Even
> when zram fullness is delayed by N write failures, to try to squeeze
> out as much storage from zsmalloc as possible, when it does eventually
> fill if zram is the only swap device the system will OOM anyway.  And
> if zram isn't the only swap device, but just the first (highest
> priority), then delaying things with unneeded write failures is
> certainly not better than just filling up so swap can move on to the
> next swap device.  The only case where write failures delaying marking
> zram as full will help is if the system stopped right at this point,
> and then started decreasing how much memory was needed.  That seems
> like a very unlikely coincidence, but maybe some testing would help
> determine how bad the write failures affect system
> performance/responsiveness and how long they delay OOM.

Please, keep in mind that swap is alreay really slow operation but
we want to use it to avoid OOM if possible so I can't buy your early
kill suggestion. If a user feel it's really slow for his product,
it means his admin was fail. He should increase the limit of zram
dynamically or statically(zram already support that ways).

The thing I'd like to solve in this patchset is to avoid system hang
where admin cannot do anyting, even ctrl+c, which is thing should
support in OS level.

> 
> Since there may be different use cases that desire different things,
> maybe there should be a zram runtime (or buildtime) config to choose
> exactly how it decides it's full?  Either full after N write failures,
> or full when alloced>limit?  That would allow the user to either defer
> getting full as long as possible (at the possible cost of system
> unresponsiveness during those write failures), or to just move
> immediately to zram being full as soon as it can't guarantee that each
> write will succeed.

Hmm, I thought it and was going to post it when I send v1.
My idea was this.

int zram_get_free_pages(...)
{
        if (zram->limit_pages &&
                zram->alloc_fail > FULL_THRESH_HOLD &&
                (100 * compr_data_size >> PAGE_SHIFT /
                        zs_get_total_pages(zram)) > FRAG_THRESH_HOLD) {
                        *free = 0;
                        return 0;
        }
        ..
}

Maybe we could export FRAG_THRESHOLD.

> 
> 
> 
> >
> >>
> >>
> >>
> >> >
> >> > +       atomic_set(&zram->alloc_fail, 0);
> >> >         update_used_max(zram, alloced_pages);
> >> >
> >> >         cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >> > @@ -951,6 +954,7 @@ static int zram_slot_free_notify(struct block_device *bdev,
> >> >         return 0;
> >> >  }
> >> >
> >> > +#define FULL_THRESH_HOLD 32
> >> >  static int zram_get_free_pages(struct block_device *bdev, long *free)
> >> >  {
> >> >         struct zram *zram;
> >> > @@ -959,12 +963,13 @@ static int zram_get_free_pages(struct block_device *bdev, long *free)
> >> >         zram = bdev->bd_disk->private_data;
> >> >         meta = zram->meta;
> >> >
> >> > -       if (!zram->limit_pages)
> >> > -               return 1;
> >> > -
> >> > -       *free = zram->limit_pages - zs_get_total_pages(meta->mem_pool);
> >> > +       if (zram->limit_pages &&
> >> > +               (atomic_read(&zram->alloc_fail) > FULL_THRESH_HOLD)) {
> >> > +               *free = 0;
> >> > +               return 0;
> >> > +       }
> >> >
> >> > -       return 0;
> >> > +       return 1;
> >>
> >> There's no way that zram can even provide a accurate number of free
> >> pages, since it can't know how compressible future stored pages will
> >> be.  It would be better to simply change this swap_hint from GET_FREE
> >> to IS_FULL, and return either true or false.
> >
> > My plan is that we can give an approximation based on
> > orig_data_size/compr_data_size with tweaking zero page and vmscan can use
> > the hint from get_nr_swap_pages to throttle file/anon balance but I want to do
> > step by step so I didn't include the hint.
> > If you are strong against with that in this stage, I can change it and
> > try it later with the number.
> > Please, say again if you want.
> 
> since as you said zram is the only user of swap_hint, changing it
> later shouldn't be a big deal.  And you could have both, IS_FULL and
> GET_FREE; since the check in scan_swap_map() really only is checking
> for IS_FULL, if you update vmscan later to adjust its file/anon
> balance based on GET_FREE, that can be added then with no trouble,
> right?

Yeb, No problem.

> 
> 
> >
> > Thanks for the review!
> >
> >
> >>
> >>
> >> >  }
> >> >
> >> >  static int zram_swap_hint(struct block_device *bdev,
> >> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> >> > index 779d03fa4360..182a2544751b 100644
> >> > --- a/drivers/block/zram/zram_drv.h
> >> > +++ b/drivers/block/zram/zram_drv.h
> >> > @@ -115,6 +115,7 @@ struct zram {
> >> >         u64 disksize;   /* bytes */
> >> >         int max_comp_streams;
> >> >         struct zram_stats stats;
> >> > +       atomic_t alloc_fail;
> >> >         /*
> >> >          * the number of pages zram can consume for storing compressed data
> >> >          */
> >> > --
> >> > 2.0.0
> >> >
> >> >>
> >> >> heesub
> >> >>
> >> >> >+
> >> >> >+    return 0;
> >> >> >+}
> >> >> >+
> >> >> >  static int zram_swap_hint(struct block_device *bdev,
> >> >> >                             unsigned int hint, void *arg)
> >> >> >  {
> >> >> >@@ -958,6 +974,8 @@ static int zram_swap_hint(struct block_device *bdev,
> >> >> >
> >> >> >     if (hint == SWAP_SLOT_FREE)
> >> >> >             ret = zram_slot_free_notify(bdev, (unsigned long)arg);
> >> >> >+    else if (hint == SWAP_GET_FREE)
> >> >> >+            ret = zram_get_free_pages(bdev, arg);
> >> >> >
> >> >> >     return ret;
> >> >> >  }
> >> >> >
> >> >>
> >> >> --
> >> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> >> see: http://www.linux-mm.org/ .
> >> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >> >
> >> > --
> >> > Kind regards,
> >> > Minchan Kim
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
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
