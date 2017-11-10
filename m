Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFB2A28028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 07:18:11 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m81so12266681ioi.15
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:18:11 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 90si1189681ioh.306.2017.11.10.04.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Nov 2017 04:18:10 -0800 (PST)
Date: Fri, 10 Nov 2017 13:17:56 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 18/30] x86, kaiser: map virtually-addressed performance
 monitoring buffers
Message-ID: <20171110121756.t7mn7bb4gy3rnw2w@hirez.programming.kicks-ass.net>
References: <20171108194646.907A1942@viggo.jf.intel.com>
 <20171108194720.0ADD17E2@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108194720.0ADD17E2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, x86@kernel.org

On Wed, Nov 08, 2017 at 11:47:20AM -0800, Dave Hansen wrote:
> +static
> +DEFINE_PER_CPU_SHARED_ALIGNED_USER_MAPPED(struct debug_store, cpu_debug_store);
> +
>  /* The size of a BTS record in bytes: */
>  #define BTS_RECORD_SIZE		24
>  
> @@ -278,6 +282,39 @@ void fini_debug_store_on_cpu(int cpu)
>  
>  static DEFINE_PER_CPU(void *, insn_buffer);
>  
> +static void *dsalloc(size_t size, gfp_t flags, int node)
> +{
> +#ifdef CONFIG_KAISER
> +	unsigned int order = get_order(size);
> +	struct page *page;
> +	unsigned long addr;
> +
> +	page = __alloc_pages_node(node, flags | __GFP_ZERO, order);
> +	if (!page)
> +		return NULL;
> +	addr = (unsigned long)page_address(page);
> +	if (kaiser_add_mapping(addr, size, __PAGE_KERNEL | _PAGE_GLOBAL) < 0) {
> +		__free_pages(page, order);
> +		addr = 0;
> +	}
> +	return (void *)addr;
> +#else
> +	return kmalloc_node(size, flags | __GFP_ZERO, node);
> +#endif
> +}
> +
> +static void dsfree(const void *buffer, size_t size)
> +{
> +#ifdef CONFIG_KAISER
> +	if (!buffer)
> +		return;
> +	kaiser_remove_mapping((unsigned long)buffer, size);
> +	free_pages((unsigned long)buffer, get_order(size));
> +#else
> +	kfree(buffer);
> +#endif
> +}

You might as well use __alloc_pages_node() / free_pages()
unconditionally. Those buffers are at least one page in size.

That should also get rid of the #ifdef muck.

>  static int alloc_ds_buffer(int cpu)
>  {
> -	int node = cpu_to_node(cpu);
> -	struct debug_store *ds;
> -
> -	ds = kzalloc_node(sizeof(*ds), GFP_KERNEL, node);
> -	if (unlikely(!ds))
> -		return -ENOMEM;
> +	struct debug_store *ds = per_cpu_ptr(&cpu_debug_store, cpu);
>  
> +	memset(ds, 0, sizeof(*ds));

Why the memset() ? isn't static per-cpu memory 0 initialized

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
