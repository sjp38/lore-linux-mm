Date: Wed, 17 Aug 2005 16:23:41 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: pagefault scalability patches
In-Reply-To: <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0508171619260.3553@g5.osdl.org>
References: <20050817151723.48c948c7.akpm@osdl.org> <Pine.LNX.4.58.0508171529530.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171550001.19273@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0508171559350.3553@g5.osdl.org>
 <Pine.LNX.4.62.0508171603240.19363@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <piggin@cyberone.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 17 Aug 2005, Christoph Lameter wrote:
>
> We have no problems if the lock are not contended. Then we just reduce the 
> overhead by eliminating one semaphore instruction.

We _do_ have a problem.

Do a kernel benchmark on UP vs SMP, and realize that the cost of just
uncontended spinlocks is about 20% on some kernel loads. That's with
purely single-threaded benchmarks, tied to one CPU - the cost of atomic
ops really is that high. The only difference is the spinlock/unlock.

(Now, the page fault case may not be that bad, but the point remains: 
locking and atomic ops are bad. The anonymous page thing is one of the 
hottest pieces of code in the kernel under perfectly normal loads, and 
getting rid of spinlocks there is worth it).

The thing is, I personally don't care very much at all about 5000 threads
doing page faults in the same VM at the same time. I care about _one_
thread doing page faults in the same VM, and the fact that your patch, if
done right, could help that. That's why I like the patch. Not because of 
your scalability numbers ;)

So we're coming from two different angles here.

			Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
