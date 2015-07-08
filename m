Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 746CB6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:18:17 -0400 (EDT)
Received: by igoe12 with SMTP id e12so2321538igo.1
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:18:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f5si3849202iof.95.2015.07.08.16.18.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 16:18:17 -0700 (PDT)
Date: Wed, 8 Jul 2015 16:18:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/7] mm: introduce kvmalloc and kvmalloc_node
Message-Id: <20150708161815.bdff609d77868dbdc2e1ce64@linux-foundation.org>
In-Reply-To: <alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1507071058350.23387@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.LRH.2.02.1507071109490.23387@file01.intranet.prod.int.rdu2.redhat.com>
	<20150707144117.5b38ac38efda238af8a1f536@linux-foundation.org>
	<alpine.LRH.2.02.1507081855340.32526@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mike Snitzer <msnitzer@redhat.com>, "Alasdair G. Kergon" <agk@redhat.com>, Edward Thornber <thornber@redhat.com>, David Rientjes <rientjes@google.com>, Vivek Goyal <vgoyal@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, Linus Torvalds <torvalds@linux-foundation.org>

On Wed, 8 Jul 2015 19:03:08 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:

> 
> 
> On Tue, 7 Jul 2015, Andrew Morton wrote:
> 
> > On Tue, 7 Jul 2015 11:10:09 -0400 (EDT) Mikulas Patocka <mpatocka@redhat.com> wrote:
> > 
> > > Introduce the functions kvmalloc and kvmalloc_node. These functions
> > > provide reliable allocation of object of arbitrary size. They attempt to
> > > do allocation with kmalloc and if it fails, use vmalloc. Memory allocated
> > > with these functions should be freed with kvfree.
> > 
> > Sigh.  We've resisted doing this because vmalloc() is somewhat of a bad
> > thing, and we don't want to make it easy for people to do bad things.
> > 
> > And vmalloc is bad because a) it's slow and b) it does GFP_KERNEL
> > allocations for page tables and c) it is susceptible to arena
> > fragmentation.
> 
> This patch makes less use of vmalloc.
> 
> The typical pattern is that someone notices random failures due to memory 
> fragmentation in some subsystem that uses large kmalloc - so he replaces 
> kmalloc with vmalloc - and the code gets slower because of that. With this 
> patch, you can replace many vmalloc users with kvmalloc - and vmalloc will 
> be used only very rarely, when the memory is too fragmented for kmalloc.

Yes, I guess there is that.

> Here I'm sending next version of the patch with comments added.

You didn't like kvzalloc()?  We can always add those later...

> --- linux-4.2-rc1.orig/include/linux/mm.h	2015-07-07 15:58:11.000000000 +0200
> +++ linux-4.2-rc1/include/linux/mm.h	2015-07-08 19:22:24.000000000 +0200
> @@ -400,6 +400,11 @@ static inline int is_vmalloc_or_module_a
>  }
>  #endif
>  
> +extern void *kvmalloc_node(size_t size, gfp_t gfp, int node);
> +static inline void *kvmalloc(size_t size, gfp_t gfp)
> +{
> +	return kvmalloc_node(size, gfp, NUMA_NO_NODE);
> +}
>  extern void kvfree(const void *addr);
>  
>  static inline void compound_lock(struct page *page)
> Index: linux-4.2-rc1/mm/util.c
> ===================================================================
> --- linux-4.2-rc1.orig/mm/util.c	2015-07-07 15:58:11.000000000 +0200
> +++ linux-4.2-rc1/mm/util.c	2015-07-08 19:22:26.000000000 +0200
> @@ -316,6 +316,61 @@ unsigned long vm_mmap(struct file *file,
>  }
>  EXPORT_SYMBOL(vm_mmap);
>  
> +void *kvmalloc_node(size_t size, gfp_t gfp, int node)
> +{
> +	void *p;
> +	unsigned uninitialized_var(noio_flag);
> +
> +	/* vmalloc doesn't support no-wait allocations */
> +	WARN_ON_ONCE(!(gfp & __GFP_WAIT));
> +
> +	if (likely(size <= KMALLOC_MAX_SIZE)) {
> +		/*
> +		 * Use __GFP_NORETRY so that we don't loop waiting for the
> +		 *	allocation - we don't have to loop here, if the memory
> +		 *	is too fragmented, we fallback to vmalloc.

I'm not sure about this decision.  The direct reclaim retry code is the
normal default behaviour and becomes more important with larger allocation
attempts.  So why turn it off, and make it more likely that we return
vmalloc memory?

> +		 * Use __GFP_NOMEMALLOC to not allocate from emergency reserves.
> +		 *	This allocation can fail, so we don't need to use
> +		 *	emergency reserves.
> +		 * Use __GFP_NOWARN to avoid the warning when the allocation
> +		 *	fails because it was too large or because of the above
> +		 *	two flags. There is no need to warn the user because
> +		 *	there is no functionality lost when this allocation
> +		 *	fails - we just fallback to vmalloc.
> +		 */
> +		p = kmalloc_node(size, gfp |
> +			__GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN, node);
> +		if (likely(p != NULL))
> +			return p;
> +	}
> +	if ((gfp & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS)) {
> +		/*
> +		 * vmalloc allocates page tables with GFP_KERNEL, regardless
> +		 * of GFP flags passed to it. If we are no GFP_NOIO context,
> +		 * we call memalloc_noio_save, so that all allocations are
> +		 * implicitly done with GFP_NOIO.
> +		 */
> +		noio_flag = memalloc_noio_save();
> +		/*
> +		 * GFP_NOIO allocations cannot rely on the swapper to free some
> +		 *	memory, so __GFP_HIGH to access the emergency pool, so
> +		 *	that the failure is less likely.
> +		 */
> +		gfp |= __GFP_HIGH;
> +	}
> +	/*
> +	 * Use __GFP_REPEAT so that the allocation less likely fails.
> +	 * Use __GFP_HIGHMEM so that it is possible to allocate pages from high
> +	 *	memory.
> +	 */
> +	p = __vmalloc_node_flags(size, node,
> +				 gfp | __GFP_REPEAT | __GFP_HIGHMEM);
> +	if ((gfp & (__GFP_IO | __GFP_FS)) != (__GFP_IO | __GFP_FS))
> +		memalloc_noio_restore(noio_flag);
> +	return p;
> +}
> +EXPORT_SYMBOL(kvmalloc_node);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
