Date: Thu, 1 Apr 2004 03:26:25 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040401012625.GV2143@dualathlon.random>
References: <20040331150718.GC2143@dualathlon.random> <Pine.LNX.4.44.0403311735560.27163-100000@localhost.localdomain> <20040331172851.GJ2143@dualathlon.random> <20040401004528.GU2143@dualathlon.random> <20040331172216.4df40fb3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040331172216.4df40fb3.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2004 at 05:22:16PM -0800, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> >
> > @@ -151,8 +151,11 @@ int rw_swap_page_sync(int rw, swp_entry_
> >  	lock_page(page);
> >  
> >  	BUG_ON(page->mapping);
> > -	page->mapping = &swapper_space;
> > -	page->index = entry.val;
> > +	ret = add_to_page_cache(page, &swapper_space, entry.val, GFP_KERNEL);
> 
> Doing a __GFP_FS allocation while holding lock_page() is worrisome.  It's
> OK if that page is private, but how do we know that the caller didn't pass
> us some page which is on the LRU?

it _has_ to be private if it's using rw_swap_page_sync. How can a page
be in a lru if we're going to execute add_to_page_cache on it? That
would be pretty broken in the first place.

> Your patch seems reasonable to run with for now, but to be totally anal
> about it, I'll run with the below monstrosity.

It's not needed IMO. We also already bugcheck on page->mapping, if
you're scared about the page being in a lru, you can add further
bugchecks on PageLru etc.. calling add_to_page_cache on anything that is
already visible to the VM in some lru is broken by design and should be
forbidden. All the users of swap suspend must work with freshly
allocated pages, the page_mapped bugcheck already covers most of the
cases.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
