Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 455F86B0047
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 02:12:08 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o197C5Co028828
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Feb 2010 16:12:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 753A745DE4F
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 16:12:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A1C045DE50
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 16:12:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E19A1DB8038
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 16:12:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E1DFEE7800A
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 16:12:04 +0900 (JST)
Date: Tue, 9 Feb 2010 16:08:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
 cgroup
Message-Id: <20100209160830.9d733f97.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	<20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
	<alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Feb 2010 22:49:09 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 9 Feb 2010, Minchan Kim wrote:
> 
> > I think it's not only a latency problem of OOM but it is also a
> > problem of deadlock.
> > We can't expect child's lock state in oom_kill_process.
> > 
> 
> task_lock() is a spinlock, it shouldn't be held for any significant length 
> of time and certainly not during a memory allocation which would be the 
> only way we'd block in such a state during the oom killer; if that exists, 
> we'd deadlock when it was chosen for kill in __oom_kill_task() anyway, 
> which negates your point about oom_kill_process() and while scanning for 
> tasks to kill and calling badness().  We don't have any special handling 
> for GFP_ATOMIC allocations in the oom killer for locks being held while 
> allocating anyway, the only thing we need to be concerned about is a 
> writelock on tasklist_lock, but the oom killer only requires a readlock.  
> You'd be correct if we help write_lock_irq(&tasklist_lock).
> 
Hmm, but it's not necessary to hold task_lock, anyway. Is this patch's logic
itself ok if I rewrite the rescription/comments ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
