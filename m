Date: Tue, 11 Jul 2000 10:36:55 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Swap clustering with new VM
Message-ID: <20000711103655.E1054@redhat.com>
References: <Pine.LNX.4.21.0007091340520.14314-100000@freak.distro.conectiva> <Pine.LNX.4.21.0007092238450.586-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007092238450.586-100000@inspiron.random>; from andrea@suse.de on Sun, Jul 09, 2000 at 10:53:35PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jul 09, 2000 at 10:53:35PM +0200, Andrea Arcangeli wrote:
> On Sun, 9 Jul 2000, Marcelo Tosatti wrote:
> 
> >AFAIK XFS's pagebuf structure contains a list of contiguous on-disk
> >buffers, so the filesystem can do IO on a pagebuf structure avoiding disk
> >seek time.
> >
> >Do you plan to fix the swap clustering problem with a similar idea? 
> 
> I don't know pagebuf well enough to understand if it can helps.

It can't --- not directly, at least --- but the underlying
kiobuf-based IO code can improve CPU efficiency for swap IO.

> What worries me a bit is that whatever we do to improve swapin seeks it
> can always disagree with what the lru says that have to be thrown away.

Sure, but disk seeks are so much more expensive than anything else
that you really want to minimise them at all costs.  In 2.2 we added
paging clustering, which performs extra IO to minimise seeks, at the
cost of potentially evicting too many useful pages from memory to make
room for clustered incoming pages which aren't guaranteed to be used.
It made things _enormously_ faster for paging.

> A dumb way to provide the current swapin-contiguous behaviour is to do a
> unmap/swap-around of the pages pointed by the pagetables slots near the
> one that we found in the lru.

Ultimately we really need to be allocating pages based on VM address,
not on lru location, to get remotely good swap clustering.  The
existinng VM-based scanout achieves this cheaply as a side effect of
the scan order, but we need to realise that it isn't perfect and that
every move to a physical page-based scan algorithm will require us to
think about replacing the clustering mechanism.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
