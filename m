Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B3BC46B0088
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 21:47:14 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so8855035pdb.18
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 18:47:14 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id nq15si19260918pdb.212.2014.11.23.18.47.11
        for <linux-mm@kvack.org>;
        Sun, 23 Nov 2014 18:47:13 -0800 (PST)
Date: Mon, 24 Nov 2014 11:50:07 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 1/7] mm/page_ext: resurrect struct page extending code
 for debugging
Message-ID: <20141124025007.GA10828@js1304-P5Q-DELUXE>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1416557646-21755-2-git-send-email-iamjoonsoo.kim@lge.com>
 <20141121153731.b68bd8f0240a2eccb142e864@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141121153731.b68bd8f0240a2eccb142e864@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 21, 2014 at 03:37:31PM -0800, Andrew Morton wrote:
> On Fri, 21 Nov 2014 17:14:00 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > When we debug something, we'd like to insert some information to
> > every page. For this purpose, we sometimes modify struct page itself.
> > But, this has drawbacks. First, it requires re-compile. This makes us
> > hesitate to use the powerful debug feature so development process is
> > slowed down. And, second, sometimes it is impossible to rebuild the kernel
> > due to third party module dependency. At third, system behaviour would be
> > largely different after re-compile, because it changes size of struct
> > page greatly and this structure is accessed by every part of kernel.
> > Keeping this as it is would be better to reproduce errornous situation.
> > 
> > This feature is intended to overcome above mentioned problems. This feature
> > allocates memory for extended data per page in certain place rather than
> > the struct page itself. This memory can be accessed by the accessor
> > functions provided by this code. During the boot process, it checks whether
> > allocation of huge chunk of memory is needed or not. If not, it avoids
> > allocating memory at all. With this advantage, we can include this feature
> > into the kernel in default and can avoid rebuild and solve related problems.
> > 
> > Until now, memcg uses this technique. But, now, memcg decides to embed
> > their variable to struct page itself and it's code to extend struct page
> > has been removed. I'd like to use this code to develop debug feature,
> > so this patch resurrect it.
> > 
> > To help these things to work well, this patch introduces two callbacks
> > for clients. One is the need callback which is mandatory if user wants
> > to avoid useless memory allocation at boot-time. The other is optional,
> > init callback, which is used to do proper initialization after memory
> > is allocated. Detailed explanation about purpose of these functions is
> > in code comment. Please refer it.
> > 
> > Others are completely same with previous extension code in memcg.
> >
> > ...
> >
> > +static bool __init invoke_need_callbacks(void)
> > +{
> > +	int i;
> > +	int entries = ARRAY_SIZE(page_ext_ops);
> > +
> > +	for (i = 0; i < entries; i++) {
> > +		if (page_ext_ops[i]->need && page_ext_ops[i]->need())
> > +			return true;
> > +	}
> > +
> > +	return false;
> > +}
> > +
> > +static void __init invoke_init_callbacks(void)
> > +{
> > +	int i;
> > +	int entries = sizeof(page_ext_ops) / sizeof(page_ext_ops[0]);
> 
> ARRAY_SIZE()

Oops... Sorry. I will fix it.

> 
> > +	for (i = 0; i < entries; i++) {
> > +		if (page_ext_ops[i]->init)
> > +			page_ext_ops[i]->init();
> > +	}
> > +}
> > +
> >
> > ...
> >
> > +void __init page_ext_init_flatmem(void)
> > +{
> > +
> > +	int nid, fail;
> > +
> > +	if (!invoke_need_callbacks)
> > +		return;
> > +
> > +	for_each_online_node(nid)  {
> > +		fail = alloc_node_page_ext(nid);
> > +		if (fail)
> > +			goto fail;
> > +	}
> > +	pr_info("allocated %ld bytes of page_ext\n", total_usage);
> > +	invoke_init_callbacks();
> > +	return;
> > +
> > +fail:
> > +	pr_crit("allocation of page_ext failed.\n");
> > +	panic("Out of memory");
> 
> Did we really need to panic the machine?  The situation should be
> pretty easily recoverable by disabling the clients.  I guess it's OK as
> long as page_ext is being used for kernel developer debug things.

I think that panic() would be better. If the feature is disabled silently
or with some printk output, user can't easily notice that situation
and will try to do real work for debugging. This would waste user's time
so panic() looks better to me.

> > +}
> > +
> 
> We'll need this to fix the build.  I'll queue it up.

Thank you!

> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: include/linux/kmemleak.h: needs slab.h
> 
> include/linux/kmemleak.h: In function 'kmemleak_alloc_recursive':
> include/linux/kmemleak.h:43: error: 'SLAB_NOLEAKTRACE' undeclared (first use in this function)
> 
> --- a/include/linux/kmemleak.h~include-linux-kmemleakh-needs-slabh
> +++ a/include/linux/kmemleak.h
> @@ -21,6 +21,8 @@
>  #ifndef __KMEMLEAK_H
>  #define __KMEMLEAK_H
>  
> +#include <linux/slab.h>
> +
>  #ifdef CONFIG_DEBUG_KMEMLEAK
>  
>  extern void kmemleak_init(void) __ref;
> 
> 
> 
> And here are a couple of tweaks for this patch:

Okay. I will include below changes in next spin.

Thanks.

> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-page_ext-resurrect-struct-page-extending-code-for-debugging-fix
> 
> use ARRAY_SIZE, clean up 80-col tricks
> 
> --- a/mm/page_ext.c~mm-page_ext-resurrect-struct-page-extending-code-for-debugging-fix
> +++ a/mm/page_ext.c
> @@ -71,7 +71,7 @@ static bool __init invoke_need_callbacks
>  static void __init invoke_init_callbacks(void)
>  {
>  	int i;
> -	int entries = sizeof(page_ext_ops) / sizeof(page_ext_ops[0]);
> +	int entries = ARRAY_SIZE(page_ext_ops);
>  
>  	for (i = 0; i < entries; i++) {
>  		if (page_ext_ops[i]->init)
> @@ -81,7 +81,6 @@ static void __init invoke_init_callbacks
>  
>  #if !defined(CONFIG_SPARSEMEM)
>  
> -
>  void __meminit pgdat_page_ext_init(struct pglist_data *pgdat)
>  {
>  	pgdat->node_page_ext = NULL;
> @@ -232,8 +231,9 @@ static void free_page_ext(void *addr)
>  		vfree(addr);
>  	} else {
>  		struct page *page = virt_to_page(addr);
> -		size_t table_size =
> -			sizeof(struct page_ext) * PAGES_PER_SECTION;
> +		size_t table_size;
> +
> +		table_size = sizeof(struct page_ext) * PAGES_PER_SECTION;
>  
>  		BUG_ON(PageReserved(page));
>  		free_pages_exact(addr, table_size);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
