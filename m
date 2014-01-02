Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id C01EA6B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:11 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so13800179pdj.18
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:11 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gm1si15344151pac.100.2014.01.01.23.13.08
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:10 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 00/16] Volatile Ranges v10
Date: Thu,  2 Jan 2014 16:12:08 +0900
Message-Id: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

Hey all,

Happy New Year!

I know it's bad timing to send this unfamiliar large patchset for
review but hope there are some guys with freshed-brain in new year
all over the world. :)
And most important thing is that before I dive into lots of testing,
I'd like to make an agreement on design issues and others

o Syscall interface
o Not bind with vma split/merge logic to prevent mmap_sem cost and
o Not bind with vma split/merge logic to avoid vm_area_struct memory
  footprint.
o Purging logic - when we trigger purging volatile pages to prevent
  working set and stop to prevent too excessive purging of volatile
  pages
o How to test
  Currently, we have a patched jemalloc allocator by Jason's help
  although it's not perfect and more rooms to be enhanced but IMO,
  it's enough to prove vrange-anonymous. The problem is that
  lack of benchmark for testing vrange-file side. I hope that
  Mozilla folks can help.

So its been a while since the last release of the volatile ranges
patches, again. I and John have been busy with other things.
Still, we have been slowly chipping away at issues and differences
trying to get a patchset that we both agree on.

There's still a few issues, but we figured any further polishing of
the patch series in private would be unproductive and it would be much
better to send the patches out for review and comment and get some wider
opinions.

You could get full patchset by git

git clone -b vrange-v10-rc5 --single-branch git://git.kernel.org/pub/scm/linux/kernel/git/minchan/linux.git

In v10, there are some notable changes following as

Whats new in v10:
* Fix several bugs and build break
* Add shmem_purge_page to correct purging shmem/tmpfs
* Replace slab shrinker with direct hooked reclaim path
* Optimize pte scanning by caching previous place
* Reorder patch and tidy up Cc-list
* Rebased on v3.12
* Add vrange-anon test with jemalloc in Dhaval's test suite
  - https://github.com/volatile-ranges-test/vranges-test
  so, you could test any application with vrange-patched jemalloc by
  LD_PRELOAD but please keep in mind that it's just a prototype to
  prove vrange syscall concept so it has more rooms to optimize.
  So, please do not compare it with another allocator.
   
Whats new in v9:
* Updated to v3.11
* Added vrange purging logic to purge anonymous pages on
  swapless systems
* Added logic to allocate the vroot structure dynamically
  to avoid added overhead to mm and address_space structures
* Lots of minor tweaks, changes and cleanups

Still TODO:
* Sort out better solution for clearing volatility on new mmaps
        - Minchan has a different approach here
* Agreement of systemcall interface
* Better discarding trigger policy to prevent working set evction
* Review, Review, Review.. Comment.
* A ton of test

Feedback or thoughts here would be particularly helpful!

Also, thanks to Dhaval for his maintaining and vastly improving
the volatile ranges test suite, which can be found here:
[1]	https://github.com/volatile-ranges-test/vranges-test

These patches can also be pulled from git here:
    git://git.linaro.org/people/jstultz/android-dev.git dev/vrange-v9

We'd really welcome any feedback and comments on the patch series.

thanks

========== &< =========

Volatile ranges provides a method for userland to inform the kernel that
a range of memory is safe to discard (ie: can be regenerated) but
userspace may want to try access it in the future.  It can be thought of
as similar to MADV_DONTNEED, but that the actual freeing of the memory
is delayed and only done under memory pressure, and the user can try to
cancel the action and be able to quickly access any unpurged pages. The
idea originated from Android's ashmem, but I've since learned that other
OSes provide similar functionality.

This funcitonality allows for a number of interesting uses:
* Userland caches that have kernel triggered eviction under memory
pressure. This allows for the kernel to "rightsize" userspace caches for
current system-wide workload. Things like image bitmap caches, or
rendered HTML in a hidden browser tab, where the data is not visible and
can be regenerated if needed, are good examples.

* Opportunistic freeing of memory that may be quickly reused. Minchan
has done a malloc implementation where free() marks the pages as
volatile, allowing the kernel to reclaim under pressure. This avoids the
unmapping and remapping of anonymous pages on free/malloc. So if
userland wants to malloc memory quickly after the free, it just needs to
mark the pages as non-volatile, and only purged pages will have to be
faulted back in. I did some test with jemalloc by Jason Mason's help who
is author of jemalloc because he had interest on vrange sytem call.

Test(RAM 2G, CPU 4, ebizzy benchmark)
ebizzy argument: ./ebizzy -S 30 -n 512

default chunksize = 512k so 512k * 512 = 256M, *a* ebizzy process
has 256M footprint.

(1.1) stands for 1 process and 1 thread so (1.4) is
1 process and 4 thread.

vanilla			patched
1.1                   1.1
records:5             records:5
sum:30225             sum:151159
avg:6045              avg:30231.8
std:12.6174482365881  std:145.0839756831
med:6042              med:30281
max:6064              max:30363
min:6026              min:29953
1.4                   1.4
records:5             records:5
sum:74882             sum:281708
avg:14976.4           avg:56341.6
std:177.827556919662  std:924.991156714412
med:14990             med:56420
max:15242             max:57398
min:14683             min:54704
1.8                   1.8
records:5             records:5
sum:75060             sum:246196
avg:15012             avg:49239.2
std:166.670933278686  std:2072.42248588458
med:14985             med:50622
max:15307             max:50863
min:14790             min:45440
1.16                  1.16
records:5             records:5
sum:92251             sum:230435
avg:18450.2           avg:46087
std:121.169963274595  std:735.596356706584
med:18531             med:46339
max:18554             max:46810
min:18242             min:44737
4.1                   4.1
records:5             records:5
sum:18832             sum:50573
avg:3766.4            avg:10114.6
std:41.3018159407047  std:100.183032495457
med:3759              med:10184
max:3843              max:10209
min:3724              min:9926
4.4                   4.4
records:5             records:5
sum:18748             sum:40348
avg:3749.6            avg:8069.6
std:29.5133867930996  std:80.6091806185631
med:3741              med:8013
max:3803              max:8170
min:3721              min:7993
4.8                   4.8
records:5             records:5
sum:18783             sum:40576
avg:3756.6            avg:8115.2
std:34.7770038962723  std:66.3789123141068
med:3747              med:8111
max:3820              max:8196
min:3716              min:8033
4.16                  4.16
records:5             records:5
sum:21926             sum:29612
avg:4385.2            avg:5922.4
std:36.4219713909391  std:1486.31189189887
med:4391              med:5123
max:4431              max:8216
min:4319              min:4537

In every case, patched jemallloc allocator is win but as memory pressure
is severe, the gain was reduced but still better.
The stddev is rather higher old. I guess some reasons but need more to
investigate it. Of course, I need more testing on various workloads.
It should be TODO.

The syscall interface is defined in patch [4/16] in this series, but
briefly there are two ways to utilze the functionality:

Explicit marking method:
1) Userland marks a range of memory that can be regenerated if necessary
as volatile
2) Before accessing the memory again, userland marks the memroy as
nonvolatile, and the kernel will provide notifcation if any pages in the
range has been purged.

Optimistic method:
1) Userland marks a large range of data as volatile
2) Userland continues to access the data as it needs.
3) If userland accesses a page that has been purged, the kernel will
send a SIGBUS
4) Userspace can trap the SIGBUS, mark the afected pages as
non-volatile, and refill the data as needed before continuing on

Other details:
The interface takes a range of memory, which can cover anonymous pages
as well as mmapped file pages. In the case that the pages are from a
shared mmapped file, the volatility set on those file pages is global.
Thus much as writes to those pages are shared to other processes, pages
marked volatile will be volatile to any other processes that have the
file mapped as well. It is advised that processes coordinate when using
volatile ranges on shared mappings (much as they must coordinate when
writing to shared data). Any uncleared volatility on mmapped files will
last until the the file is closed by all users (ie: volatility isn't
persistent on disk).

Volatility on anonymous pages are inherited across forks, but cleared on
exec.

You can read more about the history of volatile ranges here:
http://permalink.gmane.org/gmane.linux.kernel.mm/98848
http://permalink.gmane.org/gmane.linux.kernel.mm/98676
https://lwn.net/Articles/522135/
https://lwn.net/Kernel/Index/#Volatile_ranges

John Stultz (2):
  vrange: Clear volatility on new mmaps
  vrange: Add support for volatile ranges on file mappings

Minchan Kim (14):
  vrange: Add vrange support to mm_structs
  vrange: Add new vrange(2) system call
  vrange: Add basic functions to purge volatile pages
  vrange: introduce fake VM_VRANGE flag
  vrange: Purge volatile pages when memory is tight
  vrange: Send SIGBUS when user try to access purged page
  vrange: Add core shrinking logic for swapless system
  vrange: Purging vrange-anon pages from shrinker
  vrange: support shmem_purge_page
  vrange: Support background purging for vrange-file
  vrange: Allocate vroot dynamically
  vrange: Change purged with hint
  vrange: Prevent unnecessary scanning
  vrange: Add vmstat counter about purged page

 arch/x86/syscalls/syscall_64.tbl       |    1 +
 fs/inode.c                             |    4 +
 include/linux/fs.h                     |    4 +
 include/linux/mm.h                     |    9 +
 include/linux/mm_types.h               |    4 +
 include/linux/shmem_fs.h               |    1 +
 include/linux/swap.h                   |   48 +-
 include/linux/syscalls.h               |    2 +
 include/linux/vm_event_item.h          |    6 +
 include/linux/vrange.h                 |   45 +-
 include/linux/vrange_types.h           |    6 +-
 include/uapi/asm-generic/mman-common.h |    3 +
 kernel/fork.c                          |   12 +
 kernel/sys_ni.c                        |    1 +
 mm/internal.h                          |    2 -
 mm/memory.c                            |   35 +-
 mm/mincore.c                           |    5 +-
 mm/mmap.c                              |    5 +
 mm/rmap.c                              |   17 +-
 mm/shmem.c                             |   46 ++
 mm/swapfile.c                          |   37 +
 mm/vmscan.c                            |   72 +-
 mm/vmstat.c                            |    6 +
 mm/vrange.c                            | 1174 +++++++++++++++++++++++++++++++-
 24 files changed, 1477 insertions(+), 68 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
