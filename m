Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 777558D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 22:12:41 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id AE9BA3EE0BD
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:12:37 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9507E45DE5C
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:12:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E49945DE56
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:12:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C7FAE38003
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:12:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 348511DB8047
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 12:12:37 +0900 (JST)
Date: Tue, 8 Mar 2011 12:06:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110308120617.4039506a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110307171853.c31ec416.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
	<20110223150850.8b52f244.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1102231636260.21906@chino.kir.corp.google.com>
	<20110303135223.0a415e69.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071602080.23035@chino.kir.corp.google.com>
	<20110307162912.2d8c70c1.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071631080.23844@chino.kir.corp.google.com>
	<20110307165119.436f5d21.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1103071657090.24549@chino.kir.corp.google.com>
	<20110307171853.c31ec416.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Mon, 7 Mar 2011 17:18:53 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 7 Mar 2011 17:02:36 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> >  Keep in mind that for oom situations we give the killed 
> > task access to memory reserves below the min watermark with TIF_MEMDIE so 
> > that they can allocate memory to exit as quickly as possible (either to 
> > handle the SIGKILL or within the exit path).  That's because we can't 
> > guarantee anything within an oom system, cpuset, mempolicy, or memcg is 
> > ever responsive without it.  (And, the side effect of it and its threads 
> > exiting is the freeing of memory which allows everything else to once 
> > again be responsive.)
> > 
> > > That this is the only situation you've observed in which the
> > > userspace oom-handler is "unresponsive"?
> > > 
> > 
> > Personally, yes, but I could imagine other users could get caught if their 
> > userspace oom handler requires taking locks (such as mmap_sem) by reading 
> > within procfs that a thread within an oom memcg already holds.
> 
> If activity in one memcg cause a lockup of processes in a separate
> memcg then that's a containment violation and we should fix it.
> 

I hope dirty_ratio + async I/O controller will can be a help..
cpu controller is an only help for now (for limiting time for vmscan)

I'm not sure what we need other than above for now.



> One could argue that peering into a separate memcg's procfs files was
> already a containment violation, but from a practical point of view we
> definitely do want processes in a separate memcg to be able to
> passively observe activity in another without stepping on lindmines.
> 

It's namespace job, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
