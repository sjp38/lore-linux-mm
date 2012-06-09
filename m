Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 19BF56B006E
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 07:29:40 -0400 (EDT)
Received: by qabg27 with SMTP id g27so1328653qab.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2012 04:29:38 -0700 (PDT)
Date: Sat, 9 Jun 2012 07:29:35 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH] zsmalloc documentation
Message-ID: <20120609112934.GE16034@localhost.localdomain>
References: <1338754805-1733-1-git-send-email-ngupta@vflare.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338754805-1733-1-git-send-email-ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg KH <greg@kroah.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Sun, Jun 03, 2012 at 01:20:05PM -0700, Nitin Gupta wrote:
> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> ---
>  drivers/staging/zsmalloc/zsmalloc-main.c |   49 ++++++++++++++++++++++++++++++
>  1 file changed, 49 insertions(+)
> 
> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> index 4496737..f80f2fd 100644
> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> @@ -10,6 +10,55 @@
>   * Released under the terms of GNU General Public License Version 2.0
>   */
>  
> +
> +/*
> + * This allocator is designed for use with zcache and zram. Thus, the
> + * allocator is supposed to work well under low memory conditions. In
> + * particular, it never attempts higher order page allocation which is
> + * very likely to fail under memory pressure. On the other hand, if we
> + * just use single (0-order) pages, it would suffer from very high
> + * fragmentation -- any object of size PAGE_SIZE/2 or larger would occupy
> + * an entire page. This was one of the major issues with its predecessor
> + * (xvmalloc).
> + *
> + * To overcome these issues, zsmalloc allocates a bunch of 0-order pages
> + * and links them together using various 'struct page' fields. These linked
> + * pages act as a single higher-order page i.e. an object can span 0-order
> + * page boundaries. The code refers to these linked pages as a single entity
> + * called zspage.
> + *
> + * Following is how we use various fields and flags of underlying
> + * struct page(s) to form a zspage.
> + *
> + * Usage of struct page fields:

I took your definition and grouped them a bit differently:
Not sure if it is more easier to read?

page->first_page: points to the first component (0-order) page
page->index (union with page->freelist): offset of the first object
	starting in this page. For the first page, this is
	always 0, so we use this field (aka freelist) to point
	to the first free object in zspage.
page->lru: links together all component pages (except the first page)
	of a zspage

For _first_ page only:

page->private (union with page->first_page): refers to the
	component page after the first page
page->freelist: points to the first free object in zspage.
	Free objects are linked together using in-place
	metadata.
page->objects: maximum number of objects we can store in this
	zspage (class->zspage_order * PAGE_SIZE / class->size)
page->lru: links together first pages of various zspages.
	Basically forming list of zspages in a fullness group.
page->mapping: class index and fullness group of the zspage

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
