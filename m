From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912140946.BAA07601@google.engr.sgi.com>
Subject: 2.3 Pagedir allocation/free and update races
Date: Tue, 14 Dec 1999 01:46:00 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

This note describes races in the procedures that allocate and free
user level page directories. Platform code maintainers, please
read.

Prior to 2.3, a lot of architectures used to cache unused page
directories to minimize copying the kernel level page tables
from the swapper_pg_dir. 2.2 used to rely on the kernel lock
for manipulating the cache list. In 2.3.31, page directories
are allocated with the kernel lock, but not freed with this lock.
So, all architectures that cache page directories have racy code.
The i386 does not cache page directories in 2.3.31.

In 2.2, set_pgdir() could rely on kernel_lock as it traversed the
cached page directories while updating them. 2.2 set_pgdir() was
racy in the sense that it could miss updating page directories
that belonged to newly created processes that were still not on
the active task list. This race exists in 2.3.31. To compound this
race, there might be page directories that do not have active
processes anymore due to optimized mm context switching.

Partly to solve this problem, in 2.3.32, an active mm list has
been added, that links up all the active mm's on the system.
Page directory allocation and freeing happen at precisely the
same times as elements are added and deleted from the active mm
list. Also, to make sure that no page directory misses seeing
updates by set_pgdir(), the pgd_alloc() call has been replaced
by 3 different calls:

a. get_pgd_fast(), which can not go to sleep since it is called
with the mmlist spin lock held. Ideal for searching cached page
directories for a free one.
b. get_pgd_slow(), that is called without mmlist lock, can go to
sleep, user level pgde's can be 0'ed out.
c. get_pgd_uptopdate(), called on newly allocated pgdirs, with the
mmlist lock held, to update kernel level pgde's. Cache lists may
be updated, if in-use pgdirs are being cached.

(Yes, alternate solutions are possible, this is the one that makes
most sense globally).

Also, pgd_free() is now called with mmlist lock held.

Now, the mmlist lock can be used to implement a global (not percpu)
cached list of page directories.

For example, the mmlist lock has been used to restore pgd caching
for i386. The i386 do_check_pgt_cache() also grabs the mmlist lock
while freeing extra pgdirs.

I also updated the code for these hooks for alpha, mips, ppc, sh
and sparc64. Most of these had page caching, but did not have a
lock to protect the cache. Now, they can use the mmlist lock for
this. I have _NOT_ fixed the do_check_pgt_cache() to use
mmlist_lock, which is needed for complete MP-safety.

The arm, m68k and sparc code is a little more intricate, I would
like the platform maintainers to take a look at these issues.

I would like to hear back from at least one platform maintainer
for each architecture (except i386), confirming that he will look
into and fix this issue. Lets say by end of this week, by private
mail.  I am willing to review any changes. If you would like me to
fix the code for you, let me know too. Else, I will have to grope
through unfamiliar code, and send in changes to Linus without having
any way to test the changes.

Thanks a lot for taking the time to read this!

Kanoj

PS: Look for mmlist_access_lock/mmlist_modify_lock/mmlist_set_pgdir
for examples on how to use the lists and lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
