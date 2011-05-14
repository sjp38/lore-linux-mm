Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id EE93E6B0012
	for <linux-mm@kvack.org>; Sat, 14 May 2011 04:34:53 -0400 (EDT)
Subject: Re: [PATCH 0/4] Reduce impact to overall system of SLUB using
 high-order allocations V2
From: Colin Ian King <colin.king@ubuntu.com>
In-Reply-To: <1305295404-12129-1-git-send-email-mgorman@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 14 May 2011 10:34:33 +0200
Message-ID: <1305362073.1969.4.camel@hpmini>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 2011-05-13 at 15:03 +0100, Mel Gorman wrote:
> Changelog since V1
>   o kswapd should sleep if need_resched
>   o Remove __GFP_REPEAT from GFP flags when speculatively using high
>     orders so direct/compaction exits earlier
>   o Remove __GFP_NORETRY for correctness
>   o Correct logic in sleeping_prematurely
>   o Leave SLUB using the default slub_max_order
> 
> There are a few reports of people experiencing hangs when copying
> large amounts of data with kswapd using a large amount of CPU which
> appear to be due to recent reclaim changes.
> 
> SLUB using high orders is the trigger but not the root cause as SLUB
> has been using high orders for a while. The following four patches
> aim to fix the problems in reclaim while reducing the cost for SLUB
> using those high orders.
> 
> Patch 1 corrects logic introduced by commit [1741c877: mm:
> 	kswapd: keep kswapd awake for high-order allocations until
> 	a percentage of the node is balanced] to allow kswapd to
> 	go to sleep when balanced for high orders.
> 
> Patch 2 prevents kswapd waking up in response to SLUBs speculative
> 	use of high orders.
> 
> Patch 3 further reduces the cost by prevent SLUB entering direct
> 	compaction or reclaim paths on the grounds that falling
> 	back to order-0 should be cheaper.
> 
> Patch 4 notes that even when kswapd is failing to keep up with
> 	allocation requests, it should still go to sleep when its
> 	quota has expired to prevent it spinning.
> 
> My own data on this is not great. I haven't really been able to
> reproduce the same problem locally.
> 
> The test case is simple. "download tar" wgets a large tar file and
> stores it locally. "unpack" is expanding it (15 times physical RAM
> in this case) and "delete source dirs" is the tarfile being deleted
> again. I also experimented with having the tar copied numerous times
> and into deeper directories to increase the size but the results were
> not particularly interesting so I left it as one tar.
> 
> In the background, applications are being launched to time to vaguely
> simulate activity on the desktop and to measure how long it takes
> applications to start.
> 
> Test server, 4 CPU threads, x86_64, 2G of RAM, no PREEMPT, no COMPACTION, X running
> LARGE COPY AND UNTAR
>                       vanilla       fixprematurely  kswapd-nowwake slub-noexstep  kswapdsleep
> download tar           95 ( 0.00%)   94 ( 1.06%)   94 ( 1.06%)   94 ( 1.06%)   94 ( 1.06%)
> unpack tar            654 ( 0.00%)  649 ( 0.77%)  655 (-0.15%)  589 (11.04%)  598 ( 9.36%)
> copy source files       0 ( 0.00%)    0 ( 0.00%)    0 ( 0.00%)    0 ( 0.00%)    0 ( 0.00%)
> delete source dirs    327 ( 0.00%)  334 (-2.10%)  318 ( 2.83%)  325 ( 0.62%)  320 ( 2.19%)
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)        1139.7   1142.55   1149.78   1109.32   1113.26
> Total Elapsed Time (seconds)               1341.59   1342.45   1324.90   1271.02   1247.35
> 
> MMTests Statistics: application launch
> evolution-wait30     mean     34.92   34.96   34.92   34.92   35.08
> gnome-terminal-find  mean      7.96    7.96    8.76    7.80    7.96
> iceweasel-table      mean      7.93    7.81    7.73    7.65    7.88
> 
> evolution-wait30     stddev    0.96    1.22    1.27    1.20    1.15
> gnome-terminal-find  stddev    3.02    3.09    3.51    2.99    3.02
> iceweasel-table      stddev    1.05    0.90    1.09    1.11    1.11
> 
> Having SLUB avoid expensive steps in reclaim improves performance
> by quite a bit with the overall test completing 1.5 minutes
> faster. Application launch times were not really affected but it's
> not something my test machine was suffering from in the first place
> so it's not really conclusive. The kswapd patches also did not appear
> to help but again, the test machine wasn't suffering that problem.
> 
> These patches are against 2.6.39-rc7. Again, testing would be
> appreciated.

These patches solve the problem for me.  I've been soak testing the file
copy test
for 3.5 hours with nearly 400 test cycles and observed no lockups at all
- rock solid. From my observations from the output from vmstat the
system is behaving sanely.
Thanks for finding a solution - much appreciated!

> 
>  Documentation/vm/slub.txt |    2 +-
>  mm/page_alloc.c           |    3 ++-
>  mm/slub.c                 |    5 +++--
>  3 files changed, 6 insertions(+), 4 deletions(-)
> 
>  mm/page_alloc.c |    3 ++-
>  mm/slub.c       |    3 ++-
>  mm/vmscan.c     |    6 +++++-
>  3 files changed, 9 insertions(+), 3 deletions(-)
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
