Date: Wed, 10 Apr 2002 17:08:42 -0500
From: Art Haas <ahaas@neosoft.com>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre5-ac3
Message-ID: <20020410220842.GA14573@debian>
References: <20020407164439.GA5662@debian> <20020410205947.GG21206@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020410205947.GG21206@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2002 at 01:59:47PM -0700, William Lee Irwin III wrote:
> On Sun, Apr 07, 2002 at 11:44:39AM -0500, Art Haas wrote:
> [ ... snip ... ]
> 
> Thank you! This has saved me some effort.
> 
> Burning question:
> What are the hunks changing arch/i386/kernel/setup.c there for?

The initial patch I downloaded had those changes in there. Looking
at them now there doesn't seem to be any reason to include them. Perhaps
they were inadvertently added originally, and I've been continuing
that tradition ...

> Also, there appears to be a livelock in add_to_swap(), (yes, this
> has killed my boxen dead) something to help with this follows.
> (It at least turned up a different problem I'm still working on.)

Sorry to hear that. I haven't had any trouble on my machine, but
it's an old machine (200MHz Pentium), and I run desktop stuff, so
the load the patch is exposed to on this machine must not be enough
to trip things up. 

Thanks for the feedback and your additional patch! I have
one question about it though ...

> diff -urN linux-virgin/mm/swap_state.c linux/mm/swap_state.c
> --- linux-virgin/mm/swap_state.c	Tue Apr  9 18:50:48 2002
> +++ linux/mm/swap_state.c	Tue Apr  9 21:28:15 2002
> @@ -104,6 +104,7 @@
>   */
>  int add_to_swap(struct page * page)
>  {
> +	int error;
>  	swp_entry_t entry;
>  
>  	if (!PageLocked(page))
> @@ -118,11 +119,15 @@
>  		 * (adding to the page cache will clear the dirty
>  		 * and uptodate bits, so we need to do it again)
>  		 */
> -		if (add_to_swap_cache(page, entry) == 0) {
> +		error = add_to_swap_cache(page, entry);
> +		if (!error) {
>  			SetPageUptodate(page);
>  			set_page_dirty(page);
>  			swap_free(entry);
>  			return 1;
> +		} else if (error = -ENOMEM) {
> +			swap_free(entry);
> +			return 0;
>  		}
>  		/* Raced with "speculative" read_swap_cache_async */
>  		swap_free(entry);
> 

Should the new "else" clause be ...

		} else if (error == -ENOMEM) {

I think you've dropped an "=". Maybe this is the cause of the
other trouble you were seeing?

I hadn't posted it yet, but I've made a newer version of the
patch that incorporates the latest changes from Christoph Hellwig
and Andrew Morton - the changes of spin_lock() and spin_unlock()
to (read|write)_lock() and (read|write)_unlock, plus a few cosmetic
changes. I'm running a kernel with those changes right now (and things
work for me, but we've seen how that goes ...) . I'll rebuild my kernel
with your fix to the swap_state.c file and see how that kernel
performs. I can cook up a script to repeatedly build something and
let things run for a while. If it works I'll post my modified patch tomorrow.

Thanks again for the feedback!
-- 
They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
