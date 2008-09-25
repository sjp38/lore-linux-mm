From: Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCH] mm: make do_move_pages() complexity linear
Date: Thu, 25 Sep 2008 14:58:59 +0200
Message-ID: <48DB8B13.8080202@inria.fr>
References: <48CA611A.8060706@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755206AbYIYM55@vger.kernel.org>
In-Reply-To: <48CA611A.8060706@inria.fr>
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-Id: linux-mm.kvack.org

Brice Goglin wrote:
> Page migration is currently very slow because its overhead is quadratic
> with the number of pages. This is caused by each single page migration
> doing a linear lookup in the page array in new_page_node().
>     
> Since pages are stored in the array order in the pagelist and do_move_pages
> process this list in order, new_page_node() can increase the "pm" pointer
> to the page array so that the next iteration will find the next page in
> 0 or few lookup steps.
>     
> [...]
>  
> +/*
> + * Allocate a page on the node given as a page_to_node in private.
> + * Increase private to point to the next page_to_node so that the
> + * next iteration does not have to traverse the whole pm array.
> + */
>  static struct page *new_page_node(struct page *p, unsigned long private,
>  		int **result)
>  {
> -	struct page_to_node *pm = (struct page_to_node *)private;
> +	struct page_to_node **pmptr = (struct page_to_node **)private;
> +	struct page_to_node *pm = *pmptr;
>  
>  	while (pm->node != MAX_NUMNODES && pm->page != p)
>  		pm++;
>  
> +	/* prepare for the next iteration */
> +	*pmptr = pm + 1;
> +
>   

Actually, this "pm+1" breaks the case where migrate_pages() calls
unmap_and_move() multiple times on the same page. In this case, we need
the while loop to look at pm instead of pm+1 first. So we can't cache
pm+1 in private, but caching pm is ok. There will be 1 while loop
instead of 0 in the regular case. Updated patch (with more comments)
coming soon.

Brice
