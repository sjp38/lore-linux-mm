Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id ADDA26B0006
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 10:29:54 -0500 (EST)
Message-ID: <1358522992.7383.13.camel@gandalf.local.home>
Subject: Re: [RFC][PATCH v2] slub: Keep page and object in sync in
 slab_alloc_node()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 18 Jan 2013 10:29:52 -0500
In-Reply-To: <20130118044242.GA18665@lge.com>
References: <1358446258.23211.32.camel@gandalf.local.home>
	 <1358447864.23211.34.camel@gandalf.local.home>
	 <0000013c4a69a2cf-1a19a6f6-e6a3-4f06-99a4-10fdd4b9aca2-000000@email.amazonses.com>
	 <1358458996.23211.46.camel@gandalf.local.home>
	 <0000013c4a7e7fbf-c51fd42a-2455-4fec-bb37-915035956f05-000000@email.amazonses.com>
	 <1358462763.23211.57.camel@gandalf.local.home>
	 <1358464245.23211.62.camel@gandalf.local.home>
	 <1358464837.23211.66.camel@gandalf.local.home>
	 <1358468598.23211.67.camel@gandalf.local.home>
	 <1358468924.23211.69.camel@gandalf.local.home>
	 <20130118044242.GA18665@lge.com>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Thomas Gleixner <tglx@linutronix.de>, RT <linux-rt-users@vger.kernel.org>, Clark Williams <clark@redhat.com>, John Kacur <jkacur@gmail.com>, "Luis Claudio
 R. Goncalves" <lgoncalv@redhat.com>

On Fri, 2013-01-18 at 13:42 +0900, Joonsoo Kim wrote:

> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 9db4825..b54dffa 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -46,6 +46,9 @@ enum stat_item {
>  struct kmem_cache_cpu {
>  	void **freelist;	/* Pointer to next available object */
>  	unsigned long tid;	/* Globally unique transaction id */
> +#ifdef CONFIG_NUMA
> +	int node;

Note, you put an int between a long and a pointer, which will waste 4
bytes on 64bit machines.

> +#endif
>  	struct page *page;	/* The slab from which we are allocating */
>  	struct page *partial;	/* Partially allocated frozen slabs */
>  #ifdef CONFIG_SLUB_STATS



> @@ -2038,10 +2049,10 @@ static void flush_all(struct kmem_cache *s)
>   * Check if the objects in a per cpu structure fit numa
>   * locality expectations.
>   */
> -static inline int node_match(struct page *page, int node)
> +static inline int node_match(struct kmem_cache_cpu *c, int node)
>  {
>  #ifdef CONFIG_NUMA
> -	if (node != NUMA_NO_NODE && page_to_nid(page) != node)
> +	if (node != NUMA_NO_NODE && c->node != node)

We still have the issue of cpu fetching c->node before c->tid and
c->freelist.

I still believe the only solution is to prevent the task from migrating
via a preempt disable.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
