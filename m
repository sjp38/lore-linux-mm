Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id TAA00654
	for <linux-mm@kvack.org>; Thu, 22 Jun 2000 19:00:55 +0100
Subject: Re: [RFC] RSS guarantees and limits
References: <Pine.LNX.4.21.0006211059410.5195-100000@duckman.distro.conectiva>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 22 Jun 2000 19:00:54 +0100
In-Reply-To: Rik van Riel's message of "Wed, 21 Jun 2000 19:29:44 -0300 (BRST)"
Message-ID: <m2lmzx38a1.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> I think I have an idea to solve the following two problems:
> - RSS guarantees and limits to protect applications from
>   each other

I think that this principle should be queried. Taking the base unit to
be the process, while reasonable, is not IMHO a good idea.

For multiuser systems the obvious unit is the user; that is, it is
clearly necessary to stop one user hogging system memory, whether
they've got 5 or 500 processes.

For workstations, often the user is only working with one or two
processes, which are extremely large (window system and math package
for example) and a series of smaller processes (xeyes and window
manager). Taking resources away from a coffee making simulator just so
some mailnotifier can keep a stupid animation in memory doesn't make
sense.

For special boxes with only one process running, keeping others in
cache will only be harmful.

[ Perhaps some system analogous to "nice" would be helpful. I think that
the user can directly give a lot of very useful information to the VM
(for example, the hint that when memory runs out, netscape should be
killed before other processes). ]

It would be better to treat all memory objects as equals; for example,
when emacs is taking up a huge amount of memory because it's acting
alternately as a news client and tetris game, your system would only
count it as one process, which is unfair -- it is logically being
treated as two. If the page were taken as basic block, all of these
problems would be solved (or why not? after all we're supposed to be
converting to the perpage system).

> - make sure streaming IO doesn't cause the RSS of the application
>   to grow too large

This problem could be more generally stated: make sure that streaming
IO does not chuck stuff which will be looked at again out of cache.
As I explained above, I think that the process is a bad basic
unit.

> - protect smaller apps from bigger memory hogs

Why? Yes, it's very altruistic, very sportsmanlike, but giving small,
rarely used processes a form of social security is only going to
increase bureaucracy ;-)

I don't follow the idea that processes should be squashed if they're
large, and my three examples demonstrate that this is a bad.

> The idea revolves around two concepts. The first idea is to
> have an RSS guarantee and an RSS limit per application, which
> is recalculated periodically. A process' RSS will not be shrunk
> to under the guarantee and cannot be grown to over the limit.
> The ratio between the guarantee and the limit is fixed (eg.
> limit = 4 x guarantee).

This is complex and arbitrary; the concept of a guarantee is not
naturally occuring therefore (looking at the current state of the mm
code) it will become detuned if it ever gets tuned (like the priority
argument to vmscan::swap_out which is almost always between 60 and 64
on my box) and merely make more performance trouble because the
complexity isn't helping any.

I do agree that looking at and adjusting to processes memory access
patterns is a good idea, if it can be done right. I disagree with this
particular way of doing it; it feels too arbitrary and I don't think
it will do any good.

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
