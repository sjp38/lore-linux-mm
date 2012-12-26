Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DE68C6B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 21:16:42 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 066353EE0C7
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 11:16:41 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD0D645DE84
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 11:16:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B26845DE76
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 11:16:40 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D2811DB8050
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 11:16:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19FE6E38003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2012 11:16:40 +0900 (JST)
Message-ID: <50DA5DE3.9060809@jp.fujitsu.com>
Date: Wed, 26 Dec 2012 11:16:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] sl[auo]b: retry allocation once in case of failure.
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <1355925702-7537-4-git-send-email-glommer@parallels.com>
In-Reply-To: <1355925702-7537-4-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

(2012/12/19 23:01), Glauber Costa wrote:
> When we are out of space in the caches, we will try to allocate a new
> page.  If we still fail, the page allocator will try to free pages
> through direct reclaim. Which means that if an object allocation failed
> we can be sure that no new pages could be given to us, even though
> direct reclaim was likely invoked.
> 
> However, direct reclaim will also try to shrink objects from registered
> shrinkers. They won't necessarily free a full page, but if our cache
> happens to be one with a shrinker, this may very well open up the space
> we need. So we retry the allocation in this case.
> 
> We can't know for sure if this happened. So the best we can do is try to
> derive from our allocation flags how likely it is for direct reclaim to
> have been called, and retry if we conclude that this is highly likely
> (GFP_NOWAIT | GFP_FS | !GFP_NORETRY).
> 
> The common case is for the allocation to succeed. So we carefuly insert
> a likely branch for that case.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: Mel Gorman <mgorman@suse.de>
> ---
>   mm/slab.c |  2 ++
>   mm/slab.h | 42 ++++++++++++++++++++++++++++++++++++++++++
>   mm/slob.c | 27 +++++++++++++++++++++++----
>   mm/slub.c | 26 ++++++++++++++++++++------
>   4 files changed, 87 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index a98295f..7e82f99 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3535,6 +3535,8 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
>   	cache_alloc_debugcheck_before(cachep, flags);
>   	local_irq_save(save_flags);
>   	objp = __do_slab_alloc_node(cachep, flags, nodeid);
> +	if (slab_should_retry(objp, flags))
> +		objp = __do_slab_alloc_node(cachep, flags, nodeid);

3 questions. 

1. why can't we do retry in memcg's code (or kmem/memcg code) rather than slab.c ?
2. It should be retries even if memory allocator returns NULL page ?
3. What's relationship with oom-killer ? The first __do_slab_alloc() will not
   invoke oom-killer and returns NULL ?

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
