Message-ID: <37FF39B7.55532FD9@colorfullife.com>
Date: Sat, 09 Oct 1999 14:48:55 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: locking question: do_mmap(), do_munmap()
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

which semaphores/spinlocks protect do_mmap() and do_munmap()?

do_mmap():
	I wrote a test patch, and I found out that some (all?) callers call
lock_kernel(), but that mm->mmap_sem is _NOT ACQUIRED_. Eg
sys_uselib()-> do_load_elf_??() -> do_mmap().

do_munmap():
???? I think here is a race:
sys_munmap() doesn't call lock_kernel(), it only acquires mm->mmap_sem.
do_mmap() internally calls do_munmap(), ie with the kernel lock, but
without mm->mmap_sem.

What about adding debugging runtime checks to these function?
ie #defines which call down_trylock() and spin_trylock() and oops on
missing locks?
We could define them to "(void)0" before 2.4.


--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
