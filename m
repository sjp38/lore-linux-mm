Date: Mon, 9 Apr 2007 14:27:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
Message-Id: <20070409142705.55fa0f34.akpm@linux-foundation.org>
In-Reply-To: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon,  9 Apr 2007 11:25:09 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Quicklists for page table pages V5
> 
> ...
>
> +/*
> + * The two key functions quicklist_alloc and quicklist_free are inline so
> + * that they may be custom compiled for the platform.
> + * Specifying a NULL ctor can remove constructor support. Specifying
> + * a constant quicklist allows the determination of the exact address
> + * in the per cpu area.
> + *
> + * The fast patch in quicklist_alloc touched only a per cpu cacheline and
> + * the first cacheline of the page itself. There is minmal overhead involved.
> + */
> +static inline void *quicklist_alloc(int nr, gfp_t flags, void (*ctor)(void *))
> +{
> +	struct quicklist *q;
> +	void **p = NULL;
> +
> +	q =&get_cpu_var(quicklist)[nr];
> +	p = q->page;
> +	if (likely(p)) {
> +		q->page = p[0];
> +		p[0] = NULL;
> +		q->nr_pages--;
> +	}
> +	put_cpu_var(quicklist);
> +	if (likely(p))
> +		return p;
> +
> +	p = (void *)__get_free_page(flags | __GFP_ZERO);
> +	if (ctor && p)
> +		ctor(p);
> +	return p;
> +}
> +
> +static inline void __quicklist_free(int nr, void (*dtor)(void *), void *p,
> +	struct page *page)
> +{
> +	struct quicklist *q;
> +	int nid = page_to_nid(page);
> +
> +	if (unlikely(nid != numa_node_id())) {
> +		if (dtor)
> +			dtor(p);
> +		free_page((unsigned long)p);

free_page() has to run virt_to_page(), but we already have the page*.

> +		return;
> +	}
> +
> +	q = &get_cpu_var(quicklist)[nr];
> +	*(void **)p = q->page;
> +	q->page = p;
> +	q->nr_pages++;
> +	put_cpu_var(quicklist);
> +}
> +
> +static inline void quicklist_free(int nr, void (*dtor)(void *), void *pp)
> +{
> +	__quicklist_free(nr, dtor, pp, virt_to_page(pp));
> +}
> +
> +static inline void quicklist_free_page(int nr, void (*dtor)(void *),
> +							struct page *page)
> +{
> +	__quicklist_free(nr, dtor, page_address(page), page);
> +}

All this (still) seems way too big to be inlined.  I'm showing a 20-odd
byte reduction in x86_64's memory.o text when it is uninlined.  Pretty
modest I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
