MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14609.53317.581465.821028@charged.uio.no>
Date: Thu, 4 May 2000 21:32:21 +0200 (CEST)
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <Pine.LNX.4.21.0005042022200.3416-100000@alpha.random>
References: <shsya5q2rdl.fsf@charged.uio.no>
	<Pine.LNX.4.21.0005042022200.3416-100000@alpha.random>
Reply-To: trond.myklebust@fys.uio.no
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Andrea Arcangeli <andrea@suse.de> writes:

     > On 4 May 2000, Trond Myklebust wrote:
    >> Not good. If I'm running /bin/bash, and somebody on the server
    >> updates /bin/bash, then I don't want to reboot my machine. With
    >> the above

     > If you use rename(2) to update the shell (as you should since
     > `cp` would corrupt also users that are reading /bin/bash from
     > local fs) then nfs should get it right also with my patch since
     > it should notice the inode number changed (the nfs fd handle
     > should get the inode number as cookie), right?

Yes, but I'm on the client: I cannot guarantee that people on the
server will do it 'right'. The server can have temporarily dropped
down into single user mode in order to protect its own users for all I
know.

Accuracy has to be the first rule whatever the case.

     > The only problem I am wondering about is that we simply can't
     > unlink _mapped_ page-cache pages from the pagecache as we do
     > now.

     > Say there's page A in the page cache. It gets mapped into a pte
     > of process
     > X. Then before you can drop A from the page cache to invalidate
     >    it
     > (because such page changed on the nfs server), you _first_ have
     > to unmap such page from the pte of process X. This is why
     > invalidate_inode_pages must not unlink mapped pages. It's not a
     > locking problem, PageLocked() pagecache_lock and all other
     > locks are irrelevant. It's not a race but a design issue.

As far as NFS is concerned, that page is incorrect and should be read
in again whenever we next try to access it. That is the purpose of the
call to invalidate_inode_pages().  As far as I can see, your patch
fundamentally breaks that concept for all files whether they are
mmapped or not.

When you say 'unmap from the pte', what exactly do you mean? Why does
such a page still have to be part of an inode's i_data?

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
