Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA00135
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 04:16:23 -0500
Date: Mon, 18 Jan 1999 10:15:07 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.95.990117210123.28579G-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990118095719.302B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 17 Jan 1999, Linus Torvalds wrote:

> Note that what I really wanted to use PG_dirty for was not for normal
> page-outs, but for shared mappings of files. 

Ah, Ok ;). I was using it in a completly different manner. I was using it
to indicate that the swap cache page was not uptodate on the swap space.
But as just said this cause not ordered write to disk from shrink_mmap().
Other than that it _was_ fine.

> The reason PG_dirty should be a win for shared mappings is: (a) it gets
> rid of the file write semaphore problem in a very clean way and (b) it

I can't understand this. I think to know _where_ to mark the page dirty
(in the `if (vm_op->swapout)' path) but I don't understand _where_ to
write the page out to disk avoiding the fs deadlock. Writing them in
shrink_mmap() would not fix the deadlock (obviously if shrink_mmap() is
still recalled as now by try_to_free_pages() etc...). 

> I know you worked on patches to reduce (b) by walking multiple page
> tables, but quite frankly that was always so ugly as to never stand a

OK, agreed ;). I am taking it here in the meantime only because it should
be at least safe. 

> I looked at the problem, and PG_dirty for shared mappings should be
> reasonably simple. However, I don't think I can do it for 2.2 simply
> because it involves some VFS interface changes (it requires that you can
> use the pame_map[] information and nothing else to page out: we have the
> inode and the offset which actually is enough data to do it, but we don't
> have a good enough "inode->i_op->writepage()" setup yet).

I still don't understand from _where_ doing the writepage. If we would do
it from shrink_mmap() I can't see how we could clear the pte of the
process (or better processes) before starting the writepage(). Probably I
am missing something of important (maybe because these nights I had not a
lot of time to sleep ;)... 

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
