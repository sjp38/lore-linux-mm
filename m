Date: Wed, 6 Jun 2001 13:47:23 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Message-ID: <20010606134723.D1757@redhat.com>
References: <l03130308b7439bb9f187@[192.168.239.105]> <3B1E203C.5DC20103@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B1E203C.5DC20103@uow.edu.au>; from andrewm@uow.edu.au on Wed, Jun 06, 2001 at 10:21:16PM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Jonathan Morton <chromi@cyberspace.org>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 06, 2001 at 10:21:16PM +1000, Andrew Morton wrote:
> Jonathan Morton wrote:
> > 
> > Interesting observation.  Something else though, which kswapd is guilty of
> > as well: consider a page shared among many processes, eg. part of a
> > library.  As kswapd scans, the page is aged down for each process that uses
> > it.  So glibc gets aged down many times more quickly than a non-shared
> > page, precisely the opposite of what we really want to happen.
> 
> Perhaps the page should be aged down by (1 / page->count)?

The problem, of course, is that the referenced bit is not being
maintained at the same rate for all pages: we set it whenever we see a
mapping for it.  So, in fact, glibc can get aged *up* more than other
pages: because it is in multiple VMs, the swap loop has the chance to
rejuvinate the page more often.

We really want the aging done elsewhere.  Ideally, the VM page
scanning should be maintaining the state of the referenced bit on the
page, but the age manipulation should be done in the inactive-refill
loop.  That way the referenced-bit state would be propagated into the
page age at a uniform rate for all pages.  The difficulty is that the
refill-inactive loop and the try_to_swap_out loops proceed at
different rates, so it's not really possible at the moment to
determine all at once whether or not a page has been referenced in any
way since it was last seen.

Remember also that an unreferenced page gets unlinked from the page
tables in try_to_swap_out, so the presence of multiple inactive links
to glibc won't affect the swapper too much --- once those links have
been passed over once, they will be removed and we won't get extra
aging down done in subsequent passes.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
