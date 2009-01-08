Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1373E6B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 22:59:35 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n083xTfH030404
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:29:29 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n083vodP4300882
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 09:27:50 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n083xSMi011473
	for <linux-mm@kvack.org>; Thu, 8 Jan 2009 14:59:29 +1100
Date: Thu, 8 Jan 2009 09:29:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches
Message-ID: <20090108035930.GB7294@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain> <20090108093040.22d5f281.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090108093040.22d5f281.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, riel@redhat.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-08 09:30:40]:

> On Thu, 08 Jan 2009 00:11:10 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > 
> > Here is v1 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. We'll compare shares and soft limits
> > below. I've had soft limit implementations earlier, but I've discarded those
> > approaches in favour of this one.
> > 
> > Soft limits are the most useful feature to have for environments where
> > the administrator wants to overcommit the system, such that only on memory
> > contention do the limits become active. The current soft limits implementation
> > provides a soft_limit_in_bytes interface for the memory controller and not
> > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > that exceed their soft limit and starts reclaiming from the group that
> > exceeds this limit by the maximum amount.
> > 
> > This is an RFC implementation and is not meant for inclusion
> > 
> Core implemantation seems simple and the feature sounds good.

Thanks!

> But, before reviewing into details, 3 points.
> 
>   1. please fix current bugs on hierarchy management, before new feature.
>      AFAIK, OOM-Kill under hierarchy is broken. (I have patches but waits for
>      merge window close.)

I've not hit the OOM-kill issue under hierarchy so far, is the OOM
killer selecting a bad task to kill? I'll debug/reproduce the issue.
I am not posting these patches for inclusion, fixing bugs is
definitely the highest priority.

>      I wonder there will be some others. Lockdep error which Nishimura reported
>      are all fixed now ?

I run all my kernels and tests with lockdep enabled, I did not see any
lockdep errors showing up.

> 
>   2. You inserts reclaim-by-soft-limit into alloc_pages(). But, to do this,
>      you have to pass zonelist to try_to_free_mem_cgroup_pages() and have to modify
>      try_to_free_mem_cgroup_pages().
>      2-a) If not, when the memory request is for gfp_mask==GFP_DMA or allocation
>           is under a cpuset, memory reclaim will not work correctlly.

The idea behind adding the code in alloc_pages() is to detect
contention and trim mem cgroups down, if they have grown beyond their
soft limit

>      2-b) try_to_free_mem_cgroup_pages() cannot do good work for order > 1 allocation.
>   
>      Please try fake-numa (or real NUMA machine) and cpuset.

Yes, order > 1 is documented in the patch and you can see the code as
well. Your suggestion is to look at the gfp_mask as well, I'll do
that.

> 
>   3. If you want to insert hooks to "generic" page allocator, it's better to add CC to
>      Rik van Riel, Kosaki Motohiro, at leaset.

Sure, I'll do that in the next patchset.

> 
>      To be honest, I myself don't like to add a hook to alloc_pages() directly.
>      Can we implment call soft-limit like kswapd (or on kswapd()) ?
>      i.e. in moderate way ?
>    

Yes, that might be another point to experiment with, I'll try that in
the next iteration.


> A happy new year,
> 

A very happy new year to you as well.

> -Kame
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
