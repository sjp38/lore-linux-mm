Date: Fri, 21 Jan 2000 03:43:25 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001210301470.4332-100000@alpha.random>
Message-ID: <Pine.LNX.4.10.10001210337350.27593-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Andrea Arcangeli wrote:

> Anyway I think to see the problem described by Rik and actually I
> think it can be fixed by killing the useless polling of 1 second
> and replacing it with an unconiditional pre-wakeup of kswapd when
> GFP touch the freepages.high watermark. This will in turn should
> also help performances and it will try to free the cache from
> inside kswapd before a process have to free it itself.

It will damage performance. We want the hysteresis provided
by freepages.{min,low,high}...

Between .low and .high the one-second poll should do
the trick, making sure that all allocations are done
without delay.

Just around .low kswapd should be unconditionally
woken up.

Between .min and .low kswapd should be woken and
__GFP_WAIT allocations should wait.

Below .min only GFP_ATOMIC and PF_MEMALLOC allocations
should be allowed.

This is how the priorities have been intended
from the start on (except that we didn't have the
waiting part in the beginning, this needed fixing
later).

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
