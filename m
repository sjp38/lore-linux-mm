Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DA2216B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 19:31:47 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n080ViVL024773
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 09:31:45 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AB1A45DE5A
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:31:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4730E45DE53
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:31:44 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F0811DB805E
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:31:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F8821DB805D
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 09:31:43 +0900 (JST)
Date: Thu, 8 Jan 2009 09:30:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches
Message-Id: <20090108093040.22d5f281.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, riel@redhat.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 08 Jan 2009 00:11:10 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> Here is v1 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. We'll compare shares and soft limits
> below. I've had soft limit implementations earlier, but I've discarded those
> approaches in favour of this one.
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> This is an RFC implementation and is not meant for inclusion
> 
Core implemantation seems simple and the feature sounds good.
But, before reviewing into details, 3 points.

  1. please fix current bugs on hierarchy management, before new feature.
     AFAIK, OOM-Kill under hierarchy is broken. (I have patches but waits for
     merge window close.)
     I wonder there will be some others. Lockdep error which Nishimura reported
     are all fixed now ?

  2. You inserts reclaim-by-soft-limit into alloc_pages(). But, to do this,
     you have to pass zonelist to try_to_free_mem_cgroup_pages() and have to modify
     try_to_free_mem_cgroup_pages().
     2-a) If not, when the memory request is for gfp_mask==GFP_DMA or allocation
          is under a cpuset, memory reclaim will not work correctlly.
     2-b) try_to_free_mem_cgroup_pages() cannot do good work for order > 1 allocation.
  
     Please try fake-numa (or real NUMA machine) and cpuset.

  3. If you want to insert hooks to "generic" page allocator, it's better to add CC to
     Rik van Riel, Kosaki Motohiro, at leaset.

     To be honest, I myself don't like to add a hook to alloc_pages() directly.
     Can we implment call soft-limit like kswapd (or on kswapd()) ?
     i.e. in moderate way ?
   
A happy new year,

-Kame



> TODOs
> 
> 1. The shares interface is not yet implemented, the current soft limit
>    implementation is not yet hierarchy aware. The end goal is to add
>    a shares interface on top of soft limits and to maintain shares in
>    a manner similar to the group scheduler
> 2. The current implementation maintains the delta from the soft limit
>    and pushes back groups to their soft limits, a ratio of delta/soft_limit
>    is more useful
> 3. It would be nice to have more targetted reclaim (in terms of pages to
>    recalim) interface. So that groups are pushed back, close to their soft
>    limits.
> 
> Tests
> -----
> 
> I've run two memory intensive workloads with differing soft limits and
> seen that they are pushed back to their soft limit on contention. Their usage
> was their soft limit plus additional memory that they were able to grab
> on the system.
> 
> Please review, comment.
> 
> Series
> ------
> 
> memcg-soft-limit-documentation.patch
> memcg-add-soft-limit-interface.patch
> memcg-organize-over-soft-limit-groups.patch
> memcg-soft-limit-reclaim-on-contention.patch
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
