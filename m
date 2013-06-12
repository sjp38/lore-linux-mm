Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 009F06B0034
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 00:23:13 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa11so6162994pad.5
        for <linux-mm@kvack.org>; Tue, 11 Jun 2013 21:23:13 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/8] Volatile Ranges (v8?)
Date: Tue, 11 Jun 2013 21:22:43 -0700
Message-Id: <1371010971-15647-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hey everyone.

I know its been quite awhile. But Minchan and I have been doing a
fair amount of discussing offlist since lsf-mm, trying to come
to agreement on the semantics for the volatile ranges interface,
and after circling around each other's arguments for awhile (he'd
suggest and idea, I'd disagree, then I'd come around to agree just as
he would begin to disagree :) I think things have started to converge
pretty nicely, at least as far as the interface goes.

Some of the more interesting and challenging ideas we've explored
recently have been given up for now, mostly so we can get some core
agreed functionality moving upstream. We may still want to revisit
those ideas before the final push, but for now, we're focusing on
the parts we agree on that we think have a chance at eventually
being merged.

If you've read some of my earlier summaries, you'll likely find
this patchset much simplified:
* We only have one interface: vrange(address, len, mode, *purged),
  which is used in a method similar to madvise on both file or
  anonymous pages.
* We no longer have a concept of anon-only or private-volatility.
  Despite the potential performance gains that Minchan liked in
  avoiding the mmap_sem,the semantics were often confusing when using
  private volatility on non-anonymous pages.
* We no longer have behavior flags. Potential extensions can still be
  done via introducing new mode flags.

The patch set has also been heavily reworked and reordered to make
more iterative sense and hopefully to be easier to review.

Patches 1-5 are what we're wanting the most feedback on, since this
is the area dealing with the userland interface and the semantics of
how volatile ranges behave.

Patches 6-8 provide the back-end purging logic, which is likely
to change, and is provided only so folks can start playing around
with a functional patch series. It currently has some limitations,
like it doesn't purge anonymous pages on swap free systems.
Additionally, the newly integrated file page purging logic likely has
issues still to be resolved.

Overall, We still have the following TODOS with the patchset:
* Come to consensus on the best way to avoid inheriting mm_struct
  volatility when the underlying vmas change. (see patch 4 in this
  series)
* Ensure we zap underlying file page (ala  truncate_inode_pages_range)
  when we purge file pages - this make purging similar to file hole
  punching and ensures we don't find stale data later. (patch 7)
* Avoid lockdep warnings caused by allocations made while holding vroot
  lock triggering reclaim which could try to purge volatile ranges,
  grabbing the same vroot lock.  Minchan added a GFP_NO_VRANGE flag,
  but we've not hooked that up into the reclaim logic to avoid purging.
* Re-integrate Minchan's logic to purge anonymous pages on swapfree
  systems (dropped for this release to keep things simpler for review)


Any feedback and review would be greatly appreciated!

thanks!
-john


Volatile Ranges
============== 
Volatile ranges provide a way for userland applications to provide
hints to the kernel, about memory that is not immediately in use and
can be regenerated if needed.

After marking a range as volatile, if the kernel experiences memory
pressure, the kernel can then purge those pages, freeing up additional
space.  Userland can also tell the kernel it wants to use that memory
again, by marking the range non-volatile, after which the kernel will
not purge that memory.

If the kernel has already purged the memory when userland requests
it be made non-volatile, the kernel will return a warning value to
notify userland that the data was lost and must be regenerated.

If userland accesses memory marked volatile that has not been purged,
it will get the values it expects.

However, if userland touches volatile memory that has been purged, the
kernel will send it a SIGBUS.  This makes it possible for userland to
handle the SIGBUS, marking the memory as non-volatile and re-generating
it as needed before continuing.

In some ways, the kernel's purging of memory can be considered
as similar to a delayed MADV_DONTNEED or FALLOC_FL_PUNCH_HOLE
operation, which can be canceled. Thus similarly to MADV_DONTNEED
or FALLOC_FL_PUNCH_HOLE, operations done on file data that is mmaped
shared will be seen by other processes who have that file mapped. Thus
if an application marks shared  mmaped file data as volatile, that
volatility state is also shared across other tasks. This allows tasks
to coordinate for one task to mark  shared file data as volatile, and a
second task to be able to unmark it if necessary. If the kernel purges
volatile file data that was marked by one task, all tasks sharing
that data will see the data as purged, and will have to mark it as
non-volatile before accessing it or will have to handle the SIGBUS.

All volatility on files is cleared when the last fd handle is closed.


Interface:
The vrange syscall is defined as follows:

int vrange(unsigned long address, size_t length, int mode, int* purged)

address:	Starting address in the process where memory will be
	 	marked. This must be page aligned

length:		Length of the range to be marked. This must be in page
		size units.

mode:
 VRANGE_VOLATILE:	Marks the specified range as volatile, and
			able to be purged.
 VRANGE_NONVOLATILE:	Marks the specified range as non-volatile. If
			any data in that range was volatile and has
			been purged, 1 will be returned in the purged
			pointer.

purged:		Pointer to an integer that will be set to 1 if any data
		in the range being marked non-volatile has been purged
		and is lost. If it is zero, then no data in the
		specified range has been lost.

Return values:
		Returns the number of bytes marked or unmarked. Similar
		to write(), it  may return fewer bytes then specified
		if it ran into a problem.

		If an error (negative value) is returned,no changes
		were made.

Errors:
	EINVAL:
		* address is not page-aligned, or is invalid.
		* length is not a multiple of the page size.
		* length is negative.
	ENOMEM:
		* Not enough memory.
	EFAULT:
		* Purge pointer is invalid.




Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dgiani@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>


John Stultz (2):
  vrange: Add vrange support for file address_spaces
  vrange: Clear volatility on new mmaps

Minchan Kim (6):
  vrange: Add basic data structure and functions
  vrange: Add vrange support to mm_structs
  vrange: Add new vrange(2) system call
  vrange: Add GFP_NO_VRANGE allocation flag
  vrange: Add method to purge volatile ranges
  vrange: Send SIGBUS when user try to access purged page

 arch/x86/include/asm/pgtable_types.h   |   2 +
 arch/x86/syscalls/syscall_64.tbl       |   1 +
 fs/file_table.c                        |   5 +
 fs/inode.c                             |   2 +
 include/asm-generic/pgtable.h          |  11 +
 include/linux/fs.h                     |   2 +
 include/linux/gfp.h                    |   7 +-
 include/linux/mm_types.h               |   5 +
 include/linux/rmap.h                   |  12 +-
 include/linux/swap.h                   |   1 +
 include/linux/vrange.h                 |  60 +++
 include/linux/vrange_types.h           |  19 +
 include/uapi/asm-generic/mman-common.h |   3 +
 init/main.c                            |   2 +
 kernel/fork.c                          |   6 +
 lib/Makefile                           |   2 +-
 mm/Makefile                            |   2 +-
 mm/ksm.c                               |   2 +-
 mm/memory.c                            |  23 +-
 mm/mmap.c                              |   5 +
 mm/rmap.c                              |  30 +-
 mm/swapfile.c                          |  36 ++
 mm/vmscan.c                            |  16 +-
 mm/vrange.c                            | 731 +++++++++++++++++++++++++++++++++
 24 files changed, 963 insertions(+), 22 deletions(-)
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
