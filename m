Date: Wed, 14 Jun 2000 15:57:30 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006141039230.6334-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006141549210.14124-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jun 2000, Rik van Riel wrote:

>So if the ZONE_DMA is filled by mlock()ed memory, classzone
>will *not* try to balance it? Will classzone *only* try to

It will try but it won't succeed.

>balance the big classzone containing zone_dma, and not the
>dma zone itself?  (since the dma zone doesn't contain any

No, I definitely try to balance the DMA zone itself. But in such case (all
DMA zone mlocked) kswapd will just spend CPU trying to balance the zone
but it _can't_ succeed because mlocked just means we can't even attempt to
move such memory elsewhere in the physical space or we'll break userspace 
critical latency needs.

>other zone, doesn't it need to be balanced?)

Yes, I of course agree, it needs to be balanced and classzone will try to
balance it.

>A few mails back you wrote that the classzone patch would
>do just about the same if a _classzone_ fills up. (except

What you mean with "just about the same"? You mean spending CPU in kswapd
trying to release some memory? If so yes. When a classzone fills up kswapd
will spend cpu trying to free some memory so that the next
GFP_DMA/GFP_KERNEL/GFP_HIGHUSER allocation (depending on the classzone
that is low on memory) will succeed.

>that the different shrink_mmap() causes it to go to sleep
>before being woken up again at the next allocation)

In classzone shrink_mmap doesn't control in any way how kswapd will react
to low memory conditions. Only the level of memory of the classzones are
controlling kswapd. If classzone is low on memory kswapd will keep to try
to shrink it.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
