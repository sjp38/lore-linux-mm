Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 751346B0038
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:02 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1667397pdj.4
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:02 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so1667212pdj.21
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:51:59 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 00/14] Volatile Ranges v9
Date: Wed,  2 Oct 2013 17:51:29 -0700
Message-Id: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

So its been awhile since the last release of the volatile ranges
patches, and while Minchan and I have been busy with other things,
we have been slowly chipping away at issues and differences
trying to get a patchset that we both agree on.

There's still a few smaller issues, but we figured any further
polishing of the patch series in private would be unproductive
and it would be much better to send the patches out for review
and comment and get some wider opinions.

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
* Sort out apparent shrinker livelock that occasionally crops
  up under severe pressure
 
Feedback or thoughts here would be particularly helpful!

As is apparent from the author list, Minchan has really been the
one doing the heavy lifting here, and I've only been finding and
fixing a few bugs, refactoring the code for readability, and
trying to clarify commit messages. So many many thanks to Minchan
here for all his great work, and putting up with my sometimes
misguided "editing".

Also, thanks to Dhaval for his maintaining and vastly improving
the volatile ranges test suite, which can be found here:
	https://github.com/volatile-ranges-test/vranges-test


These patches can also be pulled from git here:
    git://git.linaro.org/people/jstultz/android-dev.git dev/vrange-v9

We'd really welcome any feedback and comments on the patch series. 

thanks
-john

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>


John Stultz (2):
  vrange: Clear volatility on new mmaps
  vrange: Add support for volatile ranges on file mappings

Minchan Kim (12):
  vrange: Add basic data structure and functions
  vrange: Add vrange support to mm_structs
  vrange: Add new vrange(2) system call
  vrange: Add basic functions to purge volatile pages
  vrange: Purge volatile pages when memory is tight
  vrange: Send SIGBUS when user try to access purged page
  vrange: Add vrange LRU list for purging
  vrange: Add core shrinking logic for swapless system
  vrange: Purging vrange-anon pages from shrinker
  vrange: Support background purging for vrange-file
  vrange: Allocate vroot dynamically
  vrange: Add vmstat counter about purged page

 arch/x86/syscalls/syscall_64.tbl       |    1 +
 fs/inode.c                             |    4 +
 include/linux/fs.h                     |    4 +
 include/linux/mm_types.h               |    4 +
 include/linux/rmap.h                   |   11 +-
 include/linux/swap.h                   |    6 +-
 include/linux/syscalls.h               |    2 +
 include/linux/vm_event_item.h          |    2 +
 include/linux/vrange.h                 |   84 +++
 include/linux/vrange_types.h           |   28 +
 include/uapi/asm-generic/mman-common.h |    3 +
 kernel/fork.c                          |   12 +
 kernel/sys_ni.c                        |    1 +
 lib/Makefile                           |    2 +-
 mm/Makefile                            |    2 +-
 mm/internal.h                          |    2 -
 mm/ksm.c                               |    2 +-
 mm/memory.c                            |   27 +
 mm/mincore.c                           |    5 +-
 mm/mmap.c                              |    5 +
 mm/rmap.c                              |   28 +-
 mm/vmscan.c                            |   17 +-
 mm/vmstat.c                            |    2 +
 mm/vrange.c                            | 1196 ++++++++++++++++++++++++++++++++
 24 files changed, 1429 insertions(+), 21 deletions(-)
 create mode 100644 include/linux/vrange.h
 create mode 100644 include/linux/vrange_types.h
 create mode 100644 mm/vrange.c

-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
