Date: Thu, 13 Jan 2000 23:28:02 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [RFC] 2.3.39 zone balancing
In-Reply-To: <200001132213.OAA37225@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10001132322280.13454-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrea Arcangeli <andrea@suse.de>, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jan 2000, Kanoj Sarcar wrote:

	[snip Linus' winning idea]

> Yes, that's what everyone seems to be pointing at. As I mentioned, I am
> looking into this as I type. The only thing is, as Andrea points out, 
> 2.3 bh/irq handlers do not request HIGHMEM pages, so shouldn't the
> 2.3 kswapd do something more like: 
> 
>        more_work = 0;
>        for (i = 0; i < MAX_NR_ZONES; i++) {
> 		if (i != ZONE_HIGHMEM)
>                		more_work |= balance_zone(zone+i)
>        }
>        if (!more_work)
>                sleep()

Nope. We want to do page aging and reclamation in ZONE_HIGHMEM
too, otherwise all memory `rotation' is going to happen in the
other zones and the system can thrash in the remaining 1G of
memory while there's 3G of unused data in ZONE_HIGHMEM...

But I agree, we probably don't have to reclaim that many pages
in ZONE_HIGHMEM, something like freepages.min should be enough.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
