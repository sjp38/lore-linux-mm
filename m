Date: Thu, 30 Sep 1999 10:59:02 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.3.96.990929201805.6780A-100000@kanga.kvack.org>
Message-ID: <Pine.LNX.4.10.9909300958100.3455-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Benjamin C.R. LaHaise" <blah@kvack.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> No, same problem.  You can't put a process to sleep without
> inter-processor interrupts on smp if its not running currently.

So only putting the current process to sleep doesn't cost anything. 
Putting another process to sleep does cost. I see this as being alot less
costly then the unmap the framebuffer and put the process to sleep on page
fault just before you access the accel engine solution. I though putting
another process to sleep would be easy. Just remove it from the run queue
and place it in the wait_queue. Mark the process as UNINTERUPPITABLE. Once
finished with the accel engine just remove it from the wait_queue and
place on the run_queue again. What am I missing?

Here is another question since its very expensive putting another process 
to sleep. If the process owns both the accel engine and framebuffer then I
should be able to put the process to sleep while the accel engine is
running? Since the process is asleep it can't acces the framebuffer but
the accel engine is still running on the card.    

  Another question. Do the cards lock when you access any part of the
framebuffer and the accel engine or do the cards lock when you access
the a part of the framebuffer which at the same time is being modified by
the accel engine? If this is the case I was thinking about this possible
solution. You could have ioctl call to /dev/gfx where you would specify a
window in the framebuffer you want. That area of the framebuffer would be
removed from process address space owning the framebuffer and added to the
process address space that owns /dev/gfx. This way you could have a
application open /dev/gfx in X windows it would  actually grab a piece of
the framebuffer for its self. The X server could not access this memory
region. Of course the X server would have to handle the seg fault
gracefully. The application could then write to the framebuffer directly.
Also the application could send accel commands to this region. Now since
both regions are controled by the same process we can put to sleep that
process until the accel engine is done.         

> You can't
> allow the kernel to touch the frame buffer if the user is using the
> accelerator or vice-versa.  Have an ioctl to lock the kernel out from
> updating, and only unlock it from user space when there's no activity for
> a while.

  These are mmapped regions. So locking out the kernel will not help. You
have to prevent userland from accessing the memory region to prevent the
machine from locking. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
