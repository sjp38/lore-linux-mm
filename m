Received: (from msimons@localhost)
	by moria.simons-clan.com (8.10.0/8.10.0) id e4G2i3i06226
	for linux-mm@kvack.org; Mon, 15 May 2000 22:44:03 -0400
Date: Mon, 15 May 2000 22:44:03 -0400
From: Mike Simons <msimons@moria.simons-clan.com>
Subject: More observations...
Message-ID: <20000515224403.B5677@moria.simons-clan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

mmap002 application cause crashes, ways to avoid the kernel deadlocks,
and how to speed them up ;).

Questions:
- In vmstat output, if memory doesn't show up in "free", "buff", or in
  "cache" ... where is it?
- I don't understand why vmstat "block out" doesn't start happening shortly
  after the mmap002 application starts running?
- Why can't the kernel be flushing buffers to disk while the dirty
  buffers are being created by the application?  (especially when the number
  of "dirty" buffers on the system is > X %)

  The application making the dirty pages is only doing about 6M per second
of new dirty pages using about 6% of the processor.  Which my hard drive would
more that be able to keep up with flushing out.
  Based on my previous post it appears the kernel waits until *just*
before killing mmap002 to do any writes.  As far as I can tell, had the
kernel been flushing the buffers as they were dirtied there would never
have been a problem.   However, the kernel currently backs itself into 
a corner by encouraging applications to _fill_ all available memory with
dirty buffers so when someone asks for more memory there is no where to 
run ... except lots of disk I/O and blocking which the current kernel
(for whatever reason) doesn't wait long enough to happen before it starts
blowing processes to bits.  =)
  Sure if the kernel flushed started forcing flushed buffers to disk after
75% dirty the application could redirty ones already flushed and there 
would be some wasted I/O but that might just prevent the system from
completely running out of "available" pages to use, since it could
reuse one of it just put out to disk...

    
  Well... Since I don't know anything about how the kernel VM system works
I started tinkering with mmap002.c to see if there were different kernel
behaviors under different types of load:

  - Added fprintf's to tell which when mmap003 finishes each loop.

    I found that the first loop was never finishing before it was killed.
    After mmap003 was killed most of the memory was left in "cache".
    
    
  - Changed the for loops to skip 1024 bytes into the map for 
    each dirty... ("i++" --> "i+=1024")
    
    This causes the kernel to kill almost every application (a list of
    about 8 (including init 6 times)), the first time mmap003 is
    run after a fresh reboot.  This on the -pre8+riel patch 2 kernel
    I mentioned earlier today, the major change is it normally took
    at least three runs kill the system before, and only occasionally
    killed more than mmap and init... now it is slaying several 
    applications every time.


  - Still skipping 1024 bytes, I added a msync to flush the entire
    mmap'ed buffer after dirtying every 1Meg of the file.

    This version takes 11 seconds to run the first loop. Never ever,
    gets killed running the first loop...

    When it starts the second for loop (which uses a non-file-mmapped buffer)
    suddenly memory disappears from "cache" and does not reappear in any
    other category.  I killed the application after vmstat only showed
    24Megs left in my system (4 free, 0 buff, 20 cached).  All these missing
    buffers appeared back in free instantly.
      I then let this run this a few times, each time it kills the mmap003
    application while in the second for loop... this loop never completes.
    When the application is killed all the memory that was missing appears
    in the free memory area instantly.  (Sometimes this second loop will
    kill init and lock the system so be careful.)


  - Changed the msync to request ASYNC flushing of the whole buffer, 
    once every 32 Megs... the first loop completes in 8 seconds of real
    time, 0 seconds user, 1 seconds system (256 Meg file).  The system
    locks up for about 4 seconds just before finishing the for loop, but
    is responsive before and after...


  - I noticed the difference between a file-mapped and a non-file-mapped
    application kill and the effects on free memory... so I've tried killing
    the application manually.  Which has the same effect (memory doesn't
    move to free).

    I tracked this down to the buffers remain in the "cache" state until the
    file which is file-mapped is unlinked.  At which point all of the
    buffers instantly free up.

    TTFN,
      Mike Simons

vmstat runs during some tests and some version of the mmap003.c code is
available from:
  http://moria.simons-clan.com/~msimons/

note the original mmap code is part of a suite by Juan Jose Quintela 
and is available:
  http://carpanta.dc.fi.udc.es/~quintela/memtest/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
