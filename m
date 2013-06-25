Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2C99D6B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 13:38:20 -0400 (EDT)
Message-ID: <51C9D56F.8040400@infradead.org>
Date: Tue, 25 Jun 2013 10:37:51 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: add kmalloc() to kernel API documentation
References: <1372177015-30492-1-git-send-email-michael.opdenacker@free-electrons.com>
In-Reply-To: <1372177015-30492-1-git-send-email-michael.opdenacker@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/25/13 09:16, Michael Opdenacker wrote:
> At the moment, kmalloc() isn't even listed in the kernel API
> documentation (DocBook/kernel-api.html after running "make htmldocs").
> 
> Another issue is that the documentation for kmalloc_node()
> refers to kcalloc()'s documentation to describe its 'flags' parameter,
> while kcalloc() refered to kmalloc()'s documentation, which doesn't exist!
> 
> This patch is a proposed fix for this. It also removes the documentation
> for kmalloc() in include/linux/slob_def.h which isn't included to
> generate the documentation anyway. This way, kmalloc() is described
> in only one place.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>\

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.


> ---
>  include/linux/slab.h     | 18 ++++++++++++++----
>  include/linux/slob_def.h |  8 --------
>  2 files changed, 14 insertions(+), 12 deletions(-)
> 
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 0c62175..dffc7a2 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -356,9 +356,8 @@ int cache_show(struct kmem_cache *s, struct seq_file *m);
>  void print_slabinfo_header(struct seq_file *m);
>  
>  /**
> - * kmalloc_array - allocate memory for an array.
> - * @n: number of elements.
> - * @size: element size.
> + * kmalloc - allocate memory
> + * @size: how many bytes of memory are required.
>   * @flags: the type of memory to allocate.
>   *
>   * The @flags argument may be one of:
> @@ -405,6 +404,17 @@ void print_slabinfo_header(struct seq_file *m);
>   * There are other flags available as well, but these are not intended
>   * for general use, and so are not documented here. For a full list of
>   * potential flags, always refer to linux/gfp.h.
> + *
> + * kmalloc is the normal method of allocating memory
> + * in the kernel.
> + */
> +static __always_inline void *kmalloc(size_t size, gfp_t flags);
> +
> +/**
> + * kmalloc_array - allocate memory for an array.
> + * @n: number of elements.
> + * @size: element size.
> + * @flags: the type of memory to allocate (see kmalloc).
>   */
>  static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
>  {
> @@ -428,7 +438,7 @@ static inline void *kcalloc(size_t n, size_t size, gfp_t flags)
>  /**
>   * kmalloc_node - allocate memory from a specific node
>   * @size: how many bytes of memory are required.
> - * @flags: the type of memory to allocate (see kcalloc).
> + * @flags: the type of memory to allocate (see kmalloc).
>   * @node: node to allocate from.
>   *
>   * kmalloc() for non-local nodes, used to allocate from a specific node
> diff --git a/include/linux/slob_def.h b/include/linux/slob_def.h
> index f28e14a..095a5a4 100644
> --- a/include/linux/slob_def.h
> +++ b/include/linux/slob_def.h
> @@ -18,14 +18,6 @@ static __always_inline void *kmalloc_node(size_t size, gfp_t flags, int node)
>  	return __kmalloc_node(size, flags, node);
>  }
>  
> -/**
> - * kmalloc - allocate memory
> - * @size: how many bytes of memory are required.
> - * @flags: the type of memory to allocate (see kcalloc).
> - *
> - * kmalloc is the normal method of allocating memory
> - * in the kernel.
> - */
>  static __always_inline void *kmalloc(size_t size, gfp_t flags)
>  {
>  	return __kmalloc_node(size, flags, NUMA_NO_NODE);
> 


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
