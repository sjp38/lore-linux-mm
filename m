Date: Fri, 14 Jul 2000 09:51:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
Message-ID: <20000714095135.B3113@redhat.com>
References: <20000711125006.S1054@redhat.com> <Pine.LNX.4.21.0007111756200.3644-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007111756200.3644-100000@inspiron.random>; from andrea@suse.de on Tue, Jul 11, 2000 at 06:17:25PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Rik van Riel <riel@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jul 11, 2000 at 06:17:25PM +0200, Andrea Arcangeli wrote:
> >It's not supposed to work that way.
> Think if I shrink the lru_mapped first. you could have 100mbyte of clean
> and unmapped cache and before shrinking it you would unmap `vi`. ...

Andrea:	"This case here is really bad."
Stephen:"But the proposed mechanism doesn't work that way."
Andrea:	"But if it did, this case here would be really bad."

Andrea, it doesn't work this way, so the case you are complaining
about does not happen!

These different lists are DIFFERENT LISTS.  They do different jobs.

Free pages are given out from the scavenge list.  That list can be
topped up from the inactive list.  _That_ list can be topped up from
the active list.

The active list is where we do page aging.  The inactive list is where
we do write-back of unmapped but dirty pages.  The scavenge list is a
list of clean, unmapped pages which can be reclaimed at any time.

So, we do page aging in the active list when the inactive list is too
short (and having these different lists means that, finally, we can
actually measure the amount of pressure on these different lists
quantitatively, so that we can --- for example --- set a goal of
having one second's worth of pages on each list given the current
demand for pages).  

We just don't shrink lru_mapped (or the active list or whatever you
want to call it) first.  We only shrink it on demand, and we don't
swap out pages when we do so.  

> The object of this simple example is to show that the lrus have different
> priorities. These priorities will probably change in function of the
> workload of course but we can try to take care of that.

More than that, the lrus have completely different functions.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
