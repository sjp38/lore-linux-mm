Date: Thu, 11 May 2000 17:09:48 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] Recent VM fiasco - fixed
In-Reply-To: <20000511193858.A402@stormix.com>
Message-ID: <Pine.LNX.4.10.10005111700520.1319-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Simon Kirby <sim@stormix.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On Thu, 11 May 2000, Simon Kirby wrote:
> 
> Hrm!  pre7 release seems to be even better.  113 vmstat-line-seconds now
> (yes, I know this isn't a very scientific testing method :)).  Second try
> was 114 vmstat-line-seconds.  classzone-27 did it in 107, so that's not
> very far off!  Also, it swapped much less this time, and used less CPU. 
> vmstat output attached.

The final pre7 did something that I'm not entirely excited about, but that
kind of makes sense at least from a CPU standpoint (as the SGI people have
repeated multiple times). What the real pre7 does is to just move any page
that has problems getting free'd to the head of the LRU list, so that we
won't try it immediately the next time. This way we don't test the same
pages over and over again when they are either shared, in the wrong zone,
or have dirty/locked buffers.

It means that the "LRU" is less LRU, but you could see it as a "how hard
do we want to free this" pressure-based system that really a least
recently _used_ system. And it avoids the "repeat the whole thing on the
same page" issue. And it looks like it behaves reasonably well, while
saving a lot of CPU.

Knock wood.

I'm still considering the pre7 as more a "ok, I tried to get rid of the
cruft" thing. Most of the special case code that has accumulated lately is
gone. We can start adding stuff back now, I'm happy that the basics are
reasonably clean.

I think Ingo already posted a very valid concern about high-memory
machines, and there are other issues we should look at. I just want to be
in a position where we can look at the code and say "we do X because Y",
rather than a collection of random tweaks that just happens to work.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
