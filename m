Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA05940
	for <linux-mm@kvack.org>; Wed, 19 Aug 1998 09:52:20 -0400
Date: Wed, 19 Aug 1998 10:45:36 +0100
Message-Id: <199808190945.KAA00835@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: Notebooks
In-Reply-To: <199808182138.OAA00489@penguin.transmeta.com>
References: <19980814115843.43989@orci.com>
	<m0z88bh-000aNFC@the-village.bc.nu>
	<199808182138.OAA00489@penguin.transmeta.com>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@lxorguk.ukuu.org.uk, davem@dm.cobaltmicro.com, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 18 Aug 1998 14:38:07 -0700, Linus Torvalds
<torvalds@transmeta.com> said:

> Ok, I found this.

> Once more, it was the slab stuff that broke badly.  I'm going to
> consider just throwing out the slabs for v2.2 unless somebody is willing
> to stand up and fix it - the multi-page allocation stuff just breaks too
> horribly. 

    /* If the num of objs per slab is <= SLAB_MIN_OBJS_PER_SLAB,
     * then the page order must be less than this before trying the next order.
     */
    #define	SLAB_BREAK_GFP_ORDER_HI	2
    #define	SLAB_BREAK_GFP_ORDER_LO	1

replace orders with 0; no more unnecessary higher-order allocations.  We
want this to be configurable at boot time, however; the extra efficiency
may be worth it on larger memory machines.  Linus, I'll do this if you
want it: default all the BREAK orders to 0 and add a boot option to
increase it.

> In this case, TCP wanted to allocate a single skb, and due to slabs this
> got turned into a multi-page request even though it fit perfectly fine
> into one page.  Thus a critical allocation could fail, and the TCP layer
> started looping - and kswapd could never even try to fix it up because
> the TCP code held the kernel lock. 

If the network stack can loop on an allocation without dropping the
lock, then even single-page allocations can deadlock.  (If there's a lot
of dirty data in swap, kswapd can quite easily block with no free pages
present for a time, especially if there is high network load at the
time.)

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
