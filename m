Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6309C6B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 23:26:03 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n084PvD8015595
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:55:57 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n084Q0Bu4178030
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:56:00 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n084PuvZ012539
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:55:56 +0530
Date: Thu, 8 Jan 2009 09:55:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/4] Memory controller soft limit organize cgroups
Message-ID: <20090108042558.GC7294@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain> <20090107184128.18062.96016.sendpatchset@localhost.localdomain> <20090108101148.96e688f4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108101148.96e688f4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 10:11:48]:

> On Thu, 08 Jan 2009 00:11:28 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > This patch introduces a RB-Tree for storing memory cgroups that are over their
> > soft limit. The overall goal is to
> > 
> > 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
> >    We are careful about updates, updates take place only after a particular
> >    time interval has passed
> > 2. We remove the node from the RB-Tree when the usage goes below the soft
> >    limit
> > 
> > The next set of patches will exploit the RB-Tree to get the group that is
> > over its soft limit by the largest amount and reclaim from it, when we
> > face memory contention.
> > 
> 
> Hmm,  Could you clarify following ?
>   
>   - Usage of memory at insertsion and usage of memory at reclaim is different.
>     So, this *sorted* order by RB-tree isn't the best order in general.

True, but we frequently update the tree at an interval of HZ/4.
Updating at every page fault sounded like an overkill and building the
entire tree at reclaim is an overkill too.

>     Why don't you sort this at memory-reclaim dynamically ?
>   - Considering above, the look of RB tree can be
> 
>                 +30M (an amount over soft limit is 30M)
>                 /  \
>              -15M   +60M

We don't have elements below their soft limit in the tree

>      ?
> 
>     At least, pleease remove the node at uncharge() when the usage goes down.
>

We do remove the tree if it goes under its soft limit at commit_charge,
I thought I had the same code in uncharge(), but clearly that is
missing. Thanks, I'll add it there.


> Thanks,
> -Kame

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
