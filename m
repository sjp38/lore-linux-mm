Date: Mon, 3 Jul 2000 17:09:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: More 2.2.17pre9 VM issues
Message-ID: <20000703170902.L3284@redhat.com>
References: <20000703145642.B3284@redhat.com> <Pine.LNX.4.21.0007031643100.1375-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007031643100.1375-100000@inspiron.random>; from andrea@suse.de on Mon, Jul 03, 2000 at 04:56:46PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 03, 2000 at 04:56:46PM +0200, Andrea Arcangeli wrote:
> 
> >pages to be swapped in, invoking parts of the VM which assume they are
> >able to use GFP_IO safely.
> 
> arghh b is a problem. I could workaround that with per per-process bitflag
> set before down(&inode->i_sem) that reminds me not to write on any fs
> because I would risk to recurse on the inode->i_sem.

It's not necessarily a problem, as the file paging routines don't take
the inode semaphore any more (at least on ext2).  But unless we want
to explicitly ban the read/writepage routines from invoking that
semaphore, we have to be prepared for this to happen.

Given that a write() syscall takes the semaphore for its whole
duration, that's an *awefully* long time to be preventing paging on
that inode.  So this is in fact probably the way forward --- document
that only write() can use the semaphore, but VM-invoked functions like
*writepage must not.

> The main problem I have with kpiod is that while it obviously avoids any
> kind of deadlocks on the fs since make_pio_request is completly
> asynchronous, it also introduces a problem in the swap_out code where we
> have no way to know if we did some progress or not and if we should wait
> some buffer to be written to disk.

Sure, but I've already said that I think we need multiple separate
paging queues, with the process of aging and cleaning pages made
separate from the process of evicting pages.  If you do that, then you
can always tell, from the length of the queues, whether or not you
still have work to do.

But I still agree that getting rid of kpiod is probably a good thing.
We just can't do it in 2.2.  In 2.4, keep it away by all means, but we
have to be aware of the implications when you do write() to an mmaped
file.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
