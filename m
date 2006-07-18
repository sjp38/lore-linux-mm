Message-ID: <44BC39AF.7070600@redhat.com>
Date: Mon, 17 Jul 2006 21:30:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: [RFC] pageout IO problem and possible solution
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Something that I forgot during the VM summit yesterday.

One of the problems that network block devices and network swap can
have is that the VM can end up submitting too much I/O at once for
swapout.  This, in turn, could leave not enough free memory to finish
the IO, leaving the system stuck.

A related problem can happen with local disk subsystems, where we
submit a gazillion pages for writeout simultaneously and end up
causing horrible latency problems...

There are a number of solutions possible in the 2.6 kernel.

The first one would be to limit the amount of writes in progress
through the block layer ->congested test, but allowing less I/O
in flight if we are doing pageout and/or memory is low.

The second one would be to introduce the inactive_laundry list
from 2.4-rmap.  This eats a bit from the already scarce page
flags though.

Either of these approaches should work I suspect, as long as we
also throttle kswapd when there is too much I/O in flight.  I am
not sure the current kernel does this, or has an exception for
kswapd.

I am not sure what the threshold for I/O in flight should be
though.

Maybe let there be as many pages in flight as we have (free +
easily reclaimable free) pages around, to reduce the chance of
a deadlock to something really really low?

Maybe that is not high enough to achieve the best throughput
on some high-end I/O subsystems?

Any ideas?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
