Date: Mon, 3 Jul 2000 14:56:42 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: More 2.2.17pre9 VM issues
Message-ID: <20000703145642.B3284@redhat.com>
References: <20000703111813.D2699@redhat.com> <Pine.LNX.4.21.0007031314190.12740-100000@inspiron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0007031314190.12740-100000@inspiron.random>; from andrea@suse.de on Mon, Jul 03, 2000 at 01:28:48PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, Jens Axboe <axboe@suse.de>, Alan Cox <alan@redhat.com>, Derek Martin <derek@cerberus.ne.mediaone.net>, Linux Kernel <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jul 03, 2000 at 01:28:48PM +0200, Andrea Arcangeli wrote:

> Stephen, are we really sure we still need kpiod?i

Yes.

> Isn't GFP_IO meant to be
> clear if anybody is helding any filesystem lock (like superblock lock)?

That has never been a requirement, and I'd think it would be
dangerous to make such a new rule so close to 2.4.  

Certainly, in 2.2 we would do all sorts of stuff while holding
filesystem locks (in particular the inode and superblock locks).  Any
file write, including mm page writes, would take the inode lock.  

Right now, in 2.4, the mm locks less but write(2) still takes the
inode lock.  That means that we _must_ be able to allocate with GFP_IO
while holding the inode lock, since (a) write()s go through the page
cache, and (b) touching the user's buffer during the write() can cause
pages to be swapped in, invoking parts of the VM which assume they are
able to use GFP_IO safely.

Sure, you could audit every single path through every filesystem to
make sure that there are no possible deadlocks here, but the whole
point of kpiod is to separate out the pageout from the process doing
the write() in such situations to make deadlock impossible.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
