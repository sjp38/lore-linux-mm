Date: Thu, 14 Jun 2007 23:05:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] memory unplug v5 [3/6] walk memory resources assist
 function.
In-Reply-To: <20070614160156.9aa218ec.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.0.99.0706142304530.1729@chino.kir.corp.google.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614160156.9aa218ec.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007, KAMEZAWA Hiroyuki wrote:

> Index: devel-2.6.22-rc4-mm2/kernel/resource.c
> ===================================================================
> --- devel-2.6.22-rc4-mm2.orig/kernel/resource.c
> +++ devel-2.6.22-rc4-mm2/kernel/resource.c
> @@ -244,7 +244,7 @@ EXPORT_SYMBOL(release_resource);
>   * the caller must specify res->start, res->end, res->flags.
>   * If found, returns 0, res is overwritten, if not found, returns -1.
>   */
> -int find_next_system_ram(struct resource *res)
> +static int find_next_system_ram(struct resource *res)
>  {
>  	resource_size_t start, end;
>  	struct resource *p;
> @@ -277,6 +277,30 @@ int find_next_system_ram(struct resource
>  		res->end = p->end;
>  	return 0;
>  }
> +
> +int walk_memory_resource(unsigned long start_pfn, unsigned long nr_pages,
> +			 void *arg, walk_memory_callback_t func)
> +{
> +	struct resource res;
> +	unsigned long pfn, len;
> +	u64 orig_end;
> +	int ret;
> +	res.start = (u64) start_pfn << PAGE_SHIFT;
> +	res.end = ((u64)(start_pfn + nr_pages) << PAGE_SHIFT) - 1;
> +	res.flags = IORESOURCE_MEM;
> +	orig_end = res.end;
> +	while ((res.start < res.end) && (find_next_system_ram(&res) >= 0)) {
> +		pfn = (unsigned long)(res.start >> PAGE_SHIFT);
> +		len = (unsigned long)(res.end + 1 - res.start) >> PAGE_SHIFT;

This needs to be

	len = (unsigned long)((res.end + 1 - res.start) >> PAGE_SHIFT);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
