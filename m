From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14314.49322.671097.451248@dukat.scot.redhat.com>
Date: Fri, 24 Sep 1999 01:07:06 +0100 (BST)
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909221454320.26444-100000@imperial.edgeglobal.com>
References: <Pine.LNX.4.10.9909221454320.26444-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 22 Sep 1999 17:02:07 -0400 (EDT), James Simmons <jsimmons@edgeglobal.com> said:

> I noticed that mm_struct has a semaphore in it. How go is it protecting
> the memory region? Say we have teh following case. I have a process
> that mmaps a chunk of memory and this memory can be sharded with other 
> processes. What if the process does a mlock which does a
> down(mm->mmap_sem). Now the process goes to sleep and another process
> tries to modify the memory region. 

You have missed the point of the semaphore.  mmap_sem only protects the
vm list against being modified temporarily.  For example, it makes sure
that you don't unmap a VM region while doing a page fault on the same
region.  

An mlock() system call will take the semaphore while it performs the
locking operation and page faults all of the locked data into memory,
but when the mlock call returns, the semaphore will have been released.

> Will this semaphore protect this region? In a SMP machine same
> thing. What kind of protect does this semaphore provide? Does it
> prevent other process from doing anything to the memory. 

No.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
