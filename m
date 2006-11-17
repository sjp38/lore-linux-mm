Date: Thu, 16 Nov 2006 16:16:36 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm: cleanup and document reclaim recursion
Message-Id: <20061116161636.aa210bf1.akpm@osdl.org>
In-Reply-To: <1163670745.5968.83.camel@twins>
References: <1163618703.5968.50.camel@twins>
	<20061115124228.db0b42a6.akpm@osdl.org>
	<1163625058.5968.64.camel@twins>
	<20061115132340.3cbf4008.akpm@osdl.org>
	<1163626378.5968.74.camel@twins>
	<20061115140049.c835fbfd.akpm@osdl.org>
	<1163670745.5968.83.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Nov 2006 10:52:25 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> On Wed, 2006-11-15 at 14:00 -0800, Andrew Morton wrote:
> > On Wed, 15 Nov 2006 22:32:58 +0100
> > Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > 
> > > +			current->flags |= PF_MEMALLOC;
> > >  			try_to_free_pages(zones, GFP_NOFS);
> > > +			current->flags &= ~PF_MEMALLOC;
> > 
> > Sometime, later, in a different patch, we might as well suck that into
> > try_to_free_pages() itself.   Along with nice comment explaining
> > what it means and WARN_ON(current->flags & PF_MEMALLOC).
> 
> ---
> 
> Cleanup and document the reclaim recursion avoiding properties of PF_MEMALLOC.
> 
> ..

hmm.

>  
> +	/* We're already in reclaim */
> +	if (current->flags & PF_MEMALLOC)
> +		return;
> +

We're kinda dead if free_more_memory() does this.  It'll go into an
infinite loop.

Recurring back into try_to_free_pages() would actually be a better thing to
do..

Taking a nap might make some sense, not sure.

It all needs more thought, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
