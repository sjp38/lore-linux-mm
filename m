Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 233376B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 08:41:23 -0400 (EDT)
Date: Tue, 10 Jul 2012 14:41:08 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] shmem: fix negative rss in memcg memory.stat
Message-ID: <20120710124107.GE1779@cmpxchg.org>
References: <alpine.LSU.2.00.1207091533001.2051@eggly.anvils>
 <alpine.LSU.2.00.1207091541310.2051@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207091541310.2051@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 09, 2012 at 03:44:24PM -0700, Hugh Dickins wrote:
> When adding the page_private checks before calling shmem_replace_page(),
> I did realize that there is a further race, but thought it too unlikely
> to need a hurried fix.
> 
> But independently I've been chasing why a mem cgroup's memory.stat
> sometimes shows negative rss after all tasks have gone: I expected it
> to be a stats gathering bug, but actually it's shmem swapping's fault.
> 
> It's an old surprise, that when you lock_page(lookup_swap_cache(swap)),
> the page may have been removed from swapcache before getting the lock; 
> or it may have been freed and reused and be back in swapcache; and it
> can even be using the same swap location as before (page_private same).
> 
> The swapoff case is already secure against this (swap cannot be reused
> until the whole area has been swapped off, and a new swapped on); and
> shmem_getpage_gfp() is protected by shmem_add_to_page_cache()'s check
> for the expected radix_tree entry - but a little too late.
> 
> By that time, we might have already decided to shmem_replace_page():
> I don't know of a problem from that, but I'd feel more at ease not to
> do so spuriously.  And we have already done mem_cgroup_cache_charge(),
> on perhaps the wrong mem cgroup: and this charge is not then undone on
> the error path, because PageSwapCache ends up preventing that.

I couldn't see anything wrong with shmem_replace_page(), either, but
maybe the comment in its error path could be updated as the callsite
does not rely on page_private alone anymore to confirm correct swap.

> It's this last case which causes the occasional negative rss in
> memory.stat: the page is charged here as cache, but (sometimes) found
> to be anon when eventually it's uncharged - and in between, it's an
> undeserved charge on the wrong memcg.
> 
> Fix this by adding an earlier check on the radix_tree entry: it's
> inelegant to descend the tree twice, but swapping is not the fast path,
> and a better solution would need a pair (try+commit) of memcg calls,
> and a rework of shmem_replace_page() to keep out of the swapcache.
> 
> We can use the added shmem_confirm_swap() function to replace the
> find_get_page+page_cache_release we were already doing on the error
> path.  And add a comment on that -EEXIST: it seems a peculiar errno
> to be using, but originates from its use in radix_tree_insert().
> 
> [It can be surprising to see positive rss left in a memcg's memory.stat
> after all tasks have gone, since it is supposed to count anonymous but
> not shmem.  Aside from sharing anon pages via fork with a task in some
> other memcg, it often happens after swapping: because a swap page can't
> be freed while under writeback, nor while locked.  So it's not an error,
> and these residual pages are easily freed once pressure demands.]
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Michal Hocko <mhocko@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
