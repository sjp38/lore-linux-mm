Date: Sun, 14 May 2000 14:19:36 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: pre8: where has the anti-hog code gone?
In-Reply-To: <Pine.LNX.4.21.0005140855260.16064-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005141415220.2201-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sun, 14 May 2000, Rik van Riel wrote:

> if (couldn't find an easy page) {
> 	atomic_inc(&zone->steal_before_allocate);
> 	try_to_free_pages();
> 	blah blah blah;
> 	atomic_dec(&zone->steal_before_allocate);
> }

ignore my previous comment about single-threadedness. Yes, this could
solve the problem, but might have other problems. There are some
differences: the above method is 'global', ie. it penalizes all
allocations if a try_to_free_pages() is blocked. [think about
try_to_free_pages() blocking for a _long_ time due to some reason - every
allocation will do a try_to_free_pages even though the original low memory
situation is long gone.] Am i correct?

The fundamental point would be to shield the result of a
try_to_free_pages() from other allocation points.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
