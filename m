Date: Tue, 4 Jan 2005 16:34:21 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
In-Reply-To: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0501041629490.4111@ppc970.osdl.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F02900FBD@scsmsx401.amr.corp.intel.com>
 <41C20E3E.3070209@yahoo.com.au> <Pine.LNX.4.58.0412211154100.1313@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231119540.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231132170.31791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0412231133130.31791@schroedinger.engr.sgi.com>
 <Pine.GSO.4.61.0501011123550.27452@waterleaf.sonytel.be>
 <Pine.LNX.4.58.0501041510430.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Linux Kernel Development <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


On Tue, 4 Jan 2005, Christoph Lameter wrote:
>
> This patch introduces __GFP_ZERO as an additional gfp_mask element to allow
> to request zeroed pages from the page allocator.

Ok, let's start merging this slowly, and in particular, this 1/4 one looks 
pretty much like a cleanup regardless of whatever else happen, so let's 
just do it. However, for it to really be a cleanup, how about making 
_this_ part:

> +
> +		if (gfp_flags & __GFP_ZERO) {
> +#ifdef CONFIG_HIGHMEM
> +			if (PageHighMem(page)) {
> +				int n = 1 << order;
> +
> +				while (n-- >0)
> +					clear_highpage(page + n);
> +			} else
> +#endif
> +			clear_page(page_address(page), order);
> +		}

Match the existing previous part:

>  		if (order && (gfp_flags & __GFP_COMP))
>  			prep_compound_page(page, order);


and just split it up into a "prep_zero_page(page, order)"? I dislike 
#ifdef's in the middle of deep functions. In the middle of a _trivial_ 
function it's much more palatable.

At that point at least part 1 ends up being a nice clean patch on its own, 
and should even shrink the code-size a bit. IOW, it not only is a cleanup, 
there is even a technical argument for it (even without worrying about the 
next stages).

Hmm?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
