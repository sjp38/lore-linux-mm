Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 641F36B02A5
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 21:12:25 -0500 (EST)
Subject: Re: [PATCH] mm: Fix kswapd livelock on single core, no preempt
 kernel
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <1323798271-1452-1-git-send-email-mikew@google.com>
References: <1323798271-1452-1-git-send-email-mikew@google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Dec 2011 10:24:50 +0800
Message-ID: <1323829490.22361.395.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Waychison <mikew@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickens <hughd@google.com>, Greg Thelen <gthelen@google.com>

On Wed, 2011-12-14 at 01:44 +0800, Mike Waychison wrote:
> On a single core system with kernel preemption disabled, it is possible
> for the memory system to be so taxed that kswapd cannot make any forward
> progress.  This can happen when most of system memory is tied up as
> anonymous memory without swap enabled, causing kswapd to consistently
> fail to achieve its watermark goals.  In turn, sleeping_prematurely()
> will consistently return true and kswapd_try_to_sleep() to never invoke
> schedule().  This causes the kswapd thread to stay on the CPU in
> perpetuity and keeps other threads from processing oom-kills to reclaim
> memory.
> 
> The cond_resched() instance in balance_pgdat() is never called as the
> loop that iterates from DEF_PRIORITY down to 0 will always set
> all_zones_ok to true, and not set it to false once we've passed
> DEF_PRIORITY as zones that are marked ->all_unreclaimable are not
> considered in the "all_zones_ok" evaluation.
> 
> This change modifies kswapd_try_to_sleep to ensure that we enter
> scheduler at least once per invocation if needed.  This allows kswapd to
> get off the CPU and allows other threads to die off from the OOM killer
> (freeing memory that is otherwise unavailable in the process).
your description suggests zones with all_unreclaimable set. but in this
case sleeping_prematurely() will return false instead of true, kswapd
will do sleep then. is there anything I missed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
