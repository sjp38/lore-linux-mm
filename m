Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id E26616B0033
	for <linux-mm@kvack.org>; Sun, 18 Aug 2013 23:18:10 -0400 (EDT)
Date: Mon, 19 Aug 2013 12:18:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130819031833.GA26832@bbox>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <20130814174050.GN2296@suse.de>
 <20130814185820.GA2753@gmail.com>
 <20130815171250.GA2296@suse.de>
 <20130816042641.GA2893@gmail.com>
 <20130816083347.GD2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130816083347.GD2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

Hello Mel,

On Fri, Aug 16, 2013 at 09:33:47AM +0100, Mel Gorman wrote:
> On Fri, Aug 16, 2013 at 01:26:41PM +0900, Minchan Kim wrote:
> > > > > <SNIP>
> > > > > If it's used for something like tmpfs then it becomes much worse. Normal
> > > > > tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
> > > > > sane configuration, lockups will be avoided and deleting a tmpfs file is
> > > > > guaranteed to free memory. When zram is used to back tmpfs, there is no
> > > > > guarantee that any memory is freed due to fragmentation of the compressed
> > > > > pages. The only way to recover the memory may be to kill applications
> > > > > holding tmpfs files open and then delete them which is fairly drastic
> > > > > action in a normal server environment.
> > > > 
> > > > Indeed.
> > > > Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
> > > > handle instead of pure pointer so it could migrate some zpages to somewhere
> > > > to pack in. Then, it could help above problem and OOM storm problem.
> > > > Anyway, it's a totally new feature and requires many changes and experiement.
> > > > Although we don't have such feature, zram is still good for many people.
> > > > 
> > > 
> > > And is zsmalloc was pluggable for zswap then it would also benefit.
> > 
> > But zswap isn't pseudo block device so it couldn't be used for block device.
> 
> It would not be impossible to write one. Taking a quick look it might even
> be doable by just providing a zbud_ops that does not have an evict handler
> and make sure the errors are handled correctly. i.e. does the following
> patch mean that zswap never writes back and instead just compresses pages
> in memory?
> 
> diff --git a/mm/zswap.c b/mm/zswap.c
> index deda2b6..99e41c8 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -819,7 +819,6 @@ static void zswap_frontswap_invalidate_area(unsigned type)
>  }
>  
>  static struct zbud_ops zswap_zbud_ops = {
> -	.evict = zswap_writeback_entry
>  };
>  
>  static void zswap_frontswap_init(unsigned type)
> 
> If so, it should be doable to link that up in a sane way so it can be
> configured at runtime.
> 
> Did you ever even try something like this?

Never. Because I didn't have such requirement for zram.

> 
> > Let say one usecase for using zram-blk.
> > 
> > 1) Many embedded system don't have swap so although tmpfs can support swapout
> > it's pointless still so such systems should have sane configuration to limit
> > memory space so it's not only zram problem.
> > 
> 
> If zswap was backed by a pseudo device that failed all writes or an an
> ops with no evict handler then it would be functionally similar.
> 
> > 2) Many embedded system don't have enough memory. Let's assume short-lived
> > file growing up until half of system memory once in a while. We don't want
> > to write it on flash by wear-leveing issue and very slowness so we want to use
> > in-memory but if we uses tmpfs, it should evict half of working set to cover
> > them when the size reach peak. zram would be better choice.
> > 
> 
> Then back it by a pseudo device that fails all writes so it does not have
> to write to disk.

You mean "make pseudo block device and register make_request_fn
and prevent writeback". Bah, yes, it's doable but what is it different with below?

1) move zbud into zram
2) implement frontswap API in zram
3) implement writebazk in zram

The zram has been for a long time in staging to be promoted and have been
maintained/deployed. Of course, I have asked the promotion several times
for above a year.

Why can't zram include zswap functions if you really want to merge them?
Is there any problem?

> 
> > > 
> > > > > These are the sort of reason why I feel that zram has limited cases where
> > > > > it is safe to use and zswap has a wider range of applications. At least
> > > > > I would be very unhappy to try supporting zram in the field for normal
> > > > > servers. zswap should be able to replace the functionality of zram+swap
> > > > > by backing zswap with a pseudo block device that rejects all writes. I
> > > > 
> > > > One of difference between zswap and zram is asynchronous I/O support.
> > > 
> > > As zram is not writing to disk, how compelling is asynchronous IO? If
> > > zswap was backed by the pseudo device is there a measurable bottleneck?
> > 
> > Compression. It was really bottlneck point. I had an internal patch which
> > can make zram use various compressor, not only LZO.
> > The better good compressor was, the more bottlenck compressor was.
> > 
> 
> There are two issues there. One that different compression algorithms
> should be optional with tradeoffs on speed vs compression ratio. There is
> no reason why that couldn't be hacked into zswap.
> 
> The second is that only one page can be compressed at a time. That would
> require further work to allow the frontswap API to asynchronously compress
> pages. It would be a lot more heavy lifting but it is not impossible.

You're saying zswap can do everything to replace zram and I can say that zram
also can do everything to replace zswap, too and I'd like to say zram would be
better than zswap about writeback.

Current zswap writeback has a few issues.

First of all, why should writeback happen zswap layer as I said earlier?
What if someone try to configue swap layer hierachy with fast and slow devices
among in-memory, SSD, eMMC, harddisk, network storage?
In this case, priority-based round-robin method of swap layer isn't good model
for caching hierachy. It would be better to handle it in swap layer generally.
It's not an only zswap specific problem. If we solve it in swap layer,
zram would be enough. 

Another disadvntage is that zswap is decompressing a page right before writeback.
and write one-by-one page. But zram can implement writing out it with zpage unit,
batching, sequentially if it has indirect layer to handle V2P layer which could
translate virtual swapoff to physical swapoff because physical swapoff could be
allocated right before write happening. In addtion to that, V2P layer can support
zpage compaction for mitigating the fragementation problem of zsmalloc.

> 
> > > However, I believe that the promotion will lead to zram and zswap diverging
> > > further from each other, both implementing similar functionality and
> > > ultimately cause greater maintenance headaches. There is a path that makes
> > > zswap a functional replacement for zram and I've seen no good reason why
> > > that path was not taken. Zram cannot be a functional replacment for zswap
> > > as there is no obvious sane way writeback could be implemented. Continuing
> > 
> > Then, do you think current zswap's writeback is sane way?
> 
> No, it's clunky as hell and the layering between zswap and zbud is twisty
> (e.g. zswap store -> zbud reclaim -> zswap writeback wtf?). I believe it used
> to be a lot worse but was ironed out a bit in preparation for merging. As
> bad as it is, general workloads cannot just consume unreclaimable pages with
> compressed data and writeback should be optionally handled at the very least.
> 
> How zswap currently implements it could be a whole lot better. It's silly
> that it is the allocator the directly performs synchronous writeback
> one page at a time because that will means the world stalls when zswap
> fills. On larger machines that is just going to be brick wall and considering
> that zswap was intended for virtualisation it is particularly hilarious.
> I think I brought up its stalling behaviour during review when it was being
> merged. It would have been preferable if writeback could be initiated in
> batches and then waited on at the very least. It's worse that it uses
> _swap_writepage directly instead of going through a writepage ops. It
> would have been better if zbud pages existed on the LRU and written back
> with an address space ops and properly handled asynchonous writeback.
> 
> Zswap could be massively improved, there is no denying that. I've seen no
> follow-up patches since which is a bit worrying but I'm not losing sleep
> over it.
> 
> Zram does not even try to do anything like this and from your description
> of the embedded use case there is no intention of ever trying.

Yes. Because there was no such requirement for zram but it could be doable
and even better as I said. And another reason I didn't try is zswap had a plan
to support writeback and We(I, Seth, Dan) didn't thought zswap will replace zram.
That's why I helped zswap merging.

Okay, you might disagree all points I said above and insist on that zswap
must include zram functionality and discard zram.
If everybody really want to unify zram and zswap, I can do it but I think
it should be based on zram. As I said, zram can support frontswap and
writeback via borrowing all code from zswap/zbud so that zram doesn't break
anything and it's more flexible.

1) zram-blk
2) zram-swap with block device, which can be enhanced for writeback batch,
   sequential without decompressing.
3) zswap with frontswap.
4) If VM start to consider multiple swap-cache hierachy, we can remove 3.

Why do you want to replace old-stable/has-many-users/well-maintained feature
with new-fresh thing? It is never reasonable to me.

> 
> > I didn't raise an issue because I didn't want to be a blocker when zswap was
> > promoted. Actually, I didn't like that way because I thought swap-writeback
> > feature should be implemented by VM itself rather than some hooked driver
> > internal logic.
> 
> You could also have brought it up any time since or pushed for it to be
> implemented with the view to making zswap functionally equivalent to
> zram.

Then, Are you okay if I resend zram promotion patches with adding frontswap
stuff to replace zswap? I don't want it but if everybody want, I will do.

> 
> > VM alreay has a lot information so it would handle multipe
> > heterogenous swap more efficenlty like cache hierachy without LRU inversing.
> > It could solve current zswap LRU inversing problem generally and help others
> > who want to configure multiple swap system as well as zram.
> > 
> > > to diverge will ultimately bite someone in the ass.
> > 
> > Mel, current zram situation is following as.
> > 
> > 1) There are a lot users in the world.
> > 2) So, many valuable contributions have been in there.
> > 2) The new feature development of zram had stalled because Greg asserted
> >    he doesn't accept new feature until promote will be done and recently,
> >    he said he will remove zram in staging if anybody doesn't try to promote
> > 3) You are saying zram shouldn't be promote. IOW, zram should go away.
> > 
> > Right? Then, What should we zram developers do?
> 
> I've already explained, more than once going at least as far back as
> April, how I thought zswap could be made functionally identical to zram
> and improved.
> 
> > What's next step for zram which is really perfect for embedded system?
> > We should really lose a chance to enhance zram although fresh zswap
> > couldn't replace old zram?
> > 
> > Mel, please consider embedded world although they are very little voice
> > in this core subsystem.
> > 
> 
> I already said I recognise it has a large number of users in the field
> and users count a lot more than me complaining. If it gets promoted then
> I expect it will be on those grounds.
> 
> My position is that I think it's a bad idea because it is clear there is no
> plan or intention of ever brining zram and zswap together. Instead we are
> to have two features providing similar functionality with zram diverging
> further from zswap.  Ultimately I believe this will increase maintenance
> headaches. It'll get even more entertaining if/when someone ever tries
> to reimplement zcache although since Dan left I do not believe anyone is
> planning to try. I will not be acking this series but there many be enough
> developers that are actually willing to maintain a duel zram/zswap mess
> to make it happen anyway.

Okay, My position is following as.

1) I'd like to stick compressed block device because writeback should be
   hanled in VM layer rather than zswap layer to solve common problem
   in general.

2) If you disagree with that and want to unify zswap and zram,
   I'd like to based on zram so that zram can implement frontswap API and
   writeback through borrowing from zswap. Because zram has long
   history/stable/many contributors/many users compared to zswap.
   If 1) works sometime in future, we can remove zswap internal writeback totally.
   If 1) don't work, we can enhance writeback more efficiently like I mentioned
   without frontswap.
   I admit it should be done before zswap is merged but as I already said
   at that time, we(I, Seth, Dan) never thought zswap could replace zram
   totally. But I think it's not too late.

3) I admit zswap can implement pusedo block device through borrowing many code
   from zram so that it can support zram without breaking. But it might lose
   our git history which is one of valuable from getting staging.

Andrew, please put your opinion and decision.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
