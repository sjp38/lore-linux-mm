Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 590F56B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 02:11:16 -0400 (EDT)
Date: Mon, 19 Aug 2013 15:11:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130819061138.GB28062@bbox>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <20130814174050.GN2296@suse.de>
 <20130814185820.GA2753@gmail.com>
 <20130815171250.GA2296@suse.de>
 <20130816042641.GA2893@gmail.com>
 <20130816083347.GD2296@suse.de>
 <20130819031833.GA26832@bbox>
 <521197B5.8030409@oracle.com>
 <20130819043758.GC26832@bbox>
 <CAA25o9RtxNjXj8bjjwQN3tJtePj-m8MfMn0WriD8A6pN-GKdCg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9RtxNjXj8bjjwQN3tJtePj-m8MfMn0WriD8A6pN-GKdCg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Sonny Rao <sonnyrao@google.com>, Stephen Barber <smbarber@google.com>

Hello Luigi,

On Sun, Aug 18, 2013 at 10:29:18PM -0700, Luigi Semenzato wrote:
> On Sun, Aug 18, 2013 at 9:37 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello Bob,
> >
> > Sorry for the late response. I was on holiday.
> >
> > On Mon, Aug 19, 2013 at 11:57:41AM +0800, Bob Liu wrote:
> >> Hi Minchan,
> >>
> >> On 08/19/2013 11:18 AM, Minchan Kim wrote:
> >> > Hello Mel,
> >> >
> >> > On Fri, Aug 16, 2013 at 09:33:47AM +0100, Mel Gorman wrote:
> >> >> On Fri, Aug 16, 2013 at 01:26:41PM +0900, Minchan Kim wrote:
> >> >>>>>> <SNIP>
> >> >>>>>> If it's used for something like tmpfs then it becomes much worse. Normal
> >> >>>>>> tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
> >> >>>>>> sane configuration, lockups will be avoided and deleting a tmpfs file is
> >> >>>>>> guaranteed to free memory. When zram is used to back tmpfs, there is no
> >> >>>>>> guarantee that any memory is freed due to fragmentation of the compressed
> >> >>>>>> pages. The only way to recover the memory may be to kill applications
> >> >>>>>> holding tmpfs files open and then delete them which is fairly drastic
> >> >>>>>> action in a normal server environment.
> >> >>>>>
> >> >>>>> Indeed.
> >> >>>>> Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
> >> >>>>> handle instead of pure pointer so it could migrate some zpages to somewhere
> >> >>>>> to pack in. Then, it could help above problem and OOM storm problem.
> >> >>>>> Anyway, it's a totally new feature and requires many changes and experiement.
> >> >>>>> Although we don't have such feature, zram is still good for many people.
> >> >>>>>
> >> >>>>
> >> >>>> And is zsmalloc was pluggable for zswap then it would also benefit.
> >> >>>
> >> >>> But zswap isn't pseudo block device so it couldn't be used for block device.
> >> >>
> >> >> It would not be impossible to write one. Taking a quick look it might even
> >> >> be doable by just providing a zbud_ops that does not have an evict handler
> >> >> and make sure the errors are handled correctly. i.e. does the following
> >> >> patch mean that zswap never writes back and instead just compresses pages
> >> >> in memory?
> >> >>
> >> >> diff --git a/mm/zswap.c b/mm/zswap.c
> >> >> index deda2b6..99e41c8 100644
> >> >> --- a/mm/zswap.c
> >> >> +++ b/mm/zswap.c
> >> >> @@ -819,7 +819,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
> >> >>  }
> >> >>
> >> >>  static struct zbud_ops zswap_zbud_ops = {
> >> >> -  .evict = zswap_writeback_entry
> >> >>  };
> >> >>
> >> >>  static void zswap_frontswap_init(unsigned type)
> >> >>
> >> >> If so, it should be doable to link that up in a sane way so it can be
> >> >> configured at runtime.
> >> >>
> >> >> Did you ever even try something like this?
> >> >
> >> > Never. Because I didn't have such requirement for zram.
> >> >
> >> >>
> >> >>> Let say one usecase for using zram-blk.
> >> >>>
> >> >>> 1) Many embedded system don't have swap so although tmpfs can support swapout
> >> >>> it's pointless still so such systems should have sane configuration to limit
> >> >>> memory space so it's not only zram problem.
> >> >>>
> >> >>
> >> >> If zswap was backed by a pseudo device that failed all writes or an an
> >> >> ops with no evict handler then it would be functionally similar.
> >> >>
> >> >>> 2) Many embedded system don't have enough memory. Let's assume short-lived
> >> >>> file growing up until half of system memory once in a while. We don't want
> >> >>> to write it on flash by wear-leveing issue and very slowness so we want to use
> >> >>> in-memory but if we uses tmpfs, it should evict half of working set to cover
> >> >>> them when the size reach peak. zram would be better choice.
> >> >>>
> >> >>
> >> >> Then back it by a pseudo device that fails all writes so it does not have
> >> >> to write to disk.
> >> >
> >> > You mean "make pseudo block device and register make_request_fn
> >> > and prevent writeback". Bah, yes, it's doable but what is it different with below?
> >> >
> >> > 1) move zbud into zram
> >> > 2) implement frontswap API in zram
> >> > 3) implement writebazk in zram
> >> >
> >> > The zram has been for a long time in staging to be promoted and have been
> >> > maintained/deployed. Of course, I have asked the promotion several times
> >> > for above a year.
> >> >
> >> > Why can't zram include zswap functions if you really want to merge them?
> >> > Is there any problem?
> >>
> >> I think merging zram into zswap or merging zswap into zram are the same
> >> thing. It's no difference.
> >
> > True but i'd like to merge zswap code into zram.
> > Because as you know, zram has already lots of users while zswap is almost
> > new young so I'd like to keep backward compatibility for zram so moving zswap code
> > into zram is more handy and could keep the git log as well.
> >
> >> Both way will result in a solution finally with zram block device,
> >> frontswap API etc.
> >
> > Right but z* family people should discuss that zswap-writeback is really
> > good solution for compressed swap. Firstly, I thought zswap is differnt with
> > zram so there is no issue to promote zram so I and Nitin helped zsmalloc
> > promotion for Seth and have reviewed at zswap inital phases but the situation
> > is chainging. Let's discussion further points about compresssed swap solution.
> > I raised issues as reply of Mel in my thread. Let's think of it.
> >
> >>
> >> The difference is just the name and the merging patch title, I think
> >> it's unimportant.
> >
> > If we decide merging them, yes, module name would be important and
> > we can't ignore copyright and maintainer part, either. Anyway,
> > I'd like to go that way as last resort afther enough thinking which can justify
> > frontswap-based swap writeback is right approach.
> >
> >>
> >> I've implemented a series [PATCH 0/4] mm: merge zram into zswap, I can
> >> change the tile to "merge zswap into zram" if you want and rename zswap
> >> to something like zhybrid.
> >
> > Hmm, I saw that roughly and you are ignoring zram's backward compatibility
> > and zram-blk functionality which can be used for in-memory compressed block
> > device without swap.
> >
> > Thanks.
> >
> > --
> > Kind regards,
> > Minchan Kim
> 
> We are gearing up to evaluate zswap, but we have only ported kernels
> up to 3.8 to our hardware, so we may be missing important patches.
> 
> In our experience, and with all due respect, the linux MM is a complex
> beast, and it's difficult to predict how hard it will be for us to
> switch to zswap.  Even with the relatively simple zram, our load
> triggered bugs in other parts of the MM that took a fair amount of
> work to resolve.
> 
> I may be wrong, but the in-memory compressed block device implemented
> by zram seems like a simple device which uses a well-established API
> to the rest of the kernel.  If it is removed from the kernel, will it

True.

> be difficult for us to carry our own patch?  Because we may have to do
> that for a while.  Of course we would prefer it if it stayed in, at
> least temporarily.

Totally, I agree. zram shouldn't go out before we have clear solution for
the future.

> 
> Also, could someone confirm or deny that the maximum compression ratio
> in zbud is 2?  Because we easily achieve a 2.6-2.8 compression ratio
> with our loads using zram with zsmalloc and LZO or snappy.  Losing
> that memory will cause a noticeable regression, which will encourage
> us to stick with zram.

2 is right for zbud and that's why zswap people want to merge zsmalloc into
zswap.

> 
> I am hoping that our load is not so unusual that we are the only Linux
> users in this situation, and that zsmalloc (or other
> allocator-compressor with similar characteristics) will continue to
> exist, whether it is used by zram or zswap.

Don't mind. zsmalloc should be in there.

Currently, my concern is that zswap is really a good feature for compressed
swap when we consider further enhancements? I don't think so.
Maybe zswap should borrow, if ever, all of the code from zram to emulate zram
and keep the backward compatibility.
But I don't think it does make sense. Why really young zswap should try to
absorb old zram? Hmm..

> 
> Thanks!
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
