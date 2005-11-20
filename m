Date: Sat, 19 Nov 2005 23:31:51 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 3/3] sparse provide pfn_to_nid
Message-Id: <20051119233151.01ce6c50.akpm@osdl.org>
In-Reply-To: <20051116230023.GA16493@shadowen.org>
References: <exportbomb.1132181992@pinky>
	<20051116230023.GA16493@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: kravetz@us.ibm.com, anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andy Whitcroft <apw@shadowen.org> wrote:
>
> sparsemem: provide pfn_to_nid
> 
> Before SPARSEMEM is initialised we cannot provide an efficient
> pfn_to_nid() implmentation; before initialisation is complete we use
> early_pfn_to_nid() to provide location information.  Until recently
> there was no non-init user of this functionality.  Provide a post
> init pfn_to_nid() implementation.
> 
> Note that this implmentation assumes that the pfn passed has
> been validated with pfn_valid().  The current single user of this
> function already has this check.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> ---
>  mmzone.h |   13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
> diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
> --- reference/include/linux/mmzone.h
> +++ current/include/linux/mmzone.h
> @@ -598,14 +598,11 @@ static inline int pfn_valid(unsigned lon
>  	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
>  }
>  
> -/*
> - * These are _only_ used during initialisation, therefore they
> - * can use __initdata ...  They could have names to indicate
> - * this restriction.
> - */
> -#ifdef CONFIG_NUMA
> -#define pfn_to_nid		early_pfn_to_nid
> -#endif
> +#define pfn_to_nid(pfn)							\
> +({									\
> + 	unsigned long __pfn = (pfn);                                    \
> +	page_to_nid(pfn_to_page(pfn));					\
> +})
>  
>  #define early_pfn_valid(pfn)	pfn_valid(pfn)
>  void sparse_init(void);

This causes a problem because we already have a definition of pfn_to_nid()
in include/linux/mmzone.h.  Effectively:

#ifndef CONFIG_NEED_MULTIPLE_NODES

#define pfn_to_nid(pfn)		(0)

#else /* CONFIG_NEED_MULTIPLE_NODES */

#include <asm/mmzone.h>

#endif /* !CONFIG_NEED_MULTIPLE_NODES */


If someone does !CONFIG_NEED_MULTIPLE_NODES, pfn_to_nid() gets a duplicate
definition (from inspection).

If someone does CONFIG_NEED_MULTIPLE_NODES && CONFIG_DISCONTIGMEM we get
duplicate definitions of pfn_to_nid(): one in include/linux/mmzone.h and
one in include/asm/mmzone.h.

It's a big mess - can someone please fix it up?  The maze of config options
is just over the top.

Meanwhile, I'll drop this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
