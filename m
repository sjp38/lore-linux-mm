Date: Mon, 3 Jul 2000 16:56:46 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: More 2.2.17pre9 VM issues
In-Reply-To: <20000703145642.B3284@redhat.com>
Message-ID: <Pine.LNX.4.21.0007031643100.1375-100000@inspiron.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jul 2000, Stephen C. Tweedie wrote:

>That has never been a requirement, and I'd think it would be
>dangerous to make such a new rule so close to 2.4.  

Note that 2.4.0-test* doesn't have kpiod just now (it's been dropped in
the 2.3.x cycle). Here I was wondering only about 2.2.x.

>Certainly, in 2.2 we would do all sorts of stuff while holding
>filesystem locks (in particular the inode and superblock locks).  Any
>file write, including mm page writes, would take the inode lock.  
>
>Right now, in 2.4, the mm locks less but write(2) still takes the
>inode lock.  That means that we _must_ be able to allocate with GFP_IO
>while holding the inode lock, since (a) write()s go through the page
>cache, and (b) touching the user's buffer during the write() can cause

writes in 2.2.x goes through the buffer cache that is for this reason
allocated with GFP_BUFFER.

>pages to be swapped in, invoking parts of the VM which assume they are
>able to use GFP_IO safely.

arghh b is a problem. I could workaround that with per per-process bitflag
set before down(&inode->i_sem) that reminds me not to write on any fs
because I would risk to recurse on the inode->i_sem.

The main problem I have with kpiod is that while it obviously avoids any
kind of deadlocks on the fs since make_pio_request is completly
asynchronous, it also introduces a problem in the swap_out code where we
have no way to know if we did some progress or not and if we should wait
some buffer to be written to disk. Waiting in shrink_mmap isn't even
enough since kpiod could have not yet been started writing and so there
may be none locked or dirty buffer in first place... We can't even wait on
kpiod ala wakeup_bdflush(1) since it would re-introduce the same deadlock
problem making kpiod useless for its anti-deadlock purpose.

So the only sane solution looked to me to skip the filemap_swapout when we
can't do it, and to do it ourselfs when we can. The problem is the "when
we can". Do you think it would be insane to implement the workaround I
mentioned above around the write semaphore?

>Sure, you could audit every single path through every filesystem to
>make sure that there are no possible deadlocks here, but the whole
>point of kpiod is to separate out the pageout from the process doing
>the write() in such situations to make deadlock impossible.

I'll think some more on it.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
