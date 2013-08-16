Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 91EB96B0033
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 04:33:56 -0400 (EDT)
Date: Fri, 16 Aug 2013 09:33:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130816083347.GD2296@suse.de>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <20130814174050.GN2296@suse.de>
 <20130814185820.GA2753@gmail.com>
 <20130815171250.GA2296@suse.de>
 <20130816042641.GA2893@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130816042641.GA2893@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, Aug 16, 2013 at 01:26:41PM +0900, Minchan Kim wrote:
> > > > <SNIP>
> > > > If it's used for something like tmpfs then it becomes much worse. Normal
> > > > tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
> > > > sane configuration, lockups will be avoided and deleting a tmpfs file is
> > > > guaranteed to free memory. When zram is used to back tmpfs, there is no
> > > > guarantee that any memory is freed due to fragmentation of the compressed
> > > > pages. The only way to recover the memory may be to kill applications
> > > > holding tmpfs files open and then delete them which is fairly drastic
> > > > action in a normal server environment.
> > > 
> > > Indeed.
> > > Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
> > > handle instead of pure pointer so it could migrate some zpages to somewhere
> > > to pack in. Then, it could help above problem and OOM storm problem.
> > > Anyway, it's a totally new feature and requires many changes and experiement.
> > > Although we don't have such feature, zram is still good for many people.
> > > 
> > 
> > And is zsmalloc was pluggable for zswap then it would also benefit.
> 
> But zswap isn't pseudo block device so it couldn't be used for block device.

It would not be impossible to write one. Taking a quick look it might even
be doable by just providing a zbud_ops that does not have an evict handler
and make sure the errors are handled correctly. i.e. does the following
patch mean that zswap never writes back and instead just compresses pages
in memory?

diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..99e41c8 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -819,7 +819,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 }
 
 static struct zbud_ops zswap_zbud_ops = {
-	.evict = zswap_writeback_entry
 };
 
 static void zswap_frontswap_init(unsigned type)

If so, it should be doable to link that up in a sane way so it can be
configured at runtime.

Did you ever even try something like this?

> Let say one usecase for using zram-blk.
> 
> 1) Many embedded system don't have swap so although tmpfs can support swapout
> it's pointless still so such systems should have sane configuration to limit
> memory space so it's not only zram problem.
> 

If zswap was backed by a pseudo device that failed all writes or an an
ops with no evict handler then it would be functionally similar.

> 2) Many embedded system don't have enough memory. Let's assume short-lived
> file growing up until half of system memory once in a while. We don't want
> to write it on flash by wear-leveing issue and very slowness so we want to use
> in-memory but if we uses tmpfs, it should evict half of working set to cover
> them when the size reach peak. zram would be better choice.
> 

Then back it by a pseudo device that fails all writes so it does not have
to write to disk.

> > 
> > > > These are the sort of reason why I feel that zram has limited cases where
> > > > it is safe to use and zswap has a wider range of applications. At least
> > > > I would be very unhappy to try supporting zram in the field for normal
> > > > servers. zswap should be able to replace the functionality of zram+swap
> > > > by backing zswap with a pseudo block device that rejects all writes. I
> > > 
> > > One of difference between zswap and zram is asynchronous I/O support.
> > 
> > As zram is not writing to disk, how compelling is asynchronous IO? If
> > zswap was backed by the pseudo device is there a measurable bottleneck?
> 
> Compression. It was really bottlneck point. I had an internal patch which
> can make zram use various compressor, not only LZO.
> The better good compressor was, the more bottlenck compressor was.
> 

There are two issues there. One that different compression algorithms
should be optional with tradeoffs on speed vs compression ratio. There is
no reason why that couldn't be hacked into zswap.

The second is that only one page can be compressed at a time. That would
require further work to allow the frontswap API to asynchronously compress
pages. It would be a lot more heavy lifting but it is not impossible.

> > However, I believe that the promotion will lead to zram and zswap diverging
> > further from each other, both implementing similar functionality and
> > ultimately cause greater maintenance headaches. There is a path that makes
> > zswap a functional replacement for zram and I've seen no good reason why
> > that path was not taken. Zram cannot be a functional replacment for zswap
> > as there is no obvious sane way writeback could be implemented. Continuing
> 
> Then, do you think current zswap's writeback is sane way?

No, it's clunky as hell and the layering between zswap and zbud is twisty
(e.g. zswap store -> zbud reclaim -> zswap writeback wtf?). I believe it used
to be a lot worse but was ironed out a bit in preparation for merging. As
bad as it is, general workloads cannot just consume unreclaimable pages with
compressed data and writeback should be optionally handled at the very least.

How zswap currently implements it could be a whole lot better. It's silly
that it is the allocator the directly performs synchronous writeback
one page at a time because that will means the world stalls when zswap
fills. On larger machines that is just going to be brick wall and considering
that zswap was intended for virtualisation it is particularly hilarious.
I think I brought up its stalling behaviour during review when it was being
merged. It would have been preferable if writeback could be initiated in
batches and then waited on at the very least. It's worse that it uses
_swap_writepage directly instead of going through a writepage ops. It
would have been better if zbud pages existed on the LRU and written back
with an address space ops and properly handled asynchonous writeback.

Zswap could be massively improved, there is no denying that. I've seen no
follow-up patches since which is a bit worrying but I'm not losing sleep
over it.

Zram does not even try to do anything like this and from your description
of the embedded use case there is no intention of ever trying.

> I didn't raise an issue because I didn't want to be a blocker when zswap was
> promoted. Actually, I didn't like that way because I thought swap-writeback
> feature should be implemented by VM itself rather than some hooked driver
> internal logic.

You could also have brought it up any time since or pushed for it to be
implemented with the view to making zswap functionally equivalent to
zram.

> VM alreay has a lot information so it would handle multipe
> heterogenous swap more efficenlty like cache hierachy without LRU inversing.
> It could solve current zswap LRU inversing problem generally and help others
> who want to configure multiple swap system as well as zram.
> 
> > to diverge will ultimately bite someone in the ass.
> 
> Mel, current zram situation is following as.
> 
> 1) There are a lot users in the world.
> 2) So, many valuable contributions have been in there.
> 2) The new feature development of zram had stalled because Greg asserted
>    he doesn't accept new feature until promote will be done and recently,
>    he said he will remove zram in staging if anybody doesn't try to promote
> 3) You are saying zram shouldn't be promote. IOW, zram should go away.
> 
> Right? Then, What should we zram developers do?

I've already explained, more than once going at least as far back as
April, how I thought zswap could be made functionally identical to zram
and improved.

> What's next step for zram which is really perfect for embedded system?
> We should really lose a chance to enhance zram although fresh zswap
> couldn't replace old zram?
> 
> Mel, please consider embedded world although they are very little voice
> in this core subsystem.
> 

I already said I recognise it has a large number of users in the field
and users count a lot more than me complaining. If it gets promoted then
I expect it will be on those grounds.

My position is that I think it's a bad idea because it is clear there is no
plan or intention of ever brining zram and zswap together. Instead we are
to have two features providing similar functionality with zram diverging
further from zswap.  Ultimately I believe this will increase maintenance
headaches. It'll get even more entertaining if/when someone ever tries
to reimplement zcache although since Dan left I do not believe anyone is
planning to try. I will not be acking this series but there many be enough
developers that are actually willing to maintain a duel zram/zswap mess
to make it happen anyway.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
