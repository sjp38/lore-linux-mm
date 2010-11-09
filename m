Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DF8A96B00B8
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 21:49:48 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA92njff008090
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 11:49:46 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E55545DE7B
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:49:45 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EDD6B45DE79
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:49:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D4AB81DB8037
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:49:44 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D9681DB803B
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:49:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for protecting the working set
In-Reply-To: <4CD2D18C.9080407@redhat.com>
References: <20101103224055.GC19646@google.com> <4CD2D18C.9080407@redhat.com>
Message-Id: <20101109114610.BC39.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  9 Nov 2010 11:49:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

> On 11/03/2010 06:40 PM, Mandeep Singh Baines wrote:
> 
> > I've created a patch which takes a slightly different approach.
> > Instead of limiting how fast pages get reclaimed, the patch limits
> > how fast the active list gets scanned. This should result in the
> > active list being a better measure of the working set. I've seen
> > fairly good results with this patch and a scan inteval of 1
> > centisecond. I see no thrashing when the scan interval is non-zero.
> >
> > I've made it a tunable because I don't know what to set the scan
> > interval. The final patch could set the value based on HZ and some
> > other system parameters. Maybe relate it to sched_period?
> 
> I like your approach. For file pages it looks like it
> could work fine, since new pages always start on the
> inactive file list.
> 
> However, for anonymous pages I could see your patch
> leading to problems, because all anonymous pages start
> on the active list.  With a scan interval of 1
> centiseconds, that means there would be a limit of 3200
> pages, or 12MB of anonymous memory that can be moved to
> the inactive list a second.
> 
> I have seen systems with single SATA disks push out
> several times that to swap per second, which matters
> when someone starts up a program that is just too big
> to fit in memory and requires that something is pushed
> out.
> 
> That would reduce the size of the inactive list to
> zero, reducing our page replacement to a slow FIFO
> at best, causing false OOM kills at worst.
> 
> Staying with a default of 0 would of course not do
> anything, which would make merging the code not too
> useful.
> 
> I believe we absolutely need to preserve the ability
> to evict pages quickly, when new pages are brought
> into memory or allocated quickly.
> 
> However, speed limits are probably a very good idea
> once a cache has been reduced to a smaller size, or
> when most IO bypasses the reclaim-speed-limited cache.

Yeah.

But I doubt fixed rate limit is good thing. When playing movie case
(aka streaming I/O case), We don't want any throttle. I think.
Also, I don't like jiffies dependency. CPU hardware improvement naturally
will break such heuristics.


btw, now congestion_wait() already has jiffies dependency. but we should
kill such strange timeout eventually. I think.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
