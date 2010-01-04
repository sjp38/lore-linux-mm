Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A57CD600068
	for <linux-mm@kvack.org>; Sun,  3 Jan 2010 19:38:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o040ceXg029596
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Jan 2010 09:38:40 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0136F45DE4F
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 09:38:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D5DE845DE4E
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 09:38:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B7C671DB803B
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 09:38:39 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E2E51DB8038
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 09:38:39 +0900 (JST)
Date: Mon, 4 Jan 2010 09:35:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100104000752.GC16187@balbir.in.ibm.com>
References: <20091229182743.GB12533@balbir.in.ibm.com>
	<20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104000752.GC16187@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010 05:37:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-04 08:51:08]:
> 
> > On Tue, 29 Dec 2009 23:57:43 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Hi, Everyone,
> > > 
> > > I've been working on heuristics for shared page accounting for the
> > > memory cgroup. I've tested the patches by creating multiple cgroups
> > > and running programs that share memory and observed the output.
> > > 
> > > Comments?
> > 
> > Hmm? Why we have to do this in the kernel ?
> >
> 
> For several reasons that I can think of
> 
> 1. With task migration changes coming in, getting consistent data free of races
> is going to be hard.

Hmm, Let's see real-worlds's "ps" or "top" command. Even when there are no guarantee
of error range of data, it's still useful.

> 2. The cost of doing it in the kernel is not high, it does not impact
> the memcg runtime, it is a request-response sort of cost.
>
> 3. The cost in user space is going to be high and the implementation
> cumbersome to get right.
>  
I don't like moving a cost in the userland to the kernel. Considering 
real-time kernel or full-preemptive kernel, this very long read_lock() in the
kernel is not good, IMHO. (I think css_set_lock should be mutex/rw-sem...)
cgroup_iter_xxx can block cgroup_post_fork() and this may cause critical
system delay of milli-seconds.

BTW, if you really want to calculate somthing in atomic, I think following
interface may be welcomed for freezing.

  cgroup.lock
  # echo 1 > /...../cgroup.lock 
    All task move, mkdir, rmdir to this cgroup will be blocked by mutex.
    (But fork/exit will not be blocked.)

  # echo 0 > /...../cgroup.lock
    Unlock.

  # cat /...../cgroup.lock
    show lock status and lock history (for debug).

Maybe good for some kinds of middleware.
But this may be difficult if we have to consider hierarchy.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
