Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id AAA30770
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 00:13:42 -0500
Date: Sun, 17 Jan 1999 21:11:45 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.96.990118001901.263A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.95.990117210123.28579G-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, "Eric W. Biederman" <ebiederm+eric@ccr.net>, Kalle Andersson <kalle@sslug.dk>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Max <max@Linuz.sns.it>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Jan 1999, Andrea Arcangeli wrote:
> 
> Even if rock solid my PG_dirty implementation is been a lose. This because
> swapping out from shrink_mmap() was causing not ordered write to disk. So
> even if the process userspace was ordered in the swap, it was async
> written not-ordered. This was harming a _lot_ swapout performances... 

Indeed. 

Note that what I really wanted to use PG_dirty for was not for normal
page-outs, but for shared mappings of files. 

For normal page-out activity, the PG_dirty thing isn't a win, simply
because (a) it doesn't actually buy us anything (we might as well do it 
from the page tables directly) and (b) as you noticed, it increases
fragmentation.

The reason PG_dirty should be a win for shared mappings is: (a) it gets
rid of the file write semaphore problem in a very clean way and (b) it
reduces the number of IO requests for mappings that are writable for
multiple contexts (right now we will actually do multiple page-outs, one
for each shared mapping that has dirtied the page). 

I know you worked on patches to reduce (b) by walking multiple page
tables, but quite frankly that was always so ugly as to never stand a
chance in h*ll of ever getting included in a standard kernel. 

I looked at the problem, and PG_dirty for shared mappings should be
reasonably simple. However, I don't think I can do it for 2.2 simply
because it involves some VFS interface changes (it requires that you can
use the pame_map[] information and nothing else to page out: we have the
inode and the offset which actually is enough data to do it, but we don't
have a good enough "inode->i_op->writepage()" setup yet).

		Linus

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
