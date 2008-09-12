Date: Fri, 12 Sep 2008 17:50:39 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC PATCH] discarding swap
Message-ID: <20080912165038.GA12849@shareable.org>
References: <Pine.LNX.4.64.0809092222110.25727@blonde.site> <20080910173518.GD20055@kernel.dk> <Pine.LNX.4.64.0809102015230.16131@blonde.site> <1221082117.13621.25.camel@macbook.infradead.org> <Pine.LNX.4.64.0809121154430.12812@blonde.site> <1221228567.3919.35.camel@macbook.infradead.org> <Pine.LNX.4.64.0809121631050.5142@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0809121631050.5142@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: David Woodhouse <dwmw2@infradead.org>, Jens Axboe <jens.axboe@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> > Does swap do that, when a page on the disk is deallocated and then used
> > for something else?
> 
> Yes, that's managed through the PageWriteback flag: there are various
> places where we'd like to free up swap, but cannot do so because it's
> still attached to a cached page with PageWriteback set; in which case
> its freeing has to be left until vmscan.c finds PageWriteback cleared,
> then removes page from swapcache and frees the swap.

Here's an idea which is prompted by DISCARD:

One thing the request layer doesn't do is cancellations.
But if it did:

If you schedule some swap to be written, then later it is no longer
required before the WRITE has completed (e.g. process exits), on a
busy system would it be worth _cancelling_ the WRITE while it's still
in the request queue?  This is quite similar to DISCARDing, but
internal to the kernel.

(Many userspace AIO interfaces do have cancellations, perhaps this is why).

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
