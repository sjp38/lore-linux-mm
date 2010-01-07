Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AD8A56B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 02:39:25 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o077dMNp001961
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Jan 2010 16:39:22 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 908F445DE6D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 16:39:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 61A4445DE69
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 16:39:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B84B1DB804C
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 16:39:22 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 530311DB8044
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 16:39:21 +0900 (JST)
Date: Thu, 7 Jan 2010 16:36:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100107163610.aaf831e6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100107071554.GO3059@balbir.in.ibm.com>
References: <20091229182743.GB12533@balbir.in.ibm.com>
	<20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104000752.GC16187@balbir.in.ibm.com>
	<20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104005030.GG16187@balbir.in.ibm.com>
	<20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
	<20100106070150.GL3059@balbir.in.ibm.com>
	<20100106161211.5a7b600f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100107071554.GO3059@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 2010 12:45:54 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-06 16:12:11]:
> > And piles up costs ? I think cgroup guys should pay attention to fork/exit
> > costs more. Now, it gets slower and slower.
> > In that point, I never like migrate-at-task-move work in cpuset and memcg.
> > 
> > My 1st objection to this patch is this "shared" doesn't mean "shared between
> > cgroup" but means "shared between processes".
> > I think it's of no use and no help to users.
> >
> 
> So what in your opinion would help end users? My concern is that as
> we make progress with memcg, we account only for privately used pages
> with no hint/data about the real usage (shared within or with other
> cgroups). 

The real usage is already shown as

  [root@bluextal ref-mmotm]# cat /cgroups/memory.stat
  cache 7706181632 
  rss 120905728
  mapped_file 32239616

This is real. And "sum of rss - rss+mapped" doesn't show anything.

> How do we decide if one cgroup is really heavy?
>  

What "heavy" means ? "Hard to page out ?"

Historically, it's caught by pagein/pageout _speed_.
"How heavy memory system is ?" can only be measured by "speed".
If you add latency-stat for memcg, I'm glad to use it.

Anyway, "How memory reclaim can go successfully" is generic problem rather
than memcg. Maybe no good answers from VM guys....
I think you should add codes to global VM rather than cgroup.

"How pages are shared" doesn't show good hints. I don't hear such parameter
is used in production's resource monitoring software.


> > And implementation is 2nd thing.
> > 
> 
> More details on your concern, please!
> 
I already wrote....why do you want to make fork()/exit() slow for a thing
which is not necessary to be done in atomic ?

There are many hosts which has thousands of process and a cgrop may contain
thousands of process in production server.
In that situation, How the "make kernel" can slow down with following ?
==
while true; do cat /cgroup/memory.shared > /dev/null; done
==

In a word, the implementation problem is
 - An operation against a container can cause generic system slow down.
Then, I don't like heavy task move under cgroup.


Yes, this can happen in other places (we have to do some improvements).
But this is not good for a concept of isolation by container, anyway.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
