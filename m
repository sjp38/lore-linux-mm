Message-ID: <3A423423.F73F1225@innominate.de>
Date: Thu, 21 Dec 2000 17:47:31 +0100
From: Daniel Phillips <phillips@innominate.de>
MIME-Version: 1.0
Subject: Re: Interesting item came up while working on FreeBSD's pageout daemon
References: <200012162016.eBGKGW902633@apollo.backplane.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Dillon wrote:
>     My conclusion from this is that I was wrong before when I thought that
>     clean and dirty pages should be treated the same, and I was also wrong
>     trying to give clean pages 'ultimate' priority over dirty pages, but I
>     think I may be right giving dirty pages two go-arounds in the queue
>     before flushing.  Limiting the number of dirty page flushes allowed per
>     pass also works but has unwanted side effects.

Hi, I'm a newcomer to the mm world, but it looks like fun, so I'm
jumping in. :-)

It looks like what you really want are separate lru lists for clean and
dirty.  That way you can tune the rate at which dirty vs clean pages are
moved from active to inactive.

It makes sense that dirty pages should be treated differently from clean
ones because guessing wrong about the inactiveness of a dirty page costs
twice as much as guessing wrong about a clean page (write+read vs just
read).  Does that mean that make dirty pages should hang around on
probation twice as long as clean ones?  Sounds reasonable.

I was going to suggest aging clean and dirty pages at different rates,
then I realized that an inactive_dirty page actually has two chance to
be reactivated, once while it's on inactive_dirty, and again while it's
on inactive_clean, and you get a double-length probation from that.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
