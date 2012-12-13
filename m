Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 9D4AD6B002B
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 13:17:41 -0500 (EST)
Message-ID: <50CA1B60.9000806@redhat.com>
Date: Thu, 13 Dec 2012 13:16:00 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RESEND] mm: Avoid possible deadlock caused by too_many_isolated()
References: <20121210024836.GA15821@localhost>
In-Reply-To: <20121210024836.GA15821@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Torsten Kaiser <just.for.lkml@googlemail.com>, NeilBrown <neilb@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Li Zefan <lizefan@huawei.com>, wuqixuan@huawei.com, zengweilin@huawei.com, shaoyafang@huawei.com

On 12/09/2012 09:48 PM, Fengguang Wu wrote:
> Neil find that if too_many_isolated() returns true while performing
> direct reclaim we can end up waiting for other threads to complete their
> direct reclaim.  If those threads are allowed to enter the FS or IO to
> free memory, but this thread is not, then it is possible that those
> threads will be waiting on this thread and so we get a circular
> deadlock.
>
> some task enters direct reclaim with GFP_KERNEL
>    => too_many_isolated() false
>      => vmscan and run into dirty pages
>        => pageout()
>          => take some FS lock
> 	  => fs/block code does GFP_NOIO allocation
> 	    => enter direct reclaim again
> 	      => too_many_isolated() true
> 		  => waiting for others to progress, however the other
> 		     tasks may be circular waiting for the FS lock..
>
> The fix is to let !__GFP_IO and !__GFP_FS direct reclaims enjoy higher
> priority than normal ones, by lowering the throttle threshold for the
> latter.
>
> Allowing ~1/8 isolated pages in normal is large enough. For example,
> for a 1GB LRU list, that's ~128MB isolated pages, or 1k blocked tasks
> (each isolates 32 4KB pages), or 64 blocked tasks per logical CPU
> (assuming 16 logical CPUs per NUMA node). So it's not likely some CPU
> goes idle waiting (when it could make progress) because of this limit:
> there are much more sleeping reclaim tasks than the number of CPU, so
> the task may well be blocked by some low level queue/lock anyway.
>
> Now !GFP_IOFS reclaims won't be waiting for GFP_IOFS reclaims to
> progress. They will be blocked only when there are too many concurrent
> !GFP_IOFS reclaims, however that's very unlikely because the IO-less
> direct reclaims is able to progress much more faster, and they won't
> deadlock each other. The threshold is raised high enough for them, so
> that there can be sufficient parallel progress of !GFP_IOFS reclaims.
>
> CC: Torsten Kaiser <just.for.lkml@googlemail.com>
> Tested-by: NeilBrown <neilb@suse.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
