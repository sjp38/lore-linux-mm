Date: Fri, 2 Apr 2004 03:16:27 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402011627.GK18585@dualathlon.random>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2004 at 02:03:14AM +0100, Hugh Dickins wrote:
> On Fri, 2 Apr 2004, Andrea Arcangeli wrote:
> > 
> > the good thing is that I believe this fix will make it work with the -mm
> > writeback changes. However this fix now collides with anon-vma since
> > swapsuspend passes compound pages to rw_swap_page_sync and
> > add_to_page_cache overwrites page->private and the kernel crashes at the
> > next page_cache_get() since page->private is now the swap entry and not
> > a page_t pointer. So I guess I've a good reason now to giveup trying to
> > add the page to the swapcache, and to just fake the radix tree like I
> > did in my original fix. That way the page won't be swapcache either so I
> > don't even need to use get_page to avoid remove_exclusive_swap_page to
> > mess with it.
> 
> Yes, I too was feeling that we'd gone far enough in this "make it like
> a real swap page" direction, and we'd probably have better luck with
> "take away all resemblance to a real swap page".
> 
> I've still done no work or testing on rw_swap_page_sync, but I wonder...
> remember how your page_mapping(page) gives &swapper_space on a swap
> cache page, whereas my page_mapping(page) gives NULL on them?  My guess

yes.

> (quite possibly wrong) is that I won't have any of the trouble you've
> had with this, that the page_writeback functions, seeing NULL mapping,
> won't get involved with the radix tree at all - and why should they,

Not sure but I find your way very risky since writepage operations are
address space methods, it's like calling an object method with a null
object as parameter, very risky and dirty, and the primary reason I
wanted my swap cache to have a true page_mapping(page) ==
&swapper_space, your swapcache having a null mapping looks very dirty to
me and that's why I avoided it.

Note that the same way you drop the swapper_space with your code
applied, you could drop it indipendently from mainline too w/o any other
change. I much prefer to have a real swapper_space with a real tree_lock
with a real ->writepage callback etc..

> it isn't doing anything useful for rw_swap_page_sync, just getting you
> into memory allocation difficulties.  No need for add_to_page_cache or
> add_to_swap_cache there at all.  As I say, I haven't tested this path,

I wouldn't need to call add_to_page_cache either, it's just Andrew
prefers it.

> but I do know that the rest of swap works fine with NULL page_mapping.

though your code still has no way to work since it will clash on the
compound page just like mine. Note that my code already works fine as
far as it's not a compound page, as far as Andrew's code works in
mainline, my code will work fine, if my code doesn't work yours cannot
either (we both clash in the compound page infact).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
