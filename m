Date: Sat, 9 Oct 1999 09:12:21 -0400 (EDT)
From: Alexander Viro <viro@math.psu.edu>
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <37FF39B7.55532FD9@colorfullife.com>
Message-ID: <Pine.GSO.4.10.9910090903530.14891-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


On Sat, 9 Oct 1999, Manfred Spraul wrote:

> which semaphores/spinlocks protect do_mmap() and do_munmap()?
> 
> do_mmap():
> 	I wrote a test patch, and I found out that some (all?) callers call
> lock_kernel(), but that mm->mmap_sem is _NOT ACQUIRED_. Eg
> sys_uselib()-> do_load_elf_??() -> do_mmap().
> 
> do_munmap():
> ???? I think here is a race:
> sys_munmap() doesn't call lock_kernel(), it only acquires mm->mmap_sem.
> do_mmap() internally calls do_munmap(), ie with the kernel lock, but
> without mm->mmap_sem.

do_munmap() doesn't need the big lock. do_mmap() callers should grab
the semaphore, unless they are sure that nobody else owns the same
context. Big lock on do_mmap() is still needed. do_mmap() in
do_load_elf_binary() is OK (we are the sole owners of context), but in the
do_load_elf_library() it is _not_. Moreover, sys_uselib() may do
interesting things to cloned processes. IMO the right thing would be to
check for the number of mm users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
