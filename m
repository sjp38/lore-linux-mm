Date: Fri, 27 Aug 2004 15:30:07 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH] speed up fork performance
Message-ID: <20040827153007.A11943@flint.arm.linux.org.uk>
References: <Pine.LNX.4.44.0408271006340.10272-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0408271006340.10272-100000@chimarrao.boston.redhat.com>; from riel@redhat.com on Fri, Aug 27, 2004 at 10:09:38AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, Arjan Van de Ven <arjanv@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2004 at 10:09:38AM -0400, Rik van Riel wrote:
> 
> OK, this patch is _completely_ untested, but since I'm about to run
> off to a conference I guess I should get it to you anyway.
> 
> Basically in 2.6 lru_cache_add_active() takes an extra reference to
> the page, but do_wp_page() and friends don't expect a private anonymous
> page to have 2 references instead of 1.  This little patchlet changes
> can_share_swap_page() and exclusive_swap_page() to expect the extra
> reference.
> 
> Note that we cannot test for PageLRU(page) since lru_cache_add_active()
> uses a delayed insertion onto the LRU, so the PG_lru might not get set
> for a while...
> 
> Use at your own risk.

As I've just mentioned to Rik, this is probably buggy - pages which are
in the page cache and are then faulted into userspace seem to have a
page count of 2 even though they're part of a private mapping.  We don't
particularly want to allow these to be written to...

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
