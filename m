Date: Wed, 14 Jun 2000 04:10:08 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006132231500.2954-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0006140351010.12294-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Rik van Riel wrote:

>On Wed, 14 Jun 2000, Andrea Arcangeli wrote:
>
>> >and we can support all corner cases of usage well without it. In
>> >fact, as I demonstrated above, even your own contorted example will
>> >hang classzone if I only switch the order in which the allocations
>> >happen...
>> 
>> It won't hang, but kswapd will eat CPU and that's right in your case. The
>> difference that you can't see is that in the second scenario where the
>> classzone would spend CPU in kswapd the CPU is spent for a purpose that
>> have a sense. In the first scenario where classzone wouldn't any spend
>> CPU, the CPU in kswapd would infact be _wasted_.
>
>Now explain to me *why* this happens. I'm pretty sure this happens
>because of the 'dispose = &old' in shrink_mmap and not because of
>anything even remotely classzone related...

You waste CPU in kswapd in the first scenario simply because you are not
looking backwards at the ZONE_DMA state at the time you have to choose if
you did some progress on the ZONE_NORMAL zone.

You did progress in the ZONE_DMA because it was all cache so then kswapd
should understand even if nothing is been freed from the ZONE_NORMAL, we
just have enough marging for the next GFP_KERNEL allocation too (not only
for the GFP_DMA allocations), thus it should stop looping. There's just
enough free memory for both zones.

The problem isn't related to shrink_mmap, but only to the zone design
(proper classzone part).

>I'm trying to improve the Linux kernel here, I'd appreciate it if
>you were honest with me.

Are you saying I'm not been honest with you? JFYI: I don't enjoy to get
insulted by you (and it's not the first time). I will ignore also your
above comment but please don't insult me anymore in the future! Thanks.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
