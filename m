Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 5DD036B023B
	for <linux-mm@kvack.org>; Wed,  5 May 2010 08:48:54 -0400 (EDT)
Subject: Re: [PATCH] cache last free vmap_area to avoid restarting beginning
From: Steven Whitehouse <swhiteho@redhat.com>
In-Reply-To: <1272821394.2100.224.camel@barrios-desktop>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
	 <m2g28c262361004140813j5d70a80fy1882d01436d136a6@mail.gmail.com>
	 <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <1271681929.7196.175.camel@localhost.localdomain>
	 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
	 <1272548602.7196.371.camel@localhost.localdomain>
	 <1272821394.2100.224.camel@barrios-desktop>
Content-Type: text/plain
Date: Wed, 05 May 2010 13:48:48 +0100
Message-Id: <1273063728.7196.385.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 2010-05-03 at 02:29 +0900, Minchan Kim wrote:
> Hi, Steven. 
> 
> Sorry for lazy response.
> I wanted to submit the patch which implement Nick's request whole.
> And unfortunately, I am so busy now. 
> But if it's urgent, I want to submit this one firstly and 
> at next version, maybe I will submit remained TODO things 
> after middle of May.
> 
> I think this patch can't make regression other usages.
> Nick. What do you think about?
> 
I guess the question is whether the remaining items are essential for
correct functioning of this patch, or whether they are "it would be nice
if" items. I suspect that they are the latter (I'm not a VM expert, but
from the brief descriptions it looks like that to me) in which case I'd
suggest send the currently existing patch first and the following up
with the remaining changes later.

We have got a nice speed up with your current patch and so far as I'm
aware not introduced any new bugs or regressions with it.

Nick, does that sound ok?

Steve.

> == CUT_HERE ==
> >From c93437583b5ff476fcfe13901898f981baa672d8 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Mon, 3 May 2010 01:43:30 +0900
> Subject: [PATCH] cache last free vmap_area to avoid restarting beginning.
> 
> Steven Whitehouse reported that GFS2 had a regression about vmalloc.
> He measured some test module to compare vmalloc speed on the two cases.
> 
> 1. lazy TLB flush
> 2. disable lazy TLB flush by hard coding
> 
> 1)
> vmalloc took 148798983 us
> vmalloc took 151664529 us
> vmalloc took 152416398 us
> vmalloc took 151837733 us
> 
> 2)
> vmalloc took 15363634 us
> vmalloc took 15358026 us
> vmalloc took 15240955 us
> vmalloc took 15402302 us
> 
> You can refer test module and Steven's patch
> with https://bugzilla.redhat.com/show_bug.cgi?id=581459.
> 
> The cause is that lazy TLB flush can delay release vmap_area.
> OTOH, To find free vmap_area is always started from beginnig of rbnode.
> So before lazy TLB flush happens, searching free vmap_area could take
> long time.
> 
> Steven's experiment can do 9 times faster than old.
> But Always disable lazy TLB flush is not good.
> 
> This patch caches next free vmap_area to accelerate.
> In my test case, following as.
> 
> The result is following as.
> 
> 1) vanilla
> elapsed time                    # search of rbtree
> vmalloc took 49121724 us                5535
> vmalloc took 50675245 us                5535
> vmalloc took 48987711 us                5535
> vmalloc took 54232479 us                5535
> vmalloc took 50258117 us                5535
> vmalloc took 49424859 us                5535
> 
> 3) Steven's patch
> 
> elapsed time                    # search of rbtree
> vmalloc took 11363341 us                62
> vmalloc took 12798868 us                62
> vmalloc took 13247942 us                62
> vmalloc took 11434647 us                62
> vmalloc took 13221733 us                62
> vmalloc took 12134019 us                62
> 
> 2) my patch(vmap cache)
> elapsed time                    # search of rbtree
> vmalloc took 5159893 us                 8
> vmalloc took 5124434 us                 8
> vmalloc took 5123291 us                 8
> vmalloc took 5145396 us                 12
> vmalloc took 5163605 us                 8
> vmalloc took 5945663 us                 8
> 
> Nick commented some advise.
> "
> - invalidating the cache in the case of vstart being decreased.
> - Don't unconditionally reset the cache to the last vm area freed,
>  because you might have a higher area freed after a lower area. Only
>  reset if the freed area is lower.
> - Do keep a cached hole size, so smaller lookups can restart a full
>  search.
> - refactoring rbtree search code to manage alloc_vmap_area complexity
> "
> 
> Now, it's on my TODO list.
> 
> Cc: Nick Piggin <npiggin@suse.de>
> Reported-by: Steven Whitehouse <swhiteho@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Tested-by: Steven Whitehouse <swhiteho@redhat.com>
> ---
>  mm/vmalloc.c |   49 +++++++++++++++++++++++++++++++++++--------------
>  1 files changed, 35 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ae00746..56f09ec 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -263,6 +263,7 @@ struct vmap_area {
>  
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  static struct rb_root vmap_area_root = RB_ROOT;
> +static struct rb_node *free_vmap_cache;
>  static LIST_HEAD(vmap_area_list);
>  static unsigned long vmap_area_pcpu_hole;
>  
> @@ -319,6 +320,7 @@ static void __insert_vmap_area(struct vmap_area *va)
>  
>  static void purge_vmap_area_lazy(void);
>  
> +unsigned long max_lookup_count;
>  /*
>   * Allocate a region of KVA of the specified size and alignment, within the
>   * vstart and vend.
> @@ -332,6 +334,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  	struct rb_node *n;
>  	unsigned long addr;
>  	int purged = 0;
> +	int lookup_cache = 0;
> +	struct vmap_area *first;
>  
>  	BUG_ON(!size);
>  	BUG_ON(size & ~PAGE_MASK);
> @@ -342,29 +346,42 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  		return ERR_PTR(-ENOMEM);
>  
>  retry:
> +	first = NULL;
>  	addr = ALIGN(vstart, align);
>  
>  	spin_lock(&vmap_area_lock);
>  	if (addr + size - 1 < addr)
>  		goto overflow;
>  
> -	/* XXX: could have a last_hole cache */
>  	n = vmap_area_root.rb_node;
> -	if (n) {
> -		struct vmap_area *first = NULL;
> +	if (free_vmap_cache && !purged) {
> +		struct vmap_area *cache;
> +		cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> +		if (cache->va_start >= addr && cache->va_end < vend) {
> +			lookup_cache = 1;
> +			n = free_vmap_cache;
> +		}
> +	}
>  
> -		do {
> -			struct vmap_area *tmp;
> -			tmp = rb_entry(n, struct vmap_area, rb_node);
> -			if (tmp->va_end >= addr) {
> -				if (!first && tmp->va_start < addr + size)
> +	if (n) {
> +		if (!lookup_cache) {
> +			do {
> +				struct vmap_area *tmp;
> +				tmp = rb_entry(n, struct vmap_area, rb_node);
> +				if (tmp->va_end >= addr) {
> +					if (!first && tmp->va_start < addr + size)
> +						first = tmp;
> +					n = n->rb_left;
> +				} else {
>  					first = tmp;
> -				n = n->rb_left;
> -			} else {
> -				first = tmp;
> -				n = n->rb_right;
> -			}
> -		} while (n);
> +					n = n->rb_right;
> +				}
> +			} while (n);
> +		}
> +		else {
> +			first = rb_entry(n, struct vmap_area, rb_node);
> +			addr = first->va_start;
> +		}
>  
>  		if (!first)
>  			goto found;
> @@ -396,6 +413,7 @@ overflow:
>  		if (!purged) {
>  			purge_vmap_area_lazy();
>  			purged = 1;
> +			lookup_cache = 0;
>  			goto retry;
>  		}
>  		if (printk_ratelimit())
> @@ -412,6 +430,7 @@ overflow:
>  	va->va_end = addr + size;
>  	va->flags = 0;
>  	__insert_vmap_area(va);
> +	free_vmap_cache = &va->rb_node;
>  	spin_unlock(&vmap_area_lock);
>  
>  	return va;
> @@ -426,7 +445,9 @@ static void rcu_free_va(struct rcu_head *head)
>  
>  static void __free_vmap_area(struct vmap_area *va)
>  {
> +	struct rb_node *prev;
>  	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> +	free_vmap_cache = rb_prev(&va->rb_node);
>  	rb_erase(&va->rb_node, &vmap_area_root);
>  	RB_CLEAR_NODE(&va->rb_node);
>  	list_del_rcu(&va->list);
> -- 
> 1.7.0.5
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
