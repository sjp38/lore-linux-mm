Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 2955C6B0036
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 13:41:00 -0400 (EDT)
Date: Wed, 14 Aug 2013 18:40:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
Message-ID: <20130814174050.GN2296@suse.de>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1376459736-7384-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Aug 14, 2013 at 02:55:31PM +0900, Minchan Kim wrote:
> It's 6th trial of zram/zsmalloc promotion.
> [patch 5, zram: promote zram from staging] explains why we need zram.
> 
> Main reason to block promotion is there was no review of zsmalloc part
> while Jens already acked zram part.
> 
> At that time, zsmalloc was used for zram, zcache and zswap so everybody
> wanted to make it general and at last, Mel reviewed it.
> Most of review was related to zswap dumping mechanism which can pageout
> compressed page into swap in runtime and zswap gives up using zsmalloc
> and invented a new wheel, zbud. Other reviews were not major.
> http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
> 

zsmalloc has unpredictable performance characteristics when reclaiming
a single page when it was used to back zswap. I felt the unpredictable
performance characteristics would make it close to impossible to support
for normal server workloads. It would appear to work well until there were
massive stalls and I do not think this was ever properly investigated. At one
point I would have been happy if zsmalloc could be tuned to store only store
2 compressed pages  per physical page but cannot remember why that proposal
was never implemented (or if it was and I missed it or forgot). I expected
it would change over time but there were no follow-ups that I'm aware of.

I do not believe this is a problem for zram as such because I do not
think it ever writes back to disk and is immune from the unpredictable
performance characteristics problem. The problem for zram using zsmalloc
is OOM killing. If it's used for swap then there is no guarantee that
killing processes frees memory and that could result in an OOM storm.
Of course there is no guarantee that memory is freed with zbud either but
you are guaranteed that freeing 50%+1 of the compressed pages will free a
single physical page. The characteristics for zsmalloc are much more severe.
This might be managable in an applicance with very careful control of the
applications that are running but not for general servers or desktops.

If it's used for something like tmpfs then it becomes much worse. Normal
tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
sane configuration, lockups will be avoided and deleting a tmpfs file is
guaranteed to free memory. When zram is used to back tmpfs, there is no
guarantee that any memory is freed due to fragmentation of the compressed
pages. The only way to recover the memory may be to kill applications
holding tmpfs files open and then delete them which is fairly drastic
action in a normal server environment.

These are the sort of reason why I feel that zram has limited cases where
it is safe to use and zswap has a wider range of applications. At least
I would be very unhappy to try supporting zram in the field for normal
servers. zswap should be able to replace the functionality of zram+swap
by backing zswap with a pseudo block device that rejects all writes. I
do not know why this never happened but guess the zswap people never were
interested and the zram people never tried. Why was the pseudo device
to avoid writebacks never implemented? Why was the underlying allocator
not made pluggable to optionally use zsmalloc when the user did not care
that it had terrible writeback characteristics?

zswap cannot replicate zram+tmpfs but I also think that such a configuration
is a bad idea anyway. As zram is already being deployed then it might get
promoted anyway but personally I think compressed memory continues to be
a tragic story.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
