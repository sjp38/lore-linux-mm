Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D137E6B005A
	for <linux-mm@kvack.org>; Thu, 25 Jun 2009 01:39:33 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5P5e5oP027550
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:40:05 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P5elU6188470
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:40:47 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5P5ekIh016436
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:40:47 -0600
Date: Thu, 25 Jun 2009 11:10:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-ID: <20090625054042.GA8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090624170516.GT8642@balbir.in.ibm.com> <20090624161028.b165a61a.akpm@linux-foundation.org> <20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com> <20090625032717.GX8642@balbir.in.ibm.com> <20090624204426.3dc9e108.akpm@linux-foundation.org> <20090625133908.6ae3dd40.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090625133908.6ae3dd40.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-25 13:39:08]:

> On Wed, 24 Jun 2009 20:44:26 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Thu, 25 Jun 2009 08:57:17 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > We do a read everytime before we charge.
> > 
> > See, a good way to fix that is to not do it.  Instead of
> > 
> > 	if (under_limit())
> > 		charge_some_more(amount);
> > 	else
> > 		goto fail;
> > 
> > one can do 
> > 
> > 	if (try_to_charge_some_more(amount) < 0)
> > 		goto fail;
> > 
> > which will halve the locking frequency.  Which may not be as beneficial
> > as avoiding the locking altogether on the read side, dunno.
> > 
> I don't think we do read-before-write ;)
>

I need to figure out the reason for read contention and why seqlock's
help. Like I said before I am seeing some strange values for
reclaim_stats on the root cgroup, even though it is not reclaimable or
not used for reclaim. There can be two reasons

1. Reclaim
2. User space constantly reading the counters

I have no user space utilities I am aware of running on the system,
constantly reading the contents of the files. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
