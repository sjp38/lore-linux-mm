Date: Thu, 30 Sep 1999 11:15:15 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909300958100.3455-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.3.96.990930110519.3724A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Marcus Sundberg <erammsu@kieray1.p.y.ki.era.ericsson.se>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 30 Sep 1999, James Simmons wrote:

> > No, same problem.  You can't put a process to sleep without
> > inter-processor interrupts on smp if its not running currently.
> 
> So only putting the current process to sleep doesn't cost anything. 
> Putting another process to sleep does cost. I see this as being alot less
> costly then the unmap the framebuffer and put the process to sleep on page
> fault just before you access the accel engine solution. I though putting
> another process to sleep would be easy. Just remove it from the run queue
> and place it in the wait_queue. Mark the process as UNINTERUPPITABLE. Once
> finished with the accel engine just remove it from the wait_queue and
> place on the run_queue again. What am I missing?

What if it's running on another CPU?  Then you have to do the same thing
that is done for tlb shootdown -- cross cpu synchronization is expensive!

> Here is another question since its very expensive putting another process 
> to sleep. If the process owns both the accel engine and framebuffer then I
> should be able to put the process to sleep while the accel engine is
> running? Since the process is asleep it can't acces the framebuffer but
> the accel engine is still running on the card.    

Oh gawd...  How much does the kernel know about the accelerator?
Something to consider is that the 'right' solution might be to make the
kernel pass console handling to a user task -- have you ever considered
that?

>   These are mmapped regions. So locking out the kernel will not help. You
> have to prevent userland from accessing the memory region to prevent the
> machine from locking. 

And the performance-correct way to do this is with a cooperative lock that
is *not part* of the mmap'd region.  This is where the difference between
personal computers and servers becomes apparent: with a personal computer,
you cannot protect the system against the local user in all cases because
the cost is too high.  This is one of those cases. 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
