Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6030C6B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 02:06:13 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU76AUF022334
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Nov 2010 16:06:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 99AA945DE69
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:06:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1391E45DE6A
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:06:10 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 033351DB803F
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:06:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8628D1DB803B
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 16:06:09 +0900 (JST)
Date: Tue, 30 Nov 2010 16:00:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
Message-Id: <20101130160000.ac7b0b76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1291099785-5433-1-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Nov 2010 22:49:41 -0800
Ying Han <yinghan@google.com> wrote:

> The current implementation of memcg only supports direct reclaim and this
> patchset adds the support for background reclaim. Per cgroup background
> reclaim is needed which spreads out the memory pressure over longer period
> of time and smoothes out the system performance.
> 
> The current implementation is not a stable version, and it crashes sometimes
> on my NUMA machine. Before going further for debugging, I would like to start
> the discussion and hear the feedbacks of the initial design.
> 

It's welcome but please wait until merge of dirty-ratio.
And please post after you don't see crash ....

Description of design is appreciated.
Where the cost for "kswapd" is charged agaist if cpu cgroup is used at the same time ?

> Current status:
> I run through some simple tests which reads/writes a large file and makes sure
> it triggers per cgroup kswapd on the low_wmark. Also, I compared at
> pg_steal/pg_scan ratio w/o background reclaim.
> 
>

 Step1: Create a cgroup with 500M memory_limit and set the min_free_kbytes to 1024.
> $ mount -t cgroup -o cpuset,memory cpuset /dev/cgroup
> $ mkdir /dev/cgroup/A
> $ echo 0 >/dev/cgroup/A/cpuset.cpus
> $ echo 0 >/dev/cgroup/A/cpuset.mems
> $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
> $ echo 1024 >/dev/cgroup/A/memory.min_free_kbytes
> $ echo $$ >/dev/cgroup/A/tasks
> 
> Step2: Check the wmarks.
> $ cat /dev/cgroup/A/memory.reclaim_wmarks
> memcg_low_wmark 98304000
> memcg_high_wmark 81920000
> 
> Step3: Dirty the pages by creating a 20g file on hard drive.
> $ ddtest -D /export/hdc3/dd -b 1024 -n 20971520 -t 1
> 
> Checked the memory.stat w/o background reclaim. It used to be all the pages are
> reclaimed from direct reclaim, and now about half of them are reclaimed at
> background. (note: writing '0' to min_free_kbytes disables per cgroup kswapd)
> 
> Only direct reclaim                                                With background reclaim:
> kswapd_steal 0                                                     kswapd_steal 2751822
> pg_pgsteal 5100401                                               pg_pgsteal 2476676
> kswapd_pgscan 0                                                  kswapd_pgscan 6019373
> pg_scan 5542464                                                   pg_scan 3851281
> pgrefill 304505                                                       pgrefill 348077
> pgoutrun 0                                                             pgoutrun 44568
> allocstall 159278                                                    allocstall 75669
> 
> Step4: Cleanup
> $ echo $$ >/dev/cgroup/tasks
> $ echo 0 > /dev/cgroup/A/memory.force_empty
> 
> Step5: Read the 20g file into the pagecache.
> $ cat /export/hdc3/dd/tf0 > /dev/zero;
> 
> Checked the memory.stat w/o background reclaim. All the clean pages are reclaimed at
> background instead of direct reclaim.
> 
> Only direct reclaim                                                With background reclaim
> kswapd_steal 0                                                      kswapd_steal 3512424
> pg_pgsteal 3461280                                               pg_pgsteal 0
> kswapd_pgscan 0                                                  kswapd_pgscan 3512440
> pg_scan 3461280                                                   pg_scan 0
> pgrefill 0                                                                pgrefill 0
> pgoutrun 0                                                             pgoutrun 74973
> allocstall 108165                                                    allocstall 0
> 

What is the trigger for starting background reclaim ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
