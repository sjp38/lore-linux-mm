Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Tue, 17 Aug 1999 12:39:40 +0100 (BST)
In-Reply-To: <Pine.LNX.3.95.990817000705.19678B-100000@cesium.transmeta.com> from "Linus Torvalds" at Aug 17, 99 00:23:04 am
Content-Type: text
Message-Id: <E11Ghah-0004RI-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: kanoj@google.engr.sgi.com, andrea@suse.de, alan@lxorguk.ukuu.org.uk, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, linux-usb@suse.com
List-ID: <linux-mm.kvack.org>

>  If you write a driver and you want to give direct DMA access to some
> program, the way to do it is NOT by using some magic ioctl number and
> doing stupid things like some drivers do (ie notably bttv).

The bttv does it right Linus. It has to do some nastiness to work around
the Linux vm subsystem thats all. That nastiness is solely to get a table
of bus addressses of vmalloc pages. I don't think the 4Gig patch breaks it
at all. In the ideal world virt_to_bus() would work on vmalloc pages. It
doesnt and there are good reasons why so we have to handle that bit ourself.

The only ioctl stuff it has for directly sending stuff to addresses is for
frame buffer direct DMA, which is the only sane way to handle TV viewing.
That is given the bus address of the frame buffer by the X server, which
does know what it is doing.

> process wants direct access to the buffers that the IO is done from, and
> use an explicit mmap() on the file descriptor. The driver can then
> allocate a contiguous chunk of memory of the right type, and with the
> right restrictions, and then let the nopage() function page it into the
> user process space. 

Thats basically what bttv does. When you start grabbing we do

	vmalloc
	write BT848 RISC DMA script to match the pages allocated
	
	mmap maps those pages into user space as a ring buffer

The vmalloc is done off the ioctls to begin frame grabbing because it would
be very stupid to have 2-4Mb of ram allocated on open when a user didnt
want to do capturing.

> this, and have been doing it for several years. I don't know why the bttv
> driver has to be so broken, but as far as I can tell it's one of two (the

Its doing what you say it should. So why is it broken. It has to grab
2Mb of RAM or more at times and map them into user space. It does exactly
that.

> and I hadn't noticed until after I did a quick grep.. You can use
> __get_free_pages() to grab a larger area than just a single page. 

Video capture cards want several megabytes. get_free_pages() is unreliable
above about 16K. The bttv could certainly be written to do a loop of using
get_free_page() for each page it wants. That would be a fair bit cleaner. 
However Stephens rawio promises to provide roughly the right framework
for doing this stuff properly so I don't plan to do the job twice.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
