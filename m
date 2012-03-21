Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0FBDC6B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 20:43:54 -0400 (EDT)
Received: by dadv6 with SMTP id v6so937085dad.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 17:43:53 -0700 (PDT)
Date: Wed, 21 Mar 2012 09:43:44 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: use global_dirty_limit in throttle_vm_writeout()
Message-ID: <20120321004344.GC14584@barrios>
References: <20120302061451.GA6468@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120302061451.GA6468@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Wu,

Sorry for late response.
I have a question.

On Fri, Mar 02, 2012 at 02:14:51PM +0800, Fengguang Wu wrote:
> When starting a memory hog task, a desktop box w/o swap is found to go
> unresponsive for a long time. It's solely caused by lots of congestion
> waits in throttle_vm_writeout():
> 
>  gnome-system-mo-4201 553.073384: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
>  gnome-system-mo-4201 553.073386: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
>            gtali-4237 553.080377: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
>            gtali-4237 553.080378: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
>             Xorg-3483 553.103375: congestion_wait: throttle_vm_writeout+0x70/0x7f shrink_mem_cgroup_zone+0x48f/0x4a1
>             Xorg-3483 553.103377: writeback_congestion_wait: usec_timeout=100000 usec_delayed=100000
> 
> The root cause is, the dirty threshold is knocked down a lot by the
> memory hog task. Fixed by using global_dirty_limit which decreases

AFAIUC, memory hog task, you mean it consumes lots of anon pages, not file-backed pages.
So global_dirty_limits would get small available_memory by global_reclaimable_pages
so that it ends up dirty threshold is knocked down.

Could you confirm my understanding?

Thanks.

> gradually on such events and can guarantee we stay above (the also
> decreasing) nr_dirty in the progress of following down to the new
> dirty threshold.
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  mm/page-writeback.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- linux.orig/mm/page-writeback.c	2012-03-02 14:05:01.633763187 +0800
> +++ linux/mm/page-writeback.c	2012-03-02 14:11:52.929772962 +0800
> @@ -1472,6 +1472,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
>  
>          for ( ; ; ) {
>  		global_dirty_limits(&background_thresh, &dirty_thresh);
> +		dirty_thresh = hard_dirty_limit(dirty_thresh);
>  
>                  /*
>                   * Boost the allowable dirty threshold a bit for page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
