Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7AEBC600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 23:43:38 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB14had2014132
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Dec 2009 13:43:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEB4C45DE50
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:43:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4B8F45DE4E
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:43:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EEE81DB8040
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:43:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A0101DB803C
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 13:43:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <alpine.DEB.2.00.0911301502160.12038@chino.kir.corp.google.com>
References: <20091127182607.GA30235@random.random> <alpine.DEB.2.00.0911301502160.12038@chino.kir.corp.google.com>
Message-Id: <20091201131509.5C19.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Dec 2009 13:43:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com
List-ID: <linux-mm.kvack.org>

> On Fri, 27 Nov 2009, Andrea Arcangeli wrote:
> 
> > Ok I can see the fact by being dynamic and less predictable worries
> > you. The "second to last" tasks especially are going to be less
> > predictable, but the memory hog would normally end up accounting for
> > most of the memory and this should increase the badness delta between
> > the offending tasks (or tasks) and the innocent stuff, so making it
> > more reliable. The innocent stuff should be more and more paged out
> > from ram. So I tend to think it'll be much less likely to kill an
> > innocent task this way (as demonstrated in practice by your
> > measurement too), but it's true there's no guarantee it'll always do
> > the right thing, because it's a heuristic anyway, but even total_vm
> > doesn't provide guarantee unless your workload is stationary and your
> > badness scores are fixed and no virtual memory is ever allocated by
> > any task in the system and no new task are spawned.
> > 
> 
> The purpose of /proc/pid/oom_adj is not always to polarize the heuristic 
> for the task it represents, it allows userspace to define when a task is 
> rogue.  Working with total_vm as a baseline, it is simple to use the 
> interface to tune the heuristic to prefer a certain task over another when 
> its memory consumption goes beyond what is expected.  With this interface, 
> I can easily define when an application should be oom killed because it is 
> using far more memory than expected.  I can also disable oom killing 
> completely for it, if necessary.  Unless you have a consistent baseline 
> for all tasks, the adjustment wouldn't contextually make any sense.  Using 
> rss does not allow users to statically define when a task is rogue and is 
> dependent on the current state of memory at the time of oom.
> 
> I would support removing most of the other heuristics other than the 
> baseline and the nodes intersection with mems_allowed to prefer tasks in 
> the same cpuset, though, to make it easier to understand and tune.

I feel you talked about oom_adj doesn't fit your use case. probably you need
/proc/{pid}/oom_priority new knob. oom adjustment doesn't fit you.
you need job severity based oom killing order. severity doesn't depend on any
hueristic.
server administrator should know job severity on his system.

OOM heuristic should mainly consider desktop usage. because desktop user
doesn't change oom knob at all. and they doesn't know what deamon is important.
any userful heuristics have some dynamically aspect. we can't avoid it.

thought?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
