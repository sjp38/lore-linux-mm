Date: Fri, 24 Sep 1999 10:59:31 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: mm->mmap_sem
In-Reply-To: <14314.49322.671097.451248@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9909241040460.12262-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Sep 1999, Stephen C. Tweedie wrote:

> Hi,
> 
> On Wed, 22 Sep 1999 17:02:07 -0400 (EDT), James Simmons <jsimmons@edgeglobal.com> said:
> 
> > I noticed that mm_struct has a semaphore in it. How go is it protecting
> > the memory region? Say we have teh following case. I have a process
> > that mmaps a chunk of memory and this memory can be sharded with other 
> > processes. What if the process does a mlock which does a
> > down(mm->mmap_sem). Now the process goes to sleep and another process
> > tries to modify the memory region. 
> 
> You have missed the point of the semaphore.  mmap_sem only protects the
> vm list against being modified temporarily.  For example, it makes sure
> that you don't unmap a VM region while doing a page fault on the same
> region. 
> An mlock() system call will take the semaphore while it performs the
> locking operation and page faults all of the locked data into memory,
> but when the mlock call returns, the semaphore will have been released.

Does this mean while one process is in the act of mlocking a memory
region another process can actually change the contents of that memory?

> > Will this semaphore protect this region? In a SMP machine same
> > thing. What kind of protect does this semaphore provide? Does it
> > prevent other process from doing anything to the memory. 
> 
> No.

I obtained this idea from do_page_fault. This function is called from a
interrupt when a process actually tries to access memory correct? Even if 
the page does or doesn't exist? I noticed the down(&mm->mmap_sem) in
this function. Does this mean if I had a piece of code somewhere in the
kernel that already did a down(&mm->mmap_sem) on that memory region that 
when do_page_fault would be called that the process trying to access that
page would be put to sleep? Once the semaphore would be released that then
the process would be woken up and then access that memory. If this is not
the case then what would really happen? Thank you for your help by the way
to try and understand this stuff.   


> 
> --Stephen
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
