Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id B68566B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 19:56:16 -0400 (EDT)
Date: Thu, 17 May 2012 16:56:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] scatterlist: add sg_alloc_table_from_pages function
Message-Id: <20120517165614.d5e6e4b6.akpm@linux-foundation.org>
In-Reply-To: <4FA8EC69.8010805@samsung.com>
References: <4FA8EC69.8010805@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomasz Stanislawski <t.stanislaws@samsung.com>
Cc: no To-header on input <""@mail.linuxfoundation.org>, paul.gortmaker@windriver.com, =?UTF-8?Q?'=EB=B0=95=EA=B2=BD=EB=AF=BC'?= <kyungmin.park@samsung.com>, amwang@redhat.com, dri-devel@lists.freedesktop.org, "'???/Mobile S/W Platform Lab.(???)/E3(??)/????'" <inki.dae@samsung.com>, prashanth.g@samsung.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Rob Clark <rob@ti.com>, Dave Airlie <airlied@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 08 May 2012 11:50:33 +0200
Tomasz Stanislawski <t.stanislaws@samsung.com> wrote:

> This patch adds a new constructor for an sg table. The table is constructed
> from an array of struct pages. All contiguous chunks of the pages are merged
> into a single sg nodes. A user may provide an offset and a size of a buffer if
> the buffer is not page-aligned.
> 
> The function is dedicated for DMABUF exporters which often perform conversion
> from an page array to a scatterlist. Moreover the scatterlist should be
> squashed in order to save memory and to speed-up the process of DMA mapping
> using dma_map_sg.
> 
> The code is based on the patch 'v4l: vb2-dma-contig: add support for
> scatterlist in userptr mode' and hints from Laurent Pinchart.
> 
> ...
>
>  /**
> + * sg_alloc_table_from_pages - Allocate and initialize an sg table from
> + *			       an array of pages
> + * @sgt:	The sg table header to use
> + * @pages:	Pointer to an array of page pointers
> + * @n_pages:	Number of pages in the pages array
> + * @offset:     Offset from start of the first page to the start of a buffer
> + * @size:       Number of valid bytes in the buffer (after offset)
> + * @gfp_mask:	GFP allocation mask
> + *
> + *  Description:
> + *    Allocate and initialize an sg table from a list of pages. Continuous

s/Continuous/Contiguous/

> + *    ranges of the pages are squashed into a single scatterlist node. A user
> + *    may provide an offset at a start and a size of valid data in a buffer
> + *    specified by the page array. The returned sg table is released by
> + *    sg_free_table.
> + *
> + * Returns:
> + *   0 on success, negative error on failure
> + **/

nit: Use */, not **/ here.

> +int sg_alloc_table_from_pages(struct sg_table *sgt,
> +	struct page **pages, unsigned int n_pages,
> +	unsigned long offset, unsigned long size,
> +	gfp_t gfp_mask)

I guess a 32-bit n_pages is OK.  A 16TB IO seems enough ;)

> +{
> +	unsigned int chunks;
> +	unsigned int i;

erk, please choose a different name for this.  When a C programmer sees
"i", he very much assumes it has type "int".  Making it unsigned causes
surprise.

And don't rename it to "u"!  Let's give it a nice meaningful name.  pageno?

> +	unsigned int cur_page;
> +	int ret;
> +	struct scatterlist *s;
> +
> +	/* compute number of contiguous chunks */
> +	chunks = 1;
> +	for (i = 1; i < n_pages; ++i)
> +		if (page_to_pfn(pages[i]) != page_to_pfn(pages[i - 1]) + 1)

This assumes that if two pages have contiguous pfn's then they are
physically contiguous.  Is that true for all architectures and memory
models, including sparsemem?  See sparse_encode_mem_map().

> +			++chunks;
> +
> +	ret = sg_alloc_table(sgt, chunks, gfp_mask);
> +	if (unlikely(ret))
> +		return ret;
> +
> +	/* merging chunks and putting them into the scatterlist */
> +	cur_page = 0;
> +	for_each_sg(sgt->sgl, s, sgt->orig_nents, i) {
> +		unsigned long chunk_size;
> +		unsigned int j;

"j" is an "int", too.

> +
> +		/* looking for the end of the current chunk */

s/looking/look/

> +		for (j = cur_page + 1; j < n_pages; ++j)
> +			if (page_to_pfn(pages[j]) !=
> +			    page_to_pfn(pages[j - 1]) + 1)
> +				break;
> +
> +		chunk_size = ((j - cur_page) << PAGE_SHIFT) - offset;
> +		sg_set_page(s, pages[cur_page], min(size, chunk_size), offset);
> +		size -= chunk_size;
> +		offset = 0;
> +		cur_page = j;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(sg_alloc_table_from_pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
