From: yannis@cc.gatech.edu (Yannis Smaragdakis)
Message-Id: <200007171856.OAA28852@ocelot.cc.gatech.edu>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Date: Mon, 17 Jul 2000 14:55:59 -0400 (EDT)
In-Reply-To: <Pine.LNX.4.21.0007171149440.30603-100000@duckman.distro.conectiva> from "Rik van Riel" at Jul 17, 2000 11:53:48 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: sct@redhat.com, andrea@suse.de, marcelo@conectiva.com.br, axboe@suse.de, alan@redhat.com, derek@cerberus.ne.mediaone.net, Yannis Smaragdakis <yannis@cc.gatech.edu>, davem@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Unfortunately, it sounded like I was arguing in favor of LRU, while
I was not. Also, I agree that a good algorithm should never swap out
program pages in favor of transient data. But I think it is 
overgeneralizing to go from "often pages are accessed only *once*"
to "frequency is good". The problem with frequency is that it's
very sensitive to phase behavior and may keep old pages around for
too long, just because they were accessed often some time ago.


Rik wrote:
> Both LRU and LFU break down on linear accesses to an array
> that doesn't fit in memory. In that case you really want
> MRU replacement, with some simple code that "detects the
> window size" you need to keep in memory. This seems to be

I agree and this is partly the point in our paper, only we argue that
this strategy can be generalized cleanly (instead of being a special
case hack).


> Since *both* recency and frequency are important, we can
> simply use an algorithm which keeps both into account.
> Page aging nicely fits the bill here.

Proposal:
Why not define "frequency" as "references over *normalized* time"
instead of "references over time"? If you touch a page twice
and in the meantime you have touched a million other pages,
this is important. If you touch a page twice and
in the meantime you have only touched one other page, this should not
affect "page age". In short, the way the page's age is updated should
be a function of how many other pages were found to be recently
referenced.

Say you call the code that reads/resets the reference bits and you
find that n pages were referenced in total. Then each of those
gets its age incremented by a factor proportional to n. For efficiency,
one could use the "n" that was computed during the last scan.


I think that this would get the effect you want and would alleviate
my concerns about "frequency".
	Yannis.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
