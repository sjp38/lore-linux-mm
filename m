Date: Fri, 14 Jul 2000 10:01:06 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on 2.4.0-test2
Message-ID: <20000714100106.C3113@redhat.com>
References: <Pine.LNX.4.21.0007111445280.10961-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0007111955100.5098-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007111955100.5098-100000@inspiron.random>; from andrea@suse.de on Tue, Jul 11, 2000 at 08:00:23PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jul 11, 2000 at 08:00:23PM +0200, Andrea Arcangeli wrote:
> 
> So tell me how with your design can I avoid the kernel to unmap anything
> while running:
> 
> 	cp /dev/zero .

Because the unmapped cache pages from the ./zero output file are on
the inactive queue.  We refill the scavenge queue from that inactive
queue.  Only once there are too few inactive pages will we do _any_
aging of active pages.

You are still left with the "cp /dev/zero ." command flushing other
unmapped pages out of cache, of course, but nothing mapped needs to
get unmapped.

Actually it's likely to be a bit more complex than this, because there
is memory pressure on the inactive queue in this case, so it _will_
grow initially until the write throttling achieves an equilibrium.
That's fine, because we really don't want a machine with zero memory
in cache to become unable to cache anything simply because it refuses
ever to swap out.

However, there's a second thing Rik and I were talking about relating
to this problem --- if there is constant memory pressure on the
inactive queue, we *want* to do a small amount of background page
aging.  Any mapped pages which are still in use, even if they are only
being used infrequently, should still end up being marked referenced.
Pages which are just not being touched can, and should, be swapped
eventually.

The trouble is that the kernel can't easily tell the difference
between the read of a cd image and the read of a compiler header file
just from the file access alone.  If we don't have enough cache to
cache the whole set of header files that the compiler is using, then
obviously (1) we never see multiple cache hits, because the data is
evicted from cache before the application requests it again; but also
(2) we _want_ to be able to increase the cache in this case, even at
the expense of swappinng out other inactive processes.

The only way you can detect the "other inactive processes" (or at
least inactive pages) is to have background page aging going on while
you have memory pressure in the cache.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
