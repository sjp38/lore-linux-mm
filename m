Date: Tue, 9 Jul 2002 19:32:46 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020709173246.GG8878@dualathlon.random>
References: <3D2A55D0.35C5F523@zip.com.au> <1214790647.1026163711@[10.10.2.3]> <3D2A7466.AD867DA7@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D2A7466.AD867DA7@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

the patch with the hooks into the page fault handler is basically
what Martin was suggesting me at ols when I was laughting. the ugliest
part is the implicit dependency on every copy-user to store the current
source and destination in esi/dsi.

However your implementation is still not as optimizes as you can
optimize it, if you take the max-performnace route you should do it all,
you shouldn't kunmap_atomic/kmap_atomic blindly around the page fault
handler like you're doing now. you should hold on the atomic kmap for
the whole page fault until a new kmap_atomic of the same type happens on
the current cpu under you during the page fault (either from the page
fault handler itself or another task because the page fault handler
blocked and scheduled in another task).

To detect the underlying kmap_atomic you only need a per-cpu sequence
counter that you increase during kmap_atomic (right after the implicit
preempt_disable()). you only need to read this sequence counter at
page-fault-entry-point (in the place where you are now doing the
uncoditional kunmap_atomic), and re-read the global per-cpu sequence
counter later before returning from the page fault to know if you've to
execute a new kmap_atomic. You need a sequence counter per-cpu per-type
of kmap.

NOTE: you don't need to execute the kunmap_atomic at all in the
recursive case, just disable the debugging (infact if you take this
route you can as well drop the kunmap_atomic call enterely from the
common code, you may want to verify the ppc or sparc guys aren't doing
something magic in the kunmap first, in such case you may want to skip
it only during recursion in the i386/mm/fault.c). Don't blame the fact
we lose some debugging capability, you want max performance at all costs
remeber?

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
