Date: Tue, 17 Oct 2000 08:26:19 -0400 (EDT)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: VM magic numbers
In-Reply-To: <39EBA758.D0B89C1F@norran.net>
Message-ID: <Pine.BSF.4.10.10010170807140.18983-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

I'm interested in an explanation of the magic numbers in the code
as well.  According to my notes, there are magic numbers
in the following places in the code (all of which probably
need to be tuned, justified, or otherwise eliminated with
something else):

(note: my line numbers are against test9)

zone_balance_ratio -- I understand wanting to keep more DMA
pages around in case we need them, but the choice of
numbers seems quite arbitrary.  Perhaps the demand per
zone for free vs inactive clean pages should determine
where this number goes over time?

ln 455 in page_alloc.c: when memory allocation fails
we do a memory_pressure++, effectively a magic number
of 1.  Since this decays exponentially I would think
a failed allocation may want to kick things a little
harder?

ln 274 in page_alloc.c: pages_min+8?  I think I
see what's going on here, we want to make sure that
we have 8 pages free for recursive allocations..
But this doesn't guarantee that.  Besides, we
really don't care how many free pages there are
until the inactive_clean list is empty, right?
That's when we get into the danger of deadlock..

ln 323 page_alloc.c: inactive_target / 3, was /2
in earlier rounds..  I think we're trying not to launder
too many pages at once here?

.. and inactive_target is a magic number itself, really.
By my calculations it's 1/64 of memory_pressure or 1/4
of physical memory, whichever is smaller.  I know we do
this so we don't start laundering too many pages at once
when load increases, it smooths the curve out.  Some
work probably needs to be done to tell if it's really
effective at that or not.. (if the idea was borrowed
from FreeBSD's VM design, how did Matt test that?  and
what's the effect on streaming I/O performance under
increasing memory_pressure?)

Rik, can you bring out your flashlight and shed some
light on this? :)

--
Eric Lowe
Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
