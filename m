Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 70B946B014F
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:31:12 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/4] RFC - ksm api change into madvise
Date: Thu, 14 May 2009 03:30:44 +0300
Message-Id: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: hugh@veritas.com
Cc: linux-kernel@vger.kernel.org, aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, linux-mm@kvack.org, riel@redhat.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

This is comment request for ksm api changes.
The following patchs move the api to use madvise instead of ioctls.

Before i will describe the patchs, i want to note that i rewrote this
patch seires alot of times, all the other methods that i have tried had some
fandumatel issues with them.
The current implemantion does have some issues with it, but i belive they are
all solveable and better than the other ways to do it.
If you feel you have better way how to do it, please tell me :).

Ok when we changed ksm to use madvise instead of ioctls we wanted to keep
the following rules:

Not to increase the host memory usage if ksm is not being used (even when it
is compiled), this mean not to add fields into mm_struct / vm_area_struct...

Not to effect the system performence with notifiers that will have to block
while ksm code is running under some lock - ksm is helper, it should do it
work quitely, - this why i dropped patch that i did that add mmu notifiers
support inside ksm.c and recived notifications from the MM (for example
when vma is destroyed (invalidate_range...)

Not to change the MM logic.

Trying to touch as less code as we can outisde ksm.c


Taking into account all this rules, the end result that we have came with is:
mmlist is now not used only by swapoff, but by ksm as well, this mean that
each time you call to madvise for to set vma as MERGEABLE, madvise will check
if the mm_struct is inside the mmlist and will insert it in case it isnt.
It is belived that it is better to hurt little bit the performence of swapoff
than adding another list into the mm_struct.

One issue that should be note is: after mm_struct is going into the mmlist, it
wont be kicked from it until the procsses is die (even if there are no more
VM_MERGEABLE vmas), this doesnt mean memory is wasted, but it does mean ksm
will spend little more time in doing cur = cur->next if(...).

Another issue is: when procsess is die, ksm will have to find (when scanning)
that its mm_users == 1 and then do mmput(), this mean that there might be dealy
from the time that someone do kill until the mm is really free -
i am open for suggestions on how to improve this...

(when someone do echo 0 > /sys/kernel/mm/ksm/run ksm will throw away all the
memory, so condtion when the memory wont ever be free wont happen)


Another important thing is: this is request for comment, i still not sure few
things that we have made here are totaly safe:
(the mmlist sync with drain_mmlist, and the handle_vmas() function in madvise,
the logic inside ksm for searching the next virtual address on the vmas,
and so on...)
The main purpuse of this is to ask if the new interface is what you guys
want..., and if you like the impelmantion desgin.

(I have added option to scan closed support applications as well)


Thanks.

Izik Eidus (4):
  madvice: add MADV_SHAREABLE and MADV_UNSHAREABLE calls.
  mmlist: share mmlist with ksm.
  ksm: change ksm api to use madvise instead of ioctls.
  ksm: add support for scanning procsses that were not modifided to use
    ksm

 include/asm-generic/mman.h |    2 +
 include/linux/ksm.h        |   40 --
 include/linux/mm.h         |    2 +
 include/linux/sched.h      |    3 +
 include/linux/swap.h       |    4 +
 mm/Kconfig                 |    2 +-
 mm/ksm.c                   | 1102 ++++++++++++++++++++++----------------------
 mm/madvise.c               |  124 ++++--
 mm/rmap.c                  |    8 +
 mm/swapfile.c              |    9 +-
 10 files changed, 686 insertions(+), 610 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
