Date: Sat, 13 May 2000 08:28:40 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.21.0005122031500.28943-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005130819330.1721-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 12 May 2000, Rik van Riel wrote:
> 
> I'm reading the pre8 code now and I see that the anti-hog
> code is gone. I'm still busy developing the active/inactive
> list thing, but was just doing a short test with pre8 and
> noticed a *sharp* increase in the amount of filesystem IO
> when a big memory hog is swapping ...

I removed _all_ the special-case code. This included not just the hog
stuff, but pretty much all the new logic in later 2.3.x that couldn't be
sufficiently explained.

And I'm not going to add it back in before the "out of memory" condition
has been clearly understood - it's obvious right now that the system
depends critically on kswapd in order to not return out of memory, and
that is wrong. kswapd should smooth things out, it should not be a
critical bottle-neck. 

[ You may ask "why?". The reason is two-fold: (a) I don't like having a
  fragile system that depends on something like kswapd/kflushd for correct
  operation. So Linux _will_ work without bdflush, for example, and it's
  actually a common mode for laptops that want to avoid spinning up just
  to flush more smoothly. The same should be true of kswapd. And (b)
  kswapd is a regular process, as it should be, as is bound by the regular
  schduling rules. Which may, quite validly, mean that kswapd may have to
  wait for other, more important processes. We should still handle
  low-memory circumstances gracefully ]

So pre-8 with your suggested for for kswapd() looks pretty good, actually,
but still has this issue that try_to_free_pages() seems to give up too
easily and return failure when it shouldn't. I'll happily apply patches
that make for nicer behaviour once this is clearly fixed, but not before
(unless the "nicer behaviour" patch _also_ fixes the "pathological
behaviour" case ;)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
