Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E35DC6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 03:08:38 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so475992pbc.4
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 00:08:38 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUE008RZ3SY6700@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Oct 2013 08:08:33 +0100 (BST)
Message-id: <1381302512.6638.0.camel@AMDC1943>
Subject: Re: [PATCH v3 1/6] zbud: use page ref counter for zbud pages
From: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Date: Wed, 09 Oct 2013 09:08:32 +0200
In-reply-to: <20131008204317.GA8798@medulla.variantweb.net>
References: <1381238980-2491-1-git-send-email-k.kozlowski@samsung.com>
 <1381238980-2491-2-git-send-email-k.kozlowski@samsung.com>
 <20131008204317.GA8798@medulla.variantweb.net>
Content-type: text/plain; charset=UTF-8
Content-transfer-encoding: 7bit
MIME-version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, Minchan Kim <minchan@kernel.org>

On wto, 2013-10-08 at 15:43 -0500, Seth Jennings wrote:
> On Tue, Oct 08, 2013 at 03:29:35PM +0200, Krzysztof Kozlowski wrote:
> > Use page reference counter for zbud pages. The ref counter replaces
> > zbud_header.under_reclaim flag and ensures that zbud page won't be freed
> > when zbud_free() is called during reclaim. It allows implementation of
> > additional reclaim paths.
> > 
> > The page count is incremented when:
> >  - a handle is created and passed to zswap (in zbud_alloc()),
> >  - user-supplied eviction callback is called (in zbud_reclaim_page()).
> > 
> > Signed-off-by: Krzysztof Kozlowski <k.kozlowski@samsung.com>
> > Signed-off-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
> > Reviewed-by: Bob Liu <bob.liu@oracle.com>
> 
> Other than the nit below:
> 
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
Thank you for ACK-s (here and in other patches).


> > ---
> >  mm/zbud.c |  117 +++++++++++++++++++++++++++++++++----------------------------
> >  1 file changed, 64 insertions(+), 53 deletions(-)
> > 
> > diff --git a/mm/zbud.c b/mm/zbud.c
> > index 9451361..7574289 100644
> > --- a/mm/zbud.c
> > +++ b/mm/zbud.c
> > @@ -109,7 +109,6 @@ struct zbud_header {
> >  	struct list_head lru;
> >  	unsigned int first_chunks;
> >  	unsigned int last_chunks;
> > -	bool under_reclaim;
> >  };
> > 
> >  /*****************
> > @@ -138,16 +137,9 @@ static struct zbud_header *init_zbud_page(struct page *page)
> >  	zhdr->last_chunks = 0;
> >  	INIT_LIST_HEAD(&zhdr->buddy);
> >  	INIT_LIST_HEAD(&zhdr->lru);
> > -	zhdr->under_reclaim = 0;
> >  	return zhdr;
> >  }
> > 
> > -/* Resets the struct page fields and frees the page */
> > -static void free_zbud_page(struct zbud_header *zhdr)
> > -{
> > -	__free_page(virt_to_page(zhdr));
> > -}
> > -
> >  /*
> >   * Encodes the handle of a particular buddy within a zbud page
> >   * Pool lock should be held as this function accesses first|last_chunks
> > @@ -188,6 +180,31 @@ static int num_free_chunks(struct zbud_header *zhdr)
> >  	return NCHUNKS - zhdr->first_chunks - zhdr->last_chunks - 1;
> >  }
> > 
> > +/*
> > + * Increases ref count for zbud page.
> > + */
> > +static void get_zbud_page(struct zbud_header *zhdr)
> > +{
> > +	get_page(virt_to_page(zhdr));
> > +}
> > +
> > +/*
> > + * Decreases ref count for zbud page and frees the page if it reaches 0
> > + * (no external references, e.g. handles).
> > + *
> > + * Returns 1 if page was freed and 0 otherwise.
> > + */
> > +static int put_zbud_page(struct zbud_header *zhdr)
> > +{
> > +	struct page *page = virt_to_page(zhdr);
> > +	if (put_page_testzero(page)) {
> > +		free_hot_cold_page(page, 0);
> > +		return 1;
> > +	}
> > +	return 0;
> > +}
> > +
> > +
> >  /*****************
> >   * API Functions
> >  *****************/
> > @@ -273,6 +290,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> >  				bud = FIRST;
> >  			else
> >  				bud = LAST;
> > +			get_zbud_page(zhdr);
> >  			goto found;
> >  		}
> >  	}
> > @@ -284,6 +302,10 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
> >  		return -ENOMEM;
> >  	spin_lock(&pool->lock);
> >  	pool->pages_nr++;
> > +	/*
> > +	 * We will be using zhdr instead of page, so
> > +	 * don't increase the page count.
> > +	 */
> 
> This comment isn't very clear.  I think what you mean to say is that
> we already have the page ref'ed for this entry because of the initial
> ref count done by alloc_page().
> 
> So maybe:
> 
> /*
>  * Page count is incremented by alloc_page() for the initial
>  * reference so no need to call zbud_get_page() here.
>  */

Good point. I'll change it.

Best regards,
Krzysztof

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
