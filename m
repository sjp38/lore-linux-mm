Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E22B36B01B4
	for <linux-mm@kvack.org>; Sat, 22 May 2010 05:54:01 -0400 (EDT)
Received: by pwi7 with SMTP id 7so839222pwi.14
        for <linux-mm@kvack.org>; Sat, 22 May 2010 02:54:00 -0700 (PDT)
Subject: Re: [PATCH] cache last free vmap_area to avoid restarting beginning
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100505161632.GB5378@laptop>
References: <1271262948.2233.14.camel@barrios-desktop>
	 <1271320388.2537.30.camel@localhost>
	 <1271350270.2013.29.camel@barrios-desktop>
	 <1271427056.7196.163.camel@localhost.localdomain>
	 <1271603649.2100.122.camel@barrios-desktop>
	 <1271681929.7196.175.camel@localhost.localdomain>
	 <h2g28c262361004190712v131bf7a3q2a82fd1168faeefe@mail.gmail.com>
	 <1272548602.7196.371.camel@localhost.localdomain>
	 <1272821394.2100.224.camel@barrios-desktop>
	 <1273063728.7196.385.camel@localhost.localdomain>
	 <20100505161632.GB5378@laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Sat, 22 May 2010 18:53:53 +0900
Message-ID: <1274522033.1953.21.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi, Nick.
Sorry for late review. 

On Thu, 2010-05-06 at 02:16 +1000, Nick Piggin wrote:
> On Wed, May 05, 2010 at 01:48:48PM +0100, Steven Whitehouse wrote:
> > Hi,
> > 
> > On Mon, 2010-05-03 at 02:29 +0900, Minchan Kim wrote:
> > > Hi, Steven. 
> > > 
> > > Sorry for lazy response.
> > > I wanted to submit the patch which implement Nick's request whole.
> > > And unfortunately, I am so busy now. 
> > > But if it's urgent, I want to submit this one firstly and 
> > > at next version, maybe I will submit remained TODO things 
> > > after middle of May.
> > > 
> > > I think this patch can't make regression other usages.
> > > Nick. What do you think about?
> > > 
> > I guess the question is whether the remaining items are essential for
> > correct functioning of this patch, or whether they are "it would be nice
> > if" items. I suspect that they are the latter (I'm not a VM expert, but
> > from the brief descriptions it looks like that to me) in which case I'd
> > suggest send the currently existing patch first and the following up
> > with the remaining changes later.
> > 
> > We have got a nice speed up with your current patch and so far as I'm
> > aware not introduced any new bugs or regressions with it.
> > 
> > Nick, does that sound ok?
> 
> Just got around to looking at it again. I definitely agree we need to
> fix the regression, however I'm concerned about introducing other
> possible problems while doing that.
> 
> The following patch should (modulo bugs, but it's somewhat tested) give
> no difference in the allocation patterns, so won't introduce virtual
> memory layout changes.
> 
> Any chance you could test it?
> 
> ---
>  mm/vmalloc.c |   49 +++++++++++++++++++++++++++++++++++--------------
>  1 files changed, 35 insertions(+), 14 deletions(-)
> 
> Index: linux-2.6/mm/vmalloc.c
> ===================================================================
> --- linux-2.6.orig/mm/vmalloc.c
> +++ linux-2.6/mm/vmalloc.c
> @@ -262,8 +262,13 @@ struct vmap_area {
>  };
>  
>  static DEFINE_SPINLOCK(vmap_area_lock);
> -static struct rb_root vmap_area_root = RB_ROOT;
>  static LIST_HEAD(vmap_area_list);
> +static struct rb_root vmap_area_root = RB_ROOT;
> +
> +static struct rb_node *free_vmap_cache;
> +static unsigned long cached_hole_size;
> +static unsigned long cached_start;
> +
>  static unsigned long vmap_area_pcpu_hole;
>  
>  static struct vmap_area *__find_vmap_area(unsigned long addr)
> @@ -332,6 +337,7 @@ static struct vmap_area *alloc_vmap_area
>  	struct rb_node *n;
>  	unsigned long addr;
>  	int purged = 0;
> +	struct vmap_area *first;
>  
>  	BUG_ON(!size);
>  	BUG_ON(size & ~PAGE_MASK);
> @@ -348,11 +354,23 @@ retry:
>  	if (addr + size - 1 < addr)
>  		goto overflow;
>  
> -	/* XXX: could have a last_hole cache */
> -	n = vmap_area_root.rb_node;
> -	if (n) {
> -		struct vmap_area *first = NULL;
> +	if (size <= cached_hole_size || addr < cached_start || !free_vmap_cache) {

Do we need !free_vmap_cache check?
In __free_vmap_area, we already reset whole of variables when free_vmap_cache = NULL.

> +		cached_hole_size = 0;
> +		cached_start = addr;
> +		free_vmap_cache = NULL;
> +	}
>  
> +	/* find starting point for our search */
> +	if (free_vmap_cache) {
> +		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> +		addr = ALIGN(first->va_end + PAGE_SIZE, align);
> +
> +	} else {
> +		n = vmap_area_root.rb_node;
> +		if (!n)
> +			goto found;
> +
> +		first = NULL;
>  		do {
>  			struct vmap_area *tmp;
>  			tmp = rb_entry(n, struct vmap_area, rb_node);
> @@ -369,26 +387,36 @@ retry:
>  		if (!first)
>  			goto found;
>  
> -		if (first->va_end < addr) {
> +		if (first->va_start < addr) {

I can't understand your intention.
Why do you change va_end with va_start?

> +			BUG_ON(first->va_end < addr);

And Why do you put this BUG_ON in here?
Could you elaborate on logic?

>  			n = rb_next(&first->rb_node);
> +			addr = ALIGN(first->va_end + PAGE_SIZE, align);
>  			if (n)
>  				first = rb_entry(n, struct vmap_area, rb_node);
>  			else
>  				goto found;
>  		}
> +		BUG_ON(first->va_start < addr);

Ditto. 

> +		if (addr + cached_hole_size < first->va_start)
> +			cached_hole_size = first->va_start - addr;
> +	}
>  
> -		while (addr + size > first->va_start && addr + size <= vend) {
> -			addr = ALIGN(first->va_end + PAGE_SIZE, align);
> -			if (addr + size - 1 < addr)
> -				goto overflow;
> +	/* from the starting point, walk areas until a suitable hole is found */
>  
> -			n = rb_next(&first->rb_node);
> -			if (n)
> -				first = rb_entry(n, struct vmap_area, rb_node);
> -			else
> -				goto found;
> -		}
> +	while (addr + size > first->va_start && addr + size <= vend) {
> +		if (addr + cached_hole_size < first->va_start)
> +			cached_hole_size = first->va_start - addr;
> +		addr = ALIGN(first->va_end + PAGE_SIZE, align);
> +		if (addr + size - 1 < addr)
> +			goto overflow;
> +
> +		n = rb_next(&first->rb_node);
> +		if (n)
> +			first = rb_entry(n, struct vmap_area, rb_node);
> +		else
> +			goto found;
>  	}
> +
>  found:
>  	if (addr + size > vend) {
>  overflow:
> @@ -412,6 +440,7 @@ overflow:
>  	va->va_end = addr + size;
>  	va->flags = 0;
>  	__insert_vmap_area(va);
> +	free_vmap_cache = &va->rb_node;
>  	spin_unlock(&vmap_area_lock);
>  
>  	return va;
> @@ -427,6 +456,21 @@ static void rcu_free_va(struct rcu_head
>  static void __free_vmap_area(struct vmap_area *va)
>  {
>  	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> +
> +	if (free_vmap_cache) {
> +		if (va->va_end < cached_start) {
> +			cached_hole_size = 0;
> +			cached_start = 0;
> +			free_vmap_cache = NULL;
> +		} else {
> +			struct vmap_area *cache;
> +			cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> +			if (va->va_start <= cache->va_start) {
> +				free_vmap_cache = rb_prev(&va->rb_node);
> +				cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
> +			}
> +		}
> +	}
>  	rb_erase(&va->rb_node, &vmap_area_root);
>  	RB_CLEAR_NODE(&va->rb_node);
>  	list_del_rcu(&va->list);

Hmm. I will send refactoring version soon. 
If you don't mind, let's discuss in there. :)

-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
