Date: Mon, 25 Sep 2000 16:40:44 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VM
Message-ID: <20000925164044.F2615@redhat.com>
References: <Pine.LNX.4.21.0009251511050.6224-100000@elte.hu> <E13dZX7-00055f-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13dZX7-00055f-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Sep 25, 2000 at 03:47:03PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 03:47:03PM +0100, Alan Cox wrote:
> 
> GFP_KERNEL has to be able to fail for 2.4. Otherwise you can get everything
> jammed in kernel space waiting on GFP_KERNEL and if the swapper cannot make
> space you die.

We already have PF_MEMALLOC to provide a last-chance allocation pool
which only the swapper can eat into. 

The critical thing is to avoid having the swapper itself deadlock.
Everything revolves around that.  Once you can make that guarantee,
it's perfectly safe to make GFP_KERNEL succeed for other callers, just
as long as you have enough beancounting in place in those callers.

Right now, the biggest obstacle to this is the GFP_ATOMIC behaviour:

	/*
	 * Final phase: allocate anything we can!
	 *
	 * This is basically reserved for PF_MEMALLOC and
	 * GFP_ATOMIC allocations...
	 */

Allowing GFP_ATOMIC to eat PF_MEMALLOC's last-chance pages is the
wrong thing to do if we want to guarantee swapper progress under
extreme load.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
