Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id F04E46B0073
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 02:59:30 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so11337696pad.15
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 23:59:30 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id fw3si12914494pdb.30.2014.12.14.23.59.27
        for <linux-mm@kvack.org>;
        Sun, 14 Dec 2014 23:59:29 -0800 (PST)
Date: Mon, 15 Dec 2014 17:03:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/7] slub: Do not use c->page on free
Message-ID: <20141215080338.GE4898@js1304-P5Q-DELUXE>
References: <20141210163017.092096069@linux.com>
 <20141210163033.717707217@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141210163033.717707217@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Dec 10, 2014 at 10:30:20AM -0600, Christoph Lameter wrote:
> Avoid using the page struct address on free by just doing an
> address comparison. That is easily doable now that the page address
> is available in the page struct and we already have the page struct
> address of the object to be freed calculated.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c	2014-12-09 12:25:45.770405462 -0600
> +++ linux/mm/slub.c	2014-12-09 12:25:45.766405582 -0600
> @@ -2625,6 +2625,13 @@ slab_empty:
>  	discard_slab(s, page);
>  }
>  
> +static bool same_slab_page(struct kmem_cache *s, struct page *page, void *p)
> +{
> +	long d = p - page->address;
> +
> +	return d > 0 && d < (1 << MAX_ORDER) && d < (compound_order(page) << PAGE_SHIFT);
> +}
> +

Somtimes, compound_order() induces one more cacheline access, because
compound_order() access second struct page in order to get order. Is there
any way to remove this?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
