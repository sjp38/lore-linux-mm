Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9C5D26B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 21:46:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 199993EE0BD
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:46:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EB64E45DE51
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:46:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C9E4A45DE4E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:46:27 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCC11DB803E
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:46:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D2ED1DB8041
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 10:46:27 +0900 (JST)
Message-ID: <4F975703.3080005@jp.fujitsu.com>
Date: Wed, 25 Apr 2012 10:44:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/23] slab: provide kmalloc_no_account
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1335138820-26590-5-git-send-email-glommer@parallels.com>
In-Reply-To: <1335138820-26590-5-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

(2012/04/23 8:53), Glauber Costa wrote:

> Some allocations need to be accounted to the root memcg regardless
> of their context. One trivial example, is the allocations we do
> during the memcg slab cache creation themselves. Strictly speaking,
> they could go to the parent, but it is way easier to bill them to
> the root cgroup.
> 
> Only generic kmalloc allocations are allowed to be bypassed.
> 
> The function is not exported, because drivers code should always
> be accounted.
> 
> This code is mosly written by Suleiman Souhlal.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>


Seems reasonable.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm...but can't we find the 'context' in automatic way ?

-Kame

> ---
>  include/linux/slab_def.h |    1 +
>  mm/slab.c                |   23 +++++++++++++++++++++++
>  2 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index 06e4a3e..54d25d7 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -114,6 +114,7 @@ extern struct cache_sizes malloc_sizes[];
>  
>  void *kmem_cache_alloc(struct kmem_cache *, gfp_t);
>  void *__kmalloc(size_t size, gfp_t flags);
> +void *kmalloc_no_account(size_t size, gfp_t flags);
>  
>  #ifdef CONFIG_TRACING
>  extern void *kmem_cache_alloc_trace(size_t size,
> diff --git a/mm/slab.c b/mm/slab.c
> index c4ef684..13948c3 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3960,6 +3960,29 @@ void *__kmalloc(size_t size, gfp_t flags)
>  }
>  EXPORT_SYMBOL(__kmalloc);
>  
> +static __always_inline void *__do_kmalloc_no_account(size_t size, gfp_t flags,
> +						     void *caller)
> +{
> +	struct kmem_cache *cachep;
> +	void *ret;
> +
> +	cachep = __find_general_cachep(size, flags);
> +	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
> +		return cachep;
> +
> +	ret = __cache_alloc(cachep, flags, caller);
> +	trace_kmalloc((unsigned long)caller, ret, size,
> +		      cachep->buffer_size, flags);
> +
> +	return ret;
> +}
> +
> +void *kmalloc_no_account(size_t size, gfp_t flags)
> +{
> +	return __do_kmalloc_no_account(size, flags,
> +				       __builtin_return_address(0));
> +}
> +
>  void *__kmalloc_track_caller(size_t size, gfp_t flags, unsigned long caller)
>  {
>  	return __do_kmalloc(size, flags, (void *)caller);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
