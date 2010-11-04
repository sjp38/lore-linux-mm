Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 825206B00C5
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 11:31:40 -0400 (EDT)
Message-ID: <4CD2D18C.9080407@redhat.com>
Date: Thu, 04 Nov 2010 11:30:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for protecting
 the working set
References: <20101028191523.GA14972@google.com> <20101101012322.605C.A69D9226@jp.fujitsu.com> <20101101182416.GB31189@google.com> <4CCF0BE3.2090700@redhat.com> <AANLkTi=src1L0gAFsogzCmejGOgg5uh=9O4Uw+ZmfBg4@mail.gmail.com> <4CCF8151.3010202@redhat.com> <20101103224055.GC19646@google.com>
In-Reply-To: <20101103224055.GC19646@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On 11/03/2010 06:40 PM, Mandeep Singh Baines wrote:

> I've created a patch which takes a slightly different approach.
> Instead of limiting how fast pages get reclaimed, the patch limits
> how fast the active list gets scanned. This should result in the
> active list being a better measure of the working set. I've seen
> fairly good results with this patch and a scan inteval of 1
> centisecond. I see no thrashing when the scan interval is non-zero.
>
> I've made it a tunable because I don't know what to set the scan
> interval. The final patch could set the value based on HZ and some
> other system parameters. Maybe relate it to sched_period?

I like your approach. For file pages it looks like it
could work fine, since new pages always start on the
inactive file list.

However, for anonymous pages I could see your patch
leading to problems, because all anonymous pages start
on the active list.  With a scan interval of 1
centiseconds, that means there would be a limit of 3200
pages, or 12MB of anonymous memory that can be moved to
the inactive list a second.

I have seen systems with single SATA disks push out
several times that to swap per second, which matters
when someone starts up a program that is just too big
to fit in memory and requires that something is pushed
out.

That would reduce the size of the inactive list to
zero, reducing our page replacement to a slow FIFO
at best, causing false OOM kills at worst.

Staying with a default of 0 would of course not do
anything, which would make merging the code not too
useful.

I believe we absolutely need to preserve the ability
to evict pages quickly, when new pages are brought
into memory or allocated quickly.

However, speed limits are probably a very good idea
once a cache has been reduced to a smaller size, or
when most IO bypasses the reclaim-speed-limited cache.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
