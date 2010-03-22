Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3CDC6B01AC
	for <linux-mm@kvack.org>; Mon, 22 Mar 2010 06:41:04 -0400 (EDT)
Date: Mon, 22 Mar 2010 21:40:57 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] mm, fs: warn on missing address space operations
Message-ID: <20100322104057.GG17637@laptop>
References: <20100322053937.GA17637@laptop>
 <20100322005610.5dfa70b1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100322005610.5dfa70b1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 22, 2010 at 12:56:10AM -0400, Andrew Morton wrote:
> On Mon, 22 Mar 2010 16:39:37 +1100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > It's ugly and lazy that we do these default aops in case it has not
> > been filled in by the filesystem.
> > 
> > A NULL operation should always mean either: we don't support the
> > operation; we don't require any action; or a bug in the filesystem,
> > depending on the context.
> > 
> > In practice, if we get rid of these fallbacks, it will be clearer
> > what operations are used by a given address_space_operations struct,
> > reduce branches, reduce #if BLOCK ifdefs, and should allow us to get
> > rid of all the buffer_head knowledge from core mm and fs code.
> 
> I guess this is one way of waking people up.
> 
> What happens is that hundreds of bug reports land in my inbox and I get
> to route them to various maintainers, most of whom don't exist, so
> warnings keep on landing in my inbox.  Please send a mailing address for
> my invoices.

The Linux Foundation
1796 18th Street, Suite C
San Francisco, CA 94107

:)


> It would be more practical, more successful and quicker to hunt down
> the miscreants and send them rude emails.  Plus it would save you
> money.

I could do my best at the obvious (and easy to test filesystems) before
asking you to merge the warning patch. It's probably not totally trivial
to work out what aops are left NULL because they want the default
buffer-head helper, and which are left NULL because they aren't needed.
(this is one problem of having the default callback of course)


>
> > We could add a patch like this which spits out a recipe for how to fix
> > up filesystems and get them all converted quite easily.
> > 
> > ...
> >
> > @@ -40,8 +40,14 @@ void do_invalidatepage(struct page *page
> >  	void (*invalidatepage)(struct page *, unsigned long);
> >  	invalidatepage = page->mapping->a_ops->invalidatepage;
> >  #ifdef CONFIG_BLOCK
> > -	if (!invalidatepage)
> > +	if (!invalidatepage) {
> > +		static bool warned = false;
> > +		if (!warned) {
> > +			warned = true;
> > +			print_symbol("address_space_operations %s missing invalidatepage method. Use block_invalidatepage.\n", (unsigned long)page->mapping->a_ops);
> > +		}
> >  		invalidatepage = block_invalidatepage;
> > +	}
> 
> erk, I realise 80 cols can be a pain, but 165 cols is just out of
> bounds.  Why not
> 
> 	/* this fs should use block_invalidatepage() */
> 	WARN_ON_ONCE(!invalidatepage);

Problem is that it doesn't give you the aop name (and call trace
probably won't help). I'll make it all into a macro though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
