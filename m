Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 980DF6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 07:31:11 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so498074bkg.5
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 04:31:10 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id kr4si1398806bkb.313.2014.01.20.04.31.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jan 2014 04:31:07 -0800 (PST)
Date: Mon, 20 Jan 2014 13:30:30 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 6/6] MCS Lock: add Kconfig entries to allow
 arch-specific hooks
Message-ID: <20140120123030.GE31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917316.3138.16.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1389917316.3138.16.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Jan 16, 2014 at 04:08:36PM -0800, Tim Chen wrote:
> This patch adds Kconfig entries to allow architectures to hook into the
> MCS lock/unlock functions in the contended case.
> 
> From: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  arch/Kconfig                 | 3 +++
>  include/linux/mcs_spinlock.h | 8 ++++++++
>  2 files changed, 11 insertions(+)
> 
> diff --git a/arch/Kconfig b/arch/Kconfig
> index 80bbb8c..8a2a056 100644
> --- a/arch/Kconfig
> +++ b/arch/Kconfig
> @@ -303,6 +303,9 @@ config HAVE_CMPXCHG_LOCAL
>  config HAVE_CMPXCHG_DOUBLE
>  	bool
>  
> +config HAVE_ARCH_MCS_LOCK
> +	bool
> +
>  config ARCH_WANT_IPC_PARSE_VERSION
>  	bool
>  
> diff --git a/include/linux/mcs_spinlock.h b/include/linux/mcs_spinlock.h
> index d54bb23..d2c02ad 100644
> --- a/include/linux/mcs_spinlock.h
> +++ b/include/linux/mcs_spinlock.h
> @@ -12,6 +12,14 @@
>  #ifndef __LINUX_MCS_SPINLOCK_H
>  #define __LINUX_MCS_SPINLOCK_H
>  
> +/*
> + * An architecture may provide its own lock/unlock functions for the
> + * contended case.
> + */
> +#ifdef CONFIG_HAVE_ARCH_MCS_LOCK
> +#include <asm/mcs_spinlock.h>
> +#endif
> +
>  struct mcs_spinlock {
>  	struct mcs_spinlock *next;
>  	int locked; /* 1 if lock acquired */

I've previously been told using generic-asm headers was preferred over
littering the CONFIG space like this.

Then again, people seem to whinge if you don't keep these Kbuild files
sorted, but manually sorting 29 files is just not something I like to
do.

---
 arch/alpha/include/asm/Kbuild      |  1 +
 arch/arc/include/asm/Kbuild        |  1 +
 arch/arm/include/asm/Kbuild        |  1 +
 arch/arm64/include/asm/Kbuild      |  1 +
 arch/avr32/include/asm/Kbuild      |  1 +
 arch/blackfin/include/asm/Kbuild   |  1 +
 arch/c6x/include/asm/Kbuild        |  1 +
 arch/cris/include/asm/Kbuild       |  1 +
 arch/frv/include/asm/Kbuild        |  1 +
 arch/hexagon/include/asm/Kbuild    |  1 +
 arch/ia64/include/asm/Kbuild       |  2 +-
 arch/m32r/include/asm/Kbuild       |  1 +
 arch/m68k/include/asm/Kbuild       |  1 +
 arch/metag/include/asm/Kbuild      |  1 +
 arch/microblaze/include/asm/Kbuild |  1 +
 arch/mips/include/asm/Kbuild       |  1 +
 arch/mn10300/include/asm/Kbuild    |  1 +
 arch/openrisc/include/asm/Kbuild   |  1 +
 arch/parisc/include/asm/Kbuild     |  1 +
 arch/powerpc/include/asm/Kbuild    |  2 +-
 arch/s390/include/asm/Kbuild       |  1 +
 arch/score/include/asm/Kbuild      |  1 +
 arch/sh/include/asm/Kbuild         |  1 +
 arch/sparc/include/asm/Kbuild      |  1 +
 arch/tile/include/asm/Kbuild       |  1 +
 arch/um/include/asm/Kbuild         |  1 +
 arch/unicore32/include/asm/Kbuild  |  1 +
 arch/x86/include/asm/Kbuild        |  1 +
 arch/xtensa/include/asm/Kbuild     |  1 +
 include/asm-generic/mcs_spinlock.h | 13 +++++++++++++
 30 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index f01fb505ad52..14cbbbcec01f 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 9ae21c198007..c0773a5c2ca7 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -48,3 +48,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index c38b58c80202..c68cfdde8783 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -34,3 +34,4 @@ generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 519f89f5b6a3..24a3c10cdf38 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -51,3 +51,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 658001b52400..466e13d06bd3 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -18,3 +18,4 @@ generic-y       += sections.h
 generic-y       += topology.h
 generic-y	+= trace_clock.h
 generic-y       += xor.h
+generic-y += mcs_spinlock.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index f2b43474b0e2..0bd1c5c688e3 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -45,3 +45,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index fc0b3c356027..21d7100ddef9 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -57,3 +57,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 199b1a9dab89..c571cc12a4d2 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -13,3 +13,4 @@ generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 74742dc6a3da..ccca92eb782a 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -3,3 +3,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index ada843c701ef..553077d0f50c 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -55,3 +55,4 @@ generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index f93ee087e8fe..25aed55ffeba 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -4,4 +4,4 @@ generic-y += exec.h
 generic-y += kvm_para.h
 generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.hgeneric-y += mcs_spinlock.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 2b58c5f0bc38..d64fdd1b152b 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += exec.h
 generic-y += module.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index a5d27f272a59..1f4d44c7cc33 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -32,3 +32,4 @@ generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 84d0c1d6b9b3..ae0ae6e7ff77 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -53,3 +53,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index a82426589fff..6eb70bde6212 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -5,3 +5,4 @@ generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += syscalls.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 1acbb8b77a71..c718d6342326 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -14,3 +14,4 @@ generic-y += trace_clock.h
 generic-y += preempt.h
 generic-y += ucontext.h
 generic-y += xor.h
+generic-y += mcs_spinlock.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 032143ec2324..1393ae55ddaa 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index da1951a22907..7e049d3c0be0 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -69,3 +69,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index 34b0be4ca52d..ebe16498339d 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -6,3 +6,4 @@ generic-y += word-at-a-time.h auxvec.h user.h cputime.h emergency-restart.h \
 	  poll.h xor.h clkdev.h exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index d8f9d2f18a23..426001bd9c9e 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -3,4 +3,4 @@ generic-y += clkdev.h
 generic-y += rwsem.h
 generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.hgeneric-y += mcs_spinlock.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 7a5288f3479a..850891317efe 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -3,3 +3,4 @@
 generic-y += clkdev.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index fe7471eb0167..8e39afcd2efd 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -6,3 +6,4 @@ generic-y += clkdev.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 231efbb68108..1aed131fbbfa 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -35,3 +35,4 @@ generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index bf390667657a..8843299956cc 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -17,3 +17,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 22f3bd147fa7..152fc4821424 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -39,3 +39,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index fdde187e6087..620d7292d54b 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += ftrace.h pci.h io.h param.h delay.h mutex.h current.h exec.h
 generic-y += switch_to.h clkdev.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 00045cbe5c63..cd7822c1effe 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -61,3 +61,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/arch/x86/include/asm/Kbuild b/arch/x86/include/asm/Kbuild
index 7f669853317a..a8fee078b92f 100644
--- a/arch/x86/include/asm/Kbuild
+++ b/arch/x86/include/asm/Kbuild
@@ -5,3 +5,4 @@ genhdr-y += unistd_64.h
 genhdr-y += unistd_x32.h
 
 generic-y += clkdev.h
+generic-y += mcs_spinlock.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 228d6aee3a16..9653e5cfe345 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += mcs_spinlock.h
diff --git a/include/asm-generic/mcs_spinlock.h b/include/asm-generic/mcs_spinlock.h
index e69de29bb2d1..8b921a41f351 100644
--- a/include/asm-generic/mcs_spinlock.h
+++ b/include/asm-generic/mcs_spinlock.h
@@ -0,0 +1,13 @@
+#ifndef __ASM_MCS_SPINLOCK_H
+#define __ASM_MCS_SPINLOCK_H
+
+/*
+ * Architectures can define their own:
+ *
+ *   mcs_spin_lock_contended(l)
+ *   mcs_spin_unlock_contended(l)
+ *
+ * See kernel/locking/mcs_spinlock.c.
+ */
+
+#endif /* __ASM_MCS_SPINLOCK_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
