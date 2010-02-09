Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B3356001DA
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 04:55:53 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id o199tote001256
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 01:55:51 -0800
Received: from pxi12 (pxi12.prod.google.com [10.243.27.12])
	by spaceape9.eur.corp.google.com with ESMTP id o199tlFu023323
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 01:55:49 -0800
Received: by pxi12 with SMTP id 12so7841286pxi.33
        for <linux-mm@kvack.org>; Tue, 09 Feb 2010 01:55:47 -0800 (PST)
Date: Tue, 9 Feb 2010 01:55:44 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup
In-Reply-To: <28c262361002090140p37fac1e4q2652e7a4ee3a84d4@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1002090150390.16525@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com> <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com> <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com> <28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
 <alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com> <28c262361002090140p37fac1e4q2652e7a4ee3a84d4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Feb 2010, Minchan Kim wrote:

> My point was following as.
> We try to kill child of OOMed task at first.
> But we can't know any locked state of child when OOM happens.

We don't need to, child->alloc_lock can be contended in which case we'll 
just spin but it won't stay locked because we're out of memory.  In other 
words, nothing takes task_lock(child) and then waits for memory to become 
available while holding it, that would be fundamentally broken.  So there 
is a dependency here and that is that task_lock(current) can't be taken in 
the page allocator because we'll deadlock in the oom killer, but that 
isn't anything new.

> It means at this point child is able to be holding any lock.
> So if we can try to hold task_lock of child, it could make new lock
> dependency between task_lock and other locks.
> 

The children aren't any special class of processes in this case, we always 
take task_lock() for them during the tasklist scan.  In fact, we can take 
task_lock(p) for the same process p three times during the course of an 
oom kill: once to dump its statistics when /proc/pid/oom_dump_tasks is 
enabled, once to calculate its badness() score, and once to kill it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
