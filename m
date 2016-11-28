Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFB716B0069
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 19:41:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so193107162pfx.1
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 16:41:54 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id k11si20263532pgp.150.2016.11.27.16.41.53
        for <linux-mm@kvack.org>;
        Sun, 27 Nov 2016 16:41:53 -0800 (PST)
Date: Mon, 28 Nov 2016 09:41:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 1/3] mm: support anonymous stable page
Message-ID: <20161128004152.GA30427@bbox>
References: <1480062914-25556-1-git-send-email-minchan@kernel.org>
 <1480062914-25556-2-git-send-email-minchan@kernel.org>
 <20161127131910.GB4919@tigerII>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161127131910.GB4919@tigerII>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, "Darrick J . Wong" <darrick.wong@oracle.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hi Sergey,

I'm going on a long vacation so forgive if I respond slowly. :)

On Sun, Nov 27, 2016 at 10:19:10PM +0900, Sergey Senozhatsky wrote:
> Hi,
> 
> On (11/25/16 17:35), Minchan Kim wrote:
> [..]
> > Unfortunately, zram has used per-cpu stream feature from v4.7.
> > It aims for increasing cache hit ratio of scratch buffer for
> > compressing. Downside of that approach is that zram should ask
> > memory space for compressed page in per-cpu context which requires
> > stricted gfp flag which could be failed. If so, it retries to
> > allocate memory space out of per-cpu context so it could get memory
> > this time and compress the data again, copies it to the memory space.
> > 
> > In this scenario, zram assumes the data should never be changed
> > but it is not true unless stable page supports. So, If the data is
> > changed under us, zram can make buffer overrun because second
> > compression size could be bigger than one we got in previous trial
> > and blindly, copy bigger size object to smaller buffer which is
> > buffer overrun. The overrun breaks zsmalloc free object chaining
> > so system goes crash like above.
> 
> very interesting find! didn't see this coming.
> 
> > Unfortunately, reuse_swap_page should be atomic so that we cannot wait on
> > writeback in there so the approach in this patch is simply return false if
> > we found it needs stable page.  Although it increases memory footprint
> > temporarily, it happens rarely and it should be reclaimed easily althoug
> > it happened.  Also, It would be better than waiting of IO completion,
> > which is critial path for application latency.
> 
> wondering - how many pages can it hold? we are in low memory, that's why we
> failed to zsmalloc in fast path, so how likely this to worsen memory pressure?

Actually, I don't have real number to say but a thing I can say surely is
it's really hard to meet in normal stress test I have done until now.
That's why it takes a long time to find(i.e., I could encounter the bug
once two days). But once I understood the problem, I can reproduce the
problem in 15 minutes.

About memory pressure, my testing was already severe memory pressure(i.e.,
many memory failure and frequent OOM kill) so it doesn't make any
meaningful difference before and after.

> just asking. in async zram the window between zram_rw_page() and actual
> write of a page even bigger, isn't it?

Yes. That's why I found the problem with that feature enabled. Lucky. ;)

> 
> we *probably* and *may be* can try handle it in zram:
> 
> -- store the previous clen before re-compression
> -- check if new clen > saved_clen and if it is - we can't use previously
>    allocate handle and need to allocate a new one again. if it's less or
>    equal than the saved one - store the object (wasting some space,
>    yes. but we are in low mem).

It was my first attempt but changed mind.
It can save against crash but broken data could go to the disk
(i.e., zram). If someone want to read block directly(e.g.,
open /dev/zram0; read /dev/zram or DIO), it cannot read the data
forever until someone writes some stable data into that sectors.
Instead, he will see many decompression failure message.
It's weired.

I believe stable page problem should be solved by generic layer,
not driver itself.

> 
> -- we, may be, also can try harder in zsmalloc. once we detected that
>    zsmllaoc has failed, then we can declare it as an emergency and
>    store objects of size X in higher classes (assuming that there is a
>    bigger size class available with allocated and unused object).

It cannot solve the problem I mentioned above, either and I don't want
to make zram complicated to solve that problem. :(



> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
