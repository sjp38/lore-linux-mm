Date: Tue, 21 Feb 2006 19:04:27 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] remove zone_mem_map 
In-Reply-To: <43FBAEBA.2020300@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0602211900450.23557@schroedinger.engr.sgi.com>
References: <43FBAEBA.2020300@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <haveblue@us.ibm.com>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Feb 2006, KAMEZAWA Hiroyuki wrote:

> This patch removes zone_mem_map.

Note that IA64 does not seem to depend on zone_mem_map...

> Index: test/include/asm-generic/memory_model.h
> ===================================================================
> --- test.orig/include/asm-generic/memory_model.h
> +++ test/include/asm-generic/memory_model.h
> @@ -47,9 +47,9 @@ extern unsigned long page_to_pfn(struct
> 
>  #define page_to_pfn(pg)			\
>  ({	struct page *__pg = (pg);		\
> -	struct zone *__zone = page_zone(__pg);	\
> -	(unsigned long)(__pg - __zone->zone_mem_map) +	\
> -	 __zone->zone_start_pfn;			\
> +	struct pglist_data *__pgdat = NODE_DATA(page_to_nid(__pg));	\
> +	(unsigned long)(__pg - __pgdat->node_mem_map) +	\
> +	 __pgdat->node_start_pfn;			\
>  })

NODE_DATA is an arch specific lookup, If it always is a table lookup
then the performance will be comparable to page_zone because that also 
involves one table lookup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
