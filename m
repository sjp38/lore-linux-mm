Subject: Re: [PATCH 00/14] Concurrent Page Cache
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0701290918260.28330@schroedinger.engr.sgi.com>
References: <20070128131343.628722000@programming.kicks-ass.net>
	 <Pine.LNX.4.64.0701290918260.28330@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 29 Jan 2007 19:05:44 +0100
Message-Id: <1170093944.6189.192.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-01-29 at 09:20 -0800, Christoph Lameter wrote:
> On Sun, 28 Jan 2007, Peter Zijlstra wrote:
> 
> > With Nick leading the way to getting rid of the read side of the tree_lock,
> > this work continues by breaking the write side of said lock.
> 
> Could we get the read side in separately from the write side?

Sure, apply patches 1 through 9. 10 and up are the write side.

>  I think I 
> get the read side but the write side still looks scary to me and 
> introduces new ways of locking. Ladder locking?

Its all quite simple really; imagine locking the whole tree path
beginning at the root node. This obviously doesn't provide concurrency
since holing the root node locked will avoid all other operations from
starting.

However, as soon as you've locked a node on the next level and can
determine that you will never need to traverse the tree path upwards
from this point, you can drop the lock(s) on the previous level.

In the trivial case where you will never traverse up again, this reduces
to ladder locking.

Perhaps it is best illustrated with a picture (forgive the ASCII art)

                          A0
                  B0              B1
              C0      C1      C2      C3
            D0  D1  D2  D3  D4  D5  D6  D7

Say we need D5, which yield the path: A0, B1, C2, D5.

Ladder locking would end up:

lock A0
lock B1
unlock A0 -> a new operation can start
lock C2
unlock B1
lock D5
unlock C2
** we do stuff to D5
unlock D5

For path locking, this would end up being something like this:
(say we can determine we'll never cross C2 back up)

lock A0
lock B1
lock C2
unlock A0 -> a new operation can start
unlock B1
lock D5
** we do stuff to D5 and walk back up to C2
unlock C2
unlock D5

> > Aside from breaking MTD this version of the concurrent page cache seems
> > rock solid on my dual core x86_64 box.
> 
> What exactly is the MTD doing 

drivers/mtd/devices/block2mtd.c - fudges with the pagecache, haven't
spend any time in converting that. Shouldn't be hard.

> and how does it break?

Doesn't compile anymore.

(could use atomic_long_t for mapping::nr_pages I guess)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
