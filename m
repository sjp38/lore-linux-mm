Date: Fri, 10 Dec 1999 01:44:53 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.3.96.991209180518.21542B-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9912100139370.12148-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: Rik van Riel <riel@nl.linux.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 1999, Benjamin C.R. LaHaise wrote:

> The type of allocation determines what pool memory is allocated from.  
> Ie nonpagable kernel allocations come from one zone, atomic
> allocations from another and user from yet another.  It's basically
> the same thing that the slab does, except for pages.  The key
> advantage is that allocations of different types are not mixed, so the
> lifetime of allocations in the same zone tends to be similar and
> fragmentation tends to be lower.

well, this is perfectly possible with the current zone allocator (check
out how build_zonelists() builds dynamic allocation paths). I dont see
much point in it though, it might prevent fragmentation to a certain
degree, but i dont think it is a fair use of memory resources. (i'm pretty
sure the atomic zone would stay unused most of the time) But you might
want to try it out - just pass many small zones in free_area_init_core()
and modify build_zonelists() to have private and isolated zones for
GFP_ATOMIC, etc.

the SLAB is completely different as it has micro-units of a few pages. A
zoned allocator must work on a larger scale, and cannot afford wasting
memory on the order of those larger units.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
