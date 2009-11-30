Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F30A8600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:09:50 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id nAUN9pgU008378
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:09:51 -0800
Received: from pxi42 (pxi42.prod.google.com [10.243.27.42])
	by zps38.corp.google.com with ESMTP id nAUN7fwg015847
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:09:48 -0800
Received: by pxi42 with SMTP id 42so3201749pxi.5
        for <linux-mm@kvack.org>; Mon, 30 Nov 2009 15:09:47 -0800 (PST)
Date: Mon, 30 Nov 2009 15:09:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091127182607.GA30235@random.random>
Message-ID: <alpine.DEB.2.00.0911301502160.12038@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com> <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com> <20091125124433.GB27615@random.random> <alpine.DEB.2.00.0911251334020.8191@chino.kir.corp.google.com> <20091127182607.GA30235@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Nov 2009, Andrea Arcangeli wrote:

> Ok I can see the fact by being dynamic and less predictable worries
> you. The "second to last" tasks especially are going to be less
> predictable, but the memory hog would normally end up accounting for
> most of the memory and this should increase the badness delta between
> the offending tasks (or tasks) and the innocent stuff, so making it
> more reliable. The innocent stuff should be more and more paged out
> from ram. So I tend to think it'll be much less likely to kill an
> innocent task this way (as demonstrated in practice by your
> measurement too), but it's true there's no guarantee it'll always do
> the right thing, because it's a heuristic anyway, but even total_vm
> doesn't provide guarantee unless your workload is stationary and your
> badness scores are fixed and no virtual memory is ever allocated by
> any task in the system and no new task are spawned.
> 

The purpose of /proc/pid/oom_adj is not always to polarize the heuristic 
for the task it represents, it allows userspace to define when a task is 
rogue.  Working with total_vm as a baseline, it is simple to use the 
interface to tune the heuristic to prefer a certain task over another when 
its memory consumption goes beyond what is expected.  With this interface, 
I can easily define when an application should be oom killed because it is 
using far more memory than expected.  I can also disable oom killing 
completely for it, if necessary.  Unless you have a consistent baseline 
for all tasks, the adjustment wouldn't contextually make any sense.  Using 
rss does not allow users to statically define when a task is rogue and is 
dependent on the current state of memory at the time of oom.

I would support removing most of the other heuristics other than the 
baseline and the nodes intersection with mems_allowed to prefer tasks in 
the same cpuset, though, to make it easier to understand and tune.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
