Date: Tue, 21 Nov 2006 17:52:28 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: drain_node_page(): Drain pages in batch units
Message-Id: <20061121175228.14eaf35b.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0611211255270.31032@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0611211255270.31032@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006 12:56:21 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> drain_node_pages() currently drains the complete pageset of all pages. If there
> are a large number of pages in the queues then we may hold off interrupts for
> too long.
> 
> Duplicate the method used in free_hot_cold_page. Only drain pcp->batch pages
> at one time.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.19-rc5-mm2/mm/page_alloc.c
> ===================================================================
> --- linux-2.6.19-rc5-mm2.orig/mm/page_alloc.c	2006-11-17 13:28:39.492284421 -0600
> +++ linux-2.6.19-rc5-mm2/mm/page_alloc.c	2006-11-21 14:53:39.313626619 -0600
> @@ -705,9 +705,15 @@ void drain_node_pages(int nodeid)
>  
>  			pcp = &pset->pcp[i];
>  			if (pcp->count) {
> +				int to_drain;
> +
>  				local_irq_save(flags);
> -				free_pages_bulk(zone, pcp->count, &pcp->list, 0);
> -				pcp->count = 0;
> +				if (pcp->count >= pcp->batch)
> +					to_drain = pcp->batch;
> +				else
> +					to_drain = pcp->count;
> +				free_pages_bulk(zone, to_drain, &pcp->list, 0);
> +				pcp->count -= to_drain;
>  				local_irq_restore(flags);
>  			}
>  		}

This will reduce the reaping rate.  Potentially vastly.

Is that a good change?  If so, why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
