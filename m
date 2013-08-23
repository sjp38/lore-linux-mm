Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6F5066B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 11:13:52 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so798051pdj.1
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 08:13:50 -0700 (PDT)
Date: Sat, 24 Aug 2013 00:13:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 0/5] zram/zsmalloc promotion
Message-ID: <20130823151303.GA2732@gmail.com>
References: <1377065791-2959-1-git-send-email-minchan@kernel.org>
 <52148730.4000709@oracle.com>
 <20130822004250.GB4665@bbox>
 <CAA_GA1fZc89BRxKyS8zs-i0-+YJ9TsVXFFZcmza2Dzo4O4kiaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1fZc89BRxKyS8zs-i0-+YJ9TsVXFFZcmza2Dzo4O4kiaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Bob Liu <bob.liu@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

Howdy Bob,

On Fri, Aug 23, 2013 at 10:10:17PM +0800, Bob Liu wrote:
> Hi Minchan,
> 
> On Thu, Aug 22, 2013 at 8:42 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hi Bob,
> >
> > On Wed, Aug 21, 2013 at 05:24:00PM +0800, Bob Liu wrote:
> >> Hi Minchan,
> >>
> >> On 08/21/2013 02:16 PM, Minchan Kim wrote:
> >> > It's 7th trial of zram/zsmalloc promotion.
> >> > I rewrote cover-letter totally based on previous discussion.
> >> >
> >> > The main reason to prevent zram promotion was no review of
> >> > zsmalloc part while Jens, block maintainer, already acked
> >> > zram part.
> >> >
> >> > At that time, zsmalloc was used for zram, zcache and zswap so
> >> > everybody wanted to make it general and at last, Mel reviewed it
> >> > when zswap was submitted to merge mainline a few month ago.
> >> > Most of review was related to zswap writeback mechanism which
> >> > can pageout compressed page in memory into real swap storage
> >> > in runtime and the conclusion was that zsmalloc isn't good for
> >> > zswap writeback so zswap borrowed zbud allocator from zcache to
> >> > replace zsmalloc. The zbud is bad for memory compression ratio(2)
> >> > but it's very predictable behavior because we can expect a zpage
> >> > includes just two pages as maximum. Other reviews were not major.
> >> > http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
> >> >
> >> > Zcache doesn't use zsmalloc either so zsmalloc's user is only
> >> > zram now so this patchset moves it into zsmalloc directory.
> >> > Recently, Bob tried to move zsmalloc under mm directory to unify
> >> > zram and zswap with adding pseudo block device in zswap(It's
> >> > very weired to me) but he was simple ignoring zram's block device
> >> > (a.k.a zram-blk) feature and considered only swap usecase of zram,
> >> > in turn, it lose zram's good concept.
> >> >
> >>
> >> Yes, I didn't notice the feature that zram can be used as a normal block
> >> device.
> >>
> >>
> >> > Mel raised an another issue in v6, "maintainance headache".
> >> > He claimed zswap and zram has a similar goal that is to compresss
> >> > swap pages so if we promote zram, maintainance headache happens
> >> > sometime by diverging implementaion between zswap and zram
> >> > so that he want to unify zram and zswap. For it, he want zswap
> >> > to implement pseudo block device like Bob did to emulate zram so
> >> > zswap can have an advantage of writeback as well as zram's benefit.
> >>
> >> If consider zram as a swap device only, I still think it's better to add
> >> a pseudo block device to zswap and just disable the writeback of zswap.
> >
> > Why do you think zswap is better?
> >
> 
> In my opinion:
> 1. It's easy for zswap to do the same thing by adding a few small changes.

For supporting zram-blk, we should move most of code from zram to zswap
because zram was based on block device. For supporting zswap, we should move
just writeback code from zswap to zram. Frontswap implementation is trivial
because zram already has read/write/slot_free matched to load/save/invalidate.

In addtion to that, zram has a long history and lots of users/contributors.

Anyway, I didn't mean trivial things like this. What I want was
what's the potential of zswap when we consider upcoming futures.

> 2. zswap won't get to the block layer which can reduce a lot of overheads.

get_swap_bio
submit_bio
zram_make_request

is it really severe?

These days, block layer is optimizing to support high storage speed 
so it would have more chances to optimize by block peoples and I don't think
above block layer's overhead heavy.
Morever, we can get benefits from block layer like async I/O, block align,
sequential write and even uncompressed writeback if we add new plugin to dm.
Normally, block I/O's cost is bigger than memory operation so gain is bigger
than lose if we can enhance in block layer.

Anyway, I'd like to say agian. I don't want to make such weird beast
which is lying between mm and block.


> 3. zswap is transparent to current users who are using normal block
> device as the swap device.

So, what's benfit? Do you mean user don't have to configure zswap?
Swap enabling is just once operation during boot. Is it bothering you?

> 
> > I don't know but when I read http://lwn.net/Articles/334649/, it aimed
> > for compressing page caches as well as swap pages but it made widespread
> > hooks in core (I guess that's why zcache had a birth later by Nitin and Dan)
> > so reviewers guided him to support anon pages only to merge it.
> > And at that time, it was a specific virtual block device for only supporting
> > swap. AFAIRC, akpm suggested to make it general block device so other party
> > can have a benefit.
> >
> > You can type "zram tmp" in google and will find many article related
> > to use zram as tmp and I have been received some questions/reports
> 
> I see.
> But i think if using shmem as tmp, the pages can be reclaimed during
> memory pressure,
> get to zswap and compressed as well.

Please don't think every machine has swap. Many embedded products don't have
swap device because It saves lots of money for our business and a few dollars
is very critical for embedded business.

> 
> Mel also pointed a situation using zram as tmpfs may make things worse.

It depends on the workload as I explained.

1) Many embedded system don't have swap so although tmpfs can support swapout
it's pointless still so such systems should have sane configuration to limit
memory space so it's not only zram problem.

2) Many embedded system don't have enough memory. Let's assume short-lived
file growing up until half of system memory once in a while. We don't want
to write it on flash by wear-leveing issue and very slowness so we want to use
in-memory but if we uses tmpfs, it should evict half of working set to cover
them when the size reach peak. zram would be better choice.

I will explain another usecase I have heard from anonymous embedded developer.
He really want to reduce core dump file size because he don't have enough space
to save core file in storage. As I said, bigger storage is money
so he uses zram-blk to save core dump and logs.

> 
> > from anonymous guys by private mail. And Jorome, Redhat guy, has
> > contributed that part like partial I/O.
> >
> 
> I am not going to block zram being promoted, just some different voice.
> 
> -- 
> Regards,
> --Bob
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
