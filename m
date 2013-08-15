Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 355BF6B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 13:12:58 -0400 (EDT)
Date: Thu, 15 Aug 2013 18:12:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130815171250.GA2296@suse.de>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <20130814174050.GN2296@suse.de>
 <20130814185820.GA2753@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130814185820.GA2753@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, Aug 15, 2013 at 03:58:20AM +0900, Minchan Kim wrote:
> > <SNIP>
> >
> > I do not believe this is a problem for zram as such because I do not
> > think it ever writes back to disk and is immune from the unpredictable
> > performance characteristics problem. The problem for zram using zsmalloc
> > is OOM killing. If it's used for swap then there is no guarantee that
> > killing processes frees memory and that could result in an OOM storm.
> > Of course there is no guarantee that memory is freed with zbud either but
> > you are guaranteed that freeing 50%+1 of the compressed pages will free a
> > single physical page. The characteristics for zsmalloc are much more severe.
> > This might be managable in an applicance with very careful control of the
> > applications that are running but not for general servers or desktops.
> 
> Fair enough but let's think of current usecase for zram.
> As I said in description, most of user for zram are embedded products.
> So, most of them has no swap storage and hate OOM kill because OOM is
> already very very slow path so system slow response is really thing
> we want to avoid. We prefer early process kill to slow response.
> That's why custom low memory killer/notifier is popular in embedded side.
> so actually, OOM storm problem shouldn't be a big problem under
> well-control limited system. 
> 

Which zswap could also do if

a) it had a pseudo block device that failed all writes
b) zsmalloc was pluggable

I recognise this sucks because zram is already in the field but if zram
is promoted then zram and zswap will continue to diverge further with no
reconcilation in sight.

Part of the point of using zswap was that potentially zcache could be
implemented on top of it and so all file cache could be stored compressed
in memory. AFAIK, it's not possible to do the same thing for zram because
of the lack of writeback capabilities. Maybe it could be done if zram
could be configured to write to an underlying storage device but it may
be very clumsy to configure. I don't know as I never investigated it and
to be honest, I'm struggling to remember how I got involved anywhere near
zswap/zcache/zram/zwtf in the first place.

> > If it's used for something like tmpfs then it becomes much worse. Normal
> > tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
> > sane configuration, lockups will be avoided and deleting a tmpfs file is
> > guaranteed to free memory. When zram is used to back tmpfs, there is no
> > guarantee that any memory is freed due to fragmentation of the compressed
> > pages. The only way to recover the memory may be to kill applications
> > holding tmpfs files open and then delete them which is fairly drastic
> > action in a normal server environment.
> 
> Indeed.
> Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
> handle instead of pure pointer so it could migrate some zpages to somewhere
> to pack in. Then, it could help above problem and OOM storm problem.
> Anyway, it's a totally new feature and requires many changes and experiement.
> Although we don't have such feature, zram is still good for many people.
> 

And is zsmalloc was pluggable for zswap then it would also benefit.

> > These are the sort of reason why I feel that zram has limited cases where
> > it is safe to use and zswap has a wider range of applications. At least
> > I would be very unhappy to try supporting zram in the field for normal
> > servers. zswap should be able to replace the functionality of zram+swap
> > by backing zswap with a pseudo block device that rejects all writes. I
> 
> One of difference between zswap and zram is asynchronous I/O support.

As zram is not writing to disk, how compelling is asynchronous IO? If
zswap was backed by the pseudo device is there a measurable bottleneck?

> I guess frontswap is synchronous by semantic while zram could support
> asynchronous I/O.
> 
> > do not know why this never happened but guess the zswap people never were
> > interested and the zram people never tried. Why was the pseudo device
> > to avoid writebacks never implemented? Why was the underlying allocator
> > not made pluggable to optionally use zsmalloc when the user did not care
> > that it had terrible writeback characteristics?
> 
> I remember you suggested to make zsmalloc with pluggable for zswap.
> But I don't know why zswap people didn't implement it.
> 
> > 
> > zswap cannot replicate zram+tmpfs but I also think that such a configuration
> > is a bad idea anyway. As zram is already being deployed then it might get
> 
> It seems your big concern of zsmalloc is fragmentaion so if zsmalloc can
> support compaction, it would mitigate the concern.
> 

Even if it supported zsmalloc I would still wonder why zswap is not using
it as a pluggable option :(

> > promoted anyway but personally I think compressed memory continues to be
> 
> I admit zram might have limitations but it has helped lots of people.
> It's not an imaginary scenario.
> 

I know.

> Please, let's not do get out of zram from kernel tree and stall it on staging
> forever with preventing new features. 
> Please, let's promote, expose it to more potential users, receive more
> complains from them, recruit more contributors and let's enhance.
> 

As this is already used heavily in the field and I am not responsible
for maintaining it I am not going to object to it being promoted. I can
always push that it be disabled in distribution configs as it is not
suitable for general workloads for reason already discussed.

However, I believe that the promotion will lead to zram and zswap diverging
further from each other, both implementing similar functionality and
ultimately cause greater maintenance headaches. There is a path that makes
zswap a functional replacement for zram and I've seen no good reason why
that path was not taken. Zram cannot be a functional replacment for zswap
as there is no obvious sane way writeback could be implemented. Continuing
to diverge will ultimately bite someone in the ass.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
