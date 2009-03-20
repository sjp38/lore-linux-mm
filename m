Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AD1976B003D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 00:07:58 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2K47uFk009936
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 20 Mar 2009 13:07:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0183B45DD76
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 13:07:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CB7BF45DD72
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 13:07:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B556FE08004
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 13:07:55 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 659F1E18003
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 13:07:55 +0900 (JST)
Date: Fri, 20 Mar 2009 13:06:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Memory controller soft limit reclaim on contention
 (v7)
Message-Id: <20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090319165752.27274.36030.sendpatchset@localhost.localdomain>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165752.27274.36030.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Mar 2009 22:27:52 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Feature: Implement reclaim from groups over their soft limit
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v7...v6
> 1. Refactored out reclaim_options patch into a separate patch
> 2. Added additional checks for all swap off condition in
>    mem_cgroup_hierarchical_reclaim()

> -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> +	/*
> +	 * Try to free up some pages from the memory controllers soft
> +	 * limit queue.
> +	 */
> +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> +	if (order || !did_some_progress)
> +		did_some_progress += try_to_free_pages(zonelist, order,
> +							gfp_mask);
>  

Anyway, my biggest concern is here, always.

        By this.
          if (order > 1), try_to_free_pages() is called twice.
        Hmm...how about

        if (!pages_reclaimed && !(gfp_mask & __GFP_NORETRY)) { # this is the first loop or noretry
               did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
               if (!did_some_progress)
                    did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
        }else
                    did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
        

        maybe a bit more concervative.


        And I wonder "nodemask" should be checked or not..
        softlimit reclaim doesn't seem to work well with nodemask...
Thanks,
-Kame

                

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
