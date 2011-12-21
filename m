Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id B62066B005C
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 07:28:28 -0500 (EST)
Date: Wed, 21 Dec 2011 13:28:15 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v3] memcg: return -EINTR at bypassing try_charge().
Message-ID: <20111221122815.GF3870@cmpxchg.org>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
 <20111221172423.5d036cdd.kamezawa.hiroyu@jp.fujitsu.com>
 <20111221192934.2751f8f1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111221192934.2751f8f1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>

On Wed, Dec 21, 2011 at 07:29:34PM +0900, KAMEZAWA Hiroyuki wrote:
> Thank you for review.
> I'm sorry if my response is delayed.
> ==
> >From 1e8c917c64b3947d2e54c6e5073d53d80bd97c30 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 21 Dec 2011 16:27:25 +0900
> Subject: [PATCH] memcg: return -EINTR at bypassing try_charge().
> 
> This patch is a fix for memcg-simplify-lru-handling-by-new-rule.patch
> When running testprogram and stop it by Ctrl-C, add_lru/del_lru
> will find pc->mem_cgroup is NULL and get panic. The reason
> is bypass code in try_charge().
> 
> At try_charge(), it checks the thread is fatal or not as..
> fatal_signal_pending() or TIF_MEMDIE. In this case, __try_charge()
> returns 0(success) with setting *ptr as NULL.
> 
> Now, lruvec are deteremined by pc->mem_cgroup. So, it's better
> to reset pc->mem_cgroup as root_mem_cgroup. This patch does
> following change in try_charge()
>   1. return -EINTR at bypassing.
>   2. set *ptr = root_mem_cgroup at bypassing.
> 
> By this change, in page fault / radix-tree-insert path,
> the page will be charged against root_mem_cgroup and the thread's
> operations will go ahead without trouble. In other path,
> migration or move_account etc..., -EINTR will stop the operation.
> (may need some cleanup later..)
> 
> After this change, pc->mem_cgroup will have valid pointer if
> the page is used.
> 
> Changelog: v2 -> v3
>  - handle !mm case in another way.
>  - removed redundant commments
>  - fixed move_parent bug of uninitialized pointer
> Changelog: v1 -> v2
>  - returns -EINTR at bypassing.
>  - change error code handling at callers.
>  - changed the name of patch.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good now, thanks.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
