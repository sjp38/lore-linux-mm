Subject: Re: redundant RAMFS and cache pages on embedded system
References: <F265RQAOCop3wyv9kI3000143b1@hotmail.com>
	<3BC1928D.455D0A49@earthlink.net> <3BC1931E.3A7429A@earthlink.net>
From: ebiederman@uswest.net (Eric W. Biederman)
Date: 09 Oct 2001 14:56:42 -0600
In-Reply-To: <3BC1931E.3A7429A@earthlink.net>
Message-ID: <m1r8scv8fp.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joseph A Knapka <jknapka@earthlink.net>
Cc: Gavin Dolling <gavin_dolling@hotmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Joseph A Knapka <jknapka@earthlink.net> writes:

> (Sorry, just realized I should have supplied a useful
> subject line on my previous message.)
> 
> Joseph A Knapka wrote:
> > Gavin Dolling wrote:
> > >
> > > Your VM page has helped me immensely. I'm after so advice though about the
> > > following. No problem if you are too busy, etc. your site has already helped
> 
> > > me a great deal so just hit that delete key now ...
> > >
> > > I have an embedded linux system running out of 8M of RAM. It has no backing
> > > store and uses a RAM disk as its FS. It boots from a flash chip - at boot
> > > time things are uncompressed into RAM. Running an MTD type system with a
> > > flash FS is not an option.
> > >
> > > Memory is very tight and it is unfortunate that the binaries effectively
> > > appear twice in memory. They are in the RAM FS in full and also get paged
> > > into memory. There is a lot of paging going on which I believe is drowning
> > > the system.

The simple solution is to use ramfs, not a ramdisk with a fs on it.  As
ramfs puts the pages directly in the page cache, so you don't get
double buffering.  Possibly tmpfs/shmfs is a better solution as it has
a few more features and can't really be removed from the kernel.

> > > We have no swap file (that would obviously be stupid) but a large number of
> > > buffers (i.e. a lot of dirty pages). The application is networking stuff so
> > > it is supposed to perform at line rate - the paging appears to be preventing
> 
> > > this.
> > >
> > > What I wish to do is to page the user space binaries into the page cache,
> > > mark them so they are never evicted. Delete them from the RAMFS and recover
> > > the memory. This should be the most optimum way of running the system - in
> > > terms of memory usage anyway.

This exactly what you get with ramfs, or shmfs.

> > > So basically:
> > >
> > > a) Is this feasible?

It is done.
> > 
> > > b) When I delete the binary can I prevent it from being evicted from the
> > > page cache?
Don't go there.

> > > d) Am I insane to try this? (Why would be more useful than just a yes ;-) )
Yes, it is done.
Just use uncompress into ramfs instead of a ramdisk.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
