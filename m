Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DBD436B003D
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 00:26:32 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2Q5ECVm020310
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Mar 2009 14:14:12 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D684445DE51
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 14:14:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B890945DE50
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 14:14:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E4071DB803A
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 14:14:11 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53A34E18002
	for <linux-mm@kvack.org>; Thu, 26 Mar 2009 14:14:11 +0900 (JST)
Date: Thu, 26 Mar 2009 14:12:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][BUGFIX][PATCH] memcg: fix shrink_usage
Message-Id: <20090326141246.32305fe5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
References: <20090326130821.40c26cf1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@in.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Mar 2009 13:08:21 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This is another bug I've working on recently.
> 
> I want this (and the stale swapcache problem) to be fixed for 2.6.30.
> 
> Any comments?
> 
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Current mem_cgroup_shrink_usage has two problems.
> 
> 1. It doesn't call mem_cgroup_out_of_memory and doesn't update last_oom_jiffies,
>    so pagefault_out_of_memory invokes global OOM.
> 2. Considering hierarchy, shrinking has to be done from the mem_over_limit,
>    not from the memcg where the page to be charged to.
> 

Ah, i see. good cacth. 
But it seems to be the patch is a bit big and includes duplications.
Can't we divide this patch into 2 and reduce modification ?

mem_cgroup_shrink_usage() should do something proper...
My brief thinking is a patch like this, how do you think ?

Maybe renaming this function is appropriate...
==
mem_cgroup_shrink_usage() is called by shmem, but its purpose is
not different from try_charge().

In current behavior, it ignores upward hierarchy and doesn't update
OOM status of memcg. That's bad. We can simply call try_charge()
and drop charge later.

Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

Index: test/mm/memcontrol.c
===================================================================
--- test.orig/mm/memcontrol.c
+++ test/mm/memcontrol.c
@@ -1655,16 +1655,16 @@ int mem_cgroup_shrink_usage(struct page 
 	if (unlikely(!mem))
 		return 0;
 
-	do {
-		progress = mem_cgroup_hierarchical_reclaim(mem,
-					gfp_mask, true, false);
-		progress += mem_cgroup_check_under_limit(mem);
-	} while (!progress && --retry);
+	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, mem, true);
 
+	if (!ret) {
+		css_put(&mem->css); /* refcnt by charge *//
+		res_counter_uncharge(&mem->res, PAGE_SIZE);
+		if (do_swap_account)
+			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+	}
 	css_put(&mem->css);
-	if (!retry)
-		return -ENOMEM;
-	return 0;
+	return ret;
 }
 
 static DEFINE_MUTEX(set_limit_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
