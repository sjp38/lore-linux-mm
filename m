Message-ID: <380771D1.25616711@colorfullife.com>
Date: Fri, 15 Oct 1999 20:26:25 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kanoj-mm17-2.3.21 kswapd vma scanning protection
References: <199910151638.JAA72758@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, sct@redhat.com, andrea@suse.de, viro@math.psu.edu, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:
> If you wanted to be more careful, you
> could define the swapout prototype as swapout(start, end, flags, file).
> That *should* be enough for most future 2.3/2.4 driver.

"file" can go away if you do not call "get_file()" before releasing the
locking.

> 
> > - swap_out() is called with the semaphore held, 
> 
> Look below for why this is not safe.
You are right, this can lock-up. Swapper is only protected from
reentrancy on it's own stack, not from reentrancy from another thread.

> 
> > Or: ->swapout() releases the semaphore, 
> >
> 
> This works for filemap_swapout, but you can not expect every regular Joe
> driver writer to adhere to this rule.
The result is not a rare lock-up, but it will lock-up nearly
immediately. Even Joe would notice that.
[I know this is ugly]

> And here's one more. Before invoking swapout(), and before loosing the
> vmlist_lock in try_to_swap_out, the vma might be marked with a flag
> that indicates that swapout() is looking at the vma.
Or: use a multiple reader - single writer semaphore with "starve writer"
policy.
IMO that's cleaner than a semaphore with an attached waitqueue for
do_munmap().


> This swapout() cleanup is independent of the patch I have already posted,
> so the patch should be integrated into 2.3, while we debate how to tackle
> the cleanup.

Ok.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
