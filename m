Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 75C186B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:58:31 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kq13so10359671pab.11
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 11:58:30 -0700 (PDT)
Date: Thu, 15 Aug 2013 03:58:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130814185820.GA2753@gmail.com>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
 <20130814174050.GN2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130814174050.GN2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Aug 14, 2013 at 06:40:51PM +0100, Mel Gorman wrote:
> On Wed, Aug 14, 2013 at 02:55:31PM +0900, Minchan Kim wrote:
> > It's 6th trial of zram/zsmalloc promotion.
> > [patch 5, zram: promote zram from staging] explains why we need zram.
> > 
> > Main reason to block promotion is there was no review of zsmalloc part
> > while Jens already acked zram part.
> > 
> > At that time, zsmalloc was used for zram, zcache and zswap so everybody
> > wanted to make it general and at last, Mel reviewed it.
> > Most of review was related to zswap dumping mechanism which can pageout
> > compressed page into swap in runtime and zswap gives up using zsmalloc
> > and invented a new wheel, zbud. Other reviews were not major.
> > http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
> > 
> 
> zsmalloc has unpredictable performance characteristics when reclaiming
> a single page when it was used to back zswap. I felt the unpredictable
> performance characteristics would make it close to impossible to support
> for normal server workloads. It would appear to work well until there were
> massive stalls and I do not think this was ever properly investigated. At one
> point I would have been happy if zsmalloc could be tuned to store only store
> 2 compressed pages  per physical page but cannot remember why that proposal
> was never implemented (or if it was and I missed it or forgot). I expected
> it would change over time but there were no follow-ups that I'm aware of.

I remember you said it in LSF/MM and zswap people didn't implement it.
I have no idea why they went that way.

> 
> I do not believe this is a problem for zram as such because I do not
> think it ever writes back to disk and is immune from the unpredictable
> performance characteristics problem. The problem for zram using zsmalloc
> is OOM killing. If it's used for swap then there is no guarantee that
> killing processes frees memory and that could result in an OOM storm.
> Of course there is no guarantee that memory is freed with zbud either but
> you are guaranteed that freeing 50%+1 of the compressed pages will free a
> single physical page. The characteristics for zsmalloc are much more severe.
> This might be managable in an applicance with very careful control of the
> applications that are running but not for general servers or desktops.

Fair enough but let's think of current usecase for zram.
As I said in description, most of user for zram are embedded products.
So, most of them has no swap storage and hate OOM kill because OOM is
already very very slow path so system slow response is really thing
we want to avoid. We prefer early process kill to slow response.
That's why custom low memory killer/notifier is popular in embedded side.
so actually, OOM storm problem shouldn't be a big problem under
well-control limited system. 

> 
> If it's used for something like tmpfs then it becomes much worse. Normal
> tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
> sane configuration, lockups will be avoided and deleting a tmpfs file is
> guaranteed to free memory. When zram is used to back tmpfs, there is no
> guarantee that any memory is freed due to fragmentation of the compressed
> pages. The only way to recover the memory may be to kill applications
> holding tmpfs files open and then delete them which is fairly drastic
> action in a normal server environment.

Indeed.
Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
handle instead of pure pointer so it could migrate some zpages to somewhere
to pack in. Then, it could help above problem and OOM storm problem.
Anyway, it's a totally new feature and requires many changes and experiement.
Although we don't have such feature, zram is still good for many people.

> 
> These are the sort of reason why I feel that zram has limited cases where
> it is safe to use and zswap has a wider range of applications. At least
> I would be very unhappy to try supporting zram in the field for normal
> servers. zswap should be able to replace the functionality of zram+swap
> by backing zswap with a pseudo block device that rejects all writes. I

One of difference between zswap and zram is asynchronous I/O support.
I guess frontswap is synchronous by semantic while zram could support
asynchronous I/O.

> do not know why this never happened but guess the zswap people never were
> interested and the zram people never tried. Why was the pseudo device
> to avoid writebacks never implemented? Why was the underlying allocator
> not made pluggable to optionally use zsmalloc when the user did not care
> that it had terrible writeback characteristics?

I remember you suggested to make zsmalloc with pluggable for zswap.
But I don't know why zswap people didn't implement it.

> 
> zswap cannot replicate zram+tmpfs but I also think that such a configuration
> is a bad idea anyway. As zram is already being deployed then it might get

It seems your big concern of zsmalloc is fragmentaion so if zsmalloc can
support compaction, it would mitigate the concern.

> promoted anyway but personally I think compressed memory continues to be

I admit zram might have limitations but it has helped lots of people.
It's not an imaginary scenario.

Please, let's not do get out of zram from kernel tree and stall it on staging
forever with preventing new features. 
Please, let's promote, expose it to more potential users, receive more
complains from them, recruit more contributors and let's enhance.

> a tragic story.
> 
> -- 
> Mel Gorman
> SUSE Labs
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
