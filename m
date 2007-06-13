Date: Tue, 12 Jun 2007 22:28:57 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
Message-ID: <20070613032857.GN11115@waste.org>
References: <20070613031203.GB15009@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070613031203.GB15009@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 13, 2007 at 12:12:03PM +0900, Paul Mundt wrote:
> Here's an updated copy of the patch adding simple NUMA support to SLOB,
> against the current -mm version of SLOB this time.
> 
> I've tried to address all of the comments on the initial version so far,
> but there's obviously still room for improvement.
> 
> This approach is not terribly scalable in that we still end up using a
> global freelist (and a global spinlock!) across all nodes, making the
> partial free page lookup rather expensive. The next step after this will
> be moving towards split freelists with finer grained locking.
> 
> The scanning of the global freelist could be sped up by simply ignoring
> the node id unless __GFP_THISNODE is set. This patch defaults to trying
> to match up the node id for the partial pages (whereas the last one just
> grabbed the first partial page from the list, regardless of node
> placement), but perhaps that's the wrong default and should only be done
> for __GFP_THISNODE?

Hmmm. There's not a whole lot that uses __GFP_THISNODE. Dunno.
 
> +static inline void *slob_new_page(gfp_t gfp, int order, int node)
> +{
> +	void *page;
> +
> +#ifdef CONFIG_NUMA
> +	if (node != -1)
> +		page = alloc_pages_node(node, gfp, order);
> +	else
> +#endif
> +		page = alloc_pages(gfp, order);
> +
> +	if (!page)
> +		return NULL;
> +
> +	return page_address(page);

We might want to leave the inlining decision here to the compiler. The
ifdef may change that decision..

> -void *__kmalloc(size_t size, gfp_t gfp)
> +static void *slob_node_alloc(size_t size, gfp_t gfp, int node)

See my comment in the last message.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
