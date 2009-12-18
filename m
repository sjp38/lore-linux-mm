Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 578726B0044
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 20:36:04 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI1a1HW007686
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 18 Dec 2009 10:36:01 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 143E245DE4E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC6A945DE51
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C0B2C1DB8046
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 60B411DB8040
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] mm: introduce dump_page() and print symbolic flag names
In-Reply-To: <20091218012324.GA7953@localhost>
References: <20091216153513.GC2804@hack> <20091218012324.GA7953@localhost>
Message-Id: <20091218102711.6532.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Fri, 18 Dec 2009 10:35:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Americo Wang <xiyou.wangcong@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Alex Chiang <achiang@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Li, Haicheng" <haicheng.li@intel.com>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Wed, Dec 16, 2009 at 11:35:13PM +0800, AmA(C)rico Wang wrote:
> > On Wed, Dec 16, 2009 at 08:33:10PM +0800, Wu Fengguang wrote:
> > >On Wed, Dec 16, 2009 at 08:26:40PM +0800, Wu Fengguang wrote:
> > >> - introduce dump_page() to print the page info for debugging some error condition.
> > >> - convert three mm users: bad_page(), print_bad_pte() and memory offline failure. 
> > >> - print an extra field: the symbolic names of page->flags
> > >> 
> > >> Example dump_page() output:
> > >> 
> > >> [  157.521694] page:ffffea0000a7cba8 count:2 mapcount:1
> > >> mapping:ffff88001c901791 index:147
> > >                                 ~~~ this is in fact 0x147
> > >
> > >The index value may sometimes be misread as decimal number, shall this
> > >be fixed by adding a "0x" prefix?
> > 
> > 
> > Using '%#x' will do.
> 
> Thanks, here is the updated patch.
> ---
> mm: introduce dump_page()
> 
> - introduce dump_page() to print the page info for debugging some error condition.
> - convert three mm users: bad_page(), print_bad_pte() and memory offline failure. 
> - print an extra field: the symbolic names of page->flags
> 
> Example dump_page() output:
> 
> [  157.521694] page:ffffea0000a7cba8 count:2 mapcount:1 mapping:ffff88001c901791 index:0x147
> [  157.525570] page flags: 100000000100068(uptodate|lru|active|swapbacked)
> 
> CC: Ingo Molnar <mingo@elte.hu> 
> CC: Alex Chiang <achiang@hp.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Andi Kleen <andi@firstfloor.org> 
> CC: Mel Gorman <mel@linux.vnet.ibm.com> 
> CC: Christoph Lameter <cl@linux-foundation.org> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/mm.h  |    2 +
>  mm/memory.c         |    8 +---
>  mm/memory_hotplug.c |    6 +--
>  mm/page_alloc.c     |   83 +++++++++++++++++++++++++++++++++++++++---
>  4 files changed, 86 insertions(+), 13 deletions(-)
> 
> --- linux-mm.orig/mm/page_alloc.c	2009-12-11 10:01:25.000000000 +0800
> +++ linux-mm/mm/page_alloc.c	2009-12-16 20:33:35.000000000 +0800
> @@ -49,6 +49,7 @@
>  #include <linux/debugobjects.h>
>  #include <linux/kmemleak.h>
>  #include <trace/events/kmem.h>
> +#include <linux/ftrace_event.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/div64.h>
> @@ -262,10 +263,7 @@ static void bad_page(struct page *page)
>  
>  	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
>  		current->comm, page_to_pfn(page));
> -	printk(KERN_ALERT
> -		"page:%p flags:%p count:%d mapcount:%d mapping:%p index:%lx\n",
> -		page, (void *)page->flags, page_count(page),
> -		page_mapcount(page), page->mapping, page->index);
> +	dump_page(page);
>  
>  	dump_stack();
>  out:
> @@ -5106,3 +5104,80 @@ bool is_free_buddy_page(struct page *pag
>  	return order < MAX_ORDER;
>  }
>  #endif
> +
> +static struct trace_print_flags pageflag_names[] = {
> +	{1UL << PG_locked,		"locked"	},
> +	{1UL << PG_error,		"error"		},
> +	{1UL << PG_referenced,		"referenced"	},
> +	{1UL << PG_uptodate,		"uptodate"	},
> +	{1UL << PG_dirty,		"dirty"		},
> +	{1UL << PG_lru,			"lru"		},
> +	{1UL << PG_active,		"active"	},
> +	{1UL << PG_slab,		"slab"		},
> +	{1UL << PG_owner_priv_1,	"owner_priv_1"	},
> +	{1UL << PG_arch_1,		"arch_1"	},
> +	{1UL << PG_reserved,		"reserved"	},
> +	{1UL << PG_private,		"private"	},
> +	{1UL << PG_private_2,		"private_2"	},
> +	{1UL << PG_writeback,		"writeback"	},
> +#ifdef CONFIG_PAGEFLAGS_EXTENDED
> +	{1UL << PG_head,		"head"		},
> +	{1UL << PG_tail,		"tail"		},
> +#else
> +	{1UL << PG_compound,		"compound"	},
> +#endif
> +	{1UL << PG_swapcache,		"swapcache"	},
> +	{1UL << PG_mappedtodisk,	"mappedtodisk"	},
> +	{1UL << PG_reclaim,		"reclaim"	},
> +	{1UL << PG_buddy,		"buddy"		},
> +	{1UL << PG_swapbacked,		"swapbacked"	},
> +	{1UL << PG_unevictable,		"unevictable"	},
> +#ifdef CONFIG_MMU
> +	{1UL << PG_mlocked,		"mlocked"	},
> +#endif
> +#ifdef CONFIG_ARCH_USES_PG_UNCACHED
> +	{1UL << PG_uncached,		"uncached"	},
> +#endif
> +#ifdef CONFIG_MEMORY_FAILURE
> +	{1UL << PG_hwpoison,		"hwpoison"	},
> +#endif
> +	{-1UL,				NULL		},
> +};
> +
> +static void dump_page_flags(unsigned long flags)
> +{
> +	const char *delim = "";
> +	unsigned long mask;
> +	int i;
> +
> +	printk(KERN_ALERT "page flags: %lx(", flags);

nit.
Now, you append 0x prefix to index. why don't you appent 0x prefix to this?
I mean we have to keep consist prefix printing rule in the same printk.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
