Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 980FB9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 19:15:39 -0400 (EDT)
Date: Thu, 22 Sep 2011 16:15:23 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [PATCH 6/8] kstaled: rate limit pages scanned per second.
Message-Id: <20110922161523.f5b2193f.akpm@google.com>
In-Reply-To: <1316230753-8693-7-git-send-email-walken@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-7-git-send-email-walken@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 16 Sep 2011 20:39:11 -0700
Michel Lespinasse <walken@google.com> wrote:

> Scan some number of pages from each node every second, instead of trying to
> scan the entime memory at once and being idle for the rest of the configured
> interval.

Well...  why?  The amount of work done per scan interval is the same
(actually, it will be slightly increased due to cache evictions).

I think we should see a good explanation of what observed problem this
hackery^Wtweak is trying to solve.  Once that is revealed, we can
compare the proposed solution with one based on thread policy/priority
(for example).

>
> ....
>
> @@ -5788,21 +5800,60 @@ static int kstaled(void *dummy)
>  		 */
>  		BUG_ON(scan_seconds <= 0);
>  
> -		for_each_mem_cgroup_all(mem)
> -			memset(&mem->idle_scan_stats, 0,
> -			       sizeof(mem->idle_scan_stats));
> +		earlier = jiffies;
>  
> +		scan_done = true;
>  		for_each_node_state(nid, N_HIGH_MEMORY)
> -			kstaled_scan_node(NODE_DATA(nid));
> +			scan_done &= kstaled_scan_node(NODE_DATA(nid),
> +						       scan_seconds, reset);
> +
> +		if (scan_done) {
> +			struct mem_cgroup *mem;
> +
> +			for_each_mem_cgroup_all(mem) {
> +				write_seqcount_begin(&mem->idle_page_stats_lock);
> +				mem->idle_page_stats = mem->idle_scan_stats;
> +				mem->idle_page_scans++;
> +				write_seqcount_end(&mem->idle_page_stats_lock);
> +				memset(&mem->idle_scan_stats, 0,
> +				       sizeof(mem->idle_scan_stats));
> +			}
> +		}
>  
> -		for_each_mem_cgroup_all(mem) {
> -			write_seqcount_begin(&mem->idle_page_stats_lock);
> -			mem->idle_page_stats = mem->idle_scan_stats;
> -			mem->idle_page_scans++;
> -			write_seqcount_end(&mem->idle_page_stats_lock);
> +		delta = jiffies - earlier;
> +		if (delta < HZ / 2) {
> +			delayed = 0;
> +			schedule_timeout_interruptible(HZ - delta);
> +		} else {
> +			/*
> +			 * Emergency throttle if we're taking too long.
> +			 * We are supposed to scan an entire slice in 1 second.
> +			 * If we keep taking longer for 10 consecutive times,
> +			 * scale back our scan_seconds.
> +			 *
> +			 * If someone changed kstaled_scan_seconds while we
> +			 * were running, hope they know what they're doing and
> +			 * assume they've eliminated any delays.
> +			 */
> +			bool updated = false;
> +			spin_lock(&kstaled_scan_seconds_lock);
> +			if (scan_seconds != kstaled_scan_seconds)
> +				delayed = 0;
> +			else if (++delayed == 10) {
> +				delayed = 0;
> +				scan_seconds *= 2;
> +				kstaled_scan_seconds = scan_seconds;
> +				updated = true;
> +			}
> +			spin_unlock(&kstaled_scan_seconds_lock);
> +			if (updated)
> +				pr_warning("kstaled taking too long, "
> +					   "scan_seconds now %d\n",
> +					   scan_seconds);
> +			schedule_timeout_interruptible(HZ / 2);

This is all rather unpleasing.

>  
> -		schedule_timeout_interruptible(scan_seconds * HZ);
> +		reset = scan_done;
>  	}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
