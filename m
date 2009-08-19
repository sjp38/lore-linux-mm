Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1B1A16B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 00:52:03 -0400 (EDT)
Received: by pxi15 with SMTP id 15so2282666pxi.23
        for <linux-mm@kvack.org>; Tue, 18 Aug 2009 21:52:09 -0700 (PDT)
Date: Wed, 19 Aug 2009 13:51:05 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: abnormal OOM killer message
Message-Id: <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
In-Reply-To: <4A8B7508.4040001@vflare.org>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	<20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
	<4A8B7508.4040001@vflare.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: ngupta@vflare.org
Cc: Minchan Kim <minchan.kim@gmail.com>, =?UTF-8?B?7Jqw7Lap6riw?= <chungki.woo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>


On Wed, 19 Aug 2009 09:14:08 +0530
Nitin Gupta <ngupta@vflare.org> wrote:

> On 08/19/2009 08:14 AM, Minchan Kim wrote:
> > On Wed, 19 Aug 2009 10:41:51 +0900
> > i??i?(C)e,?<chungki.woo@gmail.com>  wrote:
> >
> >> Hi all~
> >> I have got a log message with OOM below. I don't know why this
> >> phenomenon was happened.
> >> When direct reclaim routine(try_to_free_pages) in __alloc_pages which
> >> allocates kernel memory was failed,
> >> one last chance is given to allocate memory before OOM routine is executed.
> >> And that time, allocator uses ALLOC_WMARK_HIGH to limit watermark.
> >> Then, zone_watermark_ok function test this value with current memory
> >> state and decide 'can allocate' or 'cannot allocate'.
> >>
> >> Here is some kernel source code in __alloc_pages function to understand easily.
> >> Kernel version is 2.6.18 for arm11. Memory size is 32Mbyte. And I use
> >> compcache(0.5.2).
> 
> <snip>
> 
> >>
> >> In my case, you can see free pages(6804KB) is much more higher than
> >> high watermark value(1084KB) in OOM message.
> >> And order of allocating is also zero.(order=0)
> >> In buddy system, the number of 4kbyte page is 867.
> >> So, I think OOM can't be happend.
> >>
> >
> > Yes. I think so.
> >
> > In that case, even we can also avoid zone defensive algorithm.
> >
> >> How do you think about this?
> >> Is this side effect of compcache?
> >
> 
> compcache can be storing lot of stale data and this memory space cannot be
> reclaimed (unless overwritten by some other swap data). This is because

stale data. It seems related ARMv6. 
I think Chungki's CPU is ARMv6. 

> compcache does not know when a swap slot has been freed and hence does not know 
> when its safe to free corresponding memory. You can check current memory usage 
> with /proc/ramzswap (see MemUsedTotal).
> 

Let me have a question. 
Now the system has 79M as total swap. 
It's bigger than system memory size. 
Is it possible in compcache?
Can we believe the number?

> BTW, with compcache-0.6 there is an experimental kernel patch that gets rid of 
> all this stale data:
> http://patchwork.kernel.org/patch/41083/
> 
> However, this compcache version needs at least kernel 2.6.28. This version also 
> fixes all known problems on ARM. compcache-0.5.3 or earlier is known to crash on 
> ARM (see: http://code.google.com/p/compcache/issues/detail?id=33).
>

Chungki. Is it reproducible easily ?
Could you try it with compcache-0.6. 
As Nitin said, it seems to solve cache aliasing problem. 

> Thanks,
> Nitin


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
