Date: Tue, 25 Jan 2000 10:08:58 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.14 VM fix #3
In-Reply-To: <14476.42622.777454.521474@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.10001250959170.12802-100000@d251.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2000, Stephen C. Tweedie wrote:

>> And the 1-second polling loop has to be killed since it make no sense.
>
>Actually, that probably isn't too bad, as long as we make sure we wake

Agreed. It definitely isn't too bad. But as far I can tell it shouldn't
help either in RL and performance would be better without it. The point of
the 1 second polling loop basically is to refill the freelist from the low
to the high watermark even if the last allocation didn't caused the
watermark to go below the "low" level.

I think it would be better to make sure that kswapd will do a high-low
work at each run and not a not interesting 2/3 page work (for obvious
icache-lines reasons). And kswapd is so fast freeing the high-low pages,
that 1 second is a too long measure to make a RL difference. We just made
sure to not block on allocations before we go below the "min" level, thus
kswapd will have all the time to do its work before we block (if the mem
load is not heavy, and if the load is heavy the 1 second polling loop was
just a noop in the first place ;).

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
