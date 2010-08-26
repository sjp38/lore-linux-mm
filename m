Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 79A456B02AD
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 20:44:24 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q0iNiN020438
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 09:44:24 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BEC7B45DE4F
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:44:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A46645DE4C
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:44:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8442E1DB8014
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:44:23 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 30CC01DB8015
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 09:44:23 +0900 (JST)
Date: Thu, 26 Aug 2010 09:39:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
Message-Id: <20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 03:25:25 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:
> 
> > 3) No reason to implement ABI breakage.
> >    old tuning parameter mean)
> > 	oom-score = oom-base-score x 2^oom_adj
> 
> Everybody knows this is useless beyond polarizing a task for kill or 
> making it immune.
> 
> >    new tuning parameter mean)
> > 	oom-score = oom-base-score + oom_score_adj / (totalram + totalswap)
> 
> This, on the other hand, has an actual unit (proportion of available 
> memory) that can be used to prioritize tasks amongst those competing for 
> the same set of shared resources and remains constant even when a task 
> changes cpuset, its memcg limit changes, etc.
> 
> And your equation is wrong, it's
> 
> 	((rss + swap) / (available ram + swap)) + oom_score_adj
> 
> which is completely different from what you think it is.
> 

I'm now trying to write a userspace tool to calculate this, for me.
Then, could you update documentation ? 
==
3.2 /proc/<pid>/oom_score - Display current oom-killer score
-------------------------------------------------------------

This file can be used to check the current score used by the oom-killer is for
any given <pid>. Use it together with /proc/<pid>/oom_adj to tune which
process should be killed in an out-of-memory situation.
==

add a some documentation like:
==
(For system monitoring tool developpers, not for usual users.)
oom_score calculation is implemnentation dependent and can be modified without
any caution. But current logic is

oom_score = ((proc's rss + proc's swap) / (available ram + swap)) + oom_score_adj

proc's rss and swap can be obtained by /proc/<pid>/statm and available ram + swap
is dependent on the situation.
If the system is totaly under oom,
	available ram  == /proc/meminfo's MemTotal
	available swap == in most case == /proc/meminfo's SwapTotal
When you use memory cgroup,
	When swap is limited,  avaliable ram + swap == memory cgroup's memsw limit.
	When swap is unlimited, avaliable ram + swap = memory cgroup's memory limit + 
							SwapTotal

Then, please be careful that oom_score's order among tasks depends on the
situation. Assume 2 proceses A, B which has oom_score_adj of 300 and 0
 And A uses 200M, B uses 1G of memory under 4G system

 Under the 4G system.
 	A's socre = (200M *1000)/4G + 300 = 350
 	B's score = (1G * 1000)/4G = 250.

	 In the memory cgroup, it has 2G of resource.
	A's score = (200M * 1000)/2G + 300 = 400
	B's socre = (1G * 1000)/2G = 500

You shoudn't depend on /proc/<pid>/oom_score if you have to handle OOM under
cgroups and cpuset. But the logic is simple.
==

If you don't want, I'll add text and a sample tool to cgroup/memory.txt.


Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
