Date: Thu, 4 May 2000 22:15:28 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: classzone-VM + mapped pages out of lru_cache
In-Reply-To: <14609.53317.581465.821028@charged.uio.no>
Message-ID: <Pine.LNX.4.21.0005042201520.5533-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2000, Trond Myklebust wrote:

>Yes, but I'm on the client: I cannot guarantee that people on the
>server will do it 'right'. [..]

If people on the server uses `cp` to upgrade bash they will screwup
themselfs and their shell will segfault from under them elventually.

> [..] The server can have temporarily dropped
>down into single user mode in order to protect its own users for all I
>know.
>
>Accuracy has to be the first rule whatever the case.

I fully see your point, however as far I can see (at least for 2.2.x where
we probably don't want to redesign the VM rules) we have to choose between
accuracy and stability and I choose stability. I much prefer to reboot
cleanly the machine (or more simply unmount/remount the nfs) than to
crash. That's also a local security issue, btw.

>As far as NFS is concerned, that page is incorrect and should be read
>in again whenever we next try to access it. That is the purpose of the
>call to invalidate_inode_pages().  As far as I can see, your patch
>fundamentally breaks that concept for all files whether they are
>mmapped or not.

It breaks the concept only for mmaped files. non mmaped files have
page->count == 1 so their cache will be shrunk completly as usual.

>When you say 'unmap from the pte', what exactly do you mean? Why does
               ^^^^^^^^^^^^^^^^^^

unmapping page from the pagetable means that later userspace won't be
anymore able to read/write to the page (only kernel will have visibility
on the page then and you'll read from the page in each read(2) and
write(2)). A page in the cache can be mapped in several ptes and we have
to unmap it from all them before we're allowed to unlink the page from the
pagecache or current VM will break.

>such a page still have to be part of an inode's i_data?

Mapped page-cache can't be unlinked from the cache as first because when
you'll have to sync the dirty shard mapping (because you run low on memory
and you have to get rid of dirty data in the VM) you won't know anymore
which inode and which fs the page belongs to.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
