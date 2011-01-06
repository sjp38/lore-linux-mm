Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E9AEE6B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 00:46:12 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp07.in.ibm.com (8.14.4/8.13.1) with ESMTP id p065k5bK015638
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 11:16:05 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p065k5nW2441232
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 11:16:05 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p065k4IA012258
	for <linux-mm@kvack.org>; Thu, 6 Jan 2011 16:46:05 +1100
Date: Thu, 6 Jan 2011 11:16:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch v3] memcg: add oom killer delay
Message-ID: <20110106054600.GH3722@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
 <20101221235924.b5c1aecc.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1012220031010.24462@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1012221443540.2612@chino.kir.corp.google.com>
 <20101227095225.2cf907a3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1012272103370.27164@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1012272228350.17843@chino.kir.corp.google.com>
 <20110104104130.a3faf0d5.kamezawa.hiroyu@jp.fujitsu.com>
 <20110104035956.GA3120@balbir.in.ibm.com>
 <20110106105315.5f88ebce.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110106105315.5f88ebce.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-06 10:53:15]:

> > Kamezawa-San, not sure if your comment is clear, are you suggesting
> > 
> > Since memcg is the root of a hierarchy, we need to use hierarchical
> > locking before changing the value of the root oom_delay?
> > 
> 
> No. mem_cgroup_oom_lock() is a lock for hierarchy, not for a group.
> 
> For example,
> 
>   A
>  / \
> B   C
> 
> In above hierarchy, when C is in OOM, A's OOM will be blocked by C's OOM.
> Because A's OOM can be fixed by C's oom-kill.
> This means oom_delay for A should be for C (and B), IOW, for hierarchy.
> 
> 
> A and B, C should have the same oom_delay, oom_disable value.
>

Why so? You already mentioned that A's OOM will be blocked by C's OOM?
If we keep that behaviour, if C has a different oom_delay value, it
won't matter, since we'll never go up to A. If the patch breaks that
behaviour then we are in trouble. With hierarchy we need to ensure
that if A has a oom_delay set and C does not, A's setting takes
precendence. In the absence of that logic what you say makes sense.
 
> About oom_disable,
>  - It can be set only when A has no children and root of hierarchy.
>  - It's inherited at creating children.
> 
> Then, A, B ,C have the same value.
> 
> Considering race conditions, I like current oom_disable's approach.
>

Thanks for clarifying. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
