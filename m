Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC2D9003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:44:44 -0400 (EDT)
Received: by padck2 with SMTP id ck2so125380147pad.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 13:44:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fn7si45737690pdb.248.2015.07.21.13.44.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 13:44:43 -0700 (PDT)
Date: Tue, 21 Jul 2015 13:44:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V4 2/6] mm: mlock: Add new mlock, munlock, and
 munlockall system calls
Message-Id: <20150721134441.d69e4e1099bd43e56835b3c5@linux-foundation.org>
In-Reply-To: <1437508781-28655-3-git-send-email-emunson@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
	<1437508781-28655-3-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, 21 Jul 2015 15:59:37 -0400 Eric B Munson <emunson@akamai.com> wrote:

> With the refactored mlock code, introduce new system calls for mlock,
> munlock, and munlockall.  The new calls will allow the user to specify
> what lock states are being added or cleared.  mlock2 and munlock2 are
> trivial at the moment, but a follow on patch will add a new mlock state
> making them useful.
> 
> munlock2 addresses a limitation of the current implementation.  If a
> user calls mlockall(MCL_CURRENT | MCL_FUTURE) and then later decides
> that MCL_FUTURE should be removed, they would have to call munlockall()
> followed by mlockall(MCL_CURRENT) which could potentially be very
> expensive.  The new munlockall2 system call allows a user to simply
> clear the MCL_FUTURE flag.

This is hard.  Maybe we shouldn't have wired up anything other than
x86.  That's what we usually do with new syscalls.

You appear to have missed
mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix.patch:

--- a/arch/arm64/include/asm/unistd.h~mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix
+++ a/arch/arm64/include/asm/unistd.h
@@ -44,7 +44,7 @@
 #define __ARM_NR_compat_cacheflush	(__ARM_NR_COMPAT_BASE+2)
 #define __ARM_NR_compat_set_tls		(__ARM_NR_COMPAT_BASE+5)
 
-#define __NR_compat_syscalls		388
+#define __NR_compat_syscalls		391
 #endif
 
 #define __ARCH_WANT_SYS_CLONE


And mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix-2.patch:


From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix-2

can we just remove the s390 bits which cause the breakage?
I will wire up the syscalls as soon as the patch set gets merged.

Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Eric B Munson <emunson@akamai.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/s390/kernel/syscalls.S |    3 ---
 1 file changed, 3 deletions(-)

diff -puN arch/s390/kernel/syscalls.S~mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix-2 arch/s390/kernel/syscalls.S
--- a/arch/s390/kernel/syscalls.S~mm-mlock-add-new-mlock-munlock-and-munlockall-system-calls-fix-2
+++ a/arch/s390/kernel/syscalls.S
@@ -363,6 +363,3 @@ SYSCALL(sys_bpf,compat_sys_bpf)
 SYSCALL(sys_s390_pci_mmio_write,compat_sys_s390_pci_mmio_write)
 SYSCALL(sys_s390_pci_mmio_read,compat_sys_s390_pci_mmio_read)
 SYSCALL(sys_execveat,compat_sys_execveat)
-SYSCALL(sys_mlock2,compat_sys_mlock2)			/* 355 */
-SYSCALL(sys_munlock2,compat_sys_munlock2)
-SYSCALL(sys_munlockall2,compat_sys_munlockall2)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
