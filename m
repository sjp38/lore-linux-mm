Date: Mon, 16 Feb 2004 10:44:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 2.6.3-rc3-mm1: align scan_page per node
Message-Id: <20040216104436.7e529efd.akpm@osdl.org>
In-Reply-To: <30430000.1076956618@flay>
References: <4030BB86.8060206@cyberone.com.au>
	<7090000.1076946440@[10.10.2.4]>
	<20040216095746.5ad2656b.akpm@osdl.org>
	<30430000.1076956618@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: piggin@cyberone.com.au, Nikita@Namesys.COM, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > 
> > We would need struct page in scope for mmzone.h.  Not nice.  It could be
> > done: move the bare pageframe defn into its own header with appropriate
> > forward decls.
> 
> Bah, not that *again* ;-) ... We've hit this several times before, and 
> kludged around it. Here's an old fix from 2.5.58 ... if I do something
> along these lines to current code, and test it, would you be interested
> in taking it? I think most of the top section all got done already, so
> it really shouldn't be too bad.

It would need a lot of compile-testing.

> +struct page {
> +	unsigned long flags;		/* atomic flags, some possibly
> +					   updated asynchronously */
> +	atomic_t count;			/* Usage count, see below. */
> +	struct list_head list;		/* ->mapping has some page lists. */
> +	struct address_space *mapping;	/* The inode (or ...) we belong to. */
> +	unsigned long index;		/* Our offset within mapping. */
> +	struct list_head lru;		/* Pageout list, eg. active_list;
> +					   protected by zone->lru_lock !! */
> +	union {
> +		struct pte_chain *chain;/* Reverse pte mapping pointer.
> +					 * protected by PG_chainlock */
> +		pte_addr_t direct;
> +	} pte;
> +	unsigned long private;		/* mapping-private opaque data */
> +
> +	/*
> +	 * On machines where all RAM is mapped into kernel address space,
> +	 * we can simply calculate the virtual address. On machines with
> +	 * highmem some memory is mapped into kernel virtual memory
> +	 * dynamically, so we need a place to store that address.
> +	 * Note that this field could be 16 bits on x86 ... ;)
> +	 *
> +	 * Architectures with slow multiplication can define
> +	 * WANT_PAGE_VIRTUAL in asm/page.h
> +	 */
> +#if defined(WANT_PAGE_VIRTUAL)
> +	void *virtual;			/* Kernel virtual address (NULL if
> +					   not kmapped, ie. highmem) */
> +#endif /* WANT_PAGE_VIRTUAL */

atomic_t, list_head, pte_chain, pte_addr_t all need to be in scope and
address_space needs a forward decl.  I bet other stuff will explode.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
