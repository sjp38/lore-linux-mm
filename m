Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 022E06B0087
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 00:58:01 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Postfix) with ESMTP id 8FBF23EE0BB
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 14:57:59 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7686645DE4D
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 14:57:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A43A45DE59
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 14:57:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ED21E08001
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 14:57:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 174391DB8038
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 14:57:59 +0900 (JST)
Date: Thu, 6 Jan 2011 14:52:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch v3] memcg: add oom killer delay
Message-Id: <20110106145201.dab01250.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110106054600.GH3722@balbir.in.ibm.com>
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
	<20110106054600.GH3722@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Jan 2011 11:16:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-06 10:53:15]:
> 
> > > Kamezawa-San, not sure if your comment is clear, are you suggesting
> > > 
> > > Since memcg is the root of a hierarchy, we need to use hierarchical
> > > locking before changing the value of the root oom_delay?
> > > 
> > 
> > No. mem_cgroup_oom_lock() is a lock for hierarchy, not for a group.
> > 
> > For example,
> > 
> >   A
> >  / \
> > B   C
> > 
> > In above hierarchy, when C is in OOM, A's OOM will be blocked by C's OOM.
> > Because A's OOM can be fixed by C's oom-kill.
> > This means oom_delay for A should be for C (and B), IOW, for hierarchy.
> > 
> > 
> > A and B, C should have the same oom_delay, oom_disable value.
> >
> 
> Why so? You already mentioned that A's OOM will be blocked by C's OOM?
> If we keep that behaviour, if C has a different oom_delay value, it
> won't matter, since we'll never go up to A. 

When C's oom_delay is 10min and A's oom_delay is 1min, A can be blocked
for 10min even if it has 1min delay. 

I don't want this complex rule.

> If the patch breaks that
> behaviour then we are in trouble. With hierarchy we need to ensure
> that if A has a oom_delay set and C does not, A's setting takes
> precendence. In the absence of that logic what you say makes sense.
>  
His implemenation doesn't do that and I want a simple one even if I have
to make an Ack to a feature which seems of-no-use to me.



Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
