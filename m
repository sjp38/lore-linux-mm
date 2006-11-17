Subject: Re: [PATCH] mm: cleanup and document reclaim recursion
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061116161636.aa210bf1.akpm@osdl.org>
References: <1163618703.5968.50.camel@twins>
	 <20061115124228.db0b42a6.akpm@osdl.org> <1163625058.5968.64.camel@twins>
	 <20061115132340.3cbf4008.akpm@osdl.org> <1163626378.5968.74.camel@twins>
	 <20061115140049.c835fbfd.akpm@osdl.org> <1163670745.5968.83.camel@twins>
	 <20061116161636.aa210bf1.akpm@osdl.org>
Content-Type: text/plain
Date: Fri, 17 Nov 2006 13:18:33 +0100
Message-Id: <1163765913.5968.96.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-11-16 at 16:16 -0800, Andrew Morton wrote:

> hmm.
> 
> >  
> > +	/* We're already in reclaim */
> > +	if (current->flags & PF_MEMALLOC)
> > +		return;
> > +
> 
> We're kinda dead if free_more_memory() does this.  It'll go into an
> infinite loop.

Yeah, this yield() might slow it down or not, but this direct claim
instance will indeed stall and busy wait for some other reclaimer to
free up memory. Which might only be kswapd() that also runs with
__GFP_FS and hence might deadlock?

> Recurring back into try_to_free_pages() would actually be a better thing to
> do..

*sigh*, it would be able to make progress due to the GFP_NOFS thing, but
gah ugly!

> Taking a nap might make some sense, not sure.

If we can deadlock because kswapd runs __GFP_FS then no, just a nap
won't do.

> It all needs more thought, no?

Yes, most definitely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
