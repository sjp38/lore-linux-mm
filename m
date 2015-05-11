Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 045AC6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:52:46 -0400 (EDT)
Received: by wiun10 with SMTP id n10so101736365wiu.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:52:45 -0700 (PDT)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id w6si443276wiv.14.2015.05.11.08.52.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 11 May 2015 08:52:44 -0700 (PDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 11 May 2015 16:52:43 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 0F7EA1B08023
	for <linux-mm@kvack.org>; Mon, 11 May 2015 16:53:26 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4BFqfKb52166730
	for <linux-mm@kvack.org>; Mon, 11 May 2015 15:52:41 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4BFqdQL014419
	for <linux-mm@kvack.org>; Mon, 11 May 2015 09:52:41 -0600
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: [PATCH v1 00/15] decouple pagefault_disable() from preempt_disable()
Date: Mon, 11 May 2015 17:52:05 +0200
Message-Id: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@redhat.com, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, tglx@linutronix.de, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org, dahi@linux.vnet.ibm.com

RFC -> v1:
- keep the in_atomic() in the fault handlers (via faulthandler_disabled() ) to
  not break fault handler in irq context (Peter)

-------------------------------------------------------------------------

I recently discovered that might_fault() doesn't call might_sleep()
anymore. Therefore bugs like:

  spin_lock(&lock);
  rc = copy_to_user(...);
  spin_unlock(&lock);

would not be detected with CONFIG_DEBUG_ATOMIC_SLEEP. The code was
changed to disable false positives for code like:

  pagefault_disable();
  rc = copy_to_user(...);
  pagefault_enable();

Whereby the caller wants do deal with failures.

If we schedule while holding a spinlock, bad things can happen.
Preemption is disabled, but we still preempt - on s390 this can lead
to spinlocks never getting unlocked (as unlocking code checks for the
cpu id that locke the spinlock), therefore resulting in a deadlock.

Until now, pagefault_(dis|en)nable) simply modified the preempt count,
therefore telling the pagefault handler that the context is atomic and
sleeping is disallowed.

With !CONFIG_PREEMPT_COUNT, the preempt count does not exist.
So preempt_disable() as well es pagefault_disable() is a NOP.
in_atomic() checks the preempt count. So we can't detect in_atomic on
systems without preemption.
That is also mentioned in the comment of in_atomic():

  "WARNING: this macro cannot always detect atomic context; in particular,
   it cannot know about held spinlocks in non-preemptible kernels."

We automatically have !CONFIG_PREEMPT_COUNT with !CONFIG_PREEMPT
and !CONFIG_DEBUG_ATOMIC_SLEEP, so on a system with disabled pagefaults.

All fault handlers currently rely on in_atomic() to check for disabled
pagefaults.

This series therefore does 2 things:


1. Decouple pagefault_disable() from preempt_enable()

pagefault_(dis|en)able() modifies an own counter and doesn't touch
preemption anymore. The fault handlers now only check for
disabled pagefaults.

I checked (hopefully) every caller of pagefault_disable(), if they
implicitly rely on preempt_disable() -  and if so added these calls.
Hope I haven't missed some cases.

I didn't check all users of preempt_disable() if they relied on them
disabling pagefaults. My assumption is that such code is broken
either way (on non-preemptible systems). Pagefaults would only be
disabled with CONFIG_PREEMPT_COUNT (exception: irq context).

in_atomic() checks are left in the fault handlers to detect irq context.


2. Reenable might_sleep() checks for might_fault()

As we can now decide if we really have pagefaults disabled,
we can reenable the might_sleep() check in might_fault().

So this should now work:

  spin_lock(&lock); /* also if left away */
  pagefault_disable()
  rc = copy_to_user(...);
  pagefault_enable();
  spin_unlock(&lock);

And this should report a warning again:

  spin_lock(&lock);
  rc = copy_to_user(...);
  spin_unlock(&lock);


Cross compiled on powerpc, arm, sparc, sparc64, arm64, x86_64, i386,
mips, alpha, ia64, xtensa, m68k, microblaze.

Tested on s390x.

Any feedback very welcome!

Thanks!


David Hildenbrand (15):
  uaccess: count pagefault_disable() levels in pagefault_disabled
  mm, uaccess: trigger might_sleep() in might_fault() with disabled
    pagefaults
  uaccess: clarify that uaccess may only sleep if pagefaults are enabled
  mm: explicitly disable/enable preemption in kmap_atomic_*
  mips: kmap_coherent relies on disabled preemption
  mm: use pagefault_disable() to check for disabled pagefaults in the
    handler
  drm/i915: use pagefault_disabled() to check for disabled pagefaults
  futex: UP futex_atomic_op_inuser() relies on disabled preemption
  futex: UP futex_atomic_cmpxchg_inatomic() relies on disabled
    preemption
  arm/futex: UP futex_atomic_cmpxchg_inatomic() relies on disabled
    preemption
  arm/futex: UP futex_atomic_op_inuser() relies on disabled preemption
  futex: clarify that preemption doesn't have to be disabled
  powerpc: enable_kernel_altivec() requires disabled preemption
  mips: properly lock access to the fpu
  uaccess: decouple preemption from the pagefault logic

 arch/alpha/mm/fault.c                      |  5 ++--
 arch/arc/include/asm/futex.h               | 10 +++----
 arch/arc/mm/fault.c                        |  2 +-
 arch/arm/include/asm/futex.h               | 13 ++++++--
 arch/arm/mm/fault.c                        |  2 +-
 arch/arm/mm/highmem.c                      |  3 ++
 arch/arm64/include/asm/futex.h             |  4 +--
 arch/arm64/mm/fault.c                      |  2 +-
 arch/avr32/include/asm/uaccess.h           | 12 +++++---
 arch/avr32/mm/fault.c                      |  4 +--
 arch/cris/mm/fault.c                       |  6 ++--
 arch/frv/mm/fault.c                        |  4 +--
 arch/frv/mm/highmem.c                      |  2 ++
 arch/hexagon/include/asm/uaccess.h         |  3 +-
 arch/ia64/mm/fault.c                       |  4 +--
 arch/m32r/include/asm/uaccess.h            | 30 ++++++++++++-------
 arch/m32r/mm/fault.c                       |  8 ++---
 arch/m68k/mm/fault.c                       |  4 +--
 arch/metag/mm/fault.c                      |  2 +-
 arch/metag/mm/highmem.c                    |  4 ++-
 arch/microblaze/include/asm/uaccess.h      |  6 ++--
 arch/microblaze/mm/fault.c                 |  8 ++---
 arch/microblaze/mm/highmem.c               |  4 ++-
 arch/mips/include/asm/uaccess.h            | 45 ++++++++++++++++++----------
 arch/mips/kernel/signal-common.h           |  9 ++----
 arch/mips/mm/fault.c                       |  4 +--
 arch/mips/mm/highmem.c                     |  5 +++-
 arch/mips/mm/init.c                        |  2 ++
 arch/mn10300/include/asm/highmem.h         |  3 ++
 arch/mn10300/mm/fault.c                    |  4 +--
 arch/nios2/mm/fault.c                      |  2 +-
 arch/parisc/include/asm/cacheflush.h       |  2 ++
 arch/parisc/kernel/traps.c                 |  4 +--
 arch/parisc/mm/fault.c                     |  4 +--
 arch/powerpc/lib/vmx-helper.c              | 11 +++----
 arch/powerpc/mm/fault.c                    |  9 +++---
 arch/powerpc/mm/highmem.c                  |  4 ++-
 arch/s390/include/asm/uaccess.h            | 15 ++++++----
 arch/s390/mm/fault.c                       |  2 +-
 arch/score/include/asm/uaccess.h           | 15 ++++++----
 arch/score/mm/fault.c                      |  3 +-
 arch/sh/mm/fault.c                         |  5 ++--
 arch/sparc/mm/fault_32.c                   |  4 +--
 arch/sparc/mm/fault_64.c                   |  4 +--
 arch/sparc/mm/highmem.c                    |  4 ++-
 arch/sparc/mm/init_64.c                    |  2 +-
 arch/tile/include/asm/uaccess.h            | 18 +++++++----
 arch/tile/mm/fault.c                       |  4 +--
 arch/tile/mm/highmem.c                     |  3 +-
 arch/um/kernel/trap.c                      |  4 +--
 arch/unicore32/mm/fault.c                  |  2 +-
 arch/x86/include/asm/uaccess.h             | 15 ++++++----
 arch/x86/include/asm/uaccess_32.h          |  6 ++--
 arch/x86/lib/usercopy_32.c                 |  6 ++--
 arch/x86/mm/fault.c                        |  5 ++--
 arch/x86/mm/highmem_32.c                   |  3 +-
 arch/x86/mm/iomap_32.c                     |  2 ++
 arch/xtensa/mm/fault.c                     |  4 +--
 arch/xtensa/mm/highmem.c                   |  2 ++
 drivers/crypto/vmx/aes.c                   |  8 ++++-
 drivers/crypto/vmx/aes_cbc.c               |  6 ++++
 drivers/crypto/vmx/ghash.c                 |  8 +++++
 drivers/gpu/drm/i915/i915_gem_execbuffer.c |  3 +-
 include/asm-generic/futex.h                |  7 +++--
 include/linux/highmem.h                    |  2 ++
 include/linux/io-mapping.h                 |  2 ++
 include/linux/kernel.h                     |  3 +-
 include/linux/sched.h                      |  1 +
 include/linux/uaccess.h                    | 48 ++++++++++++++++++++++--------
 kernel/fork.c                              |  3 ++
 lib/strnlen_user.c                         |  6 ++--
 mm/memory.c                                | 18 ++++-------
 72 files changed, 319 insertions(+), 174 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
