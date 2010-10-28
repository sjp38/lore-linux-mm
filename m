Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 78A9A8D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 16:11:24 -0400 (EDT)
Date: Thu, 28 Oct 2010 13:10:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
Message-Id: <20101028131029.ee0aadc0.akpm@linux-foundation.org>
In-Reply-To: <20101028191523.GA14972@google.com>
References: <20101028191523.GA14972@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010 12:15:23 -0700
Mandeep Singh Baines <msb@chromium.org> wrote:

> On ChromiumOS, we do not use swap.

Well that's bad.  Why not?

> When memory is low, the only way to
> free memory is to reclaim pages from the file list. This results in a
> lot of thrashing under low memory conditions. We see the system become
> unresponsive for minutes before it eventually OOMs. We also see very
> slow browser tab switching under low memory. Instead of an unresponsive
> system, we'd really like the kernel to OOM as soon as it starts to
> thrash. If it can't keep the working set in memory, then OOM.
> Losing one of many tabs is a better behaviour for the user than an
> unresponsive system.
> 
> This patch create a new sysctl, min_filelist_kbytes, which disables reclaim
> of file-backed pages when when there are less than min_filelist_bytes worth
> of such pages in the cache. This tunable is handy for low memory systems
> using solid-state storage where interactive response is more important
> than not OOMing.
> 
> With this patch and min_filelist_kbytes set to 50000, I see very little
> block layer activity during low memory. The system stays responsive under
> low memory and browser tab switching is fast. Eventually, a process a gets
> killed by OOM. Without this patch, the system gets wedged for minutes
> before it eventually OOMs. Below is the vmstat output from my test runs.
> 
> BEFORE (notice the high bi and wa, also how long it takes to OOM):

That's an interesting result.

Having the machine "wedged for minutes" thrashing away paging
executable text is pretty bad behaviour.  I wonder how to fix it. 
Perhaps simply declaring oom at an earlier stage.

Your patch is certainly simple enough but a bit sad.  It says "the VM
gets this wrong, so lets just disable it all".  And thereby reduces the
motivation to fix it for real.

But the patch definitely improves the situation in real-world
situations and there's a case to be made that it should be available at
least as an interim thing until the VM gets fixed for real.  Which
means that the /proc tunable might disappear again (or become a no-op)
some time in the future.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
