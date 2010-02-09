Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE6E56B0047
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 01:49:21 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o196nGnb019607
	for <linux-mm@kvack.org>; Tue, 9 Feb 2010 06:49:16 GMT
Received: from pzk15 (pzk15.prod.google.com [10.243.19.143])
	by wpaz21.hot.corp.google.com with ESMTP id o196n1KV023770
	for <linux-mm@kvack.org>; Mon, 8 Feb 2010 22:49:15 -0800
Received: by pzk15 with SMTP id 15so3024088pzk.11
        for <linux-mm@kvack.org>; Mon, 08 Feb 2010 22:49:14 -0800 (PST)
Date: Mon, 8 Feb 2010 22:49:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup
In-Reply-To: <28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com> <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com> <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com> <28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Feb 2010, Minchan Kim wrote:

> I think it's not only a latency problem of OOM but it is also a
> problem of deadlock.
> We can't expect child's lock state in oom_kill_process.
> 

task_lock() is a spinlock, it shouldn't be held for any significant length 
of time and certainly not during a memory allocation which would be the 
only way we'd block in such a state during the oom killer; if that exists, 
we'd deadlock when it was chosen for kill in __oom_kill_task() anyway, 
which negates your point about oom_kill_process() and while scanning for 
tasks to kill and calling badness().  We don't have any special handling 
for GFP_ATOMIC allocations in the oom killer for locks being held while 
allocating anyway, the only thing we need to be concerned about is a 
writelock on tasklist_lock, but the oom killer only requires a readlock.  
You'd be correct if we help write_lock_irq(&tasklist_lock).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
