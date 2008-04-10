Date: Thu, 10 Apr 2008 11:03:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: git-slub crashes on the t16p
Message-Id: <20080410110310.671db953.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0804101029270.11781@schroedinger.engr.sgi.com>
References: <20080410015958.bc2fd041.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804101327190.15828@sbz-30.cs.Helsinki.FI>
	<47FE37D0.5030004@cs.helsinki.fi>
	<47FE41EE.8040402@cs.helsinki.fi>
	<20080410102454.8248e0ae.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0804101029270.11781@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008 10:30:05 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 10 Apr 2008, Andrew Morton wrote:
> 
> > That's within the call to atomic64_inc(), from the inc_slabs_node() here:
> 
> Right. The slab counter cleanup patch did a non equivalent transformation 
> here.
> 
> Index: linux-2.6/mm/slub.c
> ===================================================================
> --- linux-2.6.orig/mm/slub.c	2008-04-10 10:27:29.000000000 -0700
> +++ linux-2.6/mm/slub.c	2008-04-10 10:28:02.000000000 -0700
> @@ -1174,6 +1174,8 @@
>  	if (!page)
>  		goto out;
>  
> +	/* Must use the node that the page allocator determined for us. */
> +	node = page_to_nid(page);
>  	inc_slabs_node(s, node, page->objects);
>  	page->slab = s;
>  	page->flags |= 1 << PG_slab;

That fixed it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
