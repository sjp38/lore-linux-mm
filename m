Date: Fri, 12 Jan 2001 16:23:15 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <Pine.LNX.4.21.0101121705540.10842-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101121617230.8097-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Zlatko Calusic <zlatko@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 12 Jan 2001, Marcelo Tosatti wrote:
> > 
> > I really think that that page_launder() should be a "try_to_free_page()"
> > instead.
> 
> Linus,
> 
> do_try_to_free_pages() will shrink the caches too, so I'm not sure if that
> is the reason for the slowdown Zlatko is seeing. 

The point is that do_try_to_free_pages() will _also_ cause some VM swapout
activity, which will cause _future_ out-of-memory behaviour to be less of
a problem (because in the future we can depend on page_launder() instead
of having to flush caches).

> I dont understand the following changes you've done to try_to_swapout() in
> pre2 (as someone previously commented on this thread): 

I removed the extra aging, because basically it was a hack to avoid
swapping out stuff that shouldn't be swapped out.

> Secondly, you removed the "(page->age > 0)" check which is obviously
> correct to me (we don't want to unmap the page if it does not have age 0)

It's NOT "obviously correct". In fact, it's obviously _not_ correct. The
fact that the _page_ is new, does not mean that the page table reference
to that page is new. We _should_ drop the page from the page tables:
because that will mean that we will be better able to handle it in
page_launder().

If the page truly is new (because of some other user), then page_launder()
won't drop it, and it doesn't matter. But dropping it from the VM means
that the list handling can work right, and that the page will be aged (and
thrown out) at the same rate as other pages.

Now, I did find one bug: we should say

	if (!page->age)
		deactivate_page(page);

because we should not deactivate the page if it has an age (but we SHOULD
throw it out of the page tables).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
