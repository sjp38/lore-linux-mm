Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EBB976B004D
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 00:33:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A4tRaC009156
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 13:55:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FD9845DE50
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 13:55:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0717645DE52
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 13:55:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CEB2A1DB8038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 13:55:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82E671DB803C
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 13:55:23 +0900 (JST)
Date: Fri, 10 Jul 2009 13:53:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v8)
Message-Id: <20090710135340.97b82f17.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 09 Jul 2009 22:44:41 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> New Feature: Soft limits for memory resource controller.
> 
> Here is v8 of the new soft limit implementation. Soft limits is a new feature
> for the memory resource controller, something similar has existed in the
> group scheduler in the form of shares. The CPU controllers interpretation
> of shares is very different though. 
> 
> Soft limits are the most useful feature to have for environments where
> the administrator wants to overcommit the system, such that only on memory
> contention do the limits become active. The current soft limits implementation
> provides a soft_limit_in_bytes interface for the memory controller and not
> for memory+swap controller. The implementation maintains an RB-Tree of groups
> that exceed their soft limit and starts reclaiming from the group that
> exceeds this limit by the maximum amount.
> 
> v8 has come out after a long duration, we were held back by bug fixes
> (most notably swap cache leak fix) and Kamezawa-San has his series of
> patches for soft limits. Kamezawa-San asked me to refactor these patches
> to make the data structure per-node-per-zone.
> 
> TODOs
> 
> 1. The current implementation maintains the delta from the soft limit
>    and pushes back groups to their soft limits, a ratio of delta/soft_limit
>    might be more useful
> 2. Small optimizations that I intend to push in v9, if the v8 design looks
>    good and acceptable.
> 
> Tests
> -----
> 
> I've run two memory intensive workloads with differing soft limits and
> seen that they are pushed back to their soft limit on contention. Their usage
> was their soft limit plus additional memory that they were able to grab
> on the system. Soft limit can take a while before we see the expected
> results.
> 

Before pointing out nitpicks, here are my impressions.
 
 1. seems good in general.

 2. Documentation is not enough. I think it's necessary to write "excuse" as
    "soft-limit is built on complex memory management system's behavior, then,
     this may not work as you expect. But in many case, this works well.
     please take this as best-effort service" or some.

 3. Using "jiffies" again is not good. plz use other check or event counter.

 4. I think it's better to limit soltlimit only against root of hierarcy node.
    (use_hierarchy=1) I can't explain how the system works if several soft limits
    are set to root and its children under a hierarchy.

 5. I'm glad if you extract patch 4/5 as an independent clean up patch.

 6. no overheads ?

other comments to each patch.

Thanks,
-Kame


> Please review, comment.
> 
> Series
> ------
> 
> memcg-soft-limits-documentation.patch
> memcg-soft-limits-interface.patch
> memcg-soft-limits-organize.patch
> memcg-soft-limits-refactor-reclaim-bits
> memcg-soft-limits-reclaim-on-contention.patch
> 
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
