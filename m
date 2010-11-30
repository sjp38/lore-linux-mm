Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EE6276B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:54:08 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAU6s6eV016448
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 30 Nov 2010 15:54:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9572145DE57
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:54:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CFF845DE56
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:54:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FBD8E08003
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:54:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 23AE51DB803B
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 15:54:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
In-Reply-To: <1291099785-5433-1-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
Message-Id: <20101130155327.8313.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 30 Nov 2010 15:54:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The current implementation of memcg only supports direct reclaim and this
> patchset adds the support for background reclaim. Per cgroup background
> reclaim is needed which spreads out the memory pressure over longer period
> of time and smoothes out the system performance.
> 
> The current implementation is not a stable version, and it crashes sometimes
> on my NUMA machine. Before going further for debugging, I would like to start
> the discussion and hear the feedbacks of the initial design.

I haven't read your code at all. However I agree your claim that memcg 
also need background reclaim.

So if you post high level design memo, I'm happy.

> 
> Current status:
> I run through some simple tests which reads/writes a large file and makes sure
> it triggers per cgroup kswapd on the low_wmark. Also, I compared at
> pg_steal/pg_scan ratio w/o background reclaim.
> 
> Step1: Create a cgroup with 500M memory_limit and set the min_free_kbytes to 1024.
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



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
