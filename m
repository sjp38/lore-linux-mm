Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C8AE06B00C0
	for <linux-mm@kvack.org>; Sun, 26 May 2013 10:21:49 -0400 (EDT)
Date: Sun, 26 May 2013 17:21:30 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3-resend 00/11] uaccess: better might_sleep/might_fault
 behavior
Message-ID: <1369575487-26176-1-git-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

I seem to have mis-sent v3.  Trying again with same patches after
fixing the message id for the cover letter. I hope the duplicates
that are thus created don't inconvenience people too much.
If they do, I apologize.
I have pared down the Cc list to reduce the noise.
sched maintainers are Cc'd on all patches since that's
the tree I aim for with these patches.

This improves the might_fault annotations used
by uaccess routines:

1. The only reason uaccess routines might sleep
   is if they fault. Make this explicit for
   all architectures.
2. a voluntary preempt point in uaccess functions
   means compiler can't inline them efficiently,
   this breaks assumptions that they are very
   fast and small that e.g. net code seems to make.
   remove this preempt point so behaviour
   matches what callers assume.
3. Accesses (e.g through socket ops) to kernel memory
   with KERNEL_DS like net/sunrpc does will never sleep.
   Remove an unconditinal might_sleep in the inline
   might_fault in kernel.h
   (used when PROVE_LOCKING is not set).
4. Accesses with pagefault_disable return EFAULT
   but won't cause caller to sleep.
   Check for that and avoid might_sleep when
   PROVE_LOCKING is set.

I'd like these changes to go in for 3.11:
besides a general benefit of improved
consistency and performance, I would also like them
for the vhost driver where we want to call socket ops
under a spinlock, and fall back on slower thread handler
on error.

If the changes look good, would sched maintainers
please consider merging them through sched/core because of the
interaction with the scheduler?

Please review, and consider for 3.11.

Note on arch code updates:
I tested x86_64 code.
Other architectures were build-tested.
I don't have cross-build environment for arm64, tile, microblaze and
mn10300 architectures. arm64 and tile got acks.
The arch changes look generally safe enough
but would appreciate review/acks from arch maintainers.
core changes naturally need acks from sched maintainers.

Version 1 of this change was titled
	x86: uaccess s/might_sleep/might_fault/

Changes from v2:
	add a patch removing a colunatry preempt point
	in uaccess functions when PREEMPT_VOLUNATRY is set.
		Addresses comments by Arnd Bergmann,
		and Peter Zijlstra.
	comment on future possible simplifications in the git log
		for the powerpc patch. Addresses a comment
		by Arnd Bergmann.
	
Changes from v1:
	add more architectures
	fix might_fault() scheduling differently depending
	on CONFIG_PROVE_LOCKING, as suggested by Ingo

Michael S. Tsirkin (11):
  asm-generic: uaccess s/might_sleep/might_fault/
  arm64: uaccess s/might_sleep/might_fault/
  frv: uaccess s/might_sleep/might_fault/
  m32r: uaccess s/might_sleep/might_fault/
  microblaze: uaccess s/might_sleep/might_fault/
  mn10300: uaccess s/might_sleep/might_fault/
  powerpc: uaccess s/might_sleep/might_fault/
  tile: uaccess s/might_sleep/might_fault/
  x86: uaccess s/might_sleep/might_fault/
  kernel: drop voluntary schedule from might_fault
  kernel: uaccess in atomic with pagefault_disable

 arch/arm64/include/asm/uaccess.h      |  4 ++--
 arch/frv/include/asm/uaccess.h        |  4 ++--
 arch/m32r/include/asm/uaccess.h       | 12 ++++++------
 arch/microblaze/include/asm/uaccess.h |  6 +++---
 arch/mn10300/include/asm/uaccess.h    |  4 ++--
 arch/powerpc/include/asm/uaccess.h    | 16 ++++++++--------
 arch/tile/include/asm/uaccess.h       |  2 +-
 arch/x86/include/asm/uaccess_64.h     |  2 +-
 include/asm-generic/uaccess.h         | 10 +++++-----
 include/linux/kernel.h                |  7 ++-----
 mm/memory.c                           | 10 +++++++---
 11 files changed, 39 insertions(+), 38 deletions(-)

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
