Date: Tue, 4 Jan 2000 08:35:34 +0100 (CET)
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: vm_operations (was: Re: release not called for my driver?)
In-Reply-To: <E125GRI-000221-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.10001040816410.8982-100000@nightmaster.csn.tu-chemnitz.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux Kernel Development <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jan 2000, Alan Cox wrote:

> > the device, I get the call to release exactly how I expect. HOwever, if
> > the application does a mmap of the device, then killing the device will
> > cause the vmclose to be called, BUT RELEASE IS NOT CALLED.
> 
> Guess one - you are still fiddling with the usage counts. With Linux 2.2.x
> you dont need to do that. Compare the 2.0 and 2.2 bttv drivers handling
> of mmap

Is there _any_ good Documentation on vm_opererations? When
exactly are each called? Under which conditions? (locks,
interrupt context, preparation of arguments, etc.)

Reading source is helpful, but sometimes these cases are not
_that_ clear...

E.g. I still see no method for a shared mmaped page that could be
updated "under your ass" from your device (which modifies data on
the page and can signal, if it is starting/finishing processing
the contents) to be updated in your process memory.

e.g.

   -  shared mmap of "/dev/page_modifier" to page AREA
   -  fault-in page -> device reads the page
   -  process write to page + calls msync -> device writes the
      page
   -  device starts updating page -> call ???? to temporarly
      unmap the page and halt process that is trying to
      read/write this page
   -  device finishes updating page -> call ???? to map the page
      again (to same location of course!) and wakeup all
      processes that were trying to read/write to this page.
      
There could be a _long_ time between these updates and the
updates itself take also a long time (device may hang, so we
eventuelly need to reboot it after a while).

Note: This _cannot_ be a block device (because it has
   non-continous memory, that is mapped and is able to do
   processing on data), but it is similarly handled (because it
   handles/swallows/generates mass data) ;)

Thanks and Regards

Ingo Oeser
-- 
Feel the power of the penguin - run linux@your.pc
<esc>:x


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
