Date: Thu, 4 May 2000 20:43:40 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <shsya5q2rdl.fsf@charged.uio.no>
Message-ID: <Pine.LNX.4.21.0005042022200.3416-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On 4 May 2000, Trond Myklebust wrote:

>Not good. If I'm running /bin/bash, and somebody on the server updates
>/bin/bash, then I don't want to reboot my machine. With the above

If you use rename(2) to update the shell (as you should since `cp` would
corrupt also users that are reading /bin/bash from local fs) then nfs
should get it right also with my patch since it should notice the inode
number changed (the nfs fd handle should get the inode number as cookie),
right?

>We have to insist on the PageLocked() both in 2.2.x and 2.3.x because
>only pages which are in the process of being read in are safe. If we
>know we're scheduled to write out a full page then that would be safe
>too, but that is the only such case.

I'm not wondering about locking/coherency/read/writes.

The only problem I am wondering about is that we simply can't unlink
_mapped_ page-cache pages from the pagecache as we do now.

Say there's page A in the page cache. It gets mapped into a pte of process
X. Then before you can drop A from the page cache to invalidate it
(because such page changed on the nfs server), you _first_ have to unmap
such page from the pte of process X. This is why invalidate_inode_pages
must not unlink mapped pages. It's not a locking problem, PageLocked()
pagecache_lock and all other locks are irrelevant. It's not a race but a
design issue.

>PS: It would be nice to have truncate_inode_pages() work in the same
>way as it does now: waiting on pages and locking them. This is useful
>for reading in the directory pages, since they need to be read in
>sequentially (please see the proposed patch I put on l-k earlier
>today).

I'll look at it.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
