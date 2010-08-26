Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7B1306B02B5
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 21:20:32 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q1GeQl002215
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 10:16:40 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 32EAA45DE57
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:16:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05A6D45DE51
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:16:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E34E3E08001
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:16:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B8381DB803A
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 10:16:39 +0900 (JST)
Date: Thu, 26 Aug 2010 10:11:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2][BUGFIX] oom: remove totalpage normalization from
 oom_badness()
Message-Id: <20100826101139.eb05fe2d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1008251746200.28401@chino.kir.corp.google.com>
References: <20100825184001.F3EF.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1008250300500.13300@chino.kir.corp.google.com>
	<20100826093923.d4ac29b6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1008251746200.28401@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010 17:52:06 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Thu, 26 Aug 2010, KAMEZAWA Hiroyuki wrote:
> 
> > I'm now trying to write a userspace tool to calculate this, for me.
> > Then, could you update documentation ? 
> > ==
> > 3.2 /proc/<pid>/oom_score - Display current oom-killer score
> > -------------------------------------------------------------
> > 
> > This file can be used to check the current score used by the oom-killer is for
> > any given <pid>. Use it together with /proc/<pid>/oom_adj to tune which
> > process should be killed in an out-of-memory situation.
> > ==
> > 
> 
> You'll want to look at section 3.1 of Documentation/filesystems/proc.txt, 
> which describes /proc/pid/oom_score_adj, not 3.2.
> 
> > add a some documentation like:
> > ==
> > (For system monitoring tool developpers, not for usual users.)
> > oom_score calculation is implemnentation dependent and can be modified without
> > any caution. But current logic is
> > 
> > oom_score = ((proc's rss + proc's swap) / (available ram + swap)) + oom_score_adj
> > 
> 
> I'd hesitate to state the formula outside of the implementation and 
> instead focus on the semantics of oom_score_adj (as a proportion of 
> available memory compared to other tasks), which I tried doing in section 
> 3.1.  Then, the userspace tool only need be concerned about the units of 
> oom_score_adj rather than whether rss, swap, or later extentions such as 
> shm are added.
> 
Hmm. I'll add a text like following to cgroup/memory.txt. O.K. ?

==
Notes on oom_score and oom_score_adj.

oom_score is calculated as
	oom_score = (taks's proportion of memory) + oom_score_adj.

Then, when you use oom_score_adj to control the order of priority of oom,
you should know about the amount of memory you can use.
So, an approximate oom_score under memcg can be

 memcg_oom_score = (oom_score - oom_score_adj) * system_memory/memcg's limit
		+ oom_score_adj.

And yes, this can be affected by hierarchy control of memcg and calculation
will be more complicated. See, oom_disable feature also.
==

Thanks,
-Kame












--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
