Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id D6056828DF
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:32:59 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id s6so20220492obg.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:32:59 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id e7si9652859oeq.66.2016.02.25.22.32.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:32:58 -0800 (PST)
Received: by mail-oi0-x22e.google.com with SMTP id m82so56066112oif.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:32:58 -0800 (PST)
Date: Thu, 25 Feb 2016 22:32:54 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
In-Reply-To: <20160225092315.GD17573@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1602252219020.9793@eggly.anvils>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <20160203132718.GI6757@dhcp22.suse.cz> <alpine.LSU.2.11.1602241832160.15564@eggly.anvils> <20160225092315.GD17573@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Thu, 25 Feb 2016, Michal Hocko wrote:
> On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
> [...]
> > Boot with mem=1G (or boot your usual way, and do something to occupy
> > most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> > way to gobble up most of the memory, though it's not how I've done it).
> > 
> > Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> > kernel source tree into a tmpfs: size=2G is more than enough.
> > make defconfig there, then make -j20.
> > 
> > On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> > 
> > Except that you'll probably need to fiddle around with that j20,
> > it's true for my laptop but not for my workstation.  j20 just happens
> > to be what I've had there for years, that I now see breaking down
> > (I can lower to j6 to proceed, perhaps could go a bit higher,
> > but it still doesn't exercise swap very much).
> > 
> > This OOM detection rework significantly lowers the number of jobs
> > which can be run in parallel without being OOM-killed. 
> 
> This all smells like pre mature OOM because of a high order allocation
> (order-2 for fork) which Tetuo has seen already. Sergey Senozhatsky is

You're absolutely right, and I'm ashamed not to have noticed that, nor
your comments and patch earlier in this thread, before bothering you.
Order 2 they are.

> reporting order-2 OOMs as well. It is true that what we have in the
> mmomt right now is quite fragile if all order-N+ are completely
> depleted. That was the case for both Tetsuo and Sergey. I have tried to
> mitigate this at least to some degree by
> http://lkml.kernel.org/r/20160204133905.GB14425@dhcp22.suse.cz (below
> with the full changelog) but I haven't heard back whether it helped
> so I haven't posted the official patch yet.
> 
> I also suspect that something is not quite right with the compaction and
> it gives up too early even though we have quite a lot reclaimable pages.
> I do not have any numbers for that because I didn't have a load to
> reproduce this problem yet. I will try your setup and see what I can do

Thanks a lot.

> about that. It would be great if you could give the patch below a try
> and see if it helps.
> ---
> From d09de26cee148b4d8c486943b4e8f3bd7ad6f4be Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 4 Feb 2016 14:56:59 +0100
> Subject: [PATCH] mm, oom: protect !costly allocations some more
> 
> should_reclaim_retry will give up retries for higher order allocations
> if none of the eligible zones has any requested or higher order pages
> available even if we pass the watermak check for order-0. This is done
> because there is no guarantee that the reclaimable and currently free
> pages will form the required order.
> 
> This can, however, lead to situations were the high-order request (e.g.
> order-2 required for the stack allocation during fork) will trigger
> OOM too early - e.g. after the first reclaim/compaction round. Such a
> system would have to be highly fragmented and the OOM killer is just a
> matter of time but let's stick to our MAX_RECLAIM_RETRIES for the high
> order and not costly requests to make sure we do not fail prematurely.
> 
> This also means that we do not reset no_progress_loops at the
> __alloc_pages_slowpath for high order allocations to guarantee a bounded
> number of retries.
> 
> Longterm it would be much better to communicate with the compaction
> and retry only if the compaction considers it meaningfull.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

It didn't really help, I'm afraid: it reduces the actual number of OOM
kills which occur before the job is terminated, but doesn't stop the
job from being terminated very soon.

I also tried Hillf's patch (separately) too, but as you expected,
it didn't seem to make any difference.

(I haven't tried on the PowerMac G5 yet, since that's busy with
other testing; but expect that to tell the same story.)

Hugh

> ---
>  mm/page_alloc.c | 20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 269a04f20927..f05aca36469b 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3106,6 +3106,18 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
>  		}
>  	}
>  
> +	/*
> +	 * OK, so the watermak check has failed. Make sure we do all the
> +	 * retries for !costly high order requests and hope that multiple
> +	 * runs of compaction will generate some high order ones for us.
> +	 *
> +	 * XXX: ideally we should teach the compaction to try _really_ hard
> +	 * if we are in the retry path - something like priority 0 for the
> +	 * reclaim
> +	 */
> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER)
> +		return true;
> +
>  	return false;
>  }
>  
> @@ -3281,11 +3293,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  		goto noretry;
>  
>  	/*
> -	 * Costly allocations might have made a progress but this doesn't mean
> -	 * their order will become available due to high fragmentation so do
> -	 * not reset the no progress counter for them
> +	 * High order allocations might have made a progress but this doesn't
> +	 * mean their order will become available due to high fragmentation so
> +	 * do not reset the no progress counter for them
>  	 */
> -	if (did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER)
> +	if (did_some_progress && !order)
>  		no_progress_loops = 0;
>  	else
>  		no_progress_loops++;
> -- 
> 2.7.0
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
