Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 188D86B005C
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 15:49:09 -0500 (EST)
Received: by iacb35 with SMTP id b35so9373131iac.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 12:49:09 -0800 (PST)
Date: Mon, 19 Dec 2011 12:49:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] memcg: reset to root_mem_cgroup at bypassing
In-Reply-To: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1112191218350.3639@eggly.anvils>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Mon, 19 Dec 2011, KAMEZAWA Hiroyuki wrote:
> From d620ff605a3a592c2b1de3a046498ce5cd3d3c50 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 19 Dec 2011 16:55:10 +0900
> Subject: [PATCH 2/2] memcg: reset lru to root_mem_cgroup in special cases.
> 
> This patch is a fix for memcg-simplify-lru-handling-by-new-rule.patch
> 
> After the patch, all pages which will be onto LRU must have sane
> pc->mem_cgroup. But, in special case, it's not set.
> 
> If task->mm is NULL or task is TIF_MEMDIE or fatal_signal_pending(),
> try_charge() is bypassed and the new charge will not be charged. And
> pc->mem_cgroup is unset even if the page will be used/mapped and added
> to LRU. To avoid this,  this patch charges such pages to root_mem_cgroup,
> then, pc->mem_cgroup will be handled correctly.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0d6d21c..9268e8e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2324,7 +2324,7 @@ nomem:
>  	*ptr = NULL;
>  	return -ENOMEM;
>  bypass:
> -	*ptr = NULL;
> +	*ptr = root_mem_cgroup;
>  	return 0;
>  }
>  
> -- 

I'm dubious about this patch: certainly you have not fully justified it.

I speak from experience: I did *exactly* the same at "bypass" when
I introduced our mem_cgroup_reset_page(), which corresponds to your
mem_cgroup_reset_owner(); it seemed right to me that a successful
(return 0) call to try_charge() should provide a good *ptr.

But others (Ying and Greg) pointed out that it changes the semantics
of __mem_cgroup_try_charge() in this case, so you need to justify the
change to all those places which do something like "if (ret || !memcg)"
after calling it.  Perhaps it is a good change everywhere, but that's
not obvious, so we chose caution.

Doesn't it lead to bypass pages being marked as charged to root, so
they don't get charged to the right owner next time they're touched?

In our internal kernel, I restored "bypass" to set *ptr = NULL as
before, but routed those callers that need it to continue on to
__mem_cgroup_commit_charge() when it's NULL, and let that do a
quick little mem_cgroup_reset_page() to root_mem_cgroup for this.

But I was growing tired of mem_cgroup_reset_page() when I prepared
the rollup I posted two weeks ago, it adds overhead where we don't
want it, so I found a way to avoid it completely.

What you're doing with mem_cgroup_reset_owner() seems reasonable to
me as a phase to go through (though there's probably more callsites
to be found - sorry to be unhelpfully mysterious about that, but
just because per-memcg-lru-locking needed them doesn't imply that
your patchset needs them), but I expect to (offer a patch to) remove
it later.

I am intending to rebase upon your patches, or at least the ones
which akpm has already taken in (I've not studied the pcg flag ones,
more noise than I want at the moment).  I'm waiting for those to
appear in a linux-next, disappointed that they weren't in today's.

(But I'm afraid my patches will then clash with Mel's new lru work.)

I have been running successfully on several machines with an
approximation to what I expect linux-next to be when it has your
patches in.  Ran very stably on two, but one hangs in reclaim after
a few hours, that's high on my list to investigate (you made no
change to vmscan.c, maybe the problem comes from Hannes's earlier
patches, but I hadn't noticed it with those alone).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
