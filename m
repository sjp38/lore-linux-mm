Date: Fri, 23 Mar 2001 17:23:29 -0500 (EST)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
In-Reply-To: <E14gZuj-0005YN-00@the-village.bc.nu>
Message-ID: <Pine.GSO.4.21.0103231721120.10092-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ben LaHaise <bcrl@redhat.com>, Christoph Rohland <cr@sap.com>
List-ID: <linux-mm.kvack.org>


On Fri, 23 Mar 2001, Alan Cox wrote:

> > On Fri, 23 Mar 2001, Stephen C. Tweedie wrote:
> > >
> > > The patch below is for two races in sysV shared memory.
> > 
> > 	+       spin_lock (&info->lock);
> > 	+
> > 	+       /* The shmem_swp_entry() call may have blocked, and
> > 	+        * shmem_writepage may have been moving a page between the page
> > 	+        * cache and swap cache.  We need to recheck the page cache
> > 	+        * under the protection of the info->lock spinlock. */
> > 	+
> > 	+       page = find_lock_page(mapping, idx);
> > 
> > Ehh.. Sleeping with the spin-lock held? Sounds like a truly bad idea.
> 
> Umm find_lock_page doesnt sleep does it ?

It certainly does. find_lock_page() -> __find_lock_page() -> lock_page() ->
-> __lock_page() -> schedule().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
