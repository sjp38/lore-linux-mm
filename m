Message-ID: <3BC1931E.3A7429A@earthlink.net>
Date: Mon, 08 Oct 2001 11:50:54 +0000
From: Joseph A Knapka <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: redundant RAMFS and cache pages on embedded system
References: <F265RQAOCop3wyv9kI3000143b1@hotmail.com> <3BC1928D.455D0A49@earthlink.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gavin Dolling <gavin_dolling@hotmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(Sorry, just realized I should have supplied a useful
subject line on my previous message.)

Joseph A Knapka wrote:
> 
> Hi Gavin,
> 
> [Forwarded to linux-mm, since those guys will be able to
>  answer your questions much more completely. Maybe someone
>  has already solved your problem.]
> 
> Gavin Dolling wrote:
> >
> > Your VM page has helped me immensely. I'm after so advice though about the
> > following. No problem if you are too busy, etc. your site has already helped
> > me a great deal so just hit that delete key now ...
> >
> > I have an embedded linux system running out of 8M of RAM. It has no backing
> > store and uses a RAM disk as its FS. It boots from a flash chip - at boot
> > time things are uncompressed into RAM. Running an MTD type system with a
> > flash FS is not an option.
> >
> > Memory is very tight and it is unfortunate that the binaries effectively
> > appear twice in memory. They are in the RAM FS in full and also get paged
> > into memory. There is a lot of paging going on which I believe is drowning
> > the system.
> >
> > We have no swap file (that would obviously be stupid) but a large number of
> > buffers (i.e. a lot of dirty pages). The application is networking stuff so
> > it is supposed to perform at line rate - the paging appears to be preventing
> > this.
> >
> > What I wish to do is to page the user space binaries into the page cache,
> > mark them so they are never evicted. Delete them from the RAMFS and recover
> > the memory. This should be the most optimum way of running the system - in
> > terms of memory usage anyway.
> >
> > I am planning to hack filemap.c. Going to use page_cache_read on each binary
> > and then remove from RAM FS. If the page is not in use I will have to make
> > sure that deleting the file does not result in the page being evicted.
> > Basically some more hacking required. I am also concerned about the inode
> > associated with the page, this is going to cause me pain I think?
> >
> > I am going to try this on my PC first. Going to try and force 'cat' to be
> > fully paged in and then rename it. I should still be able to use cat at the
> > command line.
> 
> I don't think this will work as a test case. The address_space mappings
> are based on inode identity, and since you won't actually have
> a "cat" program on your filesystem, the inode won't be found, so
> the kernel will not have a way of knowing that the cached pages
> are the right ones. You'd have to leave at least enough of the
> filesystem intact for the kernel to be able to map the program
> name to the correct inode. You might solve this by pinning the
> inode buffers in main memory before reclaiming the RAMFS pages,
> but that's pure speculation on my part.
> 
> > So basically:
> >
> > a) Is this feasible?
> 
> See below.
> 
> > b) When I delete the binary can I prevent it from being evicted from the
> > page cache?
> > (I note with interest that if I mv my /usr/bin/emacs whilst emacs is running
> >       e.g.   $ emacs &; mv /usr/bin/emacs /usr/bin/emacs2
> > it allows me to do it and what's more nothing bad happens. This tells me I
> > do not understand enough of what is going on - I would have expected this to
> > fail in some manner).
> 
> The disk inode for a moved or deleted file (and the file's disk
> blocks) don't get freed until all references to the inode are
> gone. If the kernel has the file open (eg due to mmap()),
> the file can still be used for paging until it's unmapped
> by all the processes that are using it. (This is another
> reason your test case above might be misleading.)
> 
> > c) I must have to leave something in the RAMFS such that the instance of the
> > binary still exists even if not its whole content.
> >
> > d) Am I insane to try this? (Why would be more useful than just a yes ;-)  )
> 
> I don't know. This is a deeper hack than any I've contemplated.
> However, I'm tempted to say that it would be easier to figure
> out a way to directly add the RAMFS pages to the page cache,
> and thus use a single page simultaneously as a cache page and
> an FS page. I don't know how hard that's going to be, but I
> think it might be easier than trying to yank the FS out from
> under an in-use mapping.
> 
> Cheers,
> 
> -- Joe
> # "You know how many remote castles there are along the
> #  gorges? You can't MOVE for remote castles!" - Lu Tze re. Uberwald
> # Linux MM docs:
> http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html

-- 
# Replace the pink stuff with net to reply.
# "You know how many remote castles there are along the
#  gorges? You can't MOVE for remote castles!" - Lu Tze re. Uberwald
# Linux MM docs:
http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
