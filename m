Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE6C6B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 23:03:06 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id bj1so638045pad.4
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 20:03:06 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zq3si3720030pac.175.2014.08.27.20.03.04
        for <linux-mm@kvack.org>;
        Wed, 27 Aug 2014 20:03:05 -0700 (PDT)
Date: Thu, 28 Aug 2014 12:04:03 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 3/4] zram: zram memory size limitation
Message-ID: <20140828030403.GC28686@bbox>
References: <CAFdhcLQce05qi2LGP85N=aaQiKz1ArC3Kn+W-s86R58BkjMr3w@mail.gmail.com>
 <20140827012610.GA10198@js1304-P5Q-DELUXE>
 <20140827025132.GI32620@bbox>
 <CALZtONDij=uioTACao7oK-44FsNX90ODXivwJWauFsgx01-=YQ@mail.gmail.com>
 <CAFdhcLTS-4U-ynDhGzbMO0vc9nWoMR1=anO-SNDN09VOrbSw7w@mail.gmail.com>
 <CALZtONBnw4AzXyTS9AOnT9Ftjzbu6788-vkkvKJLCmExvfX7qA@mail.gmail.com>
 <CAFdhcLSdwbzvbA8Q1qBJBVqS51XVVqG_b-u57Ds8UXk4-1mcxA@mail.gmail.com>
 <CALZtONBZwgV1z8snwdgG9mWHY6dq75mt2n25dNMgGTOXYd4zdA@mail.gmail.com>
 <CAFdhcLSR=juBMu0FHJq2_S3hE_7d-H1yGRuwto5BS-RLW9ie7g@mail.gmail.com>
 <CALZtONCT2-eRP18JHRfmWiDHYMv+SeM2roCePuC_uZC=H5MtOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONCT2-eRP18JHRfmWiDHYMv+SeM2roCePuC_uZC=H5MtOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: David Horner <ds2horner@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>

On Wed, Aug 27, 2014 at 03:04:32PM -0400, Dan Streetman wrote:
> On Wed, Aug 27, 2014 at 12:59 PM, David Horner <ds2horner@gmail.com> wrote:
> > On Wed, Aug 27, 2014 at 12:29 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> >> On Wed, Aug 27, 2014 at 11:35 AM, David Horner <ds2horner@gmail.com> wrote:
> >>> On Wed, Aug 27, 2014 at 11:14 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> >>>> On Wed, Aug 27, 2014 at 10:44 AM, David Horner <ds2horner@gmail.com> wrote:
> >>>>> On Wed, Aug 27, 2014 at 10:03 AM, Dan Streetman <ddstreet@ieee.org> wrote:
> >>>>>> On Tue, Aug 26, 2014 at 10:51 PM, Minchan Kim <minchan@kernel.org> wrote:
> >>>>>>> Hey Joonsoo,
> >>>>>>>
> >>>>>>> On Wed, Aug 27, 2014 at 10:26:11AM +0900, Joonsoo Kim wrote:
> >>>>>>>> Hello, Minchan and David.
> >>>>>>>>
> >>>>>>>> On Tue, Aug 26, 2014 at 08:22:29AM -0400, David Horner wrote:
> >>>>>>>> > On Tue, Aug 26, 2014 at 3:55 AM, Minchan Kim <minchan@kernel.org> wrote:
> >>>>>>>> > > Hey Joonsoo,
> >>>>>>>> > >
> >>>>>>>> > > On Tue, Aug 26, 2014 at 04:37:30PM +0900, Joonsoo Kim wrote:
> >>>>>>>> > >> On Mon, Aug 25, 2014 at 09:05:55AM +0900, Minchan Kim wrote:
> >>>>>>>> > >> > @@ -513,6 +540,14 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
> >>>>>>>> > >> >             ret = -ENOMEM;
> >>>>>>>> > >> >             goto out;
> >>>>>>>> > >> >     }
> >>>>>>>> > >> > +
> >>>>>>>> > >> > +   if (zram->limit_pages &&
> >>>>>>>> > >> > +           zs_get_total_pages(meta->mem_pool) > zram->limit_pages) {
> >>>>>>>> > >> > +           zs_free(meta->mem_pool, handle);
> >>>>>>>> > >> > +           ret = -ENOMEM;
> >>>>>>>> > >> > +           goto out;
> >>>>>>>> > >> > +   }
> >>>>>>>> > >> > +
> >>>>>>>> > >> >     cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
> >>>>>>>> > >>
> >>>>>>>> > >> Hello,
> >>>>>>>> > >>
> >>>>>>>> > >> I don't follow up previous discussion, so I could be wrong.
> >>>>>>>> > >> Why this enforcement should be here?
> >>>>>>>> > >>
> >>>>>>>> > >> I think that this has two problems.
> >>>>>>>> > >> 1) alloc/free happens unnecessarilly if we have used memory over the
> >>>>>>>> > >> limitation.
> >>>>>>>> > >
> >>>>>>>> > > True but firstly, I implemented the logic in zsmalloc, not zram but
> >>>>>>>> > > as I described in cover-letter, it's not a requirement of zsmalloc
> >>>>>>>> > > but zram so it should be in there. If every user want it in future,
> >>>>>>>> > > then we could move the function into zsmalloc. That's what we
> >>>>>>>> > > concluded in previous discussion.
> >>>>>>>>
> >>>>>>>> Hmm...
> >>>>>>>> Problem is that we can't avoid these unnecessary overhead in this
> >>>>>>>> implementation. If we can implement this feature in zram efficiently,
> >>>>>>>> it's okay. But, I think that current form isn't.
> >>>>>>>
> >>>>>>>
> >>>>>>> If we can add it in zsmalloc, it would be more clean and efficient
> >>>>>>> for zram but as I said, at the moment, I didn't want to put zram's
> >>>>>>> requirement into zsmalloc because to me, it's weird to enforce max
> >>>>>>> limit to allocator. It's client's role, I think.
> >>>>>>>
> >>>>>>> If current implementation is expensive and rather hard to follow,
> >>>>>>> It would be one reason to move the feature into zsmalloc but
> >>>>>>> I don't think it makes critical trobule in zram usecase.
> >>>>>>> See below.
> >>>>>>>
> >>>>>>> But I still open and will wait others's opinion.
> >>>>>>> If other guys think zsmalloc is better place, I am willing to move
> >>>>>>> it into zsmalloc.
> >>>>>>
> >>>>>> Moving it into zsmalloc would allow rejecting new zsmallocs before
> >>>>>> actually crossing the limit, since it can calculate that internally.
> >>>>>> However, with the current patches the limit will only be briefly
> >>>>>> crossed, and it should not be crossed by a large amount.  Now, if this
> >>>>>> is happening repeatedly and quickly during extreme memory pressure,
> >>>>>> the constant alloc/free will clearly be worse than a simple internal
> >>>>>> calculation and failure.  But would it ever happen repeatedly once the
> >>>>>> zram limit is reached?
> >>>>>>
> >>>>>> Now that I'm thinking about the limit from the perspective of the zram
> >>>>>> user, I wonder what really will happen.  If zram is being used for
> >>>>>> swap space, then when swap starts getting errors trying to write
> >>>>>> pages, how damaging will that be to the system?  I haven't checked
> >>>>>> what swap does when it encounters disk errors.  Of course, with no
> >>>>>> zram limit, continually writing to zram until memory is totally
> >>>>>> consumed isn't good either.  But in any case, I would hope that swap
> >>>>>> would not repeatedly hammer on a disk when it's getting write failures
> >>>>>> from it.
> >>>>>>
> >>>>>> Alternately, if zram was being used as a compressed ram disk for
> >>>>>> regular file storage, it's entirely up to the application to handle
> >>>>>> write failures, so it may continue to try to write to a full zram
> >>>>>> disk.
> >>>>>>
> >>>>>> As far as what the zsmalloc api would look like with the limit added,
> >>>>>> it would need a setter and getter function (adding it as a param to
> >>>>>> the create function would be optional i think).  But more importantly,
> >>>>>> it would need to handle multiple ways of specifying the limit.  In our
> >>>>>> specific current use cases, zram and zswap, each handles their
> >>>>>> internal limit differently - zswap currently uses a % of total ram as
> >>>>>> its limit (defaulting to 20), while with these patches zram will use a
> >>>>>> specific number of bytes as its limit (defaulting to no limit).  If
> >>>>>> the limiting mechanism is moved into zsmalloc (and possibly zbud),
> >>>>>> then either both users need to use the same units (bytes or %ram), or
> >>>>>> zsmalloc/zbud need to be able to set their limit in either units.  It
> >>>>>> seems to me like keeping the limit in zram/zswap is currently
> >>>>>> preferable, at least without both using the same limit units.
> >>>>>>
> >>>>>
> >>>>> zswap knows what 20% (or whatever % it currently uses , and perhaps it too
> >>>>> will become a tuning knob) of memory is in bytes.
> >>>>>
> >>>>> So, if the interface to establish a limit for a pool (or pool set, or whatever
> >>>>> zsmalloc sets up for its allocation mechanism) is stipulated in bytes
> >>>>> (to actually use pages internally, of visa-versa) , then both can use
> >>>>> that interface.
> >>>>> zram with its native page stipulation, and zswap with calculated % of memory).
> >>>>
> >>>> No, unless zswap monitors memory hotplug and updates the limit on each
> >>>> hotplug event, 20% of the *current* total ram at zswap initialization
> >>>> is not equal to an actual 20% of ram limit.  zswap checks its size
> >>>> against totalram_pages for each new allocation. I don't think we would
> >>>> prefer adding memory hotplug monitoring to zswap just to update the
> >>>> zpool size limit.
> >>>>
> >>>
> >>> OK - I see the need to retain the limits where they are in the using
> >>> components so that
> >>> zsmalloc is not unnecessarily complicated (keeping track of 2 limit methods).
> >>>
> >>> So, zswap has the same race conditions and possible transient over-allocations?
> >>> It looks like I will have to check on how zswap implements it.
> >>> But perhaps you can answer the question that is not in the code:
> >>> Have there been reported thrashing behaviour around the 20% limit for zswap?
> >>
> >> zswap does a simple over-allocation check before allocating anything.
> >> So during page store, it checks if (total_ram * 0.20) < used.  This
> >> actually places the effective limit higher than the specified limit,
> >> but only by a single allocation.  This approach could be taken with
> >> zram as well.
> >>
> >> The amount of over-allocation (past the specified limit) would vary
> >> between zsmalloc and zbud.  Since zbud increases itself in page
> >> increments, any over-allocation past the zswap limit would be by only
> >> 1 page.  However, zsmalloc is variable in its allocation increments,
> >> as it depends on which class needs to be grown; zsmalloc is divided
> >> into many "classes", each of contains some number of "zspages" which
> >> try to precisely contain some number of N-sized areas; e.g. one class
> >> might use zspages that are 2 pages to store 3 separate areas which are
> >> each 2/3 of a page number of bytes; if that class needed to be grown,
> >> it would add one zspage that is 2 pages.  The max number of actual
> >> pages per zspage is defined by ZS_MAX_PAGES_PER_ZSPAGE which is
> >> currently set to 1<<2, so 4.
> >>
> >> So with zswap, it will over-allocate memory past its specified limit,
> >> up to 1 page (with zbud) or up to 4 pages (with zsmalloc).  zram could
> >> do the same, simply check if its size > limit before each write, and
> >> fail if so; that would remove the alloc/free issue, and would only
> >> over-allocate by at most 4 pages (with the current zsmalloc settings).
> >> Alternately, zram could check if its (current_size + 4pages > limit),
> >> which would then stop it short of the limit by up to 4 pages.  Really
> >> though, 4 pages either above or under the limit probably doesn't
> >> matter.
> >
> > I agree that it isn't the over allocation of a few pages, per se, but if
> > there is potential for concurrent allocation through either zram of zswap
> > there is the possibility of high contention thrashing as the processes
> > jocky for those final pages. Perhaps not a thundering herd, but
> >  it could readily become a hot spot as the pressure is on and there is
> >  no explicit mechanism to throttle back retries and new efforts.
> >
> > I agree that a precheck before zsmalloc request in zram may be a valuable
> > optimization, but only if there is a real possibility of threshold thrashing.
> > I suggested before that it might be best to wait and see....
> > Do you have any suggestions on a stress test approach to empirically assess
> > the risk?
> 
> Minchan is the expert here so he may have suggestions and/or existing
> tests, but I think just creating a zram device with a limit and any
> filesystem and mounting it, then filling up the device, would be a
> good basic test.  Maybe once it gets close to the limit, try writing
> to it with multiple threads concurrently.  Also, while near/at the
> limit, try concurrently writing to it and deleting from it - probably
> writing many small files as well as deleting many small files would be
> best to keep it right at its limit.  However, I think
> zram_bvec_write() is already protected inside the init_lock semphore
> (via zram_make_request), so it seems like there will never be any
> concurrency issue.

Strictly speaking, it's read-side lock so that it could be concurrent.

> 
> Since the threads writing to files at the limit will be getting
> (expected) errors during write, the test is really looking at is
> whether there is any significant performance difference between a
> alloc/free-on-full approach or a pre-check/fail-on-full approach.
> That might not become apparent until there is significant memory
> pressure, so you might set the zram limit high enough, or you could
> otherwise artificially use up system memory (e.g. stress -m).
> 
> Also, as a general test of the new zram limit, it would be interesting
> to see how various filesystem drivers handle unexpected write
> failures...I'm no fs expert, but I would expect that this is different
> than a typical ENOSPC condition, which I assume comes from the
> filesystem, not the block layer.  This error would be more like a
> hardware error.

True. Acutally, I found a BUG_ON on ext4 but didn't look it in depth
yet. Maybe I will report.

> 
> I'd also be interested in what happens when a zram-backed swap device
> reaches its limit...I would hope swap device write errors would lead
> to a normal OOM condition and invoke the oom-killer, but from
> page_io.c end_swap_bio_write:
> 
>  * We failed to write the page out to swap-space.
>  * Re-dirty the page in order to avoid it being reclaimed.
>  * Also print a dire warning that things will go BAD (tm)
>  * very quickly.
> 

Yeb, bad. as I said, VM doesn't have congestion control for swap at the
moment and it could be improved and I am seeing that.

> 
> 
> >
> > Thanks again.
> >
> >
> >>
> >>>
> >>> thanks.
> >>>
> >>>>>
> >>>>> Both would need a mechanism to change the max as need change,
> >>>>>  so the API has to handle this.
> >>>>>
> >>>>>
> >>>>> Or am I way off base?
> >>>>>
> >>>>>
> >>>>>>
> >>>>>>>
> >>>>>>>>
> >>>>>>>> > >
> >>>>>>>> > > Another idea is we could call zs_get_total_pages right before zs_malloc
> >>>>>>>> > > but the problem is we cannot know how many of pages are allocated
> >>>>>>>> > > by zsmalloc in advance.
> >>>>>>>> > > IOW, zram should be blind on zsmalloc's internal.
> >>>>>>>> > >
> >>>>>>>> >
> >>>>>>>> > We did however suggest that we could check before hand to see if
> >>>>>>>> > max was already exceeded as an optimization.
> >>>>>>>> > (possibly with a guess on usage but at least using the minimum of 1 page)
> >>>>>>>> > In the contested case, the max may already be exceeded transiently and
> >>>>>>>> > therefore we know this one _could_ fail (it could also pass, but odds
> >>>>>>>> > aren't good).
> >>>>>>>> > As Minchan mentions this was discussed before - but not into great detail.
> >>>>>>>> > Testing should be done to determine possible benefit. And as he also
> >>>>>>>> > mentions, the better place for it may be in zsmalloc, but that
> >>>>>>>> > requires an ABI change.
> >>>>>>>>
> >>>>>>>> Why we hesitate to change zsmalloc API? It is in-kernel API and there
> >>>>>>>> are just two users now, zswap and zram. We can change it easily.
> >>>>>>>> I think that we just need following simple API change in zsmalloc.c.
> >>>>>>>>
> >>>>>>>> zs_zpool_create(gfp_t gfp, struct zpool_ops *zpool_op)
> >>>>>>>> =>
> >>>>>>>> zs_zpool_create(unsigned long limit, gfp_t gfp, struct zpool_ops
> >>>>>>>> *zpool_op)
> >>>>>>>>
> >>>>>>>> It's pool allocator so there is no obstacle for us to limit maximum
> >>>>>>>> memory usage in zsmalloc. It's a natural idea to limit memory usage
> >>>>>>>> for pool allocator.
> >>>>>>>>
> >>>>>>>> > Certainly a detailed suggestion could happen on this thread and I'm
> >>>>>>>> > also interested
> >>>>>>>> > in your thoughts, but this patchset should be able to go in as is.
> >>>>>>>> > Memory exhaustion avoidance probably trumps the possible thrashing at
> >>>>>>>> > threshold.
> >>>>>>>> >
> >>>>>>>> > > About alloc/free cost once if it is over the limit,
> >>>>>>>> > > I don't think it's important to consider.
> >>>>>>>> > > Do you have any scenario in your mind to consider alloc/free cost
> >>>>>>>> > > when the limit is over?
> >>>>>>>> > >
> >>>>>>>> > >> 2) Even if this request doesn't do new allocation, it could be failed
> >>>>>>>> > >> due to other's allocation. There is time gap between allocation and
> >>>>>>>> > >> free, so legimate user who want to use preallocated zsmalloc memory
> >>>>>>>> > >> could also see this condition true and then he will be failed.
> >>>>>>>> > >
> >>>>>>>> > > Yeb, we already discussed that. :)
> >>>>>>>> > > Such false positive shouldn't be a severe problem if we can keep a
> >>>>>>>> > > promise that zram user cannot exceed mem_limit.
> >>>>>>>> > >
> >>>>>>>>
> >>>>>>>> If we can keep such a promise, why we need to limit memory usage?
> >>>>>>>> I guess that this limit feature is useful for user who can't keep such promise.
> >>>>>>>> So, we should assume that this false positive happens frequently.
> >>>>>>>
> >>>>>>>
> >>>>>>> The goal is to limit memory usage within some threshold.
> >>>>>>> so false positive shouldn't be harmful unless it exceeds the threshold.
> >>>>>>> In addition, If such false positive happens frequently, it means
> >>>>>>> zram is very trobule so that user would see lots of write fail
> >>>>>>> message, sometime really slow system if zram is used for swap.
> >>>>>>> If we protect just one write from the race, how much does it help
> >>>>>>> this situation? I don't think it's critical problem.
> >>>>>>>
> >>>>>>>>
> >>>>>>>> > And we cannot avoid the race, nor can we avoid in a low overhead competitive
> >>>>>>>> > concurrent process transient inconsistent states.
> >>>>>>>> > Different views for different observers.
> >>>>>>>> >  They are a consequence of the theory of "Special Computational Relativity".
> >>>>>>>> >  I am working on a String Unification Theory of Quantum and General CR in LISP.
> >>>>>>>> >  ;-)
> >>>>>>>>
> >>>>>>>> If we move limit logic to zsmalloc, we can avoid the race by commiting
> >>>>>>>> needed memory size before actual allocation attempt. This commiting makes
> >>>>>>>> concurrent process serialized so there is no race here. There is
> >>>>>>>> possibilty to fail to allocate, but I think this is better than alloc
> >>>>>>>> and free blindlessly depending on inconsistent states.
> >>>>>>>
> >>>>>>> Normally, zsmalloc/zsfree allocates object from existing pool so
> >>>>>>> it's not big overhead and if someone continue to try writing  once limit is
> >>>>>>> full, another overhead (vfs, fs, block) would be bigger than zsmalloc
> >>>>>>> so it's not a problem, I think.
> >>>>>>>
> >>>>>>>>
> >>>>>>>> Thanks.
> >>>>>>>>
> >>>>>>>> --
> >>>>>>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >>>>>>>> the body to majordomo@kvack.org.  For more info on Linux MM,
> >>>>>>>> see: http://www.linux-mm.org/ .
> >>>>>>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>>>>>>
> >>>>>>> --
> >>>>>>> Kind regards,
> >>>>>>> Minchan Kim
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
