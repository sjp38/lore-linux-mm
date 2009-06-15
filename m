From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/22] HWPOISON: Intro (v5)
Date: Mon, 15 Jun 2009 10:45:20 +0800
Message-ID: <20090615024520.786814520@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 65D366B0083
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 23:14:28 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Wu, Fengguang" <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Hi all,

Comments are warmly welcome on the newly introduced uevent code :)

I hope we can reach consensus in this round and then be able to post
a final version for .31 inclusion.

changes since v4:
- new feature: uevent report (and collect various states for that)
- early kill cleanups
- remove unnecessary code in __do_fault()
- fix compile error when feature not enabled
- fix kernel oops when invalid pfn is feed to corrupt-pfn
- make tasklist_lock/anon_vma locking order straight
- use the safer invalidate page for possible metadata pages

Patches from previous versions plus some discussed fixes:
 [PATCH 01/22] HWPOISON: Add page flag for poisoned pages
 [PATCH 02/22] HWPOISON: Export some rmap vma locking to outside world
 [PATCH 03/22] HWPOISON: Add support for poison swap entries v2
 [PATCH 04/22] HWPOISON: Add new SIGBUS error codes for hardware poison signals
 [PATCH 05/22] HWPOISON: Add basic support for poisoned pages in fault handler v3
 [PATCH 06/22] HWPOISON: x86: Add VM_FAULT_HWPOISON handling to x86 page fault handler v2
 [PATCH 07/22] HWPOISON: define VM_FAULT_HWPOISON to 0 when feature is disabled
 [PATCH 08/22] HWPOISON: Use bitmask/action code for try_to_unmap behaviour
 [PATCH 09/22] HWPOISON: Handle hardware poisoned pages in try_to_unmap
 [PATCH 10/22] HWPOISON: check and isolate corrupted free pages v2
 [PATCH 11/22] HWPOISON: Refactor truncate to allow direct truncating of page v3
 [PATCH 12/22] HWPOISON: The high level memory error handler in the VM v7
 [PATCH 13/22] HWPOISON: Add madvise() based injector for hardware poisoned pages v3
 [PATCH 14/22] HWPOISON: Add simple debugfs interface to inject hwpoison on arbitary PFNs

New additions that need reviews:
 [PATCH 15/22] HWPOISON: early kill cleanups and fixes
 [PATCH 16/22] mm: move page flag numbers for user space to page-flags.h
 [PATCH 17/22] HWPOISON: introduce struct hwpoison_control
 [PATCH 18/22] HWPOISON: use compound head page
 [PATCH 19/22] HWPOISON: detect free buddy pages explicitly
 [PATCH 20/22] HWPOISON: collect infos that reflect the impact of the memory corruption
 [PATCH 21/22] HWPOISON: send uevent to report memory corruption
 [PATCH 22/22] HWPOISON: FOR TESTING: Enable memory failure code unconditionally

---
Upcoming Intel CPUs have support for recovering from some memory errors
(``MCA recovery''). This requires the OS to declare a page "poisoned",
kill the processes associated with it and avoid using it in the future.

This patchkit implements the necessary infrastructure in the VM.

To quote the overview comment:

 * High level machine check handler. Handles pages reported by the
 * hardware as being corrupted usually due to a 2bit ECC memory or cache
 * failure.
 *
 * This focusses on pages detected as corrupted in the background.
 * When the current CPU tries to consume corruption the currently
 * running process can just be killed directly instead. This implies
 * that if the error cannot be handled for some reason it's safe to
 * just ignore it because no corruption has been consumed yet. Instead
 * when that happens another machine check will happen.
 *
 * Handles page cache pages in various states. The tricky part
 * here is that we can access any page asynchronous to other VM
 * users, because memory failures could happen anytime and anywhere,
 * possibly violating some of their assumptions. This is why this code
 * has to be extremely careful. Generally it tries to use normal locking
 * rules, as in get the standard locks, even if that means the
 * error handling takes potentially a long time.
 *
 * Some of the operations here are somewhat inefficient and have non
 * linear algorithmic complexity, because the data structures have not
 * been optimized for this case. This is in particular the case
 * for the mapping from a vma to a process. Since this case is expected
 * to be rare we hope we can get away with this.

The code consists of a the high level handler in mm/memory-failure.c,
a new page poison bit and various checks in the VM to handle poisoned
pages.

The main target right now is KVM guests, but it works for all kinds
of applications.

For the KVM use there was need for a new signal type so that
KVM can inject the machine check into the guest with the proper
address. This in theory allows other applications to handle
memory failures too. The expection is that near all applications
won't do that, but some very specialized ones might.

This is not fully complete yet, in particular there are still ways
to access poison through various ways (crash dump, /proc/kcore etc.)
that need to be plugged too.
Also undoubtedly the high level handler still has bugs and cases
it cannot recover from. For example nonlinear mappings deadlock right now
and a few other cases lose references. Huge pages are not supported
yet. Any additional testing, reviewing etc. welcome.

The patch series requires the earlier x86 MCE feature series for the x86
specific action optional part. The code can be tested without the x86 specific
part using the injector, this only requires to enable the Kconfig entry
manually in some Kconfig file (by default it is implicitely enabled
by the architecture)

v2: Lots of smaller changes in the series based on review feedback.
Rename Poison to HWPoison after akpm's request.
A new pfn based injector based on feedback.
A lot of improvements mostly from Fengguang Wu
See comments in the individual patches.
v3: Various updates, see changelogs in individual patches.
v4: Various updates, see changelogs in individual patches.
v5: add uevent notification and some cleanups/fixes.

Thanks,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
