Date: Thu, 27 Oct 2005 16:05:15 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027200515.GB12407@thunk.org>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <1130438135.23729.111.camel@localhost.localdomain> <20051027115050.7f5a6fb7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027115050.7f5a6fb7.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, andrea@suse.de, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is somewhat related to something which the JVM folks have been
pestering us (i.e., anyone within the LTC who will listen :-) for a
while now, which is a way to very _quickly_ (i.e., faster than munmap)
tell the kernel that a certain range of pages are not used any more by
the JVM, because the garbage collector has finished, and the indicated
region of memory is unused "oldspace".  

If those pages are needed the kernel is free to grab them for an other
purpose without writing them back to swap, and any attempt to read
from said memory afterwards should result in undefined behaviour.  In
practice, the JVM should never (absent bugs) try to read or write from
such pages before it tells the kernel that it cares about a region of
memory again (i.e., when the garbage collector runs again and needs to
use that section of memory for memory allocations, at which point it
won't care what the old memory values).

The JVM folks have tried using munmap, but it's too slow and if the
system isn't under memory pressure (as would be the case when an
application is correctly tuned for the machine and in benchmark
situations :-), completely unnecessary, since the pages will have to
mmaped back in after the next GC anyway.  So currently today, the JVM
folks simply do not release oldspace memory back to the system at all
after a GC.

What would be nice would be there is some way that an VMA could be
marked, "contents are unimportant", so that if there is a need for any
pages, the pages can be assumed to be clean and can simply be reused
for another purpose once they are deactivated without needing to waste
any swap bandwidth writing out pages whose contents are unimportant
and not in use by the JVM.  Then when the region is marked as being in
use again, and when it is touched, we simply map in the zero page COW.

That way, if the system is operating with plenty of memory, the
performance is minimal (simply setting and clearing a bit in the VMA).
But if the system is under memory pressure, the JVM is being a good
citizen and allowing its memory pages to be used for other purposes.

Does this sound like an idea that would be workable?  I'm not a VM
expert, but it doesn't sound like it's that hard, and I don't see any
obvious flaws with this plan.

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
