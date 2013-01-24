Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 04F736B0002
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 19:53:51 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id wy12so3680615pbc.21
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:53:51 -0800 (PST)
Message-ID: <1358988824.3351.5.camel@kernel>
Subject: Re: FIX [1/2] slub: Do not dereference NULL pointer in node_match
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 23 Jan 2013 18:53:44 -0600
In-Reply-To: <0000013c695fbd30-9023bc55-f780-4d44-965f-ab4507e483d5-000000@email.amazonses.com>
References: <20130123214514.370647954@linux.com>
	 <0000013c695fbd30-9023bc55-f780-4d44-965f-ab4507e483d5-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis
 Claudio R. Goncalves" <lgoncalv@redhat.com>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Wed, 2013-01-23 at 21:45 +0000, Christoph Lameter wrote:
> The variables accessed in slab_alloc are volatile and therefore
> the page pointer passed to node_match can be NULL. The processing
> of data in slab_alloc is tentative until either the cmpxhchg
> succeeds or the __slab_alloc slowpath is invoked. Both are
> able to perform the same allocation from the freelist.
> 
> Check for the NULL pointer in node_match.
> 
> A false positive will lead to a retry of the loop in __slab_alloc.

Hi Christoph,

Since page_to_nid(NULL) will trigger bug, then how can run into
__slab_alloc?

> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2013-01-18 08:47:29.198954250 -0600
> +++ linux/mm/slub.c	2013-01-18 08:47:40.579126371 -0600
> @@ -2041,7 +2041,7 @@ static void flush_all(struct kmem_cache
>  static inline int node_match(struct page *page, int node)
>  {
>  #ifdef CONFIG_NUMA
> -	if (node != NUMA_NO_NODE && page_to_nid(page) != node)
> +	if (!page || (node != NUMA_NO_NODE && page_to_nid(page) != node))
>  		return 0;
>  #endif
>  	return 1;
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
