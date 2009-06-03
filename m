Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C3D786B009D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:46:41 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Message-Id: <20090603846.816684333@firstfloor.org>
Subject: [PATCH] [0/16] HWPOISON: Intro
Date: Wed,  3 Jun 2009 20:46:31 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


Latest version of the hwpoison patchkit.

I rebased it on the mmotm of today to make it easier for Andrew to merge.

All comments have been addressed I believe (except I didn't move the
handlers out to other files)

For details please see the changelogs in the individual patches.

Andrew,

Please consider for merging.

Nick:

I addressed your comments on truncate. Nick can you review that
part? Is it ok for you now?
I also added a check for metadata buffer pages. Can you please review
that too.
And I integrated your truncate patch. The only thing missing 
is a Signed-off-by, can you provide that please?

Also I thought a bit about the fsync() error scenario. It's really
a problem that can already happen even without hwpoison, e.g.
when a page is dropped at the wrong time. The real fix would
be to make address space errors more sticky. Fengguang has been
looking at that, but it's probably not something for .31
I wrote up a detailed comment in the code describing the issue.

Thanks,
-Andi

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


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
