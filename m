Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 5AD4F6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 07:09:09 -0400 (EDT)
Date: Thu, 16 May 2013 14:07:33 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 00/10] uaccess: better might_sleep/might_fault behavior
Message-ID: <cover.1368702323.git.mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Howells <dhowells@redhat.com>, Hirokazu Takata <takata@linux-m32r.org>, Michal Simek <monstr@monstr.eu>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-m32r@ml.linux-m32r.org, linux-m32r-ja@ml.linux-m32r.org, microblaze-uclinux@itee.uq.edu.au, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org

This improves the might_fault annotations used
by uaccess routines:

1. The only reason uaccess routines might sleep
   is if they fault. Make this explicit for
   all architectures.
2. Accesses (e.g through socket ops) to kernel memory
   with KERNEL_DS like net/sunrpc does will never sleep.
   Remove an unconditinal might_sleep in the inline
   might_fault in kernel.h
   (used when PROVE_LOCKING is not set).
3. Accesses with pagefault_disable return EFAULT
   but won't cause caller to sleep.
   Check for that and avoid might_sleep when
   PROVE_LOCKING is set.

I'd like these changes to go in for the benefit of
the vhost driver where we want to call socket ops
under a spinlock, and fall back on slower thread handler
on error.

Please review, and consider for 3.11.


If the changes look good, what's the best way to merge them?
Maybe core/locking makes sense?

Note on arch code updates:
I tested x86_64 code.
Other architectures were build-tested.
I don't have cross-build environment for arm64, tile, microblaze and
mn10300 architectures. The changes look safe enough
but would appreciate review/acks from arch maintainers.

Version 1 of this change was titled
	x86: uaccess s/might_sleep/might_fault/


Changes from v1:
	add more architectures
	fix might_fault() scheduling differently depending
	on CONFIG_PROVE_LOCKING, as suggested by Ingo


Michael S. Tsirkin (10):
  asm-generic: uaccess s/might_sleep/might_fault/
  arm64: uaccess s/might_sleep/might_fault/
  frv: uaccess s/might_sleep/might_fault/
  m32r: uaccess s/might_sleep/might_fault/
  microblaze: uaccess s/might_sleep/might_fault/
  mn10300: uaccess s/might_sleep/might_fault/
  powerpc: uaccess s/might_sleep/might_fault/
  tile: uaccess s/might_sleep/might_fault/
  x86: uaccess s/might_sleep/might_fault/
  kernel: might_fault does not imply might_sleep

 arch/arm64/include/asm/uaccess.h      |  4 ++--
 arch/frv/include/asm/uaccess.h        |  4 ++--
 arch/m32r/include/asm/uaccess.h       | 12 ++++++------
 arch/microblaze/include/asm/uaccess.h |  6 +++---
 arch/mn10300/include/asm/uaccess.h    |  4 ++--
 arch/powerpc/include/asm/uaccess.h    | 16 ++++++++--------
 arch/tile/include/asm/uaccess.h       |  2 +-
 arch/x86/include/asm/uaccess_64.h     |  2 +-
 include/asm-generic/uaccess.h         | 10 +++++-----
 include/linux/kernel.h                |  1 -
 mm/memory.c                           | 14 +++++++++-----
 11 files changed, 39 insertions(+), 36 deletions(-)

Thanks,

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
